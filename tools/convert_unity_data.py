#!/usr/bin/env python3
"""Convert the checked-in Unity sprite databases to Godot SpriteFrames.

Uses only the Python standard library. Resolves actual GUID references and keeps
their serialized order, including reverse storm animations and glow portraits.
This reads the small, known ScriptableObject schema; it is not a Unity importer.
"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def guid_map():
    result = {}
    for path in (ROOT / "Assets").rglob("*.meta"):
        match = re.search(r"^guid: (\w+)$", path.read_text(), re.M)
        if match:
            result[match[1]] = path.with_suffix("").relative_to(ROOT).as_posix()
    return result


def fields(path, guids):
    result = {}
    current = None
    for line in path.read_text().splitlines():
        match = re.match(r"^  (\w+):(?: (.*))?$", line)
        if match:
            current = match[1]
            result[current] = []
        reference = re.search(r"guid: (\w+)", line)
        if reference and current and not current.startswith("m_"):
            result[current].append(guids[reference[1]])
    return result


def write_frames(path, animations):
    textures = list(dict.fromkeys(p for frames, _ in animations.values() for p in frames))
    if not all((ROOT / p).is_file() for p in textures):
        raise ValueError(f"Missing source texture in {path}")
    ids = {p: str(i + 1) for i, p in enumerate(textures)}
    lines = [f'[gd_resource type="SpriteFrames" load_steps={len(textures) + 1} format=3]', ""]
    for p in textures:
        lines.append(f'[ext_resource type="Texture2D" path="res://{p}" id="{ids[p]}"]')
    lines.extend(["", "[resource]", "animations = [{"])
    entries = []
    for name, (frames, loop) in animations.items():
        if not frames:
            raise ValueError(f"Empty animation: {name}")
        frame_text = ", ".join('{"duration": 1.0, "texture": ExtResource("' + ids[p] + '")}' for p in frames)
        entries.append(f'"frames": [{frame_text}],\n"loop": {str(loop).lower()},\n"name": &"{name}",\n"speed": 4.0')
    lines.append("\n}, {\n".join(entries))
    lines.append("}]")
    path.write_text("\n".join(lines) + "\n")


def main():
    guids = guid_map()
    (ROOT / "data").mkdir(exist_ok=True)
    for character in ("Aneska", "Yuvan"):
        source = fields(ROOT / f"Assets/Data/Characters/{character}.asset", guids)
        animations = {}
        for emotion in ("Neutral", "Angry", "Happy", "Joy", "Sad"):
            # Yuvan's SAD references are null in Unity. Use his neutral portrait.
            animations[emotion.lower()] = (source[emotion] or source["Neutral"], True)
            animations[emotion.lower() + "_idle"] = (
                source["Single" + emotion] or source["SingleNeutral"], False
            )
        write_frames(ROOT / f"data/{character.lower()}_portrait.tres", animations)
        source = fields(ROOT / f"Assets/Data/Backgrounds/{character}.asset", guids)
        write_frames(ROOT / f"data/{character.lower()}_background.tres", {
            name.lower(): (source[name], False) for name in ("Day", "Twilight", "Evening")
        })
    print("Converted both character databases and both background databases.")


if __name__ == "__main__":
    main()

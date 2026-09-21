# Binary Star

A Godot 4 visual novel about Aneska and Yuvan, migrated from the Unity project.
The original Ink story, illustrations, animation frames, Exo 2 font, and audio
are reused. Gameplay is GDScript, and UnityEvents are replaced by native Godot
signals connected in the scene.

## Run

Open `project.godot` in **Godot 4.7 or newer** and press **F6** with
`scenes/main.tscn` open, or **F5** to run the project. Tested with Godot 4.7.2.
The standard Godot build is sufficient; Unity and .NET are not required.
The first import takes a little time to process the original artwork and audio.

```sh
godot --editor --path .
# Or run directly after import:
godot --path .
```

- Click, tap, Space, or Enter: reveal the current line, then advance.
- Select a response when the story offers choices; keyboard focus supports them.
- **Sound on/off** or **M**: mute or unmute.
- **Restart** / **Read again**: start the conversation over.

Portrait highlights fade in over 0.15 seconds while speaking and fade out over
0.25 seconds when the line finishes. Select either portrait in Godot to adjust
**Highlight Fade In** and **Highlight Fade Out**; zero makes that direction instant.

## Project layout

| Path | Purpose |
| --- | --- |
| `scenes/main.tscn` | Playable scene, editable UI, and serialized signal connections |
| `scripts/` | Story, dialogue presentation, frame animation, and audio controllers |
| `data/*.tres` | Native SpriteFrames converted from Unity's character/background databases |
| `Assets/Ink/BinaryStar.ink` | Original editable story |
| `Assets/Ink/BinaryStar.json` | Compiled Ink story, loaded by the game |
| `Assets/Data`, `Assets/MUSIC`, `Assets/Fonts & Materials` | Original media used directly by Godot |
| `addons/inkgd` | Vendored pure GDScript Ink runtime with its MIT license and pinned provenance |
| `tests/` | Scene integration tests and source-derived reference transcripts |
| `tools/convert_unity_data.py` | Reproducible conversion of Unity's sprite GUID references |

Unity scenes, C# packages, and settings are retained for reference and excluded
from Godot scanning/export. New development starts in `project.godot`.
See [migration notes and UnityEvent → signal mapping](docs/MIGRATION.md).

## Story editing

Edit the `.ink` file, then compile it back to `Assets/Ink/BinaryStar.json` with
[Inky or inklecate](https://github.com/inkle/ink). Keep both files together in
version control. The bundled runtime supports Ink JSON versions 18 through 21.
The restored story is compiled with official **inklecate 1.2.1** to format 21,
matching the runtime. A compiler is only needed when editing the story, not to
run the game:

```sh
inklecate -o Assets/Ink/BinaryStar.json Assets/Ink/BinaryStar.ink
```

The checked-in playable path contains **76 dialogue lines**, including the 50
restored opening lines about their late-night call, binary stars, and relationship.
The original words and tags are preserved. The additional argument dialogue and
branch-selection code remain commented out. `BRANCH2` and its outro are preserved
and exercised separately in tests.

The two tags on a dialogue line are character name and emotion, for example
`#Aneska #HAPPY`. `InitiateStorm()` and `EndStorm()` emit phase signals for the
visuals and music. `ChangeBackground("Planet", "Day")` is also bound for future
story use. See `story_controller.gd` for the signal API.

Both star backgrounds animate through their 17 `2_Storm_*` frames at 4 fps when
the storm starts, then play those frames in reverse when it ends. The separate
eight-frame `Breakdown/3_Storm_*` sets remain unused, as in the Unity scene.

## Verify

```sh
godot --headless --path . --editor --import
godot --headless --path . --script tests/run_tests.gd
# Optional: real rendering, input checks, and ten screenshots in test-results/
godot --path . --script tests/run_tests.gd -- --screenshots
```

Tests cover every active/alternate dialogue line and tag, storm events, music
crossfades, typewriter completion, portrait focus and interrupted fades, input,
repeat play, variable choice counts, sprite references, and reverse background
animation. They exit nonzero on failure.

Regenerate Godot sprite databases from the preserved Unity assets with Python 3:

```sh
python3 tools/convert_unity_data.py
```

After migration, the `.tres` files can also be edited directly in Godot. Running
the converter again overwrites them using the original Unity databases.

## Export

Desktop presets are included for macOS, Windows, and Linux. Install export
templates matching your Godot version through **Editor → Manage Export Templates**
before producing a standalone application. Platform signing/distribution setup
is not included.

```sh
mkdir -p builds
godot --headless --path . --export-release macOS builds/BinaryStar.zip
```

A game pack can be exported and run with the installed Godot executable without
export templates:

```sh
godot --headless --path . --export-pack macOS builds/BinaryStar.pck
godot --main-pack builds/BinaryStar.pck
```

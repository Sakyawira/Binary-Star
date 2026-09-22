"""Generate the original, soft terminal cues used by the choice menu."""

import math
from pathlib import Path
import struct
import wave


SAMPLE_RATE = 44100
OUTPUT = Path(__file__).resolve().parents[1] / "Assets" / "SFX"


def tone(time, frequency, duration):
    if not 0 <= time < duration:
        return 0.0
    attack = min(1.0, time / 0.004)
    release = (1.0 - time / duration) ** 2
    phase = math.tau * frequency * time
    return attack * release * (math.sin(phase) + 0.12 * math.sin(phase * 2))


def write(name, duration, synth):
    samples = [synth(frame / SAMPLE_RATE) for frame in range(round(duration * SAMPLE_RATE))]
    gain = 0.55 / max(abs(sample) for sample in samples)
    data = b"".join(struct.pack("<h", round(sample * gain * 32767)) for sample in samples)
    with wave.open(str(OUTPUT / name), "wb") as sound:
        sound.setnchannels(1)
        sound.setsampwidth(2)
        sound.setframerate(SAMPLE_RATE)
        sound.writeframes(data)


if __name__ == "__main__":
    OUTPUT.mkdir(parents=True, exist_ok=True)
    # A short, rounded cursor tick, followed by a distinct rising confirmation.
    write("choice_move.wav", 0.055, lambda time: tone(time, 740, 0.055))
    write("choice_confirm.wav", 0.22, lambda time: (
        tone(time, 554.37, 0.12) + tone(time - 0.065, 830.61, 0.155)
    ))

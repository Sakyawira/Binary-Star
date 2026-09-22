"""Generate the choice menu's original, muted keyboard-like thocks."""

import math
from pathlib import Path
import random
import struct
import wave


SAMPLE_RATE = 44100
OUTPUT = Path(__file__).resolve().parents[1] / "Assets" / "SFX"


def thock(duration, body_hz, decay, seed):
    """Mix a damped key body with a filtered, non-pitched impact."""
    noise = random.Random(seed)
    low = 0.0
    high = 0.0
    low_gain = 1.0 - math.exp(-math.tau * 180 / SAMPLE_RATE)
    high_gain = 1.0 - math.exp(-math.tau * 1800 / SAMPLE_RATE)
    samples = []
    for frame in range(round(duration * SAMPLE_RATE)):
        time = frame / SAMPLE_RATE
        # A rounded attack and a rapidly falling pitch avoid a bell-like note.
        attack = 1.0 - math.exp(-time / 0.0007)
        tail = min(1.0, (duration - time) / 0.008) ** 2
        phase = math.tau * body_hz * (time + 0.009 * (1.0 - math.exp(-time / 0.009)))
        body = math.sin(phase) * math.exp(-time / decay)
        shell = 0.24 * math.sin(phase * 2.73) * math.exp(-time / 0.006)
        # Seeded noise supplies the dry key impact without a sharp hiss.
        high += high_gain * (noise.uniform(-1.0, 1.0) - high)
        low += low_gain * (high - low)
        impact = 1.5 * (high - low) * math.exp(-time / 0.008)
        samples.append((body + shell + impact) * attack * tail)
    return samples


def write(name, samples, peak):
    gain = peak / max(abs(sample) for sample in samples)
    data = b"".join(struct.pack("<h", round(sample * gain * 32767)) for sample in samples)
    with wave.open(str(OUTPUT / name), "wb") as sound:
        sound.setnchannels(1)
        sound.setsampwidth(2)
        sound.setframerate(SAMPLE_RATE)
        sound.writeframes(data)


if __name__ == "__main__":
    OUTPUT.mkdir(parents=True, exist_ok=True)
    # Navigation is a light key tap; confirmation is a deeper, weightier press.
    write("choice_move.wav", thock(0.070, 240, 0.011, seed=17), peak=0.48)
    write("choice_confirm.wav", thock(0.105, 165, 0.018, seed=29), peak=0.58)

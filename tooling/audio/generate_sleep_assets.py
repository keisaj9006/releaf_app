#!/usr/bin/env python3
"""Generate deterministic Releaf sleep sound assets.

The generated tracks contain no third-party samples. They are synthesized from
fixed-seed noise and additive tones so the same source revision produces the
same source waveform every time.
"""

from __future__ import annotations

import argparse
import math
import subprocess
import tempfile
import wave
from pathlib import Path

import numpy as np

SAMPLE_RATE = 44_100


def periodic_colored_noise(
    duration_s: int,
    seed: int,
    alpha: float,
    *,
    rms_db: float,
    channels: int = 1,
    low_hz: float = 25.0,
    high_hz: float = 18_000.0,
) -> np.ndarray:
    """Create one periodic IFFT noise block.

    alpha=0 -> white, alpha=1 -> pink, alpha=2 -> brown-ish.
    """
    n = int(duration_s * SAMPLE_RATE)
    freqs = np.fft.rfftfreq(n, d=1 / SAMPLE_RATE)
    weight = np.zeros_like(freqs)
    mask = (freqs >= low_hz) & (freqs <= high_hz)
    safe = np.maximum(freqs[mask], low_hz)
    weight[mask] = 1.0 / np.power(safe, alpha / 2.0)
    weight[0] = 0.0

    tracks: list[np.ndarray] = []
    for channel in range(channels):
        rng = np.random.default_rng(seed + channel * 10_007)
        phases = rng.uniform(0, 2 * np.pi, len(freqs))
        spectrum = weight * np.exp(1j * phases)
        spectrum[0] = 0.0
        if n % 2 == 0:
            spectrum[-1] = spectrum[-1].real + 0j
        tracks.append(np.fft.irfft(spectrum, n=n))

    audio = np.stack(tracks, axis=1)
    audio -= np.mean(audio, axis=0, keepdims=True)
    target_rms = 10 ** (rms_db / 20.0)
    rms = math.sqrt(float(np.mean(audio * audio)))
    audio *= target_rms / max(rms, 1e-12)

    peak = float(np.max(np.abs(audio)))
    if peak > 0.28:
        audio *= 0.28 / peak
    return audio.astype(np.float32)


def periodic_modulation(
    n: int,
    cycles: int,
    phase: float,
    *,
    lo: float,
    hi: float,
) -> np.ndarray:
    position = np.arange(n, dtype=np.float64) / n
    unit = 0.5 + 0.5 * np.sin(2 * np.pi * cycles * position + phase)
    return lo + (hi - lo) * unit


def soft_rain(duration_s: int = 180, seed: int = 2_026_090_811) -> np.ndarray:
    n = duration_s * SAMPLE_RATE
    high = periodic_colored_noise(
        duration_s,
        seed,
        0.15,
        rms_db=-30.0,
        channels=2,
        low_hz=900,
        high_hz=16_500,
    )
    mid = periodic_colored_noise(
        duration_s,
        seed + 100,
        0.8,
        rms_db=-31.5,
        channels=2,
        low_hz=180,
        high_hz=7_000,
    )
    env = np.stack(
        [
            periodic_modulation(n, 7, 0.2, lo=0.72, hi=1.0)
            * periodic_modulation(n, 13, 1.1, lo=0.90, hi=1.0),
            periodic_modulation(n, 7, 2.2, lo=0.74, hi=1.0)
            * periodic_modulation(n, 11, 0.7, lo=0.91, hi=1.0),
        ],
        axis=1,
    ).astype(np.float32)
    common = periodic_colored_noise(
        duration_s,
        seed + 500,
        0.5,
        rms_db=-34.0,
        channels=1,
        low_hz=500,
        high_hz=12_000,
    )
    audio = (high * 0.78 + mid * 0.55) * env
    audio += np.repeat(common, 2, axis=1) * 0.45
    peak = float(np.max(np.abs(audio)))
    if peak > 0.25:
        audio *= 0.25 / peak
    return audio.astype(np.float32)


def night_air(duration_s: int = 180, seed: int = 2_026_090_827) -> np.ndarray:
    n = duration_s * SAMPLE_RATE
    low = periodic_colored_noise(
        duration_s,
        seed,
        1.45,
        rms_db=-29.5,
        channels=2,
        low_hz=35,
        high_hz=4_500,
    )
    air = periodic_colored_noise(
        duration_s,
        seed + 50,
        0.55,
        rms_db=-36.0,
        channels=2,
        low_hz=450,
        high_hz=9_000,
    )
    env = np.stack(
        [
            periodic_modulation(n, 5, 0.0, lo=0.68, hi=1.0)
            * periodic_modulation(n, 9, 1.7, lo=0.90, hi=1.0),
            periodic_modulation(n, 5, 2.8, lo=0.70, hi=1.0)
            * periodic_modulation(n, 8, 0.4, lo=0.90, hi=1.0),
        ],
        axis=1,
    ).astype(np.float32)
    audio = low * env + air * 0.42
    peak = float(np.max(np.abs(audio)))
    if peak > 0.24:
        audio *= 0.24 / peak
    return audio.astype(np.float32)


def ocean_wash(duration_s: int = 180, seed: int = 2_026_090_863) -> np.ndarray:
    n = duration_s * SAMPLE_RATE
    low = periodic_colored_noise(
        duration_s,
        seed,
        1.7,
        rms_db=-30.0,
        channels=2,
        low_hz=35,
        high_hz=2_600,
    )
    foam = periodic_colored_noise(
        duration_s,
        seed + 90,
        0.55,
        rms_db=-35.0,
        channels=2,
        low_hz=650,
        high_hz=10_500,
    )
    swell_l = periodic_modulation(n, 9, 0.3, lo=0.34, hi=1.0)
    swell_l *= periodic_modulation(n, 13, 1.8, lo=0.82, hi=1.0)
    swell_r = periodic_modulation(n, 9, 2.4, lo=0.36, hi=1.0)
    swell_r *= periodic_modulation(n, 11, 0.9, lo=0.84, hi=1.0)
    swell = np.stack([swell_l, swell_r], axis=1).astype(np.float32)
    foam_env = np.clip((swell - 0.38) * 1.45, 0.08, 1.0)
    audio = low * swell + foam * foam_env * 0.55
    peak = float(np.max(np.abs(audio)))
    if peak > 0.23:
        audio *= 0.23 / peak
    return audio.astype(np.float32)


def forest_canopy(duration_s: int = 180, seed: int = 2_026_090_877) -> np.ndarray:
    n = duration_s * SAMPLE_RATE
    rustle = periodic_colored_noise(
        duration_s,
        seed,
        0.45,
        rms_db=-34.0,
        channels=2,
        low_hz=900,
        high_hz=13_500,
    )
    body = periodic_colored_noise(
        duration_s,
        seed + 120,
        1.25,
        rms_db=-34.0,
        channels=2,
        low_hz=90,
        high_hz=5_500,
    )
    wind_l = periodic_modulation(n, 6, 0.4, lo=0.45, hi=1.0)
    wind_l *= periodic_modulation(n, 17, 1.2, lo=0.82, hi=1.0)
    wind_r = periodic_modulation(n, 6, 2.7, lo=0.47, hi=1.0)
    wind_r *= periodic_modulation(n, 19, 0.2, lo=0.82, hi=1.0)
    wind = np.stack([wind_l, wind_r], axis=1).astype(np.float32)
    audio = rustle * wind * 0.78 + body * (0.52 + wind * 0.28)
    peak = float(np.max(np.abs(audio)))
    if peak > 0.22:
        audio *= 0.22 / peak
    return audio.astype(np.float32)


def deep_drift(duration_s: int = 180, seed: int = 2_026_090_849) -> np.ndarray:
    n = duration_s * SAMPLE_RATE
    sample_index = np.arange(n, dtype=np.float64)
    t = sample_index / SAMPLE_RATE

    frequencies = [55.0, 110.0, 165.0, 220.0, 330.0]
    amplitudes = [0.18, 0.34, 0.22, 0.12, 0.055]
    left = np.zeros(n, dtype=np.float64)
    right = np.zeros(n, dtype=np.float64)

    for index, (frequency, amplitude) in enumerate(zip(frequencies, amplitudes)):
        phase_left = (index * 0.71) % (2 * np.pi)
        phase_right = (index * 1.13 + 0.4) % (2 * np.pi)
        cycles = 4 + index
        mod_left = 0.78 + 0.22 * (
            0.5 + 0.5 * np.sin(2 * np.pi * cycles * sample_index / n + phase_left)
        )
        mod_right = 0.78 + 0.22 * (
            0.5 + 0.5 * np.sin(2 * np.pi * cycles * sample_index / n + phase_right)
        )
        left += amplitude * mod_left * np.sin(2 * np.pi * frequency * t + phase_left)
        right += amplitude * mod_right * np.sin(2 * np.pi * frequency * t + phase_right)

    texture = periodic_colored_noise(
        duration_s,
        seed,
        1.55,
        rms_db=-42.0,
        channels=2,
        low_hz=45,
        high_hz=3_200,
    )
    audio = np.stack([left, right], axis=1).astype(np.float32)
    audio += texture * 0.7
    audio -= np.mean(audio, axis=0, keepdims=True)

    target_rms = 10 ** (-30.0 / 20.0)
    rms = math.sqrt(float(np.mean(audio * audio)))
    audio *= target_rms / max(rms, 1e-12)
    peak = float(np.max(np.abs(audio)))
    if peak > 0.18:
        audio *= 0.18 / peak
    return audio.astype(np.float32)


def write_wav(path: Path, audio: np.ndarray) -> None:
    pcm = (np.clip(audio, -1.0, 1.0) * 32767.0).astype("<i2")
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(pcm.shape[1])
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(pcm.tobytes())


def encode_mp3(wav_path: Path, mp3_path: Path, channels: int) -> None:
    bitrate = "72k" if channels == 1 else "112k"
    subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-hide_banner",
            "-loglevel",
            "error",
            "-i",
            str(wav_path),
            "-codec:a",
            "libmp3lame",
            "-b:a",
            bitrate,
            "-ar",
            str(SAMPLE_RATE),
            str(mp3_path),
        ],
        check=True,
    )


def generate(output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    assets = {
        "white_noise": periodic_colored_noise(
            120,
            2_026_090_801,
            0.0,
            rms_db=-27.0,
            channels=1,
            low_hz=40,
            high_hz=17_000,
        ),
        "pink_noise": periodic_colored_noise(
            120,
            2_026_090_802,
            1.0,
            rms_db=-26.0,
            channels=1,
            low_hz=30,
            high_hz=15_000,
        ),
        "brown_noise": periodic_colored_noise(
            120,
            2_026_090_803,
            2.0,
            rms_db=-25.0,
            channels=1,
            low_hz=35,
            high_hz=9_000,
        ),
        "soft_rain": soft_rain(),
        "night_air": night_air(),
        "deep_drift": deep_drift(),
        "ocean_wash": ocean_wash(),
        "forest_canopy": forest_canopy(),
    }

    with tempfile.TemporaryDirectory(prefix="releaf-audio-") as temporary:
        temp_dir = Path(temporary)
        for name, audio in assets.items():
            wav_path = temp_dir / f"{name}.wav"
            mp3_path = output_dir / f"{name}.mp3"
            write_wav(wav_path, audio)
            encode_mp3(wav_path, mp3_path, audio.shape[1])
            print(f"generated {mp3_path}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("assets/sounds"),
    )
    args = parser.parse_args()
    generate(args.output_dir)


if __name__ == "__main__":
    main()

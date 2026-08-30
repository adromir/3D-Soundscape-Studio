# 🎧 3D Soundscape Studio

[![Author](https://img.shields.io/badge/Author-Adromir-blue.svg)](https://github.com/adromir)
[![GitHub Repository](https://img.shields.io/badge/GitHub-Repository-lightgrey.svg?logo=github)](https://github.com/adromir)
[![Engine](https://img.shields.io/badge/Engine-Godot%204.x-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![Documentation](https://img.shields.io/badge/Wiki-Documentation-blueviolet.svg?logo=bookstack)](wiki/Home.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platforms](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-informational)](#)
[![i18n](https://img.shields.io/badge/i18n-English%20%7C%20German-brightgreen)](#)

A modern, high-performance desktop application for importing, scraping, spatially arranging, and offline rendering multi-channel and binaural 3D audio soundscapes.

> 📚 **Explore the [Full Visual Wiki Documentation](wiki/Home.md)** with detailed feature guides, screenshots, and tutorials.

---

## 🌟 What the Project Does

**3D Soundscape Studio** lets you craft rich, living soundscapes in virtual 3D space:

- **Interactive 3D Radar Canvas:** Visually position audio sources relative to a central listener with real-time azimuth, elevation, and distance control.
- **Native Ambient Mixer Downloader:** Download soundscapes directly from [ambient-mixer.com](https://www.ambient-mixer.com/) with stem extraction, audio validation, metadata parsing, and cover art preservation.
- **Local Browsable Library:** Manage and browse your collection of downloaded and custom soundscape projects (`user://library/`).
- **Flexible Channel Routing:** Route tracks as pinpoint 3D sources, omnipresent ambient beds (surrounding the listener equally), or dedicated multi-channel assignments.
- **Spatial Movement & Automation:** Animate sound sources with smooth linear ping-pong, one-way traverses, or continuous random walks. Choose between continuous in-flight motion and per-trigger position jumps.
- **Advanced Interval & Trigger Engine:** Trigger audio tracks via continuous loops, fixed intervals, or random density distributions with configurable minimum cooldowns (Blockwert) to prevent overlapping.
- **Fast Offline Multi-Channel & Binaural Exporter:** Asynchronously render production-ready binaural stereo files (via HRTF `.sofa` files and `sofalizer`), Stereo, Quadraphonic (4.0), 5.1 Surround, and 7.1 Surround with dynamic audio normalization (`dynaudnorm`) and convolution reverb (`afir`).

---

## 🚀 Key Advantages & Why Users Should Use It

1. **True Spatial Audio Production:** Create immersive 3D/binaural audio for meditation, relaxation, focus, tabletop RPGs, game development, and podcasts without complex Digital Audio Workstations (DAWs).
2. **Deterministic Offline Rendering:** Export hours of generative soundscapes faster than real-time using FFmpeg's hardware-accelerated filtergraphs.
3. **Cross-Platform & Native:** Built with Godot 4.x and GDScript with zero external script dependencies (pure native HTTP scraping).
4. **Security by Design:** Strict validation of audio streams with Magic Byte verification (Ogg, MP3, WAV) and path-traversal prevention.
5. **Bilingual:** Instant language switching between English and German.

---

## 📦 Tech Stack & Architecture

- **Frontend & UI:** Godot Engine 4.x (GDScript)
- **Real-Time Spatial Audio:** Godot `AudioServer`, `AudioStreamPlayer3D`, and `AudioListener3D`
- **Offline Audio Rendering Engine:** FFmpeg (compiled with `libmysofa`)
- **HRTF Spatialization:** Standardized `.sofa` data files
- **Project File Format:** `.ambmix` (JSON-based serialized soundscape format)

---

## 🛠️ Installation & Setup

### Prerequisites

- [Godot Engine 4.x](https://godotengine.org/download) (Standard build)
- [FFmpeg](https://ffmpeg.org/download.html) (placed in system `PATH` or next to the application binary)

### Running from Source

1. Clone this repository:

   ```bash
   git clone https://github.com/adromir/3d-soundscape-studio.git
   ```

2. Open Godot Engine and import the project:
   - Click **Import**
   - Navigate to `e:/3d-soundscape-studio/`
   - Select `project.godot`
3. Press **F5** (or click **Play**) to launch the application.

---

## 📖 Usage Guide

### 1. Downloading from Ambient Mixer

1. Click **Library** in the bottom transport bar.
2. Paste a soundscape URL (e.g. `https://www.ambient-mixer.com/mix/...`) or a numeric template ID into the input bar.
3. Click **Download & Import**.
4. The soundscape and its stems are downloaded to your local library and immediately loaded into the 3D mixer canvas.

### 2. Positioning & Spatializing Tracks

- **Drag & Drop:** Click and drag any audio stem circle in the central radar view to adjust azimuth and distance.
- **Routing Mode:** In the right-hand **Track Inspector**, choose between:
  - `3D Point Source`: Directional audio in spherical coordinates.
  - `Omnipresent (All Around)`: Enveloping atmosphere surrounding the listener.
  - `Multi-Channel`: Assign to specific speaker outputs.

### 3. Automating Movement

- In the **Track Inspector**, select a **Movement Pattern** (`Ping-Pong L/R`, `One-Way L/R`, `Ping-Pong F/B`, `One-Way F/B`, `Random Walk`).
- Select **Movement Timing**:
  - `Continuous (During Play)`: Sound moves smoothly along its trajectory while playing.
  - `Jump Per Trigger`: Sound shifts to a new position each time it fires (ideal for thunder or distant wildlife).

### 4. Trigger & Interval Engine

- **Continuous Loop:** Seamless loop for water, wind, or base ambiance.
- **Fixed Interval:** Triggers every $X$ seconds.
- **Random Interval (Density):** Triggers $N$ times per time window.
- **Min. Cooldown (Blockwert):** Enforces a minimum silence window before the sound can retrigger.

### 5. Exporting Multi-Channel & Binaural Audio

1. Click **Export Audio** in the bottom bar.
2. Select the target speaker layout (`Binaural SOFA`, `Stereo`, `Quad 4.0`, `Surround 5.1`, `Surround 7.1`).
3. Set the target duration and optional `.sofa` HRTF file.
4. Click **Render Export** to generate the audio file asynchronously.

---

## ⚖️ Disclaimer

This software is designed for personal and educational soundscape composition. Audio files downloaded from third-party services are subject to their respective creators' copyright and licensing terms.

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for details.

---

**Author:** Adromir  
**Website:** [https://github.com/adromir](https://github.com/adromir)

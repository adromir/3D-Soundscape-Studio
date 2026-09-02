# 🎧 3D Soundscape Studio

[![Author](https://img.shields.io/badge/Author-Adromir-blue.svg)](https://github.com/adromir)
[![GitHub Repository](https://img.shields.io/badge/GitHub-Repository-lightgrey.svg?logo=github)](https://github.com/adromir/3D-Soundscape-Studio)
[![Engine](https://img.shields.io/badge/Engine-Godot%204.x-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![Documentation](https://img.shields.io/badge/Wiki-Documentation-blueviolet.svg?logo=bookstack)](wiki/Home.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platforms](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20Android-informational)](#)
[![Standalone Player](https://img.shields.io/badge/Standalone-3D%20Ambient%20Player-blue)](#)
[![Smart Lighting](https://img.shields.io/badge/Smart%20Lighting-Philips%20Hue%20%7C%20Home%20Assistant-purple)](#)
[![i18n](https://img.shields.io/badge/i18n-English%20%7C%20German%20%7C%20French%20%7C%20Spanish%20%7C%20Italian-brightgreen)](#)

A modern, high-performance desktop Digital Audio Workstation (DAW), 3D spatial soundscape generator, and dedicated standalone **3D Ambient Player** engineered for binaural audio, multi-channel surround rendering, interactive polar audio positioning, portable project packaging (`.3dscape`), Philips Hue smart ambient lighting, and generative relaxation audio.

> 📚 **Explore the [Full Visual Wiki Documentation](wiki/Home.md)** with detailed feature guides, architecture diagrams, and tutorials.

---

## 🌟 What the Project Does

**3D Soundscape Studio** and the **3D Ambient Player** empower sound designers, composers, tabletop RPG masters, game developers, and relaxation listeners to craft and enjoy living virtual audio environments in 3D space:

- **🎧 Dedicated Standalone 3D Ambient Player (`3D-Ambient-Player`):** A lightweight, meditative player for Windows, Linux, macOS, Android, and iOS. Features an expandable Atmosphere Stem Mixer drawer, breathing vinyl visualizer halo, sleep timer with 15-second gentle audio fade-out, 1-click `.3dscape` package import, and theme customization without DAW overhead.
- **💡 Native Philips Hue & Home Assistant Smart Lighting:** Synchronize your physical room lights with your soundscape. Features local Hue Bridge auto-discovery, 30-second push-link pairing, wide-gamut CIE 1931 xy color math, instant lightning strobe flashes ($0\text{ms}$ transition), fireplace hearth flicker, and listener proximity dimming.
- **⚡ 1-Click Dependency Downloader:** Automated cross-platform downloader and installer for `audio.cpp`, FFmpeg, and recommended AudioGen GGUF diffusion models on Windows, Linux, and macOS.
- **📦 Portable Soundscape Project Packaging (`.3dscape` / `.zip`):** Export and import self-contained soundscape archives containing track coordinates, listener movement paths, trigger schedules, metadata, cover artwork, and all referenced audio stem files with zero missing-file errors.
- **🎯 Interactive 3D Spatial Radar:** Visually position audio sources relative to a central listener with real-time azimuth, elevation, and distance attenuation (up to 30m soundspaces) with live drag & drop.
- **🌐 Native Ambient-Mixer Downloader & Importer:** Download soundscapes directly from [ambient-mixer.com](https://www.ambient-mixer.com/) with stem extraction, automatic URL subdomain categorization, metadata parsing, and cover art preservation.
- **🤖 Local AI Audio Generation (`audio.cpp`):** Generate ambient sound effects and audio loops seamlessly from text prompts inside the sample library, running entirely locally on CPU/GPU via native GGUF models.
- **📚 Integrated Soundscape & Samples Library:** Full-screen tabbed library workspace (`F3` / `F4`) for browsing soundscapes, editing metadata (title, author, category, cover artwork), and managing standalone sample sound banks.
- **🛤️ Listener Automation & Motion Paths:** Draw smooth motion paths for a virtual walking listener with real-world speed controls ($m/s$ and $km/h$), open/closed loop trajectories, and live waypoint stats.
- **🎛️ In-Inspector Multi-Channel Routing Grid:** Route tracks as pinpoint 3D sources, omnipresent ambient beds, or discrete speaker channels (`FL`, `FR`, `FC`, `LFE`, `BL`, `BR`, `SL`, `SR`, `TFL`, `TFR`, `TBL`, `TBR`) with 1-click surround presets.
- **🎲 Authentic Randomness & Interval Engine:** Schedule stem playback with seamless crossfade loops, periodic fixed intervals, or authentic Ambient-Mixer random frequency distributions ($1$ to $60$ counts per $1\text{m}$ to $4\text{h}$ window) with minimum cooldown guards.
- **🚀 Fast Offline Multi-Channel & Binaural Exporter:** Asynchronously render production-ready binaural stereo files (via HRTF `.sofa` files and `sofalizer`), Stereo, Quadraphonic (4.0), 5.1 Surround, and 7.1 Surround with dynamic audio normalization (`dynaudnorm`) and convolution reverb (`afir`).
- **🎨 Pro DAW Liquid Glass Aesthetics:** Frosted translucent glass panels over dynamic ambient caustic shader backdrops with 8 handcrafted theme styles and high-contrast light mode.
- **🌍 100% 5-Language Localization:** Instant real-time UI switching across **English**, **German**, **French**, **Spanish**, and **Italian**.

---

## 🚀 Key Advantages & Why Users Should Use It

1. **Effortless Soundscape Sharing (`.3dscape` Packages):** Bundle entire complex projects—including all audio files and 3D spatial settings—into a single portable `.3dscape` package file to share directly with friends, collaborators, or future standalone players.
2. **True Spatial Audio Without Complex DAWs:** Position sounds intuitively on a visual polar radar without needing complex routing plugins or professional audio engineering experience.
3. **Deterministic Offline Rendering:** Export hours of generative or spatialized soundscapes in minutes using FFmpeg's hardware-accelerated 64-bit float filtergraphs with zero buffer underruns or frame drops.
4. **Authentic Ambient-Mixer Scraper:** Download and expand thousands of online community soundscapes directly into spatial 3D audio environments.
5. **Cross-Platform & Dependency-Free:** Built natively in Godot 4.x and GDScript with pure native HTTP scraping, native ZIP packaging, and zero external runtime dependencies.
6. **Robust Security & Data Integrity:** Magic byte audio verification (Ogg, MP3, WAV), strict directory traversal (`..`) protection during package extraction, and local-first data storage (`./data/`).

---

## 📦 Tech Stack & Architecture

- **Frontend & Core Engine:** Godot Engine 4.x (GDScript)
- **Real-Time Spatial Audio:** Godot `AudioServer`, `AudioStreamPlayer3D`, `Camera3D`, and `AudioListener3D`
- **Offline Audio Rendering Engine:** FFmpeg (compiled with `libmysofa` for HRTF filtering)
- **Local AI Audio Generation Engine:** `audio.cpp` native C++ inference via GGUF models
- **HRTF Spatialization:** Standardized `.sofa` (Spatially Oriented Format for Acoustics) data files
- **Project File Formats:**
  - `.3dscape` / `.zip`: Portable self-contained archive (`project.ambmix` + `metadata.json` + `cover.*` + `audio/` stems)
  - `.ambmix`: JSON-based serialized soundscape configuration format
- **Design System:** Pro DAW Liquid Glass with custom shaders, responsive docks, and vector SVG icon system

---

## 🛠️ Installation & Setup

### Prerequisites

- [Godot Engine 4.x](https://godotengine.org/download) (Standard build)
- [FFmpeg](https://ffmpeg.org/download.html) (placed in system `PATH` or next to the application executable)

### Running from Source

1. Clone this repository:

   ```bash
   git clone https://github.com/adromir/3d-soundscape-studio.git
   ```

2. Open Godot Engine and import the project:
   - Click **Import**
   - Navigate to the cloned repository directory
   - Select `project.godot`
3. Press **F5** (or click **Play**) to launch the application.

---

## 📖 Usage Guide

### 1. Exporting & Importing Soundscape Packages (`.3dscape`)

- **Export Package:**
  - Go to **File > Export Soundscape Package (.3dscape)...** (`Ctrl+Shift+E`).
  - Or click the **`[ 📦 ]`** button on any soundscape card in the Library.
  - Or click **`[ 📦 Paket exportieren ]`** inside the Edit Soundscape modal or Export Dialog.
- **Import Package:**
  - Go to **File > Import Soundscape Package (.3dscape)...** (`Ctrl+Shift+I`).
  - Or click **`[ 📦 Paket importieren... ]`** in the Soundscape Library TopBar or Download dialog.
  - Or simply **drag and drop** a `.3dscape`, `.soundscape`, or `.zip` file anywhere onto the application window!

### 2. Downloading from Ambient Mixer

1. Switch to the **Library** tab (`F3`).
2. Click **Download & Import...**.
3. Enter the Ambient-Mixer URL (e.g. `https://www.ambient-mixer.com/mix/...`) or numeric template ID and choose a category.
4. Click **Download & Import**. The stems, cover art, and spatial layout are automatically downloaded, converted, and saved to your local library.

### 3. Positioning & Spatializing Tracks

- **Drag & Drop:** Click and drag any audio stem circle on the central radar canvas to adjust azimuth and distance.
- **Drag Audio Files:** Drag audio stems directly from the OS or Sample Browser onto the radar to place them at exact coordinates.
- **Routing Mode:** In the right-hand **Track Inspector**, choose between:
  - `3D Point Source`: Directional audio in spherical coordinates.
  - `Omnipresent (All Around)`: Enveloping atmosphere surrounding the listener equally.
  - `Multi-Channel Specific`: Route to discrete speaker channels (`FL`, `FR`, `FC`, `LFE`, etc.).

### 4. Simulating Listener Movement (Automation Tab `F2`)

1. Switch to the **Automation** tab (`F2`).
2. Click on the canvas to add waypoints for a walking listener path.
3. Configure walking speed ($m/s$ or $km/h$) and toggle between **Closed Loop** and **Open Path**.
4. Activate listener motion to experience a journey through your 3D sound environment.

### 5. Exporting Multi-Channel & Binaural Audio (`Ctrl+E`)

1. Click **Export** in the top transport bar (`Ctrl+E`).
2. Select your target speaker layout (`Binaural HRTF`, `Stereo`, `Quad 4.0`, `Surround 5.1`, `Surround 7.1`, or `7.1.4 Atmos`).
3. Set the target duration and optional `.sofa` HRTF file.
4. Click **🚀 Start Audio Render** to generate the offline master mixdown asynchronously.

### 6. Seamless GitHub Releases Auto-Updater

- Check for updates anytime via **Help > Check for Updates...** (`Hilfe > Nach Updates suchen...`).
- Shows release notes, version differences (`v2.0.0` ➔ `v2.1.0`), and downloads update binaries directly.
- On Windows and Linux, auto-applies the downloaded update package and restarts seamlessly.
- Configurable in **Preferences > Display & Language** (`[x] Check for updates automatically on startup`).

### 7. Using the Dedicated 3D Ambient Player

For users who want pure ambient soundscape playback, relaxation, meditation, or sleep assistance without loading the full DAW:

- **Launch Directly:** Run `3D-Ambient-Player.exe` (or `3D-Ambient-Player.x86_64` / `.app`), or pass `--player` (or `-p`) on the command line.
- **Atmosphere Stem Mixer:** Click the bottom drawer to expand real-time volume sliders and icons for each sound element (rain, wind, campfire, birds).
- **Smart Sleep Timer:** Click the crescent moon icon in the header to select 15m, 30m, 45m, 1h, or 2h with a gentle 15-second volume fade-out.
- **Library & Packages:** Click the Library button to switch soundscapes or import `.3dscape` package files.

### 8. Philips Hue & Smart Ambient Lighting

- Open **Tools > Visual Ambient Lighting (Hue & HA)...** (`F7`).
- Click **🔍 Auto-Discover Bridge** or enter your Bridge IP manually.
- Press the physical push-link button on your Hue Bridge and click **Pair with Bridge**.
- Fetch and map lights to thunder lightning strobes, fireplace flickers, and walking proximity dimming.

---

## 🖼️ Screenshots

| Studio Overview | 3D Spatial Radar & Inspector |
| :---: | :---: |
| ![Studio Overview](docs/images/01_studio_overview.png) | ![Track Inspector](docs/images/02_track_inspector_radar.png) |

| Listener Automation View | Soundscape Library & Package Management |
| :---: | :---: |
| ![Automation](docs/images/03_listener_automation_view.png) | ![Library](docs/images/05_soundscape_library_dialog.png) |

---

## ⚖️ Disclaimer

This software is designed for personal, creative, and educational soundscape composition. Audio files downloaded from third-party services are subject to their respective creators' copyright and licensing terms.

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for details.

---

**Author:** Adromir  
**Website:** [https://github.com/adromir](https://github.com/adromir)  
**Repository:** [https://github.com/adromir/3D-Soundscape-Studio](https://github.com/adromir/3D-Soundscape-Studio)

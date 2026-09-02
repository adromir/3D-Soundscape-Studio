# 3D Soundscape Studio — Official Documentation & Wiki

Welcome to the official documentation for **3D Soundscape Studio**, a next-generation Digital Audio Workstation (DAW) and spatial soundscape generator engineered specifically for binaural audio, multi-channel surround rendering, interactive polar audio positioning, portable project packaging (`.3dscape`), and ambient soundscape creation.

![Studio Overview](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/01_studio_overview.png)

---

## 🌟 Key Features at a Glance

| Feature | Description |
| :--- | :--- |
| 📦 **Portable Soundscape Packages (`.3dscape`)** | Export and import self-contained soundscapes containing all spatial coordinates, schedules, metadata, cover artwork, and audio stems in a single file for instant sharing. |
| 🎯 **Interactive 3D Spatial Radar** | Place audio sources on an intuitive polar coordinates radar with real-time azimuth, elevation, and distance attenuation (up to 30 meters) with live drag & drop. |
| 🛤️ **Listener Automation & Motion Paths** | Draw smooth motion paths for a virtual walking listener with speed controls ($m/s$ & $km/h$), open/closed loop modes, and live distance/time stats. |
| 🎛️ **Multi-Track Stem Mixer & In-Inspector Matrix** | Control stem volumes, mute/solo states, random/periodic trigger rates, seamless crossfade loops, and discrete in-inspector multi-channel routing (`FL`, `FR`, `FC`, `LFE`, `BL`, `BR`, `SL`, `SR`, `TFL`, `TFR`, `TBL`, `TBR`). |
| 📚 **Built-In Library & Ambient-Mixer Import** | Browse soundscapes, edit metadata and cover art, import XML templates directly from ambient-mixer.com, and manage custom audio sample banks. |
| 🤖 **Local AI Audio Generation (`audio.cpp`)** | Generate ambient sound effects and loops completely locally using native C++ inference and GGUF models directly within the sample browser. |
| 🔊 **Multi-Channel Surround & FFmpeg Export** | Real-time playback and offline mixdown to Stereo Binaural (HRTF / SOFA), Quadraphonic 4.0, 5.1 Surround, 7.1 Surround, and 7.1.4 Dolby Atmos. |
| 🎧 **SOFA HRTF Spatialization** | Load custom measured Head-Related Transfer Function profiles (`.sofa`) for personalized 3D headphone listening. |
| 🎨 **Pro DAW Liquid Glass & 8 Themes** | Choose between 8 handcrafted visual styles: *Aetheric Dark*, *Studio Light*, *Cyberpunk Neon*, *Warm Fantasy*, *Holo Sci-Fi*, *Antique Sepia*, *Emerald Jungle*, and *Abyss Ocean*. |
| 🎧 **Dedicated Standalone 3D Ambient Player** | Distraction-free playback for desktop & mobile (Windows, Linux, macOS, iOS, Android) with stem mixer, breathing visualizer, and sleep timer. |
| 💡 **Philips Hue & Smart Lighting** | Local Bridge REST API integration with auto-discovery, 30s push-link pairing, CIE 1931 xy colors, and audio-reactive lightning flash triggers. |
| 🌍 **100% 5-Language Localization** | Instant real-time UI localization in **English**, **German**, **French**, **Spanish**, and **Italian**. |

---

## 🚀 Quick Start Guide

1. **Launch 3D Soundscape Studio**:
   - Download the latest installer or portable executable from the [Releases](https://github.com/adromir/3D-Soundscape-Studio/releases) page.
2. **Add, Import, or Open Soundscapes**:
   - Click **`+ Add Audio Track`** at the bottom-left dock or open **Library** (`F3`) to load a preset like *Tropical Rain Forest*.
   - Or drag & drop `.3dscape` project packages or `.wav`, `.ogg`, and `.mp3` files directly into the Studio!
3. **Position Sound Sources in 3D Space**:
   - Drag track pucks across the **3D Spatial Radar Canvas** to position them around the listener.
   - Adjust **Elevation** (height) and **Distance** in the **Track Inspector** on the right.
4. **Trigger & Interval Scheduling**:
   - Set sound cues to play continuously as a loop, at fixed intervals, or with organic random density (e.g. *3x per 10 minutes*).
5. **Simulate Listener Motion**:
   - Switch to the **Automation** tab (`F2`), click on the radar to create waypoints, and activate listener motion to experience a journey through your environment.
6. **Share or Export**:
   - **Export Package (`.3dscape`)**: Go to **File > Export Soundscape Package...** (`Ctrl+Shift+E`) to share your full soundscape with audio stems.
   - **Export Audio Master**: Press **Export** (`Ctrl+E`) to render an offline multi-channel or binaural `.wav` / `.flac` mixdown.

---

## 🧭 Wiki Documentation Index

- **[🎯 3D Spatial Audio Radar](3D-Spatial-Audio-Radar.md)**: Master polar spatialization, distance attenuation, and visual source markers.
- **[🛤️ Listener Automation & Motion](Listener-Automation-&-Motion.md)**: Design dynamic movement paths, speed regulation, and waypoint curves.
- **[🎛️ Stem Audio Tracks & Parameter Inspector](Stem-Audio-Tracks-&-Parameter-Inspector.md)**: Configure stems, volume curves, trigger intervals, and channel routing.
- **[📚 Soundscape & Samples Library](Soundscape-Library-&-Ambient-Mixer-Import.md)**: Manage sound collections, `.3dscape` packaging, custom sample categories, and online imports.
- **[🤖 AI Audio Generation](AI-Audio-Generation.md)**: Guide to configuring local `audio.cpp` models and generating sounds from text prompts.
- **[🔊 Multi-Channel Surround & Offline Export](Multi-Channel-Surround-&-Offline-Export.md)**: Set up speaker configurations, SOFA profiles, and FFmpeg mixdowns.
- **[🎧 SOFA HRTF & Spatial Audio Guide](SOFA-HRTF-Spatial-Audio-Guide.md)**: Deep dive into HRTF filters, SOFA database sources, and personalized binaural audio.
- **[🎧 Dedicated 3D Ambient Player](Dedicated-3D-Ambient-Player.md)**: Explore the standalone player for desktop & mobile, the Atmosphere Stem Mixer, sleep timer, and packaging.
- **[💡 Philips Hue & Smart Lighting](Philips-Hue-&-Smart-Lighting.md)**: Synchronize physical smart lights with soundscapes via Hue Bridge or Home Assistant.
- **[🎨 Themes, Localization & Preferences](Themes-Localization-&-Preferences.md)**: Customize themes, 5 languages, and workspace preferences.

---

## ⚖️ License

3D Soundscape Studio is open-source software licensed under the **MIT License**.  
Designed & Engineered by **[Adromir](https://github.com/adromir)**.  
Repository: **[https://github.com/adromir/3D-Soundscape-Studio](https://github.com/adromir/3D-Soundscape-Studio)**

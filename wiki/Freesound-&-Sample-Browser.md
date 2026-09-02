# 🎵 Freesound.org & Integrated Sample Browser

The **Sample Browser** (`F4`) in 3D Soundscape Studio is a full-featured sound management and discovery hub. It combines local sample library browsing, direct text-to-sound AI generation (`audio.cpp`), and full integration with the **Freesound.org** public audio database.

![Sample Browser & Freesound](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/14_ai_audio_and_freesound.png)

---

## 🌐 Freesound.org REST APIv2 Integration

Discover thousands of high-quality environmental sound effects and field recordings directly inside the Studio without opening a web browser:

### Key Capabilities
- **Quick Tag Chips**: 1-click search tags for common ambient soundscape elements:
  - `#Rain`, `#Thunder`, `#Campfire`, `#Wind`, `#Birds`, `#Stream`, `#Waves`, `#Footsteps`, `#Clock`, `#Chimes`
- **Licensing Filters**:
  - **Creative Commons 0 (CC0)**: 100% public domain, free for commercial and non-commercial works with zero attribution requirements.
  - **Attribution (CC-BY)**: Requires creator credit.
  - **All Licenses**: Browse the complete Freesound library.
- **Duration Sliders**: Filter between short punchy sound cues (e.g. $0.5\text{s}$ twig snap) and expansive atmospheric loops ($60\text{s}+$ rainstorms).
- **Zero-Footprint In-Memory Streaming**: Audition preview tracks instantly in RAM without creating cluttering cache files on your hard drive.
- **1-Click 3D Stem Placement**: Click **`+ Add to Soundscape`** to download, normalize, and automatically position the sound onto the 3D radar canvas.

---

## 📁 Local Sample Bank Management

Organize your personal library of audio recordings, foley stems, and sound effects:

- **Supported Audio Formats**: `.wav` (16/24/32-bit float, uncompressed PCM), `.ogg` (Vorbis), `.mp3`, and `.flac`.
- **Drag & Drop Auditioning**: Drag any audio file from Windows File Explorer, macOS Finder, or Linux file managers directly onto the Sample Browser to audition or categorize.
- **Metadata Tagging**: Assign tags, categories, author attribution, and descriptive notes.
- **Direct Radar Dragging**: Drag sound cards from the Sample Browser directly onto any position on the 3D radar soundstage!

---

## 🤖 Local AI Audio Generation Panel

Located directly alongside the sample browser:
- Enter descriptive text prompts (e.g. *"crackling pine wood campfire with wind embers"*).
- Select duration and diffusion steps.
- Renders entirely on your local CPU or GPU using native `audio.cpp` C++ inference with zero data sent to external cloud servers.
- Generated samples are immediately auditionable and ready for 3D spatialization.

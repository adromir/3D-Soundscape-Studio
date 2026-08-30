# 📚 Library: Soundscape & Samples Workspaces

3D Soundscape Studio integrates a dedicated **Library** workspace in the main window (`F3` / `F4`), combining the **Soundscape Library** and the **Samples Library** into clean, cohesive sub-tabs for sound design, preset management, and portable soundscape sharing.

![Soundscape Library](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/05_soundscape_library_dialog.png)

---

## 📦 Soundscape Project Packages (`.3dscape` / `.zip`)

3D Soundscape Studio features a portable packaging architecture allowing soundscapes to be shared directly between instances and future dedicated players without broken audio stem paths.

### Package Architecture
A `.3dscape` archive is a standardized, self-contained ZIP container containing:
- `project.ambmix`: JSON spatial project specification with normalized relative audio stem paths (`audio/01_rain.ogg`) and relative cover path (`cover.jpg`).
- `metadata.json`: Soundscape title, author, category, description, and source tags.
- `cover.png` / `cover.jpg` / `cover.webp`: High-resolution cover artwork.
- `audio/`: Dedicated directory containing all referenced audio stem files.

### 📤 How to Export a Soundscape Package
You can export a `.3dscape` package from multiple convenient locations:
1. **MenuBar**: Choose **File > Export Soundscape Package (.3dscape)...** (`Ctrl+Shift+E`).
2. **Library Cards**: Click the **`[ 📦 ]`** icon button on any soundscape card in the library.
3. **Edit Soundscape Dialog**: Click **`[ 📦 Paket exportieren ]`** inside the Edit Properties window.
4. **Export Dialog**: Click **Export Package (.3dscape)** at the bottom of the audio export window.

### 📥 How to Import a Soundscape Package
1. **MenuBar**: Choose **File > Import Soundscape Package (.3dscape)...** (`Ctrl+Shift+I`).
2. **Library TopBar**: Click the **`[ 📦 Paket importieren... ]`** button next to the search bar.
3. **Download Modal**: Click **`[ 📦 Paket importieren... ]`** inside the download dialog.
4. **Drag & Drop**: Simply drag and drop any `.3dscape`, `.soundscape`, or `.zip` file from your desktop or file manager directly onto the 3D Soundscape Studio window!

---

## 🗂️ Soundscape Library Sub-Tab (`F3`)

Access the Soundscape Library by pressing `F3` or clicking **Soundscape-Bibliothek** in the top library sub-tabs.

### Features:
- **Card Grid View**: Soundscapes display with high-resolution cover artwork, title, author, category tag, and track count badges.
- **Card Action Bar**:
  - `[ ▶ Projekt laden ]`: Instantly loads the soundscape into the active 3D studio mixer.
  - `[ ✏️ ]`: Opens the **Edit Soundscape Properties** modal (edit title, author, category, and live cover image preview/selection).
  - `[ 📦 ]`: Exports the soundscape as a standalone `.3dscape` package.
  - `[ 🗑️ ]`: Deletes the soundscape from the local library.
- **Category Filter Chips**: Filter library items by `ALL`, `Nature`, `Weather`, `Ambient`, `Relaxation`, `Fantasy`, `Sci-Fi`, or custom tags.
- **Instant Search**: Real-time filtering across titles, authors, and keywords.

---

## 🌐 Ambient-Mixer.com Downloader & Importer

Easily import online soundscapes and templates from [ambient-mixer.com](https://www.ambient-mixer.com):

1. Click **`[ 📥 Herunterladen & Importieren... ]`** in the Soundscape Library TopBar.
2. Paste the Ambient-Mixer URL (e.g. `https://www.ambient-mixer.com/mix/tropical-rain-forest`) or numeric template ID (e.g. `12345`).
3. Select your target organizational category.
4. Click **Download & Import**.
5. 3D Soundscape Studio parses the XML track specifications, downloads all audio stems, validates file integrity, maps stereo balance to 3D polar azimuth coordinates, and saves the project into `data/library/<slug>/`.

---

## 🎵 Samples Library Sub-Tab (`F4`)

The **Samples Library** sub-tab (`F4`) allows you to organize and audition standalone audio stems and individual sound samples:

![Samples Library View](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/04_sample_browser_view.png)

### Key Capabilities:
- **Category Filter Chips**: Switch between `ALL`, `Weather`, `Nature`, `Elements`, `Ambient`, `FX`, `Music`, `Voices`, or custom user categories.
- **Add Custom Categories**: Create your own organizational tags with the **+ Kategorie hinzufügen** button.
- **Sample Metadata Editor**: Click **Edit** on any sample item to customize its default icon, category, and accent color.
- **Audition Player**: Preview audio samples instantly using the inline Play / Stop buttons.
- **One-Click Studio Insertion**: Click **`+ Add to Studio`** to instantiate a new spatial stem track in your active project.
- **Drag & Drop Audio Support**: Drag and drop audio files (`.wav`, `.ogg`, `.mp3`, `.flac`) directly onto the window or canvas to import them into your library.

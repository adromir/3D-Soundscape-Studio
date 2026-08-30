# 📚 Library: Soundscape & Samples Workspaces

3D Soundscape Studio integrates a dedicated **Library** workspace in the main window (`F3` / `F4`), combining the **Soundscape Library** and the **Samples Library** into clean, cohesive sub-tabs for seamless sound design and preset management.

![Soundscape Library](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/05_soundscape_library_dialog.png)

---

## 🗂️ Soundscape Library Sub-Tab (`F3`)

Access the Soundscape Library by pressing `F3`, clicking **Library** in the top navigation bar, or selecting **File > Soundscape Library...**.

### Features:
- **Embedded Main Window Integration**: Browse your soundscape projects directly in the main workspace without popup interruptions.
- **Card Grid View**: Soundscapes are displayed with high-resolution cover artwork, title, author, and track count badges.
- **Instant Search**: Filter soundscapes in real-time by title, tag, or author.
- **Preset Management**: Load projects into the studio with one click, change cover art, or delete soundscapes directly from the cards.
- **Custom Cover Art**: Set any `.png` or `.jpg` image as album artwork for your soundscape projects.

---

## 🌐 Ambient-Mixer.com Downloader & Importer

Easily import soundscapes and templates from [ambient-mixer.com](https://www.ambient-mixer.com):

1. Copy the URL or Template ID of any ambient-mixer soundscape (e.g. `https://www.ambient-mixer.com/mix/tropical-rain-forest` or ID `12345`).
2. Paste it into the **Ambient Mixer Downloader** input field in the Soundscape Library tab.
3. Click **Download & Import**.
4. 3D Soundscape Studio parses the XML track specifications, downloads all audio stems, maps stereo panning and volume levels to 3D polar coordinates, and stores the project in your local library!

---

## 🎵 Samples Library Sub-Tab (`F4`)

The **Samples Library** sub-tab (`F4`) allows you to organize and audition standalone audio stems and individual sound samples:

![Samples Library View](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/04_sample_browser_view.png)

### Key Capabilities:
- **Category Filter Chips**: Switch between `ALL`, `Weather`, `Nature`, `Elements`, `Ambient`, `FX`, `Music`, `Voices`, or custom user categories.
- **Add Custom Categories**: Create your own organizational tags with the **Add Category** button.
- **Sample Metadata Editor**: Click **Edit** on any sample item to customize its default icon, category, and accent color.
- **Audition Player**: Preview audio samples instantly using the inline Play / Stop buttons.
- **One-Click Studio Insertion**: Click **`+ Add to Studio`** to instantiate a new spatial stem track in your active project and automatically switch to the Studio radar.
- **Drag & Drop Audio Support**: Drag and drop audio files (`.wav`, `.ogg`, `.mp3`) directly into the window to import them into your library.

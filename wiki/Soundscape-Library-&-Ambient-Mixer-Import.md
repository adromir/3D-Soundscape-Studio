# 📚 Soundscape Library & Ambient-Mixer Import

3D Soundscape Studio features a built-in Soundscape Library and an integrated Sample Browser for managing your personal audio collections and importing presets from online communities.

![Soundscape Library Dialog](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/05_soundscape_library_dialog.png)

---

## 🗂️ Soundscape Library (`F4`)

Access the Soundscape Library by pressing `F4`, clicking **Library** in the top navigation bar, or selecting **File > Soundscape Library...**.

### Features:
- **Card Grid View**: Soundscapes are displayed with high-resolution cover artwork, title, author, and track count badges.
- **Instant Search**: Filter soundscapes in real-time by title, tag, or author.
- **Preset Management**: Load, edit metadata, change cover art, or delete soundscapes directly from the library cards.
- **Custom Cover Art**: Load any `.png` or `.jpg` image as album artwork for your soundscape projects.

---

## 🌐 Ambient-Mixer.com Importer

Easily import soundscapes and templates from [ambient-mixer.com](https://www.ambient-mixer.com):

1. Copy the URL or Template ID of any ambient-mixer soundscape (e.g. `https://www.ambient-mixer.com/mix/tropical-rain-forest` or ID `12345`).
2. Paste it into the **Ambient Mixer Downloader** input field in the Library dialog.
3. Click **Download & Import**.
4. 3D Soundscape Studio parses the XML track specifications, downloads all audio stems, maps stereo panning and volume levels to 3D polar coordinates, and stores the project in your local library!

---

## 🎵 Sample Browser View (`F3`)

The **Sample Browser** (`F3`) allows you to organize and audition standalone audio samples:

![Sample Browser View](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/04_sample_browser_view.png)

### Key Capabilities:
- **Category Filter Tabs**: Switch between `ALL`, `Weather`, `Nature`, `Elements`, `Ambient`, `FX`, `Music`, `Voices`, or custom user categories.
- **Add Custom Categories**: Create your own organizational tags with the **Add Category** button.
- **Sample Metadata Editor**: Click **Edit** (`edit.svg`) on any sample item to customize its default icon, category, and accent color.
- **Audition Player**: Preview audio samples instantly using the inline Play / Stop buttons.
- **One-Click Studio Insertion**: Click **`+ Add to Studio`** to instantiate a new spatial stem track in your active project.
- **Drag & Drop Audio Support**: Drag and drop audio files (`.wav`, `.ogg`, `.mp3`) directly into the window to import them into your library.

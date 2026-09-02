# 🎧 Dedicated 3D Ambient Player

The **3D Ambient Player** is a dedicated, distraction-free standalone player engineered for **Windows, Linux, macOS, Android, and iOS**. It provides a pure, meditative listening environment without the timeline, track inspector, or audio generation overhead of the full Studio DAW.

Built directly within the same unified repository, the Ambient Player shares the high-performance 3D spatial audio engine, project data models, soundscape package manager, and smart ambient lighting synchronization.

---

## 🌟 Key Features

| Feature | Description |
| :--- | :--- |
| **🎵 Distraction-Free Player** | Clean, minimalist interface centered around the soundscape's artwork, metadata, and spatial soundscape. |
| **✨ Breathing Halo Visualizer** | Ambient halo around the artwork that subtly pulses in sync with the audio playback. |
| **🎛️ Atmosphere Stem Mixer** | Collapsible bottom drawer displaying all active stems with custom vector icons (rain, birds, campfire, wind, stream, etc.) and real-time volume sliders. |
| **🌙 Smart Sleep Timer** | Select from 15m, 30m, 45m, 1h, or 2h with an automatic 15-second gentle fade-out before stopping. |
| **📦 1-Click `.3dscape` Import** | Load community soundscapes or shared `.3dscape` / `.zip` packages instantly via file picker or drag & drop. |
| **💡 Smart Lighting Integration** | Live synchronization with Philips Hue Bridge and Home Assistant for hearth fire flicker, proximity lighting, and lightning strobes. |
| **🎨 Theme Customization** | Instant theme switching between *Organic Zen*, *Dark Slate*, *Light Paper*, and *Cyberpunk Neon*. |
| **📱 Cross-Platform Touch & Desktop** | Responsive layout scaling smoothly from smartphone screens (down to $400\times480$) up to high-DPI desktop 4K monitors. |

---

## 🚀 How to Launch the Player

### Standalone Executable (Recommended)
When using pre-compiled releases:
- **Windows**: Launch `3D-Ambient-Player.exe`
- **Linux**: Launch `3D-Ambient-Player.x86_64`
- **macOS**: Launch `3D-Ambient-Player.app`
- **Android**: Install and launch `3D-Ambient-Player.apk`
- **iOS**: Install `3D-Ambient-Player.ipa`

### Command-Line Arguments
If using the unified binary or running from source:
```bash
# Launch directly into the 3D Ambient Player
./3D-Soundscape-Studio --player

# Short flag
./3D-Soundscape-Studio -p

# Force Studio DAW mode
./3D-Soundscape-Studio --studio
```

---

## 🎛️ Using the Atmosphere Stem Mixer

The Atmosphere Stem Mixer lets listeners tailor any soundscape to their exact mood:

1. Click **Atmosphere Stem Mixer (Click to Expand)** at the bottom of the player.
2. The drawer smoothly expands horizontally, showing every sound element in the mix.
3. Each stem card displays:
   - **Vector Sound Icon**: Visual identification of the sound (e.g. rain cloud, water drop, bird, wind).
   - **Stem Name**: Cleanly truncated track title.
   - **Volume Slider**: Adjust the volume level ($0\%$ to $100\%$) in real time.
4. Click the drawer bar again to collapse and return to the minimalist view.

---

## 🌙 Using the Sleep Timer

1. Click the **Timer** button (`moon.svg`) in the top right header.
2. Select your desired duration:
   - **15 Minutes**
   - **30 Minutes**
   - **45 Minutes**
   - **1 Hour**
   - **2 Hours**
3. Once active, the timer button displays the remaining minutes in gold (e.g. `🌙 28m`).
4. When the countdown reaches the final 15 seconds, the player automatically begins a smooth, non-jarring volume fade-out to zero, then gently stops playback and turns off ambient smart lights.

---

## 📦 Importing Soundscapes (`.3dscape`)

1. Click the **Library** button in the top left header.
2. Click **Import .3dscape**.
3. Select any `.3dscape` or `.zip` package exported from 3D Soundscape Studio.
4. The soundscape is extracted, added to your local library, and loaded immediately with all stems and cover art ready to play!

---

## 🛠️ Export Presets & Architecture

In `export_presets.cfg`, dedicated export presets are provided for all platforms with `custom_features="player"`:

- `preset.3`: **Windows Player** (`build/windows/3D-Ambient-Player.exe`)
- `preset.4`: **Linux Player** (`build/linux/3D-Ambient-Player.x86_64`)
- `preset.5`: **macOS Player** (`build/macos/3D-Ambient-Player.dmg`)
- `preset.6`: **Android Player** (`build/android/3D-Ambient-Player.apk`)
- `preset.7`: **iOS Player** (`build/ios/3D-Ambient-Player.ipa`)

The multi-target bootstrapper in `src/core/app_launcher.gd` inspects executable names, CLI arguments, and feature tags to dispatch cleanly without any startup delay.

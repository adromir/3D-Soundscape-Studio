# 🔊 Multi-Channel Surround & Offline Export

3D Soundscape Studio provides both real-time multi-speaker playback and high-precision offline surround rendering powered by FFmpeg and SOFA (Spatially Oriented Format for Acoustics) HRIR databases.

![Export Surround Dialog](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/06_export_surround_dialog.png)

---

## 🎧 Supported Speaker & Surround Formats

| Layout Format | Channel Count | Channels Used | Recommended For |
| :--- | :--- | :--- | :--- |
| **Binaural (HRTF)** | 2 (Stereo) | Left, Right (Binaural Filtered) | Standard Headphones, VR, Spatial Audio |
| **Stereo (2.0)** | 2 | FL, FR | Desktop Stereo Monitors |
| **Quadraphonic (4.0)** | 4 | FL, FR, BL, BR | Quad Studio Monitoring |
| **5.1 Surround** | 6 | FL, FR, FC, LFE, SL, SR | Home Theater & Cinema Surround |
| **7.1 Surround** | 8 | FL, FR, FC, LFE, BL, BR, SL, SR | 8-Channel Surround Systems |
| **7.1.4 Dolby Atmos** | 12 | 7.1 Bed + 4 Overhead Height Channels (TFL, TFR, TBL, TBR) | Immersive Spatial Audio Studios |

---

## 🎙️ Real-Time Speaker Setup

You can switch the active real-time output format on the fly:
- Use the **Speaker Layout** dropdown in the top transport bar.
- Or navigate to **Playback > Speaker Setup** in the MenuBar (`Stereo`, `Binaural`, `5.1`, `7.1`).

---

## 🚀 Offline FFmpeg Surround Export (`Ctrl + E`)

To render a production-ready spatial audio master:

1. Click **Export** in the top transport bar or press `Ctrl + E`.
2. Configure export settings in the modal dialog:
   - **Export Duration**: Total length of the rendered mix in seconds (e.g. $300\text{ s} = 5\text{ minutes}$).
   - **Target Speaker Layout**: Choose from Binaural, Quad, 5.1, 7.1, or 7.1.4.
   - **Custom SOFA HRTF Profile (Optional)**: Load your personalized HRIR `.sofa` file or use the built-in generic KEMAR / MIT profile.
   - **Output File Path**: Choose destination (`.wav`, `.flac`, `.m4a`, or `.ogg`).
3. Click **Start Export**.
4. 3D Soundscape Studio generates complex multi-source spatial panning matrices and executes an offline render pipeline to guarantee pristine 64-bit float mixing with zero buffer underruns or frame drops.

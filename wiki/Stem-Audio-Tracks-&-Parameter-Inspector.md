# 🎛️ Stem Audio Tracks & Parameter Inspector

The **Stem / Audio Tracks** dock and **Track Inspector** provide complete multichannel control over every audio stem in your project.

![Studio Overview with Stem Controls](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/01_studio_overview.png)

---

## 🎚️ Stem / Audio Tracks Canvas (Left Dock)

The left dock displays all active stems in the current soundscape:

- **Track List Items**:
  - **Status Indicator**: Glowing colored bar matching the track's radar accent.
  - **Category Icon**: Vector icon representing the sound type.
  - **Track Name**: Click to focus and edit parameters in the Inspector.
  - **Volume Fader**: Individual slider with percentage readout and volume icon.
  - **Solo (S) & Mute Buttons**: Isolate specific stems or mute background layers.
  - **Density / Rate Badge**: Shows active interval trigger settings (e.g. `3x / 1m`, `Continuous`).
- **Toolbar Actions**:
  - **Reset All (`reset.svg`)**: Reverts all stem parameters (positions, volumes, and states) back to their initial snapshot with a single click.
  - **`+ Add Audio Track`**: Spawns a new audio channel ready for audio sample assignment.
  - **Pop-Out**: Undocks the Stem list into a dedicated multi-window pane.

---

## 🔍 Track Parameter Inspector (Right Dock)

When a track is selected, the right dock exposes detailed acoustic properties:

### 1. General & Visual Identity
- **Track Name**: Custom name for the stem.
- **Audio Source File**: Displays loaded file path with **Load Audio...** file picker.
- **Track Accent Color**: 8 curated high-contrast color swatches.
- **Radar Sound Icon**: Dropdown picker with custom vector icons (*Rain*, *Water*, *Birds*, *Wind*, *Bell*, *Steps*, *Music*, *FX*, *Voice*, etc.).

### 2. Spatial Routing & Positioning
- **Spatial Mode**:
  - `3D Point Source`: Rendered with 3D HRTF / polar coordinates.
  - `Omnipresent / Background`: Diffuse sound that immerses the entire space without directional localization.
  - `Multi-Channel Direct`: Direct routing to specific surround channels.
- **Azimuth ($^\circ$)**: Polar angle from $-180^\circ$ (rear left) to $+180^\circ$ (rear right).
- **Elevation ($^\circ$)**: Vertical height angle from $-90^\circ$ (below) to $+90^\circ$ (overhead).
- **Distance ($m$)**: Radial distance from the listener ($0.5\text{ m}$ to $30\text{ m}$).

### 3. Motion & Trajectory Simulation
- **Movement Pattern**: `Static (None)`, `Ping-Pong (L/R)`, `One-Way (L/R)`, `Ping-Pong (F/B)`, `One-Way (F/B)`, or `Random Wander`.
- **Movement Timing**: `Continuous (In Flight)` or `Jump Per Trigger`.
- **Velocity / Speed**: Speed multiplier ($0.1\times$ to $5.0\times$).

### 4. Trigger Scheduling & Intervals
- **Continuous Loop**: Seamless playback with optional **Seamless Crossfade Loop** to eliminate clicks at buffer loop points.
- **Fixed Interval**: Plays periodically with a configured silent interval gap (in seconds).
- **Random Density Trigger**: Organic stochastic playback modeled after nature (e.g. random birds chirping or thunder claps).
  - Rate presets: `1x / 1m`, `3x / 1m`, `5x / 1m`, `1x / 5m`, `1x / 15m`, `1x / 1h`, etc.
  - Cooldown safety gate: Ensures minimum silent spacing between consecutive triggers.

---

## 🔄 Reset Stem vs Reset All

- **Reset Stem (`reset.svg`)**: Located at the top of the Track Inspector, resets only the currently selected stem.
- **Reset All (`reset.svg`)**: Located on the Stem Canvas header, restores the entire multi-track soundscape.

# 🎯 3D Spatial Audio Radar

The **3D Spatial Audio Radar** is the central visual positioning environment in 3D Soundscape Studio. It maps sound sources around a central virtual listener in real-time using polar coordinates $(r, \theta, \phi)$.

![3D Spatial Audio Radar & Track Inspector](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/02_track_inspector_radar.png)

---

## 🧭 Polar Coordinates & Visual Layout

The radar canvas visualizes the listener at the center looking forward towards the top ($0^\circ$ / **F**ront).

| Axis / Marker | Polar Angle ($\theta$) | Description |
| :--- | :--- | :--- |
| **F** (Front) | $0^\circ$ | Center forward direction directly ahead of the listener. |
| **R** (Right) | $+90^\circ$ | Directly to the listener's right ear / starboard channel. |
| **B** (Back) | $\pm 180^\circ$ | Directly behind the listener / rear surround. |
| **L** (Left) | $-90^\circ$ | Directly to the listener's left ear / port channel. |

Concentric distance rings represent distances from $1.0\text{ m}$ up to $30.0\text{ m}$ (configurable in Soundspace Settings).

---

## 🎧 Real-Time Acoustic Simulation

When a track is positioned on the radar canvas:

1. **Interaural Time Difference (ITD)**:
   - Sounds arriving from the side reach the closer ear milliseconds earlier, calculated automatically based on human head geometry models ($0.175\text{ m}$ head diameter).
2. **Interaural Level Difference (ILD)**:
   - High-frequency shadowing (head shadow effect) naturally dampens sounds in the contralateral ear.
3. **Inverse Square Distance Attenuation**:
   - Sound energy decreases logarithmically with distance according to real-world physics:
     $$A(d) = \frac{1}{1 + \alpha \cdot d}$$
   - Includes air absorption high-frequency roll-off for distant environmental sounds (rain, wind, thunder).
4. **Elevation Angle ($\phi$)**:
   - Configurable from $-90^\circ$ (directly below / foot level) to $+90^\circ$ (directly above / zenith overhead) using the **Elevation slider** in the Track Inspector.
   - Accurately routed to height channels in 7.1.4 Dolby Atmos or spectral pinna filtering in HRTF Binaural mode.

---

## 🎨 Interactive Track Markers (Pucks)

Each sound source on the radar is represented by an interactive high-contrast puck:

- **Icon**: Uniquely displays the assigned sound category (e.g. 🌧️ *Rain*, 🐦 *Birds*, 💧 *Water*, 🔥 *Fire*, 🔔 *Bell*, ⚡ *FX*).
- **Color Accent**: Pick from vibrant color swatches (Blue, Emerald, Red, Purple, Amber, Cyan, Magenta) for instant visual tracking.
- **Selection Glow**: Clicking a puck selects the track and updates the **Track Inspector** parameters in real-time.
- **Direct Drag & Drop**: Click and drag any puck to smoothly reposition sound sources with zero audio crackle or latency.
- **Sound Spread Arc**: For wide atmospheric sound bodies (e.g. an expansive rain canopy), the radar renders an acoustic dispersion cone showing sound coverage.

---

## 🪟 Dock Pop-Out / Undock

Click the **Pop-Out** icon (`popout.svg`) in the top-right corner of the Radar Canvas header to detach the radar into a standalone multi-monitor window!

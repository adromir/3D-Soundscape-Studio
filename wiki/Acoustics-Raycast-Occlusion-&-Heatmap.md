# 🧱 Acoustic Environments, Raycast Occlusion & Sound Pressure Heatmap

**3D Soundscape Studio** features advanced physics-based acoustic simulation, including real-time raycast line-of-sight occlusion, physical wall barriers, environmental reverberation zones, and an interactive GPU-accelerated acoustic heatmap.

![Acoustic Heatmap & Radar](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/02_track_inspector_radar.png)

---

## 🌡️ Real-Time Acoustic Heatmap

The Acoustic Heatmap provides an instant visual sound pressure field ($L_p$ in decibels) across your virtual soundscape.

### How It Works
- **GPU Accelerated Shader**: Built on `acoustic_heatmap.gdshader`, the heatmap computes inverse-square sound energy falloff and interference patterns from all playing audio sources in parallel.
- **Iso-dB Contour Rings**: High-contrast geometric contour rings illustrate sound dissipation boundaries and pressure gradients.
- **3 Dynamic Color Palettes**:
  1. **Thermal**: Deep indigo into warm amber and radiant red for intuitive loudness perception.
  2. **Phosphor**: Tactical monochromatic radar green reminiscent of vintage military acoustics equipment.
  3. **Cyberpunk**: High-contrast neon magenta and cyan aesthetic.
- **Instant Hotkey Toggle**: Press **`H`** anytime to toggle the heatmap overlay on both the **Studio 3D Radar** (`F1`) and the **Story Automation Walkthrough Canvas** (`F2`).

---

## 🧱 Physical Barriers & Raycast Occlusion

Create complex architectural and natural acoustic spaces by drawing physical barriers directly onto the soundstage.

### Line-of-Sight Raycasting
1. **Ray Intersection**: The `SpatialEngine` casts real-time geometric rays between the listener's head and each active audio stem puck.
2. **Frequency-Dependent Filtering**: When a wall interrupts the direct line of sight:
   - **Low-Pass Muffler**: High and mid frequencies are sharply attenuated ($f_c \approx 450\text{ Hz}$ to $1200\text{ Hz}$), replicating physical sound absorption through solid obstacles.
   - **Low-End Bleed**: Deep bass and low-frequency rumble pass through with minor dampening, accurately modeling acoustic diffraction.
   - **Volume Attenuation**: Direct signal amplitude is dampened by $-6\text{ dB}$ to $-18\text{ dB}$ depending on the obstacle thickness.
3. **Interactive Editing**: Draw, move, and reshape barrier vectors on the radar canvas with live acoustic feedback.

---

## 🏛️ Acoustic Zones & Environmental Reverb

Divide your soundscape into distinct acoustic rooms or environmental zones:

| Zone Preset | Decay Time ($RT_{60}$) | Damping | Description |
| :--- | :--- | :--- | :--- |
| **Forest Glade** | $0.4\text{ s}$ | High | High foliage absorption, soft early reflections. |
| **Cozy Wooden Cabin** | $0.6\text{ s}$ | Moderate | Warm timber resonances with gentle warmth. |
| **Cathedral / Temple** | $3.5\text{ s}$ | Low | Expansive stone reflections, long lingering reverb tail. |
| **Cavern / Cave** | $2.8\text{ s}$ | Very Low | Hard reflective walls, echoing slapback delay. |
| **Modern Studio Room** | $0.3\text{ s}$ | Extreme | Acoustically treated dry room for clinical monitoring. |

When listener automation paths cross into a new acoustic zone, reverb sends and room filters blend smoothly with adjustable crossfade curves.

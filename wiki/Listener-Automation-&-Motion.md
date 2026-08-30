# 🛤️ Listener Automation & Motion Paths

The **Listener Automation** system enables you to turn static ambient soundscapes into dynamic virtual acoustic journeys. Instead of remaining motionless at the center, the virtual listener walks, tours, or navigates along a path through the audio landscape.

![Listener Automation View](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/03_listener_automation_view.png)

---

## 🧭 Creating & Editing Motion Paths

Switch to the **Automation** view by clicking the top navigation tab or pressing `F2`.

### Waypoint Editing Controls:
- **Add Waypoint**: `Left-Click` anywhere inside the radar boundary ring to create a numbered waypoint ($\#1, \#2, \#3, \dots$).
- **Move Waypoint**: `Click and Drag` an existing waypoint circle to reposition it.
- **Delete Waypoint**: `Right-Click` any waypoint to remove it from the path.
- **Clear Entire Path**: Click the **Clear** button (with the trash can icon) in the automation toolbar.

---

## ⚙️ Path Modes & Direction

| Path Mode | Description |
| :--- | :--- |
| **Closed Loop** | The listener completes the trajectory and seamlessly wraps back to Waypoint $\#1$ from the final waypoint, creating an endless circular journey. |
| **Open Path (Ping-Pong)** | The listener travels to the final waypoint, reverses direction smoothly, and returns back along the same path. |
| **One-Way Path** | The listener journeys from start to end and stops at the destination. |

---

## 🏃 Real-World Speed & Live Statistics

The automation toolbar provides precise velocity control and live telemetry:

- **Speed Regulation**:
  - Direct speed spinbox & incremental `+` / `-` buttons in meters per second ($m/s$).
  - Real-time speedometer conversion to kilometers per hour ($km/h$) for intuitive real-world speed perception (e.g. $1.4\text{ m/s} \approx 5.0\text{ km/h}$ for natural walking, $3.0\text{ m/s} \approx 10.8\text{ km/h}$ for jogging).
- **Live Path Telemetry**:
  - **Waypoint Count**: Total number of active route points.
  - **Total Distance**: Cumulative track distance measured in meters ($m$).
  - **Estimated Lap Duration**: Total travel time calculated automatically based on the current speed ($seconds$ / $minutes$).

---

## 🔄 Dynamic Acoustic Doppler & Spatial Update

As the listener moves along the path during live playback or surround export:
- Azimuth, elevation, and distance to all stationary sound sources are recalculated at 60 Hz / audio buffer rate.
- Volume attenuation and stereo/surround panning automatically shift as the listener walks toward, passes, or recedes from each sound source.

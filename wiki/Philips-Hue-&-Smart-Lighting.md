# 💡 Philips Hue & Smart Ambient Lighting

**3D Soundscape Studio** and the **3D Ambient Player** feature native smart lighting synchronization, allowing physical room lighting to react dynamically to your virtual soundscape.

Supported backends include:
1. **Direct Philips Hue Bridge**: Local LAN control with zero cloud dependencies.
2. **Home Assistant**: REST API control over any smart bulb or LED strip connected to Home Assistant.

---

## 🌈 Supported Light Effects

| Effect | Description | Trigger |
| :--- | :--- | :--- |
| **⚡ Instant Lightning Flash** | Flashes lights to bright cool-white ($6500\text{K}$) with $0\text{ms}$ transition time, followed by automatic recovery to baseline ambient state. | Stems assigned to lightning / thunder cues. |
| **🔥 Hearth Fire Flicker** | Subtle, organic candle/fireplace brightness and warm-amber chromaticity fluctuation. | Campfire, torch, or fireplace stems. |
| **🚶 Listener Proximity Dimming** | Dynamically dims or brightens lamps as the virtual listener moves closer or further from spatial emitters. | Listener motion path on automation canvas. |

---

## 🌉 Connecting to a Philips Hue Bridge

### 1. Open the Visual Ambient Editor
- In the Studio DAW: Click **Tools > Visual Ambient Lighting (Hue & HA)...** (`F7`).
- In the Player: Click the **Light** button in the header bar.

### 2. Auto-Discovery or Manual IP
- Click **🔍 Auto-Discover Bridge**. The client queries local discovery endpoints to locate your Bridge IP automatically.
- Alternatively, type your Bridge's local IP address manually (e.g. `192.168.1.50`).

### 3. Push-Link Pairing
1. Press the large circular button on top of your physical Philips Hue Bridge.
2. Within 30 seconds, click **Pair with Bridge (Push Link Button)** in the dialog.
3. The client polls the bridge, generates a persistent API username/token, and saves it securely to `data/settings.json`.

### 4. Fetching & Assigning Lights
1. Click **Fetch Lights**. A table of all detected Hue lights will appear.
2. Assign role mappings:
   - **Lightning Flash Light**: Select the fixture to strobe during thunder strikes.
   - **Hearth / Fireplace Light**: Select the fixture to flicker during ambient fire scenes.
3. Click **⚡ Test Flash** to verify connection instantly.

---

## 🔬 Color Math: CIE 1931 xy Chromaticity

Philips Hue bulbs use the **CIE 1931 color space** $(x, y)$ rather than standard RGB or HSV:
- The Hue client implements exact inverse sRGB companding and transformation matrices to convert project color settings into Hue D65 gamut coordinates.
- Transition times are controlled in increments of $100\text{ms}$, with lightning strikes using `transitiontime: 0` for authentic, instantaneous flashes.

---

## 🏠 Home Assistant Alternative

If your smart lighting is managed through Home Assistant:
1. In the Visual Ambient Editor, switch the backend dropdown to **Home Assistant**.
2. Enter your Home Assistant server URL (e.g. `http://homeassistant.local:8123`).
3. Enter your Long-Lived Access Token.
4. Specify the target light entity (e.g. `light.living_room_lamp`).

# 🤖 AI Audio Generation (`audio.cpp`)

3D Soundscape Studio integrates local AI audio generation, allowing you to instantly create ambient sound effects, drones, and foley directly from text prompts without relying on cloud services.

This is powered by the open-source [audio.cpp](https://github.com/0xShug0/audio.cpp) C++ inference engine, utilizing GGUF models directly on your hardware (CPU/GPU) for privacy-preserving, lightning-fast audio synthesis.

## 🛠️ Setup & Configuration

To use the AI generation features, you need to configure the native engine paths in the Studio preferences.

1. **Download audio.cpp:** Obtain the compiled binaries for your OS from the `audio.cpp` releases page.
2. **Download a GGUF Audio Model:** You need an AudioGen model converted to GGUF format (e.g., `audiogen-medium.gguf`).
3. **Configure Preferences:**
   - Open **File > Preferences** (`Ctrl+,`)
   - Go to the **System Paths** tab.
   - Set **audio.cpp Binary Path** to the executable (`audio.exe` on Windows).
   - Set **GGUF Model Path for audio.cpp** to the `.gguf` file you downloaded.
   - Click **Save Preferences**.

## 🎨 Generating Sounds

Once configured, the AI is fully integrated into the Sample Browser!

1. Open the **Sample Browser** via the Soundscape Library or by clicking **Browse** when adding a track.
2. Switch to the **🤖 AI Generation** tab.
3. Enter a descriptive text prompt (e.g., *"distant thunder rolling over mountains"*, *"cyberpunk city traffic loop"*).
4. Set the **Target Duration** (in seconds).
5. Click **Generate Audio**.

The engine will spawn a background native process and display a progress bar. Once complete, the generated `.wav` file is automatically imported into your custom sample library, categorized under `AIGen`, and ready to be dragged directly onto your 3D spatial radar canvas!

## 💡 Prompting Tips

- **Be Descriptive:** Include adjectives about distance, texture, and environment (e.g., "heavy rain on tin roof", "muffled underwater hum").
- **Specify Actions:** Describe the physical interaction (e.g., "wooden door creaking open slowly").
- **Avoid Musical Notes:** AudioGen models are typically trained on environmental sounds, sound effects, and foley, rather than melodies or instruments.

---
*Note: AI generation speed depends on your hardware (CPU/GPU) and the size of the GGUF model used.*

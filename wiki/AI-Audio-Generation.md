# 🤖 AI Audio Generation (`audio.cpp`)

3D Soundscape Studio integrates local AI audio generation, allowing you to instantly create ambient sound effects, drones, and foley directly from text prompts without relying on cloud services.

This is powered by the open-source [audio.cpp](https://github.com/0xShug0/audio.cpp) C++ inference engine, utilizing GGUF models directly on your hardware (CPU/GPU) for privacy-preserving, lightning-fast audio synthesis.

## 🛠️ Setup & Configuration

You can install all required dependencies directly inside the application with 1-click on **Windows**, **Linux**, and **macOS**!

### ⚡ 1-Click Auto-Installation (Recommended)
1. Open **File > Preferences** (`Ctrl+,`).
2. In the **Display & API** tab, click **`⬇️ Auto-Install`** next to:
   - **audio.cpp Executable Path**: Automatically detects your platform (Windows x64 Vulkan/CPU, macOS Apple Silicon Metal / Intel, or Linux Vulkan/CPU) and downloads + unpacks the appropriate native binary.
   - **GGUF Model Path**: Automatically downloads the recommended high-fidelity `audiogen-medium.q8_0.gguf` model straight from HuggingFace to your local storage.
3. In the **FFmpeg** tab, click **`⬇️ Auto-Install`** to automatically download the static FFmpeg package tailored for your operating system.
4. The studio automatically configures permissions (`chmod +x`), clears macOS quarantine tags, sets paths, and saves your settings!

### 🔧 Manual Setup (Alternative)
1. **audio.cpp:** Obtain compiled binaries for your OS (Windows `audio.exe` / `audiocpp_cli.exe`, Linux/macOS `audio` / `audiocpp_cli`) from the [audio.cpp releases page](https://github.com/0xShug0/audio.cpp/releases).
2. **GGUF Audio Model:** Download an AudioGen model in `.gguf` format (e.g. `audiogen-medium.q8_0.gguf`).
3. Set the respective paths in **File > Preferences** and click **Save Preferences**.

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

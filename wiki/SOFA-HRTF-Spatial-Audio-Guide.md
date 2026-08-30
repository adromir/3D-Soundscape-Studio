# 🎧 SOFA HRTF & Spatial Audio Guide

This guide explains what **SOFA** files are, how **Head-Related Transfer Functions (HRTF)** enable 3D audio through regular stereo headphones, how 3D Soundscape Studio utilizes them, and where you can download free, high-quality SOFA profiles.

![Surround & SOFA Export Dialog](https://raw.githubusercontent.com/adromir/3D-Soundscape-Studio/main/docs/images/06_export_surround_dialog.png)

---

## 🧠 What is HRTF and Why Does it Matter?

When you listen to sounds in the physical world, your ears don't just register volume; your brain determines the exact 3D position (front, back, above, below, left, right) using three physiological cues:

1. **Interaural Time Difference (ITD)**:
   - A sound coming from the left reaches your left ear slightly earlier than your right ear (~0.6 milliseconds).
2. **Interaural Level Difference (ILD)**:
   - Your head acts as an acoustic barrier ("head shadow"), dampening high frequencies in the opposite ear.
3. **Pinna & Torso Spectral Filtering**:
   - The folds of your outer ear (**pinna**), your shoulders, and torso reflect and filter specific frequencies depending on whether the sound comes from **above**, **below**, **in front**, or **behind** you.

A **Head-Related Transfer Function (HRTF)** is a mathematical filter measured with microscopic microphones inside ears that captures these exact spectral changes for every angle in 3D space. When an audio track is processed with an HRTF, **standard stereo headphones trick your brain into hearing full 3D spherical sound**!

---

## 📦 What is a SOFA File?

**SOFA** stands for **Spatially Oriented Format for Acoustics** (formalized as the **AES69** audio engineering standard).

- **Standardized File Format**: A SOFA file (`.sofa`) contains thousands of measured Head-Related Impulse Responses (HRIR) at fine angular resolutions (e.g. every $1^\circ$ to $5^\circ$ of azimuth and elevation).
- **Universal Compatibility**: Used across VR, cinema post-production, spatial audio research, and high-performance audio engines (including FFmpeg's `sofalizer` / `libmysofa` engine used by 3D Soundscape Studio).

---

## 🛠️ How 3D Soundscape Studio Uses SOFA

During real-time preview and **Offline Surround Export (`Ctrl + E`)**:
1. 3D Soundscape Studio calculates the exact polar coordinates $(r, \theta, \phi)$ of every sound source and the virtual listener along their motion paths.
2. The offline audio renderer loads the selected `.sofa` profile.
3. FFmpeg's convolution engine dynamically interpolates impulse response filters from the SOFA dataset, rendering binaural audio masters with elevation cues (rain falling from above, birds circling overhead).

---

## 🌐 Where to Download Free SOFA Files

Because every human ear has a unique shape, different HRTF profiles may sound more natural to different listeners. You can download and experiment with thousands of free, standardized `.sofa` files from reputable acoustic research institutions:

### 1. [SOFA Acoustics Official Database](https://www.sofacoustics.org/data/database/)
The official repository maintained by the Austrian Academy of Sciences and AES:
- **Available Profiles**: KEMAR mannequin, IRCAM Listen, ARI (Acoustics Research Institute), HUTUBS, and CIPIC databases.
- **Format**: Ready-to-use `.sofa` downloads.

### 2. [SADIE II Spatial Audio Database (University of York)](https://www.york.ac.uk/sadie-project/database.html)
High-precision anechoic measurements from the University of York:
- **Available Profiles**: 20 distinct human subjects + KEMAR dummy heads with various acoustic ear sizes.
- **Recommended**: *Subject 002* and *KEMAR (Large Pinnae)*.

### 3. [IRCAM LISTEN HRTF Database](https://recherche.ircam.fr/equipes/salles/listen/)
Measured in the famous anechoic chambers at IRCAM Paris:
- **Available Profiles**: 51 individual human subjects measured at 187 discrete spatial positions.
- **Recommended**: `IRC_1002_C.sofa` and `IRC_1008_C.sofa` (widely regarded for natural sound externalization).

### 4. [HUTUBS Database (TU Berlin)](https://depositonce.tu-berlin.de/items/d74945fe-520e-4ab8-9ffb-a25e1fc414c7)
Modern database by Technische Universität Berlin:
- **Available Profiles**: 96 measured subjects with 3D mesh head scans and diffuse-field equalized HRIR files.

---

## 🚀 How to Use a SOFA File in 3D Soundscape Studio

1. **Download** a `.sofa` file (e.g. `IRC_1002_C.sofa` or `KEMAR.sofa`) and save it anywhere on your computer.
2. In 3D Soundscape Studio, open your soundscape project.
3. Click **Export** in the top transport bar or press `Ctrl + E`.
4. In the Export Dialog:
   - Set **Target Speaker Layout** to `Binaural (HRTF / Headphones)`.
   - Click **Browse...** next to **HRTF SOFA File (Optional)**.
   - Select your downloaded `.sofa` file.
   - Choose your destination output file (`.wav`, `.flac`, etc.).
5. Click **Start Export**.

> 💡 **Tip**: If you leave the SOFA file field blank (Default), 3D Soundscape Studio automatically uses FFmpeg's high-quality built-in generic KEMAR / MIT HRTF profile.

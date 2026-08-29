# 🎧 3D Ambient Mixer - Lastenheft, Pflichtenheft & Dokumentation

![Author](https://img.shields.io/badge/Author-Adromir-blue)
![Source](https://img.shields.io/badge/Source-GitHub-lightgrey?logo=github)
![Repository](https://img.shields.io/badge/Repo-https%3A%2F%2Fgithub.com%2Fadromir-green)

Projekte: https://github.com/adromir

---

## Teil 1: Lastenheft (Anforderungen)

### 1. Projektziele

* **Ziel:** Entwicklung einer eigenständigen Desktop-Applikation zum Importieren, räumlichen Abmischen (3D/Binaural) und Exportieren von Audio-Soundscapes.
* **Plattformen:** Windows, Linux.
* **Sprachen:** Benutzeroberfläche in Deutsch und Englisch (Internationalisierung). Quelltext, Ausgaben und Kommentare ausschließlich in Englisch.

### 2. Funktionale Anforderungen

* **Bibliotheksverwaltung:** Lokales Scannen und Verwalten von Audio-Dateien (Ogg, MP3, WAV).
* **Mischer-UI:** Visuelle Platzierung von Soundquellen im virtuellen 3D-Raum (Azimut, Elevation, Distanz) relativ zu einem zentralen Listener-Objekt.
* **Akustische Parameter:** Pro Spur einstellbare Lautstärke und optionale Zuweisung von Impulsantworten (Convolution Reverb).
* **Wiedergabe:** Vorhören der Szene im Editor-Modus.
* **Export:** Schneller Offline-Export der Szene als binaurale Stereo-Audiodatei.
* **Import:** Direkter Download von Soundscapes über integriertes Web-Scraping. Als zu scrapende Quelle dient die Webseite https://www.ambient-mixer.com/ . Ein Beispiel um die vorhandenen Dateien downzuloaden findet sich in der downloader.ps1 in diesem Verzeichnis

### 3. Nicht-funktionale Anforderungen

* **Performance:** Der Export muss zwingend schneller als in Echtzeit (Offline-Rendering) ablaufen.
* **Security by Design:** Strikte Validierung importierter Dateien (Abgleich der Dateiendung mit Magic Bytes) zur Verhinderung von Schadcode-Ausführung und Path-Traversal.
* **Hardware-Ausrichtung:** Konzeption für performante Ausführung auf modernen Multicore-Systemen (Referenzsystem: AMD Ryzen 9 9950x3d, AMD Radeon 9060XT).

### 4. Ausschlusskriterien (Out of Scope)

* KI-gestützte Quellentrennung (Source Separation) von Audio-Dateien.

---

## Teil 2: Pflichtenheft (Technische Umsetzung)

### 1. Systemarchitektur & Tech-Stack

* **Frontend & Steuerung:** Godot Engine 4.x (GDScript) für Benutzeroberfläche, Szenenverwaltung und Parameter-Generierung.
* **Audio-Backend (Export):** FFmpeg (als externe Binärdatei, kompiliert mit `--enable-libmysofa`) für das rechenintensive, asynchrone Offline-Rendering der Audiospuren.
* **Raumklang-Daten:** Nutzung normierter `.sofa`-Dateien für die Head-Related Transfer Functions (HRTF).

### 2. Datenstrukturen & Schnittstellen

* **Projektformat (`.ambmix`):** Speicherung von Mix-Metadaten (Referenzpfade, Lautstärken, 3D-Koordinaten) als serialisiertes JSON- oder Godot-`ConfigFile`.
* **FFmpeg-Kommunikation:** Asynchroner Aufruf der FFmpeg-Binärdatei über Godots `OS.execute()` innerhalb eines `WorkerThreadPool`-Tasks. Übergabe der Audio-Parameter als dynamisch generierter `-filter_complex`-String.

### 3. Implementierungsdetails (Kernfunktionen)

* **Sicherer Import:** Auslesen der ersten 3-4 Bytes (`FileAccess.get_buffer(4)`) zur Validierung der Formatsignaturen (Ogg, MP3, WAV), unabhängig von der vom OS gemeldeten Dateiendung.
* **Export-Pipeline (Filtergraph):**
  1. Einlesen der Einzelspuren mit endlosem Loop (`-stream_loop -1`).
  2. Modifikation: `volume` (Pegel) -> optional `afir` (Faltungshall über Impulsantwort).
  3. Spatialisation: `pan` (Stereo-Zwang) -> `sofalizer` (Binaurale 3D-Positionierung via Azimut/Elevation).
  4. Summierung: `amix` (Zusammenführung aller binauralen Spuren) -> `dynaudnorm` (Dynamische Normalisierung zur Vermeidung von Clipping).
* **Ressourcenmanagement:** FFmpeg-Prozesse müssen sauber beendet oder abgebrochen werden können, falls der Nutzer den Export abbricht.

### 4. Qualitätsstandards & Code-Richtlinien

* **Einrückung:** Ausschließlich Tabulatoren (Keine Mischung mit Leerzeichen).
* **Compiler/Engine:** Alle Warnungen und Fehler sind architektonisch zu beheben; keine Unterdrückung von Warnungen.
* **Prinzipien:** Minimal nötiger Code. Keine spekulativen Features. UI-Elemente und Bezeichner erhalten aussagekräftige Namen.

---

## Teil 3: Quelltexte

### AudioImporter.gd

```gdscript
class_name AudioImporter
extends RefCounted

# Author: Adromir
# Repository: [https://github.com/adromir](https://github.com/adromir)

const ALLOWED_EXTENSIONS: PackedStringArray = ["ogg", "mp3", "wav"]
const MAGIC_BYTES_OGG: PackedByteArray = [0x4F, 0x67, 0x67, 0x53]
const MAGIC_BYTES_WAV: PackedByteArray = [0x52, 0x49, 0x46, 0x46]
const MAGIC_BYTES_MP3: PackedByteArray = [0x49, 0x44, 0x33]

func validate_and_import(file_path: String) -> bool:
    if file_path.contains("..") or file_path.contains("~"):
        printerr("Security Error: Path traversal attempt detected.")
        return false

    var extension: String = file_path.get_extension().to_lower()
    if not ALLOWED_EXTENSIONS.has(extension):
        printerr("Security Error: Invalid file extension.")
        return false

    var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        printerr("Error: Cannot open file.")
        return false

    var header: PackedByteArray = file.get_buffer(4)
    file.close()

    var is_valid_header: bool = false
    if extension == "ogg" and header.slice(0, 4) == MAGIC_BYTES_OGG:
        is_valid_header = true
    elif extension == "wav" and header.slice(0, 4) == MAGIC_BYTES_WAV:
        is_valid_header = true
    elif extension == "mp3" and header.slice(0, 3) == MAGIC_BYTES_MP3:
        is_valid_header = true

    if not is_valid_header:
        printerr("Security Error: Magic bytes do not match file extension.")
        return false

    return true
```

### FfmpegExporter.gd

```gdscript
class_name FfmpegExporter
extends RefCounted

# Author: Adromir
# Repository: [https://github.com/adromir](https://github.com/adromir)

signal export_completed(exit_code: int, output_path: String)
signal export_failed(reason: String)

struct SoundTrack:
    var file_path: String
    var volume: float
    var azimuth: float
    var elevation: float
    var impulse_response_path: String

func start_offline_render(tracks: Array[SoundTrack], sofa_path: String, duration_seconds: int, output_path: String) -> void:
    if tracks.is_empty():
        export_failed.emit("No audio tracks provided for export.")
        return

    var ffmpeg_path: String = OS.get_executable_path().get_base_dir().path_join("ffmpeg")
    if OS.get_name() == "Windows":
        ffmpeg_path += ".exe"

    if not FileAccess.file_exists(ffmpeg_path):
        export_failed.emit("FFmpeg binary not found.")
        return

    var args: PackedStringArray = PackedStringArray()
    var filter_complex: String = ""
    var mix_inputs: String = ""

    for track in tracks:
        args.append("-stream_loop")
        args.append("-1")
        args.append("-i")
        args.append(ProjectSettings.globalize_path(track.file_path))

        if not track.impulse_response_path.is_empty():
            args.append("-i")
            args.append(ProjectSettings.globalize_path(track.impulse_response_path))

    var current_stream_index: int = 0

    for i in range(tracks.size()):
        var track: SoundTrack = tracks[i]
        var process_label: String = "[%d:a]" % current_stream_index
        current_stream_index += 1

        if not track.impulse_response_path.is_empty():
            var ir_label: String = "[%d:a]" % current_stream_index
            var reverb_label: String = "[reverb%d]" % i
            filter_complex += "%s%safir=dry=10:wet=10%s;" % [process_label, ir_label, reverb_label]
            process_label = reverb_label
            current_stream_index += 1

        var vol_label: String = "[vol%d]" % i
        var pan_label: String = "[pan%d]" % i
        var spatial_label: String = "[3d_%d]" % i

        filter_complex += "%svolume=volume=%f%s;" % [process_label, track.volume, vol_label]
        filter_complex += "%span=stereo|c0=c0|c1=c0%s;" % [vol_label, pan_label]

        var safe_sofa_path: String = ProjectSettings.globalize_path(sofa_path).replace("\\", "/")
        filter_complex += "%ssofalizer=sofa='%s':speakers=FL %f %f|FR %f %f%s;" % [
            pan_label, 
            safe_sofa_path, 
            track.azimuth, 
            track.elevation,
            track.azimuth,
            track.elevation,
            spatial_label
        ]

        mix_inputs += spatial_label

    filter_complex += "%samix=inputs=%d,dynaudnorm[out]" % [mix_inputs, tracks.size()]

    args.append("-filter_complex")
    args.append(filter_complex)
    args.append("-map")
    args.append("[out]")
    args.append("-t")
    args.append(str(duration_seconds))
    args.append("-y")
    args.append(ProjectSettings.globalize_path(output_path))

    WorkerThreadPool.submit_task(func():
        var output: Array = []
        var exit_code: int = OS.execute(ffmpeg_path, args, output, true, false)

        if exit_code == 0:
            export_completed.emit(exit_code, output_path)
        else:
            export_failed.emit("Exit code %d" % exit_code)
    )
```

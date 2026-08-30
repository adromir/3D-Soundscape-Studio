class_name LocalizationData
extends RefCounted

# Author: Adromir
# Repository: https://github.com/adromir

enum Language {
	EN,
	DE,
	FR,
	ES,
	IT
}

static var current_language: Language = Language.EN

const LANGUAGE_NAMES: Dictionary = {
	Language.EN: "English",
	Language.DE: "Deutsch",
	Language.FR: "Français",
	Language.ES: "Español",
	Language.IT: "Italiano"
}

const LANGUAGE_CODES: Dictionary = {
	Language.EN: "EN",
	Language.DE: "DE",
	Language.FR: "FR",
	Language.ES: "ES",
	Language.IT: "IT"
}

const TRANSLATIONS: Dictionary = {
	"APP_TITLE": {
		Language.EN: "3D Soundscape Studio",
		Language.DE: "3D Soundscape Studio",
		Language.FR: "3D Soundscape Studio",
		Language.ES: "3D Soundscape Studio",
		Language.IT: "3D Soundscape Studio"
	},
	"MENU_FILE": {
		Language.EN: "File",
		Language.DE: "Datei",
		Language.FR: "Fichier",
		Language.ES: "Archivo",
		Language.IT: "File"
	},
	"MENU_EDIT": {
		Language.EN: "Edit",
		Language.DE: "Bearbeiten",
		Language.FR: "Édition",
		Language.ES: "Editar",
		Language.IT: "Modifica"
	},
	"MENU_VIEW": {
		Language.EN: "View",
		Language.DE: "Ansicht",
		Language.FR: "Affichage",
		Language.ES: "Ver",
		Language.IT: "Visualizza"
	},
	"MENU_PLAYBACK": {
		Language.EN: "Playback",
		Language.DE: "Wiedergabe",
		Language.FR: "Lecture",
		Language.ES: "Reproducción",
		Language.IT: "Riproduzione"
	},
	"MENU_HELP": {
		Language.EN: "Help",
		Language.DE: "Hilfe",
		Language.FR: "Aide",
		Language.ES: "Ayuda",
		Language.IT: "Aiuto"
	},
	"BTN_PLAY": {
		Language.EN: "Play",
		Language.DE: "Abspielen",
		Language.FR: "Lecture",
		Language.ES: "Reproducir",
		Language.IT: "Riproduci"
	},
	"BTN_PAUSE": {
		Language.EN: "Pause",
		Language.DE: "Pause",
		Language.FR: "Pause",
		Language.ES: "Pausa",
		Language.IT: "Pausa"
	},
	"BTN_STOP": {
		Language.EN: "Stop",
		Language.DE: "Stopp",
		Language.FR: "Arrêt",
		Language.ES: "Detener",
		Language.IT: "Stop"
	},
	"BTN_NEW": {
		Language.EN: "New",
		Language.DE: "Neu",
		Language.FR: "Nouveau",
		Language.ES: "Nuevo",
		Language.IT: "Nuovo"
	},
	"BTN_OPEN": {
		Language.EN: "Open",
		Language.DE: "Öffnen",
		Language.FR: "Ouvrir",
		Language.ES: "Abrir",
		Language.IT: "Apri"
	},
	"BTN_SAVE": {
		Language.EN: "Save",
		Language.DE: "Speichern",
		Language.FR: "Sauvegarder",
		Language.ES: "Guardar",
		Language.IT: "Salva"
	},
	"BTN_EXPORT": {
		Language.EN: "Export",
		Language.DE: "Export",
		Language.FR: "Exporter",
		Language.ES: "Exportar",
		Language.IT: "Esporta"
	},
	"BTN_DOWNLOAD": {
		Language.EN: "Download & Import",
		Language.DE: "Herunterladen & Importieren",
		Language.FR: "Télécharger & Importer",
		Language.ES: "Descargar e importar",
		Language.IT: "Scarica e importa"
	},
	"DLG_DOWNLOAD_TITLE": {
		Language.EN: "Ambient Mixer Downloader & Library",
		Language.DE: "Ambient-Mixer Downloader & Bibliothek",
		Language.FR: "Téléchargeur et bibliothèque Ambient-Mixer",
		Language.ES: "Descargador y biblioteca de Ambient-Mixer",
		Language.IT: "Downloader e libreria di Ambient-Mixer"
	},
	"BTN_IMPORT_AUDIO": {
		Language.EN: "Import Audio...",
		Language.DE: "Audio importieren...",
		Language.FR: "Importer audio...",
		Language.ES: "Importar audio...",
		Language.IT: "Importa audio..."
	},
	"BTN_LOAD": {
		Language.EN: "Load Audio...",
		Language.DE: "Audiodatei laden...",
		Language.FR: "Charger audio...",
		Language.ES: "Cargar audio...",
		Language.IT: "Carica audio..."
	},
	"TAB_SAMPLES": {
		Language.EN: "Sounds Library",
		Language.DE: "Sound-Bibliothek",
		Language.FR: "Bibliothèque de Sons",
		Language.ES: "Biblioteca de Sonidos",
		Language.IT: "Libreria Suoni"
	},
	"BTN_IMPORT": {
		Language.EN: "Import Audio...",
		Language.DE: "Audio importieren...",
		Language.FR: "Importer audio...",
		Language.ES: "Importar audio...",
		Language.IT: "Importa audio..."
	},
	"BTN_REFRESH": {
		Language.EN: "Refresh",
		Language.DE: "Aktualisieren",
		Language.FR: "Actualiser",
		Language.ES: "Actualizar",
		Language.IT: "Aggiorna"
	},
	"BTN_ADD_CATEGORY": {
		Language.EN: "Add Category",
		Language.DE: "Kategorie hinzufügen",
		Language.FR: "Ajouter catégorie",
		Language.ES: "Añadir categoría",
		Language.IT: "Aggiungi categoria"
	},
	"BTN_SET_COVER": {
		Language.EN: "Cover",
		Language.DE: "Titelbild",
		Language.FR: "Pochette",
		Language.ES: "Portada",
		Language.IT: "Copertina"
	},
	"TOOLTIP_SET_COVER": {
		Language.EN: "Select Cover Image for Soundscape",
		Language.DE: "Titelbild für Soundscape auswählen",
		Language.FR: "Sélectionner une image de couverture",
		Language.ES: "Seleccionar imagen de portada",
		Language.IT: "Seleziona immagine di copertina"
	},
	"BTN_LIBRARY": {
		Language.EN: "Library",
		Language.DE: "Bibliothek",
		Language.FR: "Bibliothèque",
		Language.ES: "Biblioteca",
		Language.IT: "Libreria"
	},
	"BTN_ADD_TRACK": {
		Language.EN: "+ Add Audio Track",
		Language.DE: "+ Audiospur hinzufügen",
		Language.FR: "+ Ajouter une piste",
		Language.ES: "+ Añadir pista",
		Language.IT: "+ Aggiungi traccia"
	},
	"HEADER_TRACKS": {
		Language.EN: "Audio Stems / Tracks",
		Language.DE: "Audiospuren / Stems",
		Language.FR: "Pistes audio",
		Language.ES: "Pistas de audio",
		Language.IT: "Tracce audio"
	},
	"HEADER_INSPECTOR": {
		Language.EN: "Track Inspector",
		Language.DE: "Spur-Eigenschaften",
		Language.FR: "Inspecteur de piste",
		Language.ES: "Inspector de pista",
		Language.IT: "Ispettore traccia"
	},
	"LABEL_MASTER_VOL": {
		Language.EN: "Master Volume",
		Language.DE: "Gesamtlautstärke",
		Language.FR: "Volume principal",
		Language.ES: "Volumen maestro",
		Language.IT: "Volume principale"
	},
	"LABEL_OUTPUT_FORMAT": {
		Language.EN: "Speaker Layout",
		Language.DE: "Lautsprecher-Setup",
		Language.FR: "Configuration haut-parleurs",
		Language.ES: "Configuración altavoces",
		Language.IT: "Configurazione altoparlanti"
	},
	"LABEL_SPATIAL_MODE": {
		Language.EN: "Routing Mode",
		Language.DE: "Routing-Modus",
		Language.FR: "Mode de routage",
		Language.ES: "Modo de enrutamiento",
		Language.IT: "Modalità di routing"
	},
	"MODE_POINT_3D": {
		Language.EN: "3D Point Source",
		Language.DE: "3D-Punktquelle",
		Language.FR: "Source ponctuelle 3D",
		Language.ES: "Fuente puntual 3D",
		Language.IT: "Sorgente puntiforme 3D"
	},
	"MODE_OMNIPRESENT": {
		Language.EN: "Omnipresent (All Around)",
		Language.DE: "Omnipräsent (Alle Seiten)",
		Language.FR: "Omniprésent (Ambiance)",
		Language.ES: "Omnipresente (Ambiente)",
		Language.IT: "Onnipresente (Ambiente)"
	},
	"MODE_MULTI_CH": {
		Language.EN: "Multi-Channel Specific",
		Language.DE: "Mehrkanal-Zuweisung",
		Language.FR: "Multicanal spécifique",
		Language.ES: "Multicanal específico",
		Language.IT: "Multicanale specifico"
	},
	"LABEL_AZIMUTH": {
		Language.EN: "Azimuth (°)",
		Language.DE: "Azimut (°)",
		Language.FR: "Azimut (°)",
		Language.ES: "Azimut (°)",
		Language.IT: "Azimut (°)"
	},
	"LABEL_ELEVATION": {
		Language.EN: "Elevation (°)",
		Language.DE: "Elevation (°)",
		Language.FR: "Élévation (°)",
		Language.ES: "Elevación (°)",
		Language.IT: "Elevazione (°)"
	},
	"LABEL_DISTANCE": {
		Language.EN: "Distance (m)",
		Language.DE: "Distanz (m)",
		Language.FR: "Distance (m)",
		Language.ES: "Distancia (m)",
		Language.IT: "Distanza (m)"
	},
	"LABEL_MOVEMENT_PATTERN": {
		Language.EN: "Movement Pattern",
		Language.DE: "Bewegungsmuster",
		Language.FR: "Motif de mouvement",
		Language.ES: "Patrón de movimiento",
		Language.IT: "Modello di movimento"
	},
	"MOV_NONE": {
		Language.EN: "Static (None)",
		Language.DE: "Statisch (Keine)",
		Language.FR: "Statique",
		Language.ES: "Estático",
		Language.IT: "Statico"
	},
	"MOV_PING_PONG_LR": {
		Language.EN: "Left ⟷ Right (Ping-Pong)",
		Language.DE: "Links ⟷ Rechts (Ping-Pong)",
		Language.FR: "Gauche ⟷ Droite (Ping-Pong)",
		Language.ES: "Izquierda ⟷ Derecha (Ping-Pong)",
		Language.IT: "Sinistra ⟷ Destra (Ping-Pong)"
	},
	"MOV_ONE_WAY_LR": {
		Language.EN: "Left ➔ Right (One-Way)",
		Language.DE: "Links ➔ Rechts (Einweg)",
		Language.FR: "Gauche ➔ Droite (Sens unique)",
		Language.ES: "Izquierda ➔ Derecha (Unidireccional)",
		Language.IT: "Sinistra ➔ Destra (Senso unico)"
	},
	"MOV_PING_PONG_FB": {
		Language.EN: "Front ⟷ Back (Ping-Pong)",
		Language.DE: "Vorne ⟷ Hinten (Ping-Pong)",
		Language.FR: "Avant ⟷ Arrière (Ping-Pong)",
		Language.ES: "Frente ⟷ Atrás (Ping-Pong)",
		Language.IT: "Avanti ⟷ Dietro (Ping-Pong)"
	},
	"MOV_ONE_WAY_FB": {
		Language.EN: "Front ➔ Back (One-Way)",
		Language.DE: "Vorne ➔ Hinten (Einweg)",
		Language.FR: "Avant ➔ Arrière (Sens unique)",
		Language.ES: "Frente ➔ Atrás (Unidireccional)",
		Language.IT: "Avanti ➔ Dietro (Senso unico)"
	},
	"MOV_RANDOM_WALK": {
		Language.EN: "Random Walk (Continuous)",
		Language.DE: "Zufallsbewegung (Kontinuierlich)",
		Language.FR: "Marche aléatoire",
		Language.ES: "Paseo aleatorio",
		Language.IT: "Percorso casuale"
	},
	"LABEL_MOV_TIMING": {
		Language.EN: "Movement Timing",
		Language.DE: "Bewegungszeitpunkt",
		Language.FR: "Timing du mouvement",
		Language.ES: "Sincronización de movimiento",
		Language.IT: "Tempistica del movimento"
	},
	"TIMING_IN_FLIGHT": {
		Language.EN: "Continuous (During Play)",
		Language.DE: "Während Wiedergabe (Flugbahn)",
		Language.FR: "En continu pendant la lecture",
		Language.ES: "Continuo durante reproducción",
		Language.IT: "Continuo durante la riproduzione"
	},
	"TIMING_JUMP": {
		Language.EN: "Jump Per Trigger",
		Language.DE: "Sprung pro Trigger",
		Language.FR: "Saut par déclenchement",
		Language.ES: "Salto por disparo",
		Language.IT: "Salto per trigger"
	},
	"LABEL_TRIGGER_MODE": {
		Language.EN: "Playback Trigger Mode",
		Language.DE: "Wiedergabe-Modus",
		Language.FR: "Mode de déclenchement",
		Language.ES: "Modo de disparo",
		Language.IT: "Modalità di trigger"
	},
	"TRIG_CONTINUOUS": {
		Language.EN: "Continuous Loop",
		Language.DE: "Endlosschleife",
		Language.FR: "Boucle continue",
		Language.ES: "Bucle continuo",
		Language.IT: "Loop continuo"
	},
	"TRIG_FIXED": {
		Language.EN: "Fixed Interval",
		Language.DE: "Festes Intervall",
		Language.FR: "Intervalle fixe",
		Language.ES: "Intervalo fijo",
		Language.IT: "Intervallo fisso"
	},
	"TRIG_RANDOM": {
		Language.EN: "Random Interval (Density)",
		Language.DE: "Zufallsintervall (Dichte)",
		Language.FR: "Intervalle aléatoire (Densité)",
		Language.ES: "Intervalo aleatorio (Densidad)",
		Language.IT: "Intervallo casuale (Densità)"
	},
	"LABEL_INTERVAL_SEC": {
		Language.EN: "Interval (Seconds)",
		Language.DE: "Intervall (Sekunden)",
		Language.FR: "Intervalle (Secondes)",
		Language.ES: "Intervalo (Segundos)",
		Language.IT: "Intervallo (Secondi)"
	},
	"LABEL_DENSITY": {
		Language.EN: "Triggers per Window",
		Language.DE: "Auslösungen pro Zeitfenster",
		Language.FR: "Déclenchements par fenêtre",
		Language.ES: "Disparos por ventana",
		Language.IT: "Trigger per finestra"
	},
	"LABEL_COOLDOWN": {
		Language.EN: "Min. Cooldown / Block (s)",
		Language.DE: "Mindest-Pause / Blockwert (s)",
		Language.FR: "Temps de pause min. (s)",
		Language.ES: "Pausa mínima (s)",
		Language.IT: "Pausa minima (s)"
	},
	"STATUS_READY": {
		Language.EN: "Ready",
		Language.DE: "Bereit",
		Language.FR: "Prêt",
		Language.ES: "Listo",
		Language.IT: "Pronto"
	},
	"TOOLTIP_MUTE": {
		Language.EN: "Mute track (Stummschalten): Silences this audio track",
		Language.DE: "Spur stummschalten: Schaltet diese Audiospur stumm",
		Language.FR: "Couper le son de la piste",
		Language.ES: "Silenciar pista",
		Language.IT: "Disattiva audio traccia"
	},
	"TOOLTIP_SOLO": {
		Language.EN: "Solo track: Solos this track and mutes all other non-soloed tracks",
		Language.DE: "Solo hören: Schaltet alle anderen nicht-solierten Spuren stumm",
		Language.FR: "Écouter en solo",
		Language.ES: "Escuchar en solo",
		Language.IT: "Ascolta in solo"
	},
	"TOOLTIP_DELETE": {
		Language.EN: "Delete track: Removes this track from the soundscape",
		Language.DE: "Spur löschen: Entfernt diese Audiospur aus der Soundscape",
		Language.FR: "Supprimer la piste",
		Language.ES: "Eliminar pista",
		Language.IT: "Elimina traccia"
	},
	"TOOLTIP_PLAY": {
		Language.EN: "Start playback of all active soundscape tracks",
		Language.DE: "Wiedergabe aller aktiven Soundscape-Spuren starten",
		Language.FR: "Lancer la lecture",
		Language.ES: "Iniciar reproducción",
		Language.IT: "Avvia riproduzione"
	},
	"TOOLTIP_PAUSE": {
		Language.EN: "Pause current playback",
		Language.DE: "Wiedergabe pausieren",
		Language.FR: "Mettre en pause",
		Language.ES: "Pausar reproducción",
		Language.IT: "Metti in pausa"
	},
	"TOOLTIP_STOP": {
		Language.EN: "Stop playback and reset triggers",
		Language.DE: "Wiedergabe stoppen und Trigger zurücksetzen",
		Language.FR: "Arrêter la lecture",
		Language.ES: "Detener reproducción",
		Language.IT: "Interrompi riproduzione"
	},
	"TOOLTIP_MASTER_VOL": {
		Language.EN: "Master Volume: Global gain applied to all active soundscape tracks",
		Language.DE: "Gesamtlautstärke: Globaler Verstärkungsfaktor für alle Spuren",
		Language.FR: "Volume général",
		Language.ES: "Volumen maestro",
		Language.IT: "Volume principale"
	},
	"TOOLTIP_LAYOUT": {
		Language.EN: "Speaker Configuration: Select Binaural HRTF (.sofa), Stereo, Quad (4.0), 5.1, or 7.1",
		Language.DE: "Lautsprecher-Setup: Wähle Binaurales HRTF (.sofa), Stereo, Quad (4.0), 5.1 oder 7.1",
		Language.FR: "Configuration des haut-parleurs",
		Language.ES: "Configuración de altavoces",
		Language.IT: "Configurazione altoparlanti"
	},
	"TOOLTIP_ROUTING": {
		Language.EN: "Routing Mode: 3D Point Source (polar space), Omnipresent (ambient surround), or Multi-Channel",
		Language.DE: "Routing-Modus: 3D-Punktquelle (im Raum), Omnipräsent (Rundum-Atmo) oder Mehrkanal",
		Language.FR: "Mode de spatialisation",
		Language.ES: "Modo de espacialización",
		Language.IT: "Modalità di spazializzazione"
	},
	"TOOLTIP_DENSITY_COUNT": {
		Language.EN: "Number of random triggers to distribute within the specified time window",
		Language.DE: "Anzahl der zufälligen Auslösungen innerhalb des Zeitfensters",
		Language.FR: "Nombre de déclenchements aléatoires",
		Language.ES: "Número de disparos aleatorios",
		Language.IT: "Numero di trigger casuali"
	},
	"TOOLTIP_DENSITY_WINDOW": {
		Language.EN: "Duration of the time window across which triggers are distributed",
		Language.DE: "Dauer des Zeitfensters, über das die Auslösungen verteilt werden",
		Language.FR: "Durée de la fenêtre de déclenchement",
		Language.ES: "Duración de la ventana de disparo",
		Language.IT: "Durata della finestra di trigger"
	},
	"TOOLTIP_COOLDOWN": {
		Language.EN: "Minimum enforced pause (block window) between plays to prevent audio overlap",
		Language.DE: "Mindest-Pause (Blockwert) zwischen Auslösungen, um Überlappungen zu verhindern",
		Language.FR: "Pause minimale entre deux lectures",
		Language.ES: "Pausa mínima entre reproducciones",
		Language.IT: "Pausa minima tra le riproduzioni"
	},
	"EMPTY_TRACKS_TITLE": {
		Language.EN: "No Audio Tracks Added",
		Language.DE: "Keine Audiospuren vorhanden",
		Language.FR: "Aucune piste audio",
		Language.ES: "Sin pistas de audio",
		Language.IT: "Nessuna traccia audio"
	},
	"EMPTY_TRACKS_DESC": {
		Language.EN: "Click '+ Add Audio Track' or import a soundscape from the Library.",
		Language.DE: "Klicke auf '+ Audiospur hinzufügen' oder lade eine Soundscape aus der Bibliothek.",
		Language.FR: "Ajoutez une piste ou importez une ambiance.",
		Language.ES: "Añade una pista o importa un ambiente.",
		Language.IT: "Aggiungi una traccia o importa un'ambientazione."
	},
	"RATE_PICKER_TITLE": {
		Language.EN: "Random Frequency Picker",
		Language.DE: "Zufallshäufigkeit wählen",
		Language.FR: "Sélecteur de fréquence aléatoire",
		Language.ES: "Selector de frecuencia aleatoria",
		Language.IT: "Selettore frequenza casuale"
	},
	"BTN_OK": {
		Language.EN: "Ok",
		Language.DE: "OK",
		Language.FR: "Valider",
		Language.ES: "Aceptar",
		Language.IT: "OK"
	},
	"BTN_CANCEL": {
		Language.EN: "Cancel",
		Language.DE: "Abbrechen",
		Language.FR: "Annuler",
		Language.ES: "Cancelar",
		Language.IT: "Annulla"
	},
	"TOOLTIP_CROSSFADE": {
		Language.EN: "Continuous Loop (Crossfade ∞)",
		Language.DE: "Endlosschleife (Überblendung ∞)",
		Language.FR: "Boucle continue (Fondu ∞)",
		Language.ES: "Bucle continuo (Fundido ∞)",
		Language.IT: "Loop continuo (Dissolvenza ∞)"
	},
	"TOOLTIP_RANDOM": {
		Language.EN: "Random Interval Playback (⇌)",
		Language.DE: "Zufallswiedergabe (⇌)",
		Language.FR: "Lecture aléatoire (⇌)",
		Language.ES: "Reproducción aleatoria (⇌)",
		Language.IT: "Riproduzione casuale (⇌)"
	},
	"DLG_COVER_TITLE": {
		Language.EN: "Select Soundscape Cover Image",
		Language.DE: "Soundscape-Titelbild auswählen",
		Language.FR: "Choisir l'image de couverture",
		Language.ES: "Seleccionar imagen de portada",
		Language.IT: "Seleziona immagine di copertina"
	},
	"DLG_EXPORT_TITLE": {
		Language.EN: "Export Soundscape (Offline Render)",
		Language.DE: "Soundscape exportieren (Offline-Render)",
		Language.FR: "Exporter le soundscape (Rendu hors-ligne)",
		Language.ES: "Exportar soundscape (Renderizado offline)",
		Language.IT: "Esporta soundscape (Rendering offline)"
	},
	"BTN_START_EXPORT": {
		Language.EN: "Start Export",
		Language.DE: "Export starten",
		Language.FR: "Démarrer l'exportation",
		Language.ES: "Iniciar exportación",
		Language.IT: "Avvia esportazione"
	},
	"SETTINGS_TITLE": {
		Language.EN: "Studio Preferences & Settings",
		Language.DE: "Studio-Einstellungen & Optionen",
		Language.FR: "Préférences et paramètres du studio",
		Language.ES: "Preferencias y ajustes de estudio",
		Language.IT: "Preferenze e impostazioni dello studio"
	},
	"BTN_RESET_STEM": {
		Language.EN: "🔄 Reset Stem",
		Language.DE: "🔄 Stem zurücksetzen",
		Language.FR: "🔄 Réinitialiser la piste",
		Language.ES: "🔄 Restablecer pista",
		Language.IT: "🔄 Ripristina traccia"
	},
	"BTN_RESET_ALL_STEMS": {
		Language.EN: "⏪ Reset All",
		Language.DE: "⏪ Alle zurücksetzen",
		Language.FR: "⏪ Tout réinitialiser",
		Language.ES: "⏪ Restablecer todo",
		Language.IT: "⏪ Ripristina tutto"
	},
	"TOOLTIP_RESET_STEM": {
		Language.EN: "Reset this audio stem's volume, position, routing, and trigger settings to original defaults.",
		Language.DE: "Lautstärke, Position, Routing und Trigger dieser Spur auf Originalwerte zurücksetzen.",
		Language.FR: "Réinitialiser le volume, la position et les paramètres de cette piste aux valeurs par défaut.",
		Language.ES: "Restablecer volumen, posición y ajustes de esta pista a los valores originales.",
		Language.IT: "Ripristina volume, posizione e impostazioni di questa traccia ai valori originali."
	},
	"TOOLTIP_RESET_ALL": {
		Language.EN: "Reset all audio stems in this soundscape to their original defaults.",
		Language.DE: "Alle Audio-Spuren dieser Soundscape auf ihre Originalwerte zurücksetzen.",
		Language.FR: "Réinitialiser toutes les pistes audio de ce soundscape aux valeurs par défaut.",
		Language.ES: "Restablecer todas las pistas de este soundscape a los valores originales.",
		Language.IT: "Ripristina tutte le tracce di questo soundscape ai valori originali."
	},
	"CROSSFADE_LOOP": {
		Language.EN: "🔀 Seamless Crossfade Loop",
		Language.DE: "🔀 Nahtloser Crossfade-Loop",
		Language.FR: "🔀 Fondu enchaîné continu",
		Language.ES: "🔀 Bucle continuo con fundido",
		Language.IT: "🔀 Loop continuo con dissolvenza"
	},
	"TAB_SOUNDSCAPES": {
		Language.EN: "Soundscape Library",
		Language.DE: "Soundscape-Bibliothek",
		Language.FR: "Bibliothèque de Soundscapes",
		Language.ES: "Biblioteca de Soundscapes",
		Language.IT: "Libreria Soundscape"
	},
	"MENU_HELP_WIKI": {
		Language.EN: "Wiki & Documentation...",
		Language.DE: "Wiki & Dokumentation...",
		Language.FR: "Wiki & Documentation...",
		Language.ES: "Wiki y Documentación...",
		Language.IT: "Wiki e Documentazione..."
	},
	"MENU_HELP_GITHUB": {
		Language.EN: "GitHub Repository...",
		Language.DE: "GitHub-Repository...",
		Language.FR: "Dépôt GitHub...",
		Language.ES: "Repositorio GitHub...",
		Language.IT: "Repository GitHub..."
	},
	"MENU_HELP_ABOUT": {
		Language.EN: "About 3D Soundscape Studio...",
		Language.DE: "Über 3D Soundscape Studio...",
		Language.FR: "À propos de 3D Soundscape Studio...",
		Language.ES: "Acerca de 3D Soundscape Studio...",
		Language.IT: "Informazioni su 3D Soundscape Studio..."
	},
	"MENU_VIEW_LANGUAGE": {
		Language.EN: "Language",
		Language.DE: "Sprache",
		Language.FR: "Langue",
		Language.ES: "Idioma",
		Language.IT: "Lingua"
	},
	"MENU_VIEW_THEME": {
		Language.EN: "Thematic Style",
		Language.DE: "Design-Stil",
		Language.FR: "Style visuel",
		Language.ES: "Estilo visual",
		Language.IT: "Stile visivo"
	},
	"SETTINGS_TAB_AUDIO": {
		Language.EN: "Audio",
		Language.DE: "Audio",
		Language.FR: "Audio",
		Language.ES: "Audio",
		Language.IT: "Audio"
	},
	"SETTINGS_TAB_DIRECTORIES": {
		Language.EN: "Directories",
		Language.DE: "Verzeichnisse",
		Language.FR: "Répertoires",
		Language.ES: "Directorios",
		Language.IT: "Cartelle"
	},
	"SETTINGS_TAB_FFMPEG": {
		Language.EN: "FFmpeg",
		Language.DE: "FFmpeg",
		Language.FR: "FFmpeg",
		Language.ES: "FFmpeg",
		Language.IT: "FFmpeg"
	},
	"SETTINGS_TAB_DISPLAY": {
		Language.EN: "Display & Language",
		Language.DE: "Darstellung & Sprache",
		Language.FR: "Affichage & Langue",
		Language.ES: "Pantalla e Idioma",
		Language.IT: "Visualizzazione e Lingua"
	},
	"SETTINGS_LANGUAGE_LABEL": {
		Language.EN: "Interface Language:",
		Language.DE: "Benutzeroberflächen-Sprache:",
		Language.FR: "Langue de l'interface :",
		Language.ES: "Idioma de la interfaz:",
		Language.IT: "Lingua dell'interfaccia:"
	},
	"SETTINGS_THEME_LABEL": {
		Language.EN: "Thematic UI Style:",
		Language.DE: "Design-Stil der Oberfläche:",
		Language.FR: "Style visuel :",
		Language.ES: "Estilo del tema:",
		Language.IT: "Stile del tema:"
	},
	"SETTINGS_RADAR_ANIM_LABEL": {
		Language.EN: "3D Spatial Radar Visual Effects:",
		Language.DE: "3D-Spatial-Radar Grafikeffekte:",
		Language.FR: "Effets visuels du radar spatial 3D :",
		Language.ES: "Efectos visuales del radar 3D:",
		Language.IT: "Effetti visivi del radar spaziale 3D:"
	},
	"SETTINGS_RADAR_BEAM_CHK": {
		Language.EN: "Enable Rotating Radar Sweep Beam",
		Language.DE: "Rotierenden Radar-Suchstrahl aktivieren",
		Language.FR: "Activer le balayage rotatif du radar",
		Language.ES: "Activar barrido de haz del radar",
		Language.IT: "Attiva fascio di scansione del radar"
	},
	"SETTINGS_SAVE": {
		Language.EN: "Save Settings",
		Language.DE: "Einstellungen speichern",
		Language.FR: "Sauvegarder",
		Language.ES: "Guardar ajustes",
		Language.IT: "Salva impostazioni"
	},
	"SETTINGS_CANCEL": {
		Language.EN: "Cancel",
		Language.DE: "Abbrechen",
		Language.FR: "Annuler",
		Language.ES: "Cancelar",
		Language.IT: "Annulla"
	}
}

static func tr_key(key: String) -> String:
	if TRANSLATIONS.has(key):
		var lang_map: Dictionary = TRANSLATIONS[key]
		return lang_map.get(current_language, key)
	return key

static func set_language(lang: Language) -> void:
	current_language = lang

static func cycle_language() -> Language:
	var next_idx: int = (int(current_language) + 1) % 5
	current_language = next_idx as Language
	return current_language

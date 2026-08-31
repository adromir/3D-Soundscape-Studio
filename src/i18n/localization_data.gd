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
	"MENU_FILE_NEW": {
		Language.EN: "New Soundscape",
		Language.DE: "Neues Soundscape",
		Language.FR: "Nouveau soundscape",
		Language.ES: "Nuevo soundscape",
		Language.IT: "Nuovo soundscape"
	},
	"MENU_FILE_OPEN": {
		Language.EN: "Open Soundscape...",
		Language.DE: "Soundscape öffnen...",
		Language.FR: "Ouvrir un soundscape...",
		Language.ES: "Abrir soundscape...",
		Language.IT: "Apri soundscape..."
	},
	"MENU_FILE_RECENT": {
		Language.EN: "Recent Projects",
		Language.DE: "Zuletzt geöffnet",
		Language.FR: "Projets récents",
		Language.ES: "Proyectos recientes",
		Language.IT: "Progetti recenti"
	},
	"MENU_FILE_RECENT_EMPTY": {
		Language.EN: "No Recent Projects",
		Language.DE: "Keine zuletzt geöffneten Projekte",
		Language.FR: "Aucun projet récent",
		Language.ES: "Sin proyectos recientes",
		Language.IT: "Nessun progetto recente"
	},
	"MENU_FILE_RECENT_CLEAR": {
		Language.EN: "Clear Recent Projects",
		Language.DE: "Verlauf leeren",
		Language.FR: "Effacer l'historique",
		Language.ES: "Borrar historial",
		Language.IT: "Cancella cronologia"
	},
	"MENU_FILE_SAVE": {
		Language.EN: "Save Soundscape",
		Language.DE: "Soundscape speichern",
		Language.FR: "Sauvegarder le soundscape",
		Language.ES: "Guardar soundscape",
		Language.IT: "Salva soundscape"
	},
	"MENU_FILE_SAVE_AS": {
		Language.EN: "Save Soundscape As...",
		Language.DE: "Soundscape speichern unter...",
		Language.FR: "Sauvegarder sous...",
		Language.ES: "Guardar como...",
		Language.IT: "Salva come..."
	},
	"MENU_FILE_EXPORT": {
		Language.EN: "Export Audio Mix...",
		Language.DE: "Audiomix exportieren...",
		Language.FR: "Exporter le mix audio...",
		Language.ES: "Exportar mezcla de audio...",
		Language.IT: "Esporta mix audio..."
	},
	"MENU_FILE_EXPORT_PACKAGE": {
		Language.EN: "Export Soundscape Package (.3dscape)...",
		Language.DE: "Soundscape-Paket exportieren (.3dscape)...",
		Language.FR: "Exporter le paquet de soundscape (.3dscape)...",
		Language.ES: "Exportar paquete de soundscape (.3dscape)...",
		Language.IT: "Esporta pacchetto soundscape (.3dscape)..."
	},
	"MENU_FILE_IMPORT_PACKAGE": {
		Language.EN: "Import Soundscape Package (.3dscape)...",
		Language.DE: "Soundscape-Paket importieren (.3dscape)...",
		Language.FR: "Importer un paquet de soundscape (.3dscape)...",
		Language.ES: "Importar paquete de soundscape (.3dscape)...",
		Language.IT: "Importa pacchetto soundscape (.3dscape)..."
	},
	"MENU_FILE_IMPORT": {
		Language.EN: "Download & Import Soundscape...",
		Language.DE: "Soundscape herunterladen & importieren...",
		Language.FR: "Télécharger & importer un soundscape...",
		Language.ES: "Descargar e importar soundscape...",
		Language.IT: "Scarica e importa soundscape..."
	},
	"MENU_FILE_PREFERENCES": {
		Language.EN: "Preferences...",
		Language.DE: "Einstellungen...",
		Language.FR: "Préférences...",
		Language.ES: "Preferencias...",
		Language.IT: "Preferenze..."
	},
	"MENU_FILE_EXIT": {
		Language.EN: "Exit",
		Language.DE: "Beenden",
		Language.FR: "Quitter",
		Language.ES: "Salir",
		Language.IT: "Esci"
	},
	"MENU_EDIT": {
		Language.EN: "Edit",
		Language.DE: "Bearbeiten",
		Language.FR: "Édition",
		Language.ES: "Editar",
		Language.IT: "Modifica"
	},
	"MENU_EDIT_ADD_TRACK": {
		Language.EN: "Add Audio Track...",
		Language.DE: "Audiospur hinzufügen...",
		Language.FR: "Ajouter une piste audio...",
		Language.ES: "Añadir pista de audio...",
		Language.IT: "Aggiungi traccia audio..."
	},
	"MENU_EDIT_CLEAR_TRACKS": {
		Language.EN: "Clear All Audio Tracks",
		Language.DE: "Alle Audiospuren löschen",
		Language.FR: "Effacer toutes les pistes",
		Language.ES: "Borrar todas las pistas",
		Language.IT: "Cancella tutte le tracce"
	},
	"MENU_EDIT_RESET_STEM": {
		Language.EN: "Reset Selected Stem",
		Language.DE: "Ausgewählte Spur zurücksetzen",
		Language.FR: "Réinitialiser la piste sélectionnée",
		Language.ES: "Restablecer pista seleccionada",
		Language.IT: "Ripristina traccia selezionata"
	},
	"MENU_EDIT_RESET_ALL": {
		Language.EN: "Reset All Stems",
		Language.DE: "Alle Spuren zurücksetzen",
		Language.FR: "Réinitialiser toutes les pistes",
		Language.ES: "Restablecer todas las pistas",
		Language.IT: "Ripristina tutte le tracce"
	},
	"MENU_EDIT_RESET_PATH": {
		Language.EN: "Reset Listener Path",
		Language.DE: "Hörer-Pfad zurücksetzen",
		Language.FR: "Réinitialiser la trajectoire",
		Language.ES: "Restablecer trayectoria",
		Language.IT: "Ripristina percorso"
	},
	"MENU_EDIT_LIGHTING": {
		Language.EN: "Visual Ambient Lighting (Home Assistant)...",
		Language.DE: "Visuelles Ambient-Licht (Home Assistant)...",
		Language.FR: "Éclairage d'ambiance visuel (Home Assistant)...",
		Language.ES: "Iluminación ambiental visual (Home Assistant)...",
		Language.IT: "Illuminazione ambientale visiva (Home Assistant)..."
	},
	"MENU_VIEW": {
		Language.EN: "View",
		Language.DE: "Ansicht",
		Language.FR: "Affichage",
		Language.ES: "Ver",
		Language.IT: "Visualizza"
	},
	"MENU_VIEW_STUDIO": {
		Language.EN: "Studio Radar View",
		Language.DE: "Studio-Radar-Ansicht",
		Language.FR: "Vue radar du studio",
		Language.ES: "Vista de radar de estudio",
		Language.IT: "Vista radar studio"
	},
	"MENU_VIEW_AUTOMATION": {
		Language.EN: "Listener Automation",
		Language.DE: "Hörer-Automation",
		Language.FR: "Automatisation de trajectoire",
		Language.ES: "Automatización de trayectoria",
		Language.IT: "Automazione percorso"
	},
	"MENU_VIEW_LIBRARY_SOUNDSCAPES": {
		Language.EN: "Soundscape Library",
		Language.DE: "Soundscape-Bibliothek",
		Language.FR: "Bibliothèque de soundscapes",
		Language.ES: "Biblioteca de soundscapes",
		Language.IT: "Libreria soundscape"
	},
	"MENU_VIEW_LIBRARY_SAMPLES": {
		Language.EN: "Sounds Library",
		Language.DE: "Sound-Bibliothek",
		Language.FR: "Bibliothèque de sons",
		Language.ES: "Biblioteca de sonidos",
		Language.IT: "Libreria suoni"
	},
	"MENU_VIEW_THEMES": {
		Language.EN: "Thematic Style",
		Language.DE: "Design-Stil",
		Language.FR: "Style visuel",
		Language.ES: "Estilo visual",
		Language.IT: "Stile visivo"
	},
	"MENU_VIEW_LANGUAGE": {
		Language.EN: "Language",
		Language.DE: "Sprache",
		Language.FR: "Langue",
		Language.ES: "Idioma",
		Language.IT: "Lingua"
	},
	"MENU_VIEW_FULLSCREEN": {
		Language.EN: "Toggle Fullscreen",
		Language.DE: "Vollbild umschalten",
		Language.FR: "Plein écran",
		Language.ES: "Pantalla completa",
		Language.IT: "Schermo intero"
	},
	"MENU_PLAYBACK": {
		Language.EN: "Playback",
		Language.DE: "Wiedergabe",
		Language.FR: "Lecture",
		Language.ES: "Reproducción",
		Language.IT: "Riproduzione"
	},
	"MENU_PLAYBACK_PLAY_ALL": {
		Language.EN: "Play / Pause",
		Language.DE: "Wiedergabe / Pause",
		Language.FR: "Lecture / Pause",
		Language.ES: "Reproducir / Pausa",
		Language.IT: "Riproduci / Pausa"
	},
	"MENU_PLAYBACK_PAUSE": {
		Language.EN: "Pause Playback",
		Language.DE: "Wiedergabe pausieren",
		Language.FR: "Pause lecture",
		Language.ES: "Pausar reproducción",
		Language.IT: "Metti in pausa"
	},
	"MENU_PLAYBACK_STOP": {
		Language.EN: "Stop All Playback",
		Language.DE: "Wiedergabe stoppen",
		Language.FR: "Arrêter la lecture",
		Language.ES: "Detener reproducción",
		Language.IT: "Interrompi riproduzione"
	},
	"MENU_PLAYBACK_SPEAKER_SETUP": {
		Language.EN: "Speaker Setup",
		Language.DE: "Lautsprecher-Setup",
		Language.FR: "Configuration des haut-parleurs",
		Language.ES: "Configuración de altavoces",
		Language.IT: "Configurazione altoparlanti"
	},
	"MENU_HELP": {
		Language.EN: "Help",
		Language.DE: "Hilfe",
		Language.FR: "Aide",
		Language.ES: "Ayuda",
		Language.IT: "Aiuto"
	},
	"MENU_HELP_WIKI": {
		Language.EN: "Documentation / Wiki",
		Language.DE: "Dokumentation / Wiki",
		Language.FR: "Documentation / Wiki",
		Language.ES: "Documentación / Wiki",
		Language.IT: "Documentazione / Wiki"
	},
	"MENU_HELP_CHECK_UPDATES": {
		Language.EN: "Check for Updates...",
		Language.DE: "Nach Updates suchen...",
		Language.FR: "Vérifier les mises à jour...",
		Language.ES: "Buscar actualizaciones...",
		Language.IT: "Controlla aggiornamenti..."
	},
	"MENU_HELP_GITHUB": {
		Language.EN: "GitHub Repository",
		Language.DE: "GitHub-Repository",
		Language.FR: "Dépôt GitHub",
		Language.ES: "Repositorio de GitHub",
		Language.IT: "Repository GitHub"
	},
	"MENU_HELP_ABOUT": {
		Language.EN: "About 3D Soundscape Studio",
		Language.DE: "Über 3D Soundscape Studio",
		Language.FR: "À propos de 3D Soundscape Studio",
		Language.ES: "Acerca de 3D Soundscape Studio",
		Language.IT: "Informazioni su 3D Soundscape Studio"
	},
	"DLG_UPDATE_TITLE": {
		Language.EN: "3D Soundscape Studio Update",
		Language.DE: "3D Soundscape Studio Aktualisierung",
		Language.FR: "Mise à jour de 3D Soundscape Studio",
		Language.ES: "Actualización de 3D Soundscape Studio",
		Language.IT: "Aggiornamento 3D Soundscape Studio"
	},
	"UPDATE_CHECKING": {
		Language.EN: "Checking for updates on GitHub...",
		Language.DE: "Suche nach Updates auf GitHub...",
		Language.FR: "Recherche de mises à jour sur GitHub...",
		Language.ES: "Buscando actualizaciones en GitHub...",
		Language.IT: "Ricerca di aggiornamenti su GitHub..."
	},
	"UPDATE_AVAILABLE_TITLE": {
		Language.EN: "New Update Available!",
		Language.DE: "Neues Update verfügbar!",
		Language.FR: "Nouvelle mise à jour disponible !",
		Language.ES: "¡Nueva actualización disponible!",
		Language.IT: "Nuovo aggiornamento disponibile!"
	},
	"UPDATE_UP_TO_DATE_TITLE": {
		Language.EN: "You're up to date!",
		Language.DE: "Sie sind auf dem neuesten Stand!",
		Language.FR: "Vous êtes à jour !",
		Language.ES: "¡Estás actualizado!",
		Language.IT: "Sei aggiornato!"
	},
	"UPDATE_UP_TO_DATE_DESC": {
		Language.EN: "You are using the latest version of 3D Soundscape Studio (%s).",
		Language.DE: "Sie verwenden die neueste Version von 3D Soundscape Studio (%s).",
		Language.FR: "Vous utilisez la dernière version de 3D Soundscape Studio (%s).",
		Language.ES: "Estás utilizando la última versión de 3D Soundscape Studio (%s).",
		Language.IT: "Stai utilizzando l'ultima versione di 3D Soundscape Studio (%s)."
	},
	"UPDATE_CURRENT_VERSION": {
		Language.EN: "Installed Version:",
		Language.DE: "Installierte Version:",
		Language.FR: "Version installée :",
		Language.ES: "Versión instalada:",
		Language.IT: "Versione installata:"
	},
	"UPDATE_LATEST_VERSION": {
		Language.EN: "Latest Version:",
		Language.DE: "Neueste Version:",
		Language.FR: "Dernière version :",
		Language.ES: "Última versión:",
		Language.IT: "Ultima versione:"
	},
	"UPDATE_CHANGELOG": {
		Language.EN: "Release Notes & Changelog:",
		Language.DE: "Versionshinweise & Änderungen:",
		Language.FR: "Notes de version & changements :",
		Language.ES: "Notas de la versión y cambios:",
		Language.IT: "Note di rilascio e modifiche:"
	},
	"BTN_DOWNLOAD_UPDATE": {
		Language.EN: "🚀 Download & Install Update",
		Language.DE: "🚀 Update herunterladen & installieren",
		Language.FR: "🚀 Télécharger et installer la mise à jour",
		Language.ES: "🚀 Descargar e instalar actualización",
		Language.IT: "🚀 Scarica e installa aggiornamento"
	},
	"BTN_INSTALL_RESTART": {
		Language.EN: "🔄 Restart & Apply Update",
		Language.DE: "🔄 Neu starten & Update anwenden",
		Language.FR: "🔄 Redémarrer et appliquer la mise à jour",
		Language.ES: "🔄 Reiniciar y aplicar actualización",
		Language.IT: "🔄 Riavvia e applica aggiornamento"
	},
	"BTN_VIEW_GITHUB": {
		Language.EN: "🌐 View on GitHub",
		Language.DE: "🌐 Auf GitHub ansehen",
		Language.FR: "🌐 Voir sur GitHub",
		Language.ES: "🌐 Ver en GitHub",
		Language.IT: "🌐 Visualizza su GitHub"
	},
	"BTN_REMIND_LATER": {
		Language.EN: "Remind Me Later",
		Language.DE: "Später erinnern",
		Language.FR: "Me rappeler plus tard",
		Language.ES: "Recordármelo más tarde",
		Language.IT: "Ricordamelo più tardi"
	},
	"UPDATE_DOWNLOADING": {
		Language.EN: "Downloading update: %s...",
		Language.DE: "Update wird heruntergeladen: %s...",
		Language.FR: "Téléchargement de la mise à jour : %s...",
		Language.ES: "Descargando actualización: %s...",
		Language.IT: "Download dell'aggiornamento: %s..."
	},
	"UPDATE_DOWNLOAD_COMPLETED": {
		Language.EN: "✅ Update downloaded successfully. Ready to restart and apply.",
		Language.DE: "✅ Update erfolgreich heruntergeladen. Bereit zum Neustart.",
		Language.FR: "✅ Mise à jour téléchargée avec succès. Prêt à redémarrer.",
		Language.ES: "✅ Actualización descargada con éxito. Listo para reiniciar.",
		Language.IT: "✅ Aggiornamento scaricato con successo. Pronto al riavvio."
	},
	"UPDATE_FAILED": {
		Language.EN: "Update check/download failed: %s",
		Language.DE: "Update-Prüfung/Download fehlgeschlagen: %s",
		Language.FR: "Échec de la vérification/du téléchargement de la mise à jour : %s",
		Language.ES: "Error al comprobar/descargar la actualización: %s",
		Language.IT: "Controllo/download dell'aggiornamento non riuscito: %s"
	},
	"SETTINGS_CHECK_UPDATES_STARTUP": {
		Language.EN: "Check for updates automatically on startup",
		Language.DE: "Beim Start automatisch nach Updates suchen",
		Language.FR: "Vérifier automatiquement les mises à jour au démarrage",
		Language.ES: "Comprobar actualizaciones automáticamente al iniciar",
		Language.IT: "Controlla automaticamente gli aggiornamenti all'avvio"
	},
	"BTN_CHANGE_COVER": {
		Language.EN: "Change Cover Image...",
		Language.DE: "Titelbild ändern...",
		Language.FR: "Changer la pochette...",
		Language.ES: "Cambiar imagen de portada...",
		Language.IT: "Cambia immagine di copertina..."
	},
	"LBL_COVER_PREVIEW": {
		Language.EN: "Cover Artwork:",
		Language.DE: "Titelbild-Vorschau:",
		Language.FR: "Aperçu de la pochette :",
		Language.ES: "Vista previa de la portada:",
		Language.IT: "Anteprima copertina:"
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
		Language.EN: "Change Cover",
		Language.DE: "Titelbild ändern",
		Language.FR: "Changer la pochette",
		Language.ES: "Cambiar portada",
		Language.IT: "Cambia copertina"
	},
	"TOOLTIP_SET_COVER": {
		Language.EN: "Select Cover Image Artwork for Soundscape",
		Language.DE: "Titelbild / Artwork für dieses Soundscape auswählen",
		Language.FR: "Sélectionner une image de couverture / pochette",
		Language.ES: "Seleccionar imagen de portada para el soundscape",
		Language.IT: "Seleziona immagine di copertina per il soundscape"
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
	"TOOLTIP_HEATMAP_TOGGLE": {
		Language.EN: "Toggle Acoustic Pressure & Audibility Heatmap (H)",
		Language.DE: "Akustische Druck- / Hörbarkeits-Heatmap umschalten (H)",
		Language.FR: "Basculer la carte thermique de pression acoustique (H)",
		Language.ES: "Alternar mapa de calor de presión acústica (H)",
		Language.IT: "Attiva/disattiva mappa termica di pressione acustica (H)"
	},
	"TOOLTIP_HEATMAP_COLORMAP": {
		Language.EN: "Select Heatmap Colormap Palette",
		Language.DE: "Farbskala für Akustik-Heatmap auswählen",
		Language.FR: "Sélectionner la palette de la carte thermique",
		Language.ES: "Seleccionar paleta del mapa térmico",
		Language.IT: "Seleziona tavolozza mappa termica"
	},
	"HEATMAP_THERMAL": {
		Language.EN: "Thermal",
		Language.DE: "Thermal",
		Language.FR: "Thermique",
		Language.ES: "Térmico",
		Language.IT: "Termico"
	},
	"HEATMAP_PHOSPHOR": {
		Language.EN: "Phosphor",
		Language.DE: "Phosphor",
		Language.FR: "Phosphore",
		Language.ES: "Fósforo",
		Language.IT: "Fosforo"
	},
	"HEATMAP_CYBERPUNK": {
		Language.EN: "Cyberpunk",
		Language.DE: "Cyberpunk",
		Language.FR: "Cyberpunk",
		Language.ES: "Cyberpunk",
		Language.IT: "Cyberpunk"
	},
	"TAB_LOCAL_SAMPLES": {
		Language.EN: "Local Samples",
		Language.DE: "Lokale Samples",
		Language.FR: "Échantillons locaux",
		Language.ES: "Muestras locales",
		Language.IT: "Campioni locali"
	},
	"TAB_FREESOUND": {
		Language.EN: "Freesound.org Database",
		Language.DE: "Freesound.org Online-Datenbank",
		Language.FR: "Base de données Freesound.org",
		Language.ES: "Base de datos Freesound.org",
		Language.IT: "Database Freesound.org"
	},
	"SEARCH_FREESOUND_PLACEHOLDER": {
		Language.EN: "Search 500,000+ sound effects & ambient stems on Freesound.org...",
		Language.DE: "Suche in über 500.000 Soundeffekten & Ambient-Stems auf Freesound.org...",
		Language.FR: "Rechercher parmi plus de 500 000 effets sonores sur Freesound.org...",
		Language.ES: "Buscar en más de 500.000 efectos de sonido en Freesound.org...",
		Language.IT: "Cerca tra oltre 500.000 effetti sonori su Freesound.org..."
	},
	"FILTER_LICENSE": {
		Language.EN: "License",
		Language.DE: "Lizenz",
		Language.FR: "Licence",
		Language.ES: "Licencia",
		Language.IT: "Licenza"
	},
	"FILTER_DURATION": {
		Language.EN: "Duration",
		Language.DE: "Dauer",
		Language.FR: "Durée",
		Language.ES: "Duración",
		Language.IT: "Durata"
	},
	"BTN_SEARCH_ONLINE": {
		Language.EN: "Search Freesound",
		Language.DE: "Freesound durchsuchen",
		Language.FR: "Rechercher sur Freesound",
		Language.ES: "Buscar en Freesound",
		Language.IT: "Cerca su Freesound"
	},
	"BTN_IMPORT_TO_LIB": {
		Language.EN: "Import to Library",
		Language.DE: "In Bibliothek importieren",
		Language.FR: "Importer dans la bibliothèque",
		Language.ES: "Importar a la biblioteca",
		Language.IT: "Importa nella libreria"
	},
	"BTN_ADD_TO_STUDIO": {
		Language.EN: "Add to Studio",
		Language.DE: "Als 3D-Spur einfügen",
		Language.FR: "Ajouter au Studio",
		Language.ES: "Añadir al Estudio",
		Language.IT: "Aggiungi allo Studio"
	},
	"FREESOUND_SEARCHING": {
		Language.EN: "Searching Freesound.org database...",
		Language.DE: "Durchsuche Freesound.org Datenbank...",
		Language.FR: "Recherche dans la base de données Freesound.org...",
		Language.ES: "Buscando en la base de datos de Freesound.org...",
		Language.IT: "Ricerca nel database di Freesound.org..."
	},
	"FREESOUND_DOWNLOADING": {
		Language.EN: "Downloading sample...",
		Language.DE: "Lade Sample herunter...",
		Language.FR: "Téléchargement de l'échantillon...",
		Language.ES: "Descargando muestra...",
		Language.IT: "Download del campione..."
	},
	"FREESOUND_IMPORTED_SUCCESS": {
		Language.EN: "Sample imported successfully into library!",
		Language.DE: "Sample erfolgreich in die Bibliothek importiert!",
		Language.FR: "Échantillon importé avec succès dans la bibliothèque !",
		Language.ES: "¡Muestra importada con éxito a la biblioteca!",
		Language.IT: "Campione importato con successo nella libreria!"
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
	"MOV_ONE_WAY_RL": {
		Language.EN: "Right ➔ Left (One-Way)",
		Language.DE: "Rechts ➔ Links (Einweg)",
		Language.FR: "Droite ➔ Gauche (Sens unique)",
		Language.ES: "Derecha ➔ Izquierda (Unidireccional)",
		Language.IT: "Destra ➔ Sinistra (Senso unico)"
	},
	"MOV_PING_PONG_FB": {
		Language.EN: "Front ⟷ Back (Ping-Pong)",
		Language.DE: "Vorne ⟷ Hinten (Ping-Pong)",
		Language.FR: "Avant ⟷ Arrière (Ping-Pong)",
		Language.ES: "Frente ⟷ Atrás (Ping-Pong)",
		Language.IT: "Avanti ⟷ Dietro (Ping-Pong)"
	},
	"MOV_ONE_WAY_FB": {
		Language.EN: "Front ➔ Back / Recede (One-Way)",
		Language.DE: "Vorne ➔ Hinten / Entfernen (Einweg)",
		Language.FR: "Avant ➔ Arrière / Éloignement",
		Language.ES: "Frente ➔ Atrás / Alejamiento",
		Language.IT: "Avanti ➔ Dietro / Allontanamento"
	},
	"MOV_ONE_WAY_BF": {
		Language.EN: "Back ➔ Front / Approach (One-Way)",
		Language.DE: "Hinten ➔ Vorne / Annähern (Einweg)",
		Language.FR: "Arrière ➔ Avant / Rapprochement",
		Language.ES: "Atrás ➔ Frente / Acercamiento",
		Language.IT: "Dietro ➔ Avanti / Avvicinamento"
	},
	"MOV_ORBIT_CW": {
		Language.EN: "Orbit (Clockwise ↻)",
		Language.DE: "Kreisbahn (Uhrzeigersinn ↻)",
		Language.FR: "Orbite (Sens horaire ↻)",
		Language.ES: "Órbita (Sentido horario ↻)",
		Language.IT: "Orbita (Senso orario ↻)"
	},
	"MOV_ORBIT_CCW": {
		Language.EN: "Orbit (Counter-Clockwise ↺)",
		Language.DE: "Kreisbahn (Gegenuhrzeigersinn ↺)",
		Language.FR: "Orbite (Sens antihoraire ↺)",
		Language.ES: "Órbita (Sentido antihorario ↺)",
		Language.IT: "Orbita (Senso antiorario ↺)"
	},
	"MOV_SPIRAL_IN": {
		Language.EN: "Spiral (Inward 🌀)",
		Language.DE: "Spirale (Einwärts 🌀)",
		Language.FR: "Spirale (Vers l'intérieur 🌀)",
		Language.ES: "Espiral (Hacia dentro 🌀)",
		Language.IT: "Spirale (Verso l'interno 🌀)"
	},
	"MOV_SPIRAL_OUT": {
		Language.EN: "Spiral (Outward 🌀)",
		Language.DE: "Spirale (Auswärts 🌀)",
		Language.FR: "Spirale (Vers l'extérieur 🌀)",
		Language.ES: "Espiral (Hacia fuera 🌀)",
		Language.IT: "Spirale (Verso l'esterno 🌀)"
	},
	"MOV_FIGURE_EIGHT": {
		Language.EN: "Figure-8 / Lemniscate (♾️)",
		Language.DE: "Achterbahn / Lemniskate (♾️)",
		Language.FR: "Huit / Lemniscate (♾️)",
		Language.ES: "Figura en ocho / Lemniscata (♾️)",
		Language.IT: "Figura a otto / Lemniscata (♾️)"
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
	},
	"TAB_STUDIO": {
		Language.EN: "Studio",
		Language.DE: "Studio",
		Language.FR: "Studio",
		Language.ES: "Estudio",
		Language.IT: "Studio"
	},
	"TAB_AUTOMATION": {
		Language.EN: "Automation",
		Language.DE: "Automation",
		Language.FR: "Automatisation",
		Language.ES: "Automatización",
		Language.IT: "Automazione"
	},
	"TAB_LIBRARY": {
		Language.EN: "Library",
		Language.DE: "Bibliothek",
		Language.FR: "Bibliothèque",
		Language.ES: "Biblioteca",
		Language.IT: "Libreria"
	},
	"BTN_RESET_ALL": {
		Language.EN: "Reset All",
		Language.DE: "Alle zurücksetzen",
		Language.FR: "Tout réinitialiser",
		Language.ES: "Restablecer todo",
		Language.IT: "Ripristina tutto"
	},
	"LBL_PROJECT": {
		Language.EN: "Project:",
		Language.DE: "Projekt:",
		Language.FR: "Projet :",
		Language.ES: "Proyecto:",
		Language.IT: "Progetto:"
	},
	"SEARCH_SOUNDSCAPES_PLACEHOLDER": {
		Language.EN: "Search soundscapes by title, author, or tag...",
		Language.DE: "Soundscapes nach Titel, Autor oder Tag suchen...",
		Language.FR: "Rechercher des soundscapes...",
		Language.ES: "Buscar soundscapes por título o autor...",
		Language.IT: "Cerca soundscape per titolo o autore..."
	},
	"SEARCH_SAMPLES_PLACEHOLDER": {
		Language.EN: "Search single audio stems & samples...",
		Language.DE: "Einzelne Audiospuren & Samples durchsuchen...",
		Language.FR: "Rechercher des échantillons audio...",
		Language.ES: "Buscar pistas y muestras de audio...",
		Language.IT: "Cerca campioni e tracce audio..."
	},
	"HEADER_STEMS_TRACKS": {
		Language.EN: "Stems / Audio Tracks",
		Language.DE: "Stems / Audiospuren",
		Language.FR: "Pistes / Canaux audio",
		Language.ES: "Pistas / Canales de audio",
		Language.IT: "Tracce / Canali audio"
	},
	"HEADER_RADAR_CANVAS": {
		Language.EN: "3D Spatial Radar Canvas",
		Language.DE: "3D-Spatial-Radar Arbeitsfläche",
		Language.FR: "Canevas radar spatial 3D",
		Language.ES: "Lienzo de radar espacial 3D",
		Language.IT: "Canvas radar spaziale 3D"
	},
	"HEADER_TRACK_INSPECTOR": {
		Language.EN: "Track Inspector",
		Language.DE: "Spur-Eigenschaften",
		Language.FR: "Inspecteur de piste",
		Language.ES: "Inspector de pista",
		Language.IT: "Ispettore traccia"
	},
	"EMPTY_INSPECTOR_DESC": {
		Language.EN: "Select an audio track to edit its spatial placement, movement automation, and trigger intervals.",
		Language.DE: "Wähle eine Audiospur aus, um ihre Raumposition, Bewegungsautomation und Trigger-Intervalle zu bearbeiten.",
		Language.FR: "Sélectionnez une piste pour modifier sa position spatiale et ses déclencheurs.",
		Language.ES: "Selecciona una pista para editar su posición espacial y disparadores.",
		Language.IT: "Seleziona una traccia per modificare la posizione spaziale e i trigger."
	},
	"HEADER_AUTOMATION": {
		Language.EN: "Listener Path Automation",
		Language.DE: "Hörer-Pfad-Automation",
		Language.FR: "Automatisation de trajectoire de l'auditeur",
		Language.ES: "Automatización de trayectoria del oyente",
		Language.IT: "Automazione del percorso dell'ascoltatore"
	},
	"PATH_ACTIVE": {
		Language.EN: "Path: Active (Moving)",
		Language.DE: "Pfad: Aktiv (In Bewegung)",
		Language.FR: "Trajectoire : Active",
		Language.ES: "Trayectoria: Activa",
		Language.IT: "Percorso: Attivo"
	},
	"PATH_DISABLED": {
		Language.EN: "Path: Disabled (Center)",
		Language.DE: "Pfad: Deaktiviert (Zentrum)",
		Language.FR: "Trajectoire : Désactivée",
		Language.ES: "Trayectoria: Desactivada",
		Language.IT: "Percorso: Disattivato"
	},
	"PATH_LOOP_CLOSED": {
		Language.EN: "Mode: Closed Loop",
		Language.DE: "Modus: Geschlossener Rundkurs",
		Language.FR: "Mode : Boucle fermée",
		Language.ES: "Modo: Bucle cerrado",
		Language.IT: "Modalità: Percorso chiuso"
	},
	"PATH_LOOP_OPEN": {
		Language.EN: "Mode: Open Path",
		Language.DE: "Modus: Offener Weg",
		Language.FR: "Mode : Trajectoire ouverte",
		Language.ES: "Modo: Trayectoria abierta",
		Language.IT: "Modalità: Percorso aperto"
	},
	"PATH_SPEED_LABEL": {
		Language.EN: "Speed:",
		Language.DE: "Geschwindigkeit:",
		Language.FR: "Vitesse :",
		Language.ES: "Velocidad:",
		Language.IT: "Velocità:"
	},
	"PATH_CLEAR_BTN": {
		Language.EN: "Clear",
		Language.DE: "Löschen",
		Language.FR: "Effacer",
		Language.ES: "Borrar",
		Language.IT: "Cancella"
	},
	"SETTINGS_AUDIO_DEVICE": {
		Language.EN: "Output Audio Device:",
		Language.DE: "Audio-Ausgabegerät:",
		Language.FR: "Périphérique de sortie audio :",
		Language.ES: "Dispositivo de salida de audio:",
		Language.IT: "Dispositivo di uscita audio:"
	},
	"SETTINGS_SPEAKER_LAYOUT": {
		Language.EN: "Speaker Layout Configuration:",
		Language.DE: "Lautsprecher-Setup & Kanalbelegung:",
		Language.FR: "Configuration des haut-parleurs :",
		Language.ES: "Configuración de altavoces:",
		Language.IT: "Configurazione altoparlanti:"
	},
	"SETTINGS_LIB_DIR_LABEL": {
		Language.EN: "Soundscape Library Storage Path:",
		Language.DE: "Soundscape-Bibliothek Speicherpfad:",
		Language.FR: "Répertoire de la bibliothèque de soundscapes :",
		Language.ES: "Ruta de la biblioteca de soundscapes:",
		Language.IT: "Percorso libreria soundscape:"
	},
	"SETTINGS_SAMPLES_DIR_LABEL": {
		Language.EN: "Single Sounds & Samples Pool Path:",
		Language.DE: "Sounds- & Samples-Pool Speicherpfad:",
		Language.FR: "Répertoire des échantillons audio :",
		Language.ES: "Ruta de muestras de audio:",
		Language.IT: "Percorso campioni audio:"
	},
	"SETTINGS_EXPORTS_DIR_LABEL": {
		Language.EN: "Rendered Exports Storage Path:",
		Language.DE: "Audio-Exporte Speicherpfad:",
		Language.FR: "Répertoire des exports audio :",
		Language.ES: "Ruta de exportaciones:",
		Language.IT: "Percorso esportazioni:"
	},
	"SETTINGS_SOFA_LABEL": {
		Language.EN: "Default Custom HRTF SOFA File (Optional):",
		Language.DE: "Standard HRTF SOFA-Datei (Optional):",
		Language.FR: "Fichier HRTF SOFA par défaut (Optionnel) :",
		Language.ES: "Archivo HRTF SOFA predeterminado (Opcional):",
		Language.IT: "File HRTF SOFA predefinito (Opzionale):"
	},
	"SETTINGS_FFMPEG_PATH_LABEL": {
		Language.EN: "FFmpeg Executable Binary Path:",
		Language.DE: "FFmpeg ausführbare Programmdatei:",
		Language.FR: "Chemin du binaire FFmpeg :",
		Language.ES: "Ruta del ejecutable FFmpeg:",
		Language.IT: "Percorso eseguibile FFmpeg:"
	},
	"SETTINGS_FFMPEG_TEST_BTN": {
		Language.EN: "Test FFmpeg",
		Language.DE: "FFmpeg testen",
		Language.FR: "Tester FFmpeg",
		Language.ES: "Probar FFmpeg",
		Language.IT: "Testa FFmpeg"
	},
	"BTN_BROWSE": {
		Language.EN: "Browse...",
		Language.DE: "Durchsuchen...",
		Language.FR: "Parcourir...",
		Language.ES: "Examinar...",
		Language.IT: "Sfoglia..."
	},
	"BTN_SAVE_CHANGES": {
		Language.EN: "Save Changes",
		Language.DE: "Änderungen speichern",
		Language.FR: "Enregistrer les modifications",
		Language.ES: "Guardar cambios",
		Language.IT: "Salva modifiche"
	},
	"DLG_EDIT_SOUND_TITLE": {
		Language.EN: "Edit Sound Properties",
		Language.DE: "Sound-Eigenschaften bearbeiten",
		Language.FR: "Modifier les propriétés du son",
		Language.ES: "Editar propiedades del sonido",
		Language.IT: "Modifica proprietà del suono"
	},
	"LBL_SOUND_NAME": {
		Language.EN: "Sound / Stem Name:",
		Language.DE: "Sound / Spur-Name:",
		Language.FR: "Nom du son / de la piste :",
		Language.ES: "Nombre del sonido / pista:",
		Language.IT: "Nome del suono / traccia:"
	},
	"LBL_CATEGORY": {
		Language.EN: "Category:",
		Language.DE: "Kategorie:",
		Language.FR: "Catégorie :",
		Language.ES: "Categoría:",
		Language.IT: "Categoria:"
	},
	"LBL_ACCENT_COLOR": {
		Language.EN: "Accent Color Glow:",
		Language.DE: "Akzentfarb-Leuchten:",
		Language.FR: "Couleur d'accent :",
		Language.ES: "Color de acento:",
		Language.IT: "Colore d'accento:"
	},
	"BTN_DOWNLOAD_IMPORT": {
		Language.EN: "Download & Import...",
		Language.DE: "Herunterladen & Importieren...",
		Language.FR: "Télécharger & Importer...",
		Language.ES: "Descargar e Importar...",
		Language.IT: "Scarica e Importa..."
	},
	"TOOLTIP_DOWNLOAD_IMPORT": {
		Language.EN: "Download and import soundscapes from ambient-mixer.com",
		Language.DE: "Soundscapes von ambient-mixer.com herunterladen und importieren",
		Language.FR: "Télécharger et importer des soundscapes depuis ambient-mixer.com",
		Language.ES: "Descargar e importar soundscapes de ambient-mixer.com",
		Language.IT: "Scarica e importa soundscape da ambient-mixer.com"
	},
	"LBL_DOWNLOAD_URL": {
		Language.EN: "Paste Ambient-Mixer Soundscape URL or ID:",
		Language.DE: "Ambient-Mixer-URL oder -ID einfügen:",
		Language.FR: "Coller l'URL ou l'ID Ambient-Mixer :",
		Language.ES: "Pegar URL o ID de Ambient-Mixer:",
		Language.IT: "Incolla URL o ID Ambient-Mixer:"
	},
	"BTN_LOAD_PROJECT": {
		Language.EN: "Load Project",
		Language.DE: "Projekt laden",
		Language.FR: "Charger le projet",
		Language.ES: "Cargar proyecto",
		Language.IT: "Carica progetto"
	},
	"TOOLTIP_CHANGE_COVER": {
		Language.EN: "Change Cover Artwork",
		Language.DE: "Titelbild ändern",
		Language.FR: "Changer la pochette",
		Language.ES: "Cambiar portada",
		Language.IT: "Cambia copertina"
	},
	"TOOLTIP_EDIT_SOUNDSCAPE": {
		Language.EN: "Edit Soundscape Info & Category",
		Language.DE: "Soundscape-Info & Kategorie bearbeiten",
		Language.FR: "Modifier les infos et la catégorie",
		Language.ES: "Editar información y categoría",
		Language.IT: "Modifica informazioni e categoria"
	},
	"TOOLTIP_DELETE_SOUNDSCAPE": {
		Language.EN: "Delete Soundscape from Library",
		Language.DE: "Soundscape aus der Bibliothek löschen",
		Language.FR: "Supprimer le soundscape de la bibliothèque",
		Language.ES: "Eliminar soundscape de la biblioteca",
		Language.IT: "Elimina soundscape dalla libreria"
	},
	"DLG_EDIT_SOUNDSCAPE_TITLE": {
		Language.EN: "Edit Soundscape Properties",
		Language.DE: "Soundscape-Eigenschaften bearbeiten",
		Language.FR: "Modifier les propriétés du soundscape",
		Language.ES: "Editar propiedades del soundscape",
		Language.IT: "Modifica proprietà del soundscape"
	},
	"LBL_SOUNDSCAPE_TITLE": {
		Language.EN: "Soundscape Title:",
		Language.DE: "Soundscape-Titel:",
		Language.FR: "Titre du soundscape :",
		Language.ES: "Título del soundscape:",
		Language.IT: "Titolo del soundscape:"
	},
	"LBL_AUTHOR": {
		Language.EN: "Author:",
		Language.DE: "Autor:",
		Language.FR: "Auteur :",
		Language.ES: "Autor:",
		Language.IT: "Autore:"
	},
	"EMPTY_SOUNDSCAPES_DESC": {
		Language.EN: "No soundscapes found in this category.\nClick 'Download & Import...' to get soundscapes from ambient-mixer.com or save a soundscape in the Studio!",
		Language.DE: "Keine Soundscapes in dieser Kategorie gefunden.\nKlicke auf 'Herunterladen & Importieren...' oder speichere eine Soundscape im Studio!",
		Language.FR: "Aucun soundscape dans cette catégorie.\nCliquez sur 'Télécharger & Importer...' ou créez-en un dans le Studio !",
		Language.ES: "No hay soundscapes en esta categoría.\n¡Haz clic en 'Descargar e Importar...' o crea uno en el Studio!",
		Language.IT: "Nessun soundscape in questa categoria.\nFai clic su 'Scarica e Importa...' o creane uno nello Studio!"
	},
	"EMPTY_SAMPLES_DESC": {
		Language.EN: "No audio samples match the current filter.\nClick 'Import Audio...' to add audio files from your computer.",
		Language.DE: "Keine Audiosamples entsprechen dem Filter.\nKlicke auf 'Audio importieren...', um Dateien hinzuzufügen.",
		Language.FR: "Aucun échantillon audio ne correspond.\nCliquez sur 'Importer audio...' pour ajouter des fichiers.",
		Language.ES: "No hay muestras que coincidan.\nHaz clic en 'Importar audio...' para añadir archivos.",
		Language.IT: "Nessun campione corrisponde al filtro.\nFai clic su 'Importa audio...' per aggiungere file."
	},
	"INSP_STEM_NAME": {
		Language.EN: "Stem / Audio Track Name",
		Language.DE: "Spur- / Stem-Name",
		Language.FR: "Nom de la piste / de l'élément",
		Language.ES: "Nombre de la pista",
		Language.IT: "Nome della traccia"
	},
	"INSP_AUDIO_SOURCE": {
		Language.EN: "Audio Source File",
		Language.DE: "Audiodatei-Quelle",
		Language.FR: "Fichier source audio",
		Language.ES: "Archivo de origen de audio",
		Language.IT: "File sorgente audio"
	},
	"INSP_ACCENT_COLOR": {
		Language.EN: "Track Accent Color",
		Language.DE: "Spur-Akzentfarbe",
		Language.FR: "Couleur d'accent",
		Language.ES: "Color de acento",
		Language.IT: "Colore d'accento"
	},
	"INSP_RADAR_ICON": {
		Language.EN: "Radar Sound Icon",
		Language.DE: "Radar Sound-Symbol",
		Language.FR: "Icône sur le canevas radar",
		Language.ES: "Icono en radar",
		Language.IT: "Icona sul radar"
	},
	"INSP_ROUTING": {
		Language.EN: "Spatial Routing",
		Language.DE: "Räumliches Routing",
		Language.FR: "Routage spatial",
		Language.ES: "Enrutamiento espacial",
		Language.IT: "Routing spaziale"
	},
	"INSP_SPATIAL_POS": {
		Language.EN: "3D Spatial Positioning",
		Language.DE: "3D-Raumpositionierung",
		Language.FR: "Positionnement spatial 3D",
		Language.ES: "Posicionamiento espacial 3D",
		Language.IT: "Posizionamento spaziale 3D"
	},
	"INSP_AZIMUTH": {
		Language.EN: "Azimuth (°)",
		Language.DE: "Azimut (°)",
		Language.FR: "Azimut (°)",
		Language.ES: "Azimut (°)",
		Language.IT: "Azimut (°)"
	},
	"INSP_ELEVATION": {
		Language.EN: "Elevation (°)",
		Language.DE: "Höhe / Elevation (°)",
		Language.FR: "Élévation (°)",
		Language.ES: "Elevación (°)",
		Language.IT: "Elevazione (°)"
	},
	"INSP_DISTANCE": {
		Language.EN: "Distance (m)",
		Language.DE: "Entfernung (m)",
		Language.FR: "Distance (m)",
		Language.ES: "Distancia (m)",
		Language.IT: "Distanza (m)"
	},
	"INSP_MOVEMENT_AUTO": {
		Language.EN: "Movement Pattern",
		Language.DE: "Bewegungsmuster",
		Language.FR: "Modèle de mouvement",
		Language.ES: "Patrón de movimiento",
		Language.IT: "Pattern di movimento"
	},
	"INSP_MOV_TIMING": {
		Language.EN: "Movement Timing",
		Language.DE: "Bewegungs-Timing",
		Language.FR: "Synchronisation de mouvement",
		Language.ES: "Sincronización de movimiento",
		Language.IT: "Tempistica del movimento"
	},
	"INSP_MOV_SPEED": {
		Language.EN: "Velocity / Movement Speed",
		Language.DE: "Geschwindigkeit / Tempo",
		Language.FR: "Vitesse de déplacement",
		Language.ES: "Velocidad de movimiento",
		Language.IT: "Velocità di movimento"
	},
	"INSP_ROAM_RADIUS": {
		Language.EN: "Roam Boundary (Max Radius)",
		Language.DE: "Wander-Grenze (Max Radius)",
		Language.FR: "Rayon de déplacement maximal",
		Language.ES: "Radio máximo de movimiento",
		Language.IT: "Raggio massimo di movimento"
	},
	"INSP_TRIGGER_INTERVALS": {
		Language.EN: "Trigger & Intervals",
		Language.DE: "Trigger & Intervalle",
		Language.FR: "Déclenchement & Intervalles",
		Language.ES: "Disparador e Intervalos",
		Language.IT: "Trigger e Intervalli"
	},
	"INSP_MULTI_CHANNEL": {
		Language.EN: "Direct Speaker Routing:",
		Language.DE: "Direkte Lautsprecherzuweisung:",
		Language.FR: "Attribution directe aux haut-parleurs :",
		Language.ES: "Enrutamiento directo a altavoces:",
		Language.IT: "Assegnazione diretta agli altoparlanti:"
	},
	"INSP_OMNIPRESENT_DESC": {
		Language.EN: "🌐 Omnipresent Sound Bed (Active on all channels without 3D attenuation)",
		Language.DE: "🌐 Omnipräsenter Klangteppich (Auf allen Kanälen ohne 3D-Abschwächung aktiv)",
		Language.FR: "🌐 Tapis sonore omniprésent (Actif sur tous les canaux sans atténuation 3D)",
		Language.ES: "🌐 Capa sonora omnipresente (Activo en todos los canales sin atenuación 3D)",
		Language.IT: "🌐 Tappeto sonoro onnipresente (Attivo su tutti i canali senza attenuazione 3D)"
	},
	"BTN_IMPORT_LOCAL": {
		Language.EN: "Import Package...",
		Language.DE: "Paket importieren...",
		Language.FR: "Importer paquet...",
		Language.ES: "Importar paquete...",
		Language.IT: "Importa pacchetto..."
	},
	"TOOLTIP_IMPORT_PACKAGE": {
		Language.EN: "Import local soundscape package (.3dscape, .zip)",
		Language.DE: "Lokales Soundscape-Paket importieren (.3dscape, .zip)",
		Language.FR: "Importer un paquet de soundscape local (.3dscape, .zip)",
		Language.ES: "Importar paquete de soundscape local (.3dscape, .zip)",
		Language.IT: "Importa pacchetto soundscape locale (.3dscape, .zip)"
	},
	"BTN_EXPORT_PACKAGE": {
		Language.EN: "Export Package",
		Language.DE: "Paket exportieren",
		Language.FR: "Exporter paquet",
		Language.ES: "Exportar paquete",
		Language.IT: "Esporta pacchetto"
	},
	"TOOLTIP_EXPORT_PACKAGE": {
		Language.EN: "Export soundscape project package (.3dscape) to share with others",
		Language.DE: "Soundscape-Projektpaket (.3dscape) zum Teilen exportieren",
		Language.FR: "Exporter le paquet de projet soundscape (.3dscape) pour le partager",
		Language.ES: "Exportar paquete de proyecto soundscape (.3dscape) para compartir",
		Language.IT: "Esporta il pacchetto di progetto soundscape (.3dscape) per la condivisione"
	},
	"DLG_IMPORT_PKG_TITLE": {
		Language.EN: "Select Soundscape Package to Import",
		Language.DE: "Soundscape-Paket zum Importieren auswählen",
		Language.FR: "Sélectionner le paquet de soundscape à importer",
		Language.ES: "Seleccionar paquete de soundscape para importar",
		Language.IT: "Seleziona pacchetto soundscape da importare"
	},
	"DLG_EXPORT_PKG_TITLE": {
		Language.EN: "Export Soundscape Package",
		Language.DE: "Soundscape-Paket exportieren",
		Language.FR: "Exporter le paquet de soundscape",
		Language.ES: "Exportar paquete de soundscape",
		Language.IT: "Esporta pacchetto soundscape"
	},
	"MSG_IMPORT_SUCCESS": {
		Language.EN: "Soundscape imported successfully into library!",
		Language.DE: "Soundscape erfolgreich in die Bibliothek importiert!",
		Language.FR: "Soundscape importé avec succès dans la bibliothèque !",
		Language.ES: "¡Soundscape importado con éxito en la biblioteca!",
		Language.IT: "Soundscape importato con successo nella libreria!"
	},
	"MSG_EXPORT_SUCCESS": {
		Language.EN: "Soundscape package exported successfully!",
		Language.DE: "Soundscape-Paket erfolgreich exportiert!",
		Language.FR: "Paquet de soundscape exporté avec succès !",
		Language.ES: "¡Paquete de soundscape exportado con éxito!",
		Language.IT: "Pacchetto soundscape esportato con successo!"
	},
	"EXPORT_TAB_PACKAGE": {
		Language.EN: "Project Package (.3dscape)",
		Language.DE: "Projekt-Paket (.3dscape)",
		Language.FR: "Paquet de projet (.3dscape)",
		Language.ES: "Paquete de proyecto (.3dscape)",
		Language.IT: "Pacchetto di progetto (.3dscape)"
	},
	"EXPORT_PACKAGE_DESC": {
		Language.EN: "Export complete portable package with project settings, metadata, and all audio stems for sharing.",
		Language.DE: "Vollständiges portables Paket mit Projekteinstellungen, Metadaten und allen Audiospuren zum Teilen exportieren.",
		Language.FR: "Exporter un paquet portable complet avec paramètres, métadonnées et toutes les pistes audio pour le partage.",
		Language.ES: "Exportar paquete portátil completo con configuraciones, metadatos y todas las pistas de audio para compartir.",
		Language.IT: "Esporta un pacchetto portatile completo con impostazioni, metadati e tutte le tracce audio da condividere."
	},
	"TAB_AI_GEN": {
		Language.EN: "Local AI Sound Generation (audio.cpp)",
		Language.DE: "Lokale KI-Soundgenerierung (audio.cpp)",
		Language.FR: "Génération de son IA locale (audio.cpp)",
		Language.ES: "Generación de sonido IA local (audio.cpp)",
		Language.IT: "Generazione audio IA locale (audio.cpp)"
	},
	"PROMPT_AI_GEN_PLACEHOLDER": {
		Language.EN: "Describe the sound to synthesize (e.g. Whispering pine wind with temple chimes, Deep distant thunder)...",
		Language.DE: "Beschreibe den zu generierenden Klang (z.B. Flüsternder Kiefernwind mit Tempelglocken, Tiefes Donnergrollen)...",
		Language.FR: "Décrivez le son à synthétiser (ex. Vent murmurant dans les pins avec cloches de temple, Tonnerre lointain)...",
		Language.ES: "Describe el sonido a sintetizar (ej. Viento susurrante entre pinos con campanas de templo, Trueno lejano)...",
		Language.IT: "Descrivi il suono da sintetizzare (es. Vento tra i pini con campane del tempio, Tuono distante)..."
	},
	"BTN_GENERATE_AI_SOUND": {
		Language.EN: "Generate AI Sound Stem",
		Language.DE: "KI-Soundspur generieren",
		Language.FR: "Générer la piste audio IA",
		Language.ES: "Generar pista de audio IA",
		Language.IT: "Genera traccia audio IA"
	},
	"BTN_PREVIEW": {
		Language.EN: "Preview",
		Language.DE: "Vorhören",
		Language.FR: "Écouter",
		Language.ES: "Escuchar",
		Language.IT: "Ascolta"
	},
	"BTN_ADD_AS_3D_TRACK": {
		Language.EN: "Add as 3D Track",
		Language.DE: "Als 3D-Spur einfügen",
		Language.FR: "Ajouter en piste 3D",
		Language.ES: "Añadir como pista 3D",
		Language.IT: "Aggiungi come traccia 3D"
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

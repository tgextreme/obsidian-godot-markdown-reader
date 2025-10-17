extends Control

# Referencias a nodos UI básicos
@onready var welcome_screen: Control = $WelcomeScreen
@onready var file_dialog: FileDialog = $FileDialog
@onready var reader: RichTextLabel = $UI/VBoxContainer/PanelContainer/ScrollContainer/MarginContainer/Reader
@onready var ui_panel: Control = $UI
@onready var back_button: Button = $UI/VBoxContainer/TopBar/BackButton

# Referencias a controles TTS
@onready var tts_play_button: Button = $UI/VBoxContainer/TopBar/TTSContainer/TTSPlayButton
@onready var tts_pause_button: Button = $UI/VBoxContainer/TopBar/TTSContainer/TTSPauseButton
@onready var tts_stop_button: Button = $UI/VBoxContainer/TopBar/TTSContainer/TTSStopButton
@onready var tts_speed_option: OptionButton = $UI/VBoxContainer/TopBar/TTSContainer/TTSSpeedOption

# Variables básicas
var current_note_content: String = ""
var current_note_path: String = ""

# Variables TTS
var tts_playing: bool = false
var tts_paused: bool = false
var current_tts_text: String = ""
var tts_speed: float = 1.0
var available_speeds: Array[float] = [1.0, 1.25, 1.5, 1.75, 2.0]
var speed_labels: Array[String] = ["x1.0", "x1.25", "x1.5", "x1.75", "x2.0"]

func _ready():
	print("=== INICIANDO MDREADER v2 ===")
	
	# Conectar señales de AppState
	AppState.theme_changed.connect(_on_theme_changed)
	AppState.font_size_changed.connect(_on_font_size_changed)
	
	# Configurar FileDialog para importar archivos .md
	setup_file_dialog()
	
	# Aplicar configuración inicial
	apply_current_theme()
	apply_current_font_size()
	
	# Configurar controles TTS
	setup_tts_controls()
	
	# Asegurar que se muestre la pantalla de bienvenida
	show_welcome_screen()
	
	# Llamada adicional para asegurar visibilidad
	await get_tree().process_frame
	show_welcome_screen()
	
	print("=== MDREADER v2 LISTO ===")

func setup_file_dialog():
	"""Configura el diálogo de archivos para importar .md"""
	if file_dialog:
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
		file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		file_dialog.add_filter("*.md", "Archivos Markdown")
		file_dialog.add_filter("*.txt", "Archivos de texto")
		file_dialog.size = Vector2i(700, 500)
		print("FileDialog configurado correctamente")
	else:
		print("ERROR: No se encontró FileDialog")

func show_welcome_screen():
	"""Muestra la pantalla de bienvenida"""
	print("=== SHOW_WELCOME_SCREEN ===")
	
	# Forzar estados
	if welcome_screen:
		welcome_screen.visible = true
		welcome_screen.modulate = Color.WHITE
		print("WelcomeScreen: visible=", welcome_screen.visible)
	else:
		print("ERROR: WelcomeScreen no encontrado")
	
	if ui_panel:
		ui_panel.visible = false
		print("UI Panel: visible=", ui_panel.visible)
	else:
		print("ERROR: UI Panel no encontrado")
	
	print("===========================")

func show_reader():
	"""Muestra el lector de contenido"""
	if welcome_screen:
		welcome_screen.visible = false
		
	if ui_panel:
		ui_panel.visible = true

# ===== SEÑALES DE BOTONES =====

func _on_import_button_pressed():
	"""Botón importar - abrir diálogo de archivos"""
	print("Botón importar presionado")
	if file_dialog:
		file_dialog.popup_centered()
		print("FileDialog abierto")
	else:
		print("ERROR: FileDialog no disponible")

func _on_file_dialog_files_selected(paths: PackedStringArray):
	"""Archivos seleccionados en el diálogo"""
	print("Archivos seleccionados: ", paths.size())
	
	if paths.size() > 0:
		var first_file = paths[0]
		print("Cargando archivo: ", first_file)
		load_markdown_file(first_file)

func load_markdown_file(file_path: String):
	"""Carga un archivo Markdown"""
	print("Intentando cargar: ", file_path)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("ERROR: No se pudo abrir el archivo")
		show_error("No se pudo abrir el archivo")
		return
	
	var content = file.get_as_text()
	file.close()
	
	print("Archivo leído, tamaño: ", content.length(), " caracteres")
	
	if content.length() > 0:
		display_content(content)
		show_reader()
	else:
		print("ERROR: Archivo vacío")
		show_error("El archivo está vacío")

func display_content(content: String):
	"""Muestra el contenido en el lector usando el parser de Markdown"""
	# Guardar el contenido original para TTS
	current_note_content = content
	print("Contenido guardado para TTS: ", current_note_content.length(), " caracteres")
	
	if reader:
		# Usar el parser de Markdown para convertir a BBCode
		var bbcode_content = Markdown.parse_to_bbcode(content)
		reader.clear()
		reader.bbcode_enabled = true
		reader.text = bbcode_content
		
		# Aplicar tamaño de fuente actual
		apply_current_font_size()
		
		print("Contenido Markdown mostrado en el lector")
		print("Primeros 100 caracteres: ", bbcode_content.substr(0, 100))
	else:
		print("ERROR: Reader no disponible")

func show_error(message: String):
	"""Muestra un mensaje de error"""
	print("ERROR: ", message)
	# Aquí podrías añadir un diálogo de error más adelante

func _on_exit_button_pressed():
	"""Botón salir"""
	print("Saliendo de la aplicación")
	get_tree().quit()

func _on_settings_button_pressed():
	print("Configuración presionada")

func _on_about_button_pressed():
	print("Acerca de presionado")

func _on_light_theme_button_pressed():
	print("Tema claro seleccionado")
	AppState.set_theme("light")

func _on_dark_theme_button_pressed():
	print("Tema oscuro seleccionado")
	AppState.set_theme("dark")

func _on_contrast_theme_button_pressed():
	print("Alto contraste seleccionado")
	AppState.set_theme("high_contrast")

func _on_back_button_pressed():
	"""Botón para regresar al menú principal"""
	print("Regresando al menú principal")
	show_welcome_screen()

# ===== FUNCIONES DE TEMA Y FUENTE =====

func _on_theme_changed(_theme_name: String):
	"""Responde al cambio de tema desde AppState"""
	apply_current_theme()

func _on_font_size_changed(_new_size: int):
	"""Responde al cambio de tamaño de fuente desde AppState"""
	apply_current_font_size()

func apply_current_theme():
	"""Aplica el tema actual desde AppState"""
	print("Aplicando tema: ", AppState.current_theme)
	# La implementación real del tema se haría aquí
	# Por ahora solo debug

func apply_current_font_size():
	"""Aplica el tamaño de fuente actual desde AppState"""
	print("Aplicando tamaño de fuente: ", AppState.font_size_pt, "pt")
	if reader:
		reader.add_theme_font_size_override("normal_font_size", AppState.font_size_pt)
		reader.add_theme_font_size_override("bold_font_size", AppState.font_size_pt)
		reader.add_theme_font_size_override("italics_font_size", AppState.font_size_pt)

# ===== FUNCIONES DE CONTROL DE FUENTE =====

func _on_font_plus_button_pressed():
	"""Incrementar tamaño de fuente"""
	AppState.increment_font_size()

func _on_font_minus_button_pressed():
	"""Decrementar tamaño de fuente"""
	AppState.decrement_font_size()

# ===== FUNCIONES TTS (Text-to-Speech) =====

func setup_tts_controls():
	"""Configura los controles TTS"""
	if tts_speed_option:
		tts_speed_option.clear()
		for i in range(speed_labels.size()):
			tts_speed_option.add_item(speed_labels[i], i)
		tts_speed_option.select(0)  # Seleccionar x1.0 por defecto
		print("Controles TTS configurados con ", speed_labels.size(), " velocidades")
	
	# Hacer una prueba simple de TTS al configurar
	test_tts_basic()
	
	update_tts_button_states()

func test_tts_basic():
	"""Prueba básica de TTS para verificar que funciona"""
	print("=== PRUEBA BÁSICA TTS ===")
	print("Plataforma: ", OS.get_name())
	
	# Verificar voces disponibles
	var voices = DisplayServer.tts_get_voices()
	print("Voces TTS disponibles: ", voices.size())
	
	if voices.size() == 0:
		print("ERROR: No hay voces TTS disponibles")
		show_error("Error TTS: No hay voces instaladas en Windows.\n\nVe a Configuración → Hora e idioma → Voz\ny asegúrate de que hay voces instaladas.")
		return
	
	for i in range(min(voices.size(), 3)):
		print("Voz ", i, ": ", voices[i])
	
	# Probar con texto muy simple
	print("Probando TTS con texto básico...")
	DisplayServer.tts_speak("Prueba de sistema de voz", "", 80, 1.0, 1.0)
	
	await get_tree().create_timer(0.5).timeout
	var is_working = DisplayServer.tts_is_speaking()
	print("TTS funcionando después de prueba: ", is_working)
	
	if not is_working:
		print("WARNING: TTS no parece estar funcionando")
		show_error("Advertencia TTS: El sistema de voz no responde.\n\nVerifica:\n1. Volumen del sistema\n2. Dispositivos de audio conectados\n3. Permisos de la aplicación")
	else:
		print("TTS funcionando correctamente")
	
	# Limpiar después de la prueba
	await get_tree().create_timer(2.0).timeout
	DisplayServer.tts_stop()
	print("=== FIN PRUEBA BÁSICA ===")

func _on_tts_play_button_pressed():
	"""Reproducir TTS del contenido actual"""
	print("=== TTS PLAY BUTTON PRESSED ===")
	print("Contenido de nota actual: ", current_note_content.length(), " caracteres")
	
	if current_note_content.is_empty():
		print("ERROR: No hay contenido para reproducir")
		show_error("No hay contenido cargado para reproducir")
		return
	
	if tts_playing and not tts_paused:
		# Si ya está reproduciendo, pausar
		print("Ya reproduciendo, pausando...")
		_on_tts_pause_button_pressed()
		return
	
	if tts_paused and current_tts_text == current_note_content:
		# Resumir si está pausado y es el mismo texto
		print("Resumiendo TTS pausado...")
		resume_tts()
	else:
		# Iniciar nueva reproducción
		print("Iniciando nueva reproducción TTS...")
		start_tts()

func _on_tts_pause_button_pressed():
	"""Pausar TTS"""
	print("TTS Pause presionado")
	
	if tts_playing and not tts_paused:
		pause_tts()

func _on_tts_stop_button_pressed():
	"""Detener TTS"""
	print("TTS Stop presionado")
	
	if tts_playing or tts_paused:
		stop_tts()

func _on_tts_speed_option_item_selected(index: int):
	"""Cambiar velocidad TTS"""
	if index >= 0 and index < available_speeds.size():
		tts_speed = available_speeds[index]
		print("Velocidad TTS cambiada a: ", speed_labels[index], " (", tts_speed, "x)")
		
		# Si está reproduciendo, reiniciar con nueva velocidad
		if tts_playing and not tts_paused:
			restart_tts_with_new_speed()

func start_tts():
	"""Inicia la reproducción TTS"""
	print("=== DEBUG TTS START ===")
	print("Contenido actual disponible: ", not current_note_content.is_empty())
	print("Longitud del contenido: ", current_note_content.length())
	
	# Usar texto de prueba simple si no hay contenido
	var text_to_speak = current_note_content
	if text_to_speak.is_empty():
		text_to_speak = "Hola, esto es una prueba de texto a voz en español."
	
	var clean_text = clean_text_for_tts(text_to_speak)
	
	# Si el texto limpio está vacío, usar texto de emergencia
	if clean_text.is_empty() or clean_text.length() < 5:
		clean_text = "Prueba de texto a voz. Uno, dos, tres."
	
	print("Texto limpio longitud: ", clean_text.length())
	print("Texto a reproducir: ", clean_text.substr(0, 100))
	
	# Verificar si TTS está disponible en la plataforma
	print("Plataforma actual: ", OS.get_name())
	
	# Detener cualquier TTS anterior
	DisplayServer.tts_stop()
	await get_tree().process_frame
	
	# Obtener voces disponibles
	var voices = DisplayServer.tts_get_voices()
	print("Voces disponibles: ", voices.size())
	
	var voice_id = ""
	if voices.size() > 0:
		print("Primera voz: ", voices[0])
		# Buscar una voz en español o usar la primera disponible
		for voice in voices:
			if voice is Dictionary:
				if voice.has("language") and "es" in voice.get("language", "").to_lower():
					voice_id = voice.get("id", "")
					print("Usando voz en español: ", voice)
					break
				elif voice.has("id"):
					voice_id = voice.get("id", "")
		if voice_id == "" and voices[0] is Dictionary and voices[0].has("id"):
			voice_id = voices[0]["id"]
	
	print("Voice ID seleccionado: ", voice_id)
	
	# Configurar TTS con diferentes parámetros según la plataforma
	var volume = 100  # Volumen máximo
	var pitch = 1.0   # Tono normal
	var rate = tts_speed  # Velocidad seleccionada
	var utterance_id = 0
	var interrupt = true  # Interrumpir cualquier audio anterior
	
	print("Parámetros TTS - Volume:", volume, " Pitch:", pitch, " Rate:", rate)
	print("Llamando DisplayServer.tts_speak...")
	
	# Llamar TTS con parámetros completos
	DisplayServer.tts_speak(clean_text, voice_id, volume, pitch, rate, utterance_id, interrupt)
	
	# Verificar inmediatamente si comenzó
	await get_tree().process_frame
	var speaking_check1 = DisplayServer.tts_is_speaking()
	print("TTS hablando (inmediato): ", speaking_check1)
	
	# Verificar después de un breve delay
	await get_tree().create_timer(0.3).timeout
	var speaking_check2 = DisplayServer.tts_is_speaking()
	print("TTS hablando (después de 0.3s): ", speaking_check2)
	
	if speaking_check1 or speaking_check2:
		tts_playing = true
		tts_paused = false
		current_tts_text = text_to_speak
		print("TTS iniciado exitosamente")
	else:
		print("WARNING: TTS no parece haber iniciado")
		# Intentar con parámetros mínimos
		print("Intentando con parámetros mínimos...")
		DisplayServer.tts_speak(clean_text, "", 50, 1.0, 1.0)
		await get_tree().create_timer(0.3).timeout
		if DisplayServer.tts_is_speaking():
			tts_playing = true
			tts_paused = false
			current_tts_text = text_to_speak
			print("TTS iniciado con parámetros mínimos")
		else:
			print("ERROR: TTS no funcionó ni con parámetros mínimos")
			show_error("❌ Error TTS: No se pudo iniciar el texto a voz.\n\n🔧 Soluciones:\n1. Verifica el volumen del sistema\n2. Ve a Configuración → Voz en Windows\n3. Asegúrate de que hay voces instaladas\n4. Reinicia la aplicación\n\n📋 Ver TTS_TROUBLESHOOTING.md para más ayuda")
			tts_playing = false
	
	update_tts_button_states()
	print("=== FIN DEBUG TTS START ===")

func pause_tts():
	"""Pausa la reproducción TTS"""
	if DisplayServer.tts_is_speaking():
		DisplayServer.tts_pause()
		tts_paused = true
		update_tts_button_states()
		print("TTS pausado")

func resume_tts():
	"""Reanuda la reproducción TTS"""
	if DisplayServer.tts_is_paused():
		DisplayServer.tts_resume()
		tts_paused = false
		update_tts_button_states()
		print("TTS reanudado")

func stop_tts():
	"""Detiene la reproducción TTS"""
	DisplayServer.tts_stop()
	tts_playing = false
	tts_paused = false
	current_tts_text = ""
	update_tts_button_states()
	print("TTS detenido")

func restart_tts_with_new_speed():
	"""Reinicia TTS con nueva velocidad"""
	if tts_playing and not tts_paused:
		stop_tts()
		await get_tree().process_frame  # Esperar un frame
		start_tts()

func update_tts_button_states():
	"""Actualiza el estado visual de los botones TTS"""
	if not tts_play_button or not tts_pause_button or not tts_stop_button:
		return
	
	# Resetear colores
	tts_play_button.modulate = Color.WHITE
	tts_pause_button.modulate = Color.WHITE
	tts_stop_button.modulate = Color.WHITE
	
	if tts_playing and not tts_paused:
		# Reproduciendo - resaltar pause
		tts_pause_button.modulate = Color.YELLOW
		tts_play_button.text = "⏸️"  # Cambiar ícono a pause
	elif tts_paused:
		# Pausado - resaltar play
		tts_play_button.modulate = Color.YELLOW
		tts_play_button.text = "▶️"  # Cambiar ícono a play
	else:
		# Detenido - estado normal
		tts_play_button.text = "▶️"

func clean_text_for_tts(markdown_text: String) -> String:
	"""Limpia el texto markdown para TTS, removiendo símbolos de formato"""
	var clean_text = markdown_text
	
	# Remover encabezados markdown
	var header_regex = RegEx.new()
	header_regex.compile("#{1,6}\\s*")
	clean_text = header_regex.sub(clean_text, "", true)
	
	# Remover formato de código
	var code_regex = RegEx.new()
	code_regex.compile("`([^`]+)`")
	clean_text = code_regex.sub(clean_text, "$1", true)
	
	# Remover bloques de código
	var code_block_regex = RegEx.new()
	code_block_regex.compile("```[\\s\\S]*?```")
	clean_text = code_block_regex.sub(clean_text, "", true)
	
	# Remover negrita y cursiva
	clean_text = clean_text.replace("**", "")
	clean_text = clean_text.replace("*", "")
	clean_text = clean_text.replace("~~", "")
	
	# Remover enlaces markdown
	var link_regex = RegEx.new()
	link_regex.compile("\\[([^\\]]+)\\]\\([^\\)]+\\)")
	clean_text = link_regex.sub(clean_text, "$1", true)
	
	# Remover viñetas de lista
	var list_regex = RegEx.new()
	list_regex.compile("^\\s*[-*+]\\s+")
	var lines = clean_text.split("\n")
	var cleaned_lines = []
	for line in lines:
		var result = list_regex.sub(line, "", false)
		cleaned_lines.append(result)
	clean_text = "\n".join(cleaned_lines)
	
	# Limpiar espacios múltiples
	var space_regex = RegEx.new()
	space_regex.compile("\\s+")
	clean_text = space_regex.sub(clean_text, " ", true)
	
	# Limpiar bordes
	clean_text = clean_text.strip_edges()
	
	return clean_text
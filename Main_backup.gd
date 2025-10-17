extends Control

# Referencias a nodos de la UI
@onready var reader: RichTextLabel = $UI/PanelContainer/ScrollContainer/MarginContainer/Reader
@onready var top_menu_bar: VBoxContainer = $UI/TopMenuBar
@onready var welcome_screen: Control = $WelcomeScreen
@onready var file_dialog: FileDialog = $FileDialog
@onready var settings_dialog: AcceptDialog = $SettingsDialog
@onready var font_size_slider: HSlider = $SettingsDialog/VBoxContainer/FontSizeSlider
@onready var font_size_value: Label = $SettingsDialog/VBoxContainer/FontSizeValue
@onready var theme_option: OptionButton = $SettingsDialog/VBoxContainer/ThemeOption

# Referencias a botones TTS (estructura vertical)
@onready var play_button: Button = $UI/TopMenuBar/BottomRow/TTSPlayButton
@onready var pause_button: Button = $UI/TopMenuBar/BottomRow/TTSPauseButton
@onready var stop_button: Button = $UI/TopMenuBar/BottomRow/TTSStopButton

# Referencias a control de velocidad TTS (estructura vertical)
@onready var speed_option: OptionButton = $UI/TopMenuBar/BottomRow/TTSSpeedOption

# Estado actual
var current_note_path: String = ""
var note_buttons: Array = []

# TTS (Text-to-Speech) variables
var tts_playing: bool = false
var tts_paused: bool = false
var current_tts_text: String = ""
var tts_speed: float = 1.0  # Velocidad: 0.5 = lento, 1.0 = normal, 1.5 = rápido

# Variables para control de velocidad alternativo
var tts_segments: PackedStringArray = []
var current_segment_index: int = 0
var tts_timer: Timer = null

func _ready():
	print("=== INICIANDO MDREADER ===")
	setup_ui()
	connect_signals()
	apply_theme()
	apply_font_size()
	
	# Asegurar que WelcomeScreen se muestre
	if welcome_screen:
		welcome_screen.visible = true
		print("WelcomeScreen configurado como visible")
	else:
		print("ERROR: No se pudo encontrar WelcomeScreen")
	
	# Ocultar UI principal inicialmente
	if top_menu_bar:
		top_menu_bar.visible = false
		print("TopMenuBar ocultado inicialmente")
	
	check_for_notes()
	
	# Inicializar estado TTS
	setup_speed_options()
	setup_tts_timer()
	update_tts_button_states()
	print("=== MDREADER INICIADO ===")

func setup_tts_timer():
	"""Configura el timer para control de velocidad TTS"""
	if not tts_timer:
		tts_timer = Timer.new()
		tts_timer.wait_time = 1.0
		tts_timer.timeout.connect(_on_tts_timer_timeout)
		add_child(tts_timer)

func setup_ui():
	"""Configura la interfaz inicial simplificada"""
	# Configurar FileDialog
	file_dialog.size = Vector2i(700, 500)
	file_dialog.min_size = Vector2i(600, 400)
	
	# Configurar opciones de tema
	theme_option.add_item("Claro", 0)
	theme_option.add_item("Oscuro", 1)
	theme_option.add_item("Alto Contraste", 2)
	
	# Seleccionar tema actual
	match AppState.current_theme:
		"light":
			theme_option.select(0)
		"dark":
			theme_option.select(1)
		"high_contrast":
			theme_option.select(2)
	
	# Configurar slider de fuente
	font_size_slider.value = AppState.font_size_pt
	
	# Configurar opciones de velocidad TTS
	setup_speed_options()

func connect_signals():
	"""Conecta las señales de los autoloads"""
	AppState.theme_changed.connect(_on_theme_changed)
	AppState.font_size_changed.connect(_on_font_size_changed)
	NoteIndex.notes_updated.connect(_on_notes_updated)

func apply_theme():
	"""Aplica el tema actual"""
	AppState.apply_theme_to_scene()
	update_theme_button_indicators()

func update_theme_button_indicators():
	"""Actualiza los indicadores visuales de los botones de tema"""
	# Obtener referencias a los botones (si existen)
	var light_buttons = [
		get_node_or_null("WelcomeScreen/PanelContainer/VBoxContainer/ThemeContainer/LightThemeButton"),
		get_node_or_null("VBoxContainer/TopMenuBar/CenterSection/ThemeButtonsContainer/LightButton")
	]
	var dark_buttons = [
		get_node_or_null("WelcomeScreen/PanelContainer/VBoxContainer/ThemeContainer/DarkThemeButton"),
		get_node_or_null("VBoxContainer/TopMenuBar/CenterSection/ThemeButtonsContainer/DarkButton")
	]
	var contrast_buttons = [
		get_node_or_null("WelcomeScreen/PanelContainer/VBoxContainer/ThemeContainer/HighContrastButton"),
		get_node_or_null("VBoxContainer/TopMenuBar/CenterSection/ThemeButtonsContainer/ContrastButton")
	]
	
	# Resetear todos los botones
	for button in light_buttons + dark_buttons + contrast_buttons:
		if button:
			button.modulate = Color.WHITE
	
	# Resaltar botón activo
	var active_buttons = []
	match AppState.current_theme:
		"light":
			active_buttons = light_buttons
		"dark":
			active_buttons = dark_buttons
		"high_contrast":
			active_buttons = contrast_buttons
	
	for button in active_buttons:
		if button:
			button.modulate = Color.YELLOW  # Indicador visual

func apply_font_size():
	"""Aplica el tamaño de fuente actual"""
	var base_size = AppState.font_size_pt
	
	# Aplicar al reader
	if reader:
		reader.add_theme_font_size_override("normal_font_size", base_size)
		reader.add_theme_font_size_override("bold_font_size", base_size)
		reader.add_theme_font_size_override("italics_font_size", base_size)
		reader.add_theme_font_size_override("mono_font_size", base_size - 2)
	
	# Actualizar valor en configuración
	if font_size_value:
		font_size_value.text = str(base_size) + "pt"

func check_for_notes():
	"""Muestra siempre el menú de opciones al arrancar"""
	print("=== CHECK_FOR_NOTES ===")
	if welcome_screen:
		welcome_screen.visible = true
		welcome_screen.modulate = Color.WHITE  # Asegurar que no esté transparente
		print("WelcomeScreen configurado como visible en check_for_notes")
		print("WelcomeScreen position: ", welcome_screen.position)
		print("WelcomeScreen size: ", welcome_screen.size)
	else:
		print("ERROR: welcome_screen es null en check_for_notes")
	print("=======================")

func load_note(note_path: String):
	"""Carga una nota específica"""
	current_note_path = note_path
	AppState.set_last_note(note_path)
	
	var content = NoteIndex.get_note_content(note_path)
	if content.length() > 0:
		var bbcode_content = Markdown.parse_to_bbcode(content)
		reader.text = bbcode_content
		welcome_screen.visible = false
		top_menu_bar.visible = true  # Mostrar menú superior cuando hay contenido
		
		# Parar TTS si está reproduciéndose al cambiar de nota
		if tts_playing or tts_paused:
			_on_tts_stop_button_pressed()
		
		# Actualizar estado de botones TTS
		update_tts_button_states()
	else:
		reader.text = "[center][color=red]Error: No se pudo cargar la nota[/color][/center]"
	
	print("Nota cargada: ", note_path)

func load_last_note():
	"""Carga la última nota vista"""
	if AppState.last_note.length() > 0:
		load_note(AppState.last_note)

# Señales del sistema
func _on_theme_changed(_new_theme: String):
	"""Responde al cambio de tema"""
	apply_theme()

func _on_font_size_changed(_new_size: int):
	"""Responde al cambio de tamaño de fuente"""
	apply_font_size()

func _on_notes_updated():
	"""Responde a la actualización de notas"""
	check_for_notes()

# Señales de la UI
func _on_import_button_pressed():
	"""Botón de importar en pantalla de bienvenida"""
	file_dialog.popup_centered()

func _on_settings_button_pressed():
	"""Botón de configuración en menú principal"""
	settings_dialog.popup_centered()

func _on_about_button_pressed():
	"""Botón Acerca de en menú principal"""
	show_about_dialog()

func _on_exit_button_pressed():
	"""Botón de salir en menú principal"""
	get_tree().quit()

func _on_home_button_pressed():
	"""Botón para volver al menú principal"""
	welcome_screen.visible = true
	top_menu_bar.visible = false

func _on_menu_button_pressed():
	"""Botón de menú - por ahora mismo comportamiento que home"""
	_on_home_button_pressed()

func _on_font_minus_button_pressed():
	"""Decrementar tamaño de fuente"""
	AppState.decrement_font_size()

func _on_font_plus_button_pressed():
	"""Incrementar tamaño de fuente"""
	AppState.increment_font_size()

func _on_light_theme_button_pressed():
	"""Cambiar a tema claro"""
	AppState.set_theme("light")

func _on_dark_theme_button_pressed():
	"""Cambiar a tema oscuro"""
	AppState.set_theme("dark")

func _on_contrast_theme_button_pressed():
	"""Cambiar a tema de alto contraste"""
	AppState.set_theme("high_contrast")

# Funciones TTS (Text-to-Speech)
func _on_tts_play_button_pressed():
	"""Reproducir TTS del contenido actual"""
	if current_note_path.length() == 0:
		print("No hay contenido para reproducir")
		return
	
	# Obtener texto plano del markdown (sin BBCode)
	var content = NoteIndex.get_note_content(current_note_path)
	if content.length() == 0:
		print("Contenido vacío")
		return
	
	# Limpiar texto de markdown para TTS
	var clean_text = clean_text_for_tts(content)
	
	if tts_playing and not tts_paused:
		# Si ya está reproduciendo, pausar
		_on_tts_pause_button_pressed()
		return
	
	if tts_paused and current_tts_text == clean_text:
		# Resumir si está pausado y es el mismo texto
		DisplayServer.tts_resume()
		tts_paused = false
		update_tts_button_states()
		print("TTS reanudado")
	else:
		# Iniciar nueva reproducción
		current_tts_text = clean_text
		start_tts_with_speed(clean_text)  # Usar función con velocidad
		tts_playing = true
		tts_paused = false
		update_tts_button_states()
		print("TTS iniciado")

func _on_tts_pause_button_pressed():
	"""Pausar TTS"""
	if tts_playing and not tts_paused:
		DisplayServer.tts_pause()
		tts_paused = true
		update_tts_button_states()
		print("TTS pausado")

func _on_tts_stop_button_pressed():
	"""Detener TTS"""
	if tts_playing or tts_paused:
		DisplayServer.tts_stop()
		tts_playing = false
		tts_paused = false
		current_tts_text = ""
		update_tts_button_states()
		print("TTS detenido")

# Funciones de velocidad TTS
func _on_speed_option_item_selected(index: int):
	"""Cambiar velocidad TTS según selección"""
	var speeds = [1.0, 1.25, 1.5, 1.75, 2.0, 2.5]
	var speed_names = ["x1.0", "x1.25", "x1.5", "x1.75", "x2.0", "x2.5"]
	
	if index >= 0 and index < speeds.size():
		tts_speed = speeds[index]
		restart_tts_with_new_speed()
		
		# Mostrar información de debug
		print("=== TTS VELOCIDAD CAMBIADA ===")
		print("Velocidad seleccionada: ", speed_names[index], " (", tts_speed, "x)")
		print("¿TTS está reproduciéndose?: ", tts_playing)
		print("¿TTS está pausado?: ", tts_paused)
		print("==============================")

func setup_speed_options():
	"""Configura las opciones de velocidad en el OptionButton"""
	if not speed_option:
		return
	
	# Limpiar opciones existentes
	speed_option.clear()
	
	# Añadir opciones de velocidad
	speed_option.add_item("x1.0", 0)
	speed_option.add_item("x1.25", 1)
	speed_option.add_item("x1.5", 2)
	speed_option.add_item("x1.75", 3)
	speed_option.add_item("x2.0", 4)
	speed_option.add_item("x2.5", 5)
	
	# Seleccionar velocidad normal por defecto (x1.0)
	speed_option.select(0)

func update_speed_option_selection():
	"""Actualiza la selección del OptionButton según la velocidad actual"""
	if not speed_option:
		return
	
	var speeds = [1.0, 1.25, 1.5, 1.75, 2.0, 2.5]
	for i in range(speeds.size()):
		if abs(tts_speed - speeds[i]) < 0.01:  # Comparación flotante
			speed_option.select(i)
			break

func restart_tts_with_new_speed():
	"""Reinicia el TTS con la nueva velocidad si estaba reproduciéndose"""
	if tts_playing and not tts_paused and current_tts_text.length() > 0:
		# Detener y reiniciar con nueva velocidad
		DisplayServer.tts_stop()
		start_tts_with_speed(current_tts_text)

func start_tts_with_speed(text: String):
	"""Inicia TTS con la velocidad configurada usando método mejorado"""
	# Detener cualquier TTS anterior
	DisplayServer.tts_stop()
	
	# Obtener voz disponible
	var voices = DisplayServer.tts_get_voices()
	var voice_id = ""
	
	if voices.size() > 0:
		var first_voice = voices[0]
		if first_voice is Dictionary and first_voice.has("id"):
			voice_id = first_voice["id"]
	
	# Debug: Mostrar información de las voces disponibles
	print("=== DEBUG TTS ===")
	print("Voces disponibles: ", voices.size())
	if voices.size() > 0:
		print("Primera voz: ", voices[0])
	print("Velocidad configurada: ", tts_speed, "x")
	print("Texto a reproducir (primeros 50 caracteres): ", text.substr(0, 50), "...")
	print("================")
	
	# Intentar TTS con parámetros de velocidad
	_speak_with_speed_params(text, voice_id)
	
	print("TTS iniciado - Velocidad: ", tts_speed, "x")

func _speak_with_speed_params(text: String, voice_id: String):
	"""Intenta usar TTS con parámetros de velocidad"""
	# Método 1: Intentar con parámetros nativos de velocidad
	if _try_native_speed(text, voice_id):
		print("Usando control de velocidad nativo")
		return
	
	# Método 2: Fallback - usar técnica de modificación de texto
	print("Usando control de velocidad por modificación de texto")
	var modified_text = _modify_text_for_speed(text)
	DisplayServer.tts_speak(modified_text, voice_id)

func _try_native_speed(text: String, voice_id: String) -> bool:
	"""Intenta usar control de velocidad nativo"""
	var volume = 50
	var pitch = 1.0
	var rate = tts_speed
	
	# Intentar diferentes enfoques según la plataforma
	if OS.get_name() == "Windows":
		# En Windows, intentar con parámetros completos
		DisplayServer.tts_speak(text, voice_id, volume, pitch, rate)
		return true
	else:
		# En otras plataformas, usar método simple
		DisplayServer.tts_speak(text, voice_id)
		return false

func _modify_text_for_speed(text: String) -> String:
	"""Modifica el texto para simular cambios de velocidad"""
	if tts_speed >= 1.8:
		# Para velocidades muy altas, remover algunas pausas
		var fast_text = text.replace(". ", ".").replace(", ", ",")
		return fast_text
	elif tts_speed <= 0.8:
		# Para velocidades bajas, añadir pausas adicionales
		var slow_text = text.replace(". ", "... ").replace(", ", ",, ")
		return slow_text
	else:
		# Velocidad normal o cercana a normal
		return text

# Función de callback para el timer (para implementación futura si es necesario)
func _on_tts_timer_timeout():
	"""Callback del timer para control manual de velocidad"""
	# Reservado para implementación futura si el control nativo no funciona
	pass

func update_tts_speed_buttons():
	"""Ya no se necesita - el OptionButton maneja su propio estado visual"""
	pass

func clean_text_for_tts(markdown_text: String) -> String:
	"""Limpia el texto markdown para TTS, removiendo símbolos de formato"""
	var clean_text = markdown_text
	
	# Crear RegEx para diferentes patrones
	var header_regex = RegEx.new()
	header_regex.compile(r"#{1,6}\s*")
	
	var bold_regex = RegEx.new()
	bold_regex.compile(r"\*{1,2}([^*]+)\*{1,2}")
	
	var italic_regex = RegEx.new()
	italic_regex.compile(r"_{1,2}([^_]+)_{1,2}")
	
	var link_regex = RegEx.new()
	link_regex.compile(r"\[([^\]]+)\]\([^)]+\)")
	
	var code_regex = RegEx.new()
	code_regex.compile(r"`([^`]+)`")
	
	var list_regex = RegEx.new()
	list_regex.compile(r"^[\s]*[-*+]\s+")
	
	var whitespace_regex = RegEx.new()
	whitespace_regex.compile(r"\s+")
	
	# Aplicar las limpiezas usando sub() en lugar de sub_string()
	clean_text = header_regex.sub(clean_text, "", true)
	clean_text = bold_regex.sub(clean_text, "$1", true)
	clean_text = italic_regex.sub(clean_text, "$1", true)
	clean_text = link_regex.sub(clean_text, "$1", true)
	clean_text = code_regex.sub(clean_text, "$1", true)
	clean_text = list_regex.sub(clean_text, "", true)
	clean_text = whitespace_regex.sub(clean_text, " ", true)
	
	# Limpiar bordes
	clean_text = clean_text.strip_edges()
	
	return clean_text

func update_tts_button_states():
	"""Actualiza el estado visual de los botones TTS"""
	if not play_button or not pause_button or not stop_button:
		return
	
	# Resetear colores
	play_button.modulate = Color.WHITE
	pause_button.modulate = Color.WHITE
	stop_button.modulate = Color.WHITE
	
	if tts_playing and not tts_paused:
		# Reproduciendo - resaltar pause
		pause_button.modulate = Color.YELLOW
		play_button.text = "⏸️"  # Cambiar ícono a pause
		play_button.tooltip_text = "Pausar TTS"
	elif tts_paused:
		# Pausado - resaltar play
		play_button.modulate = Color.YELLOW
		play_button.text = "▶️"  # Cambiar ícono a play
		play_button.tooltip_text = "Continuar TTS"
	else:
		# Detenido - estado normal
		play_button.text = "▶️"
		play_button.tooltip_text = "Reproducir TTS"

func _on_file_dialog_files_selected(paths: PackedStringArray):
	"""Archivos seleccionados para importar"""
	print("Importando ", paths.size(), " archivos...")
	
	var imported_count = 0
	for path in paths:
		if NoteIndex.import_note(path):
			imported_count += 1
		else:
			print("Error importando: ", path)
	
	if imported_count > 0:
		print("Importados ", imported_count, " archivos exitosamente")
		welcome_screen.visible = false
		
		# Cargar la primera nota importada
		var notes = NoteIndex.get_all_notes()
		if notes.size() > 0:
			load_note(notes[0].path)
	else:
		print("No se pudo importar ningún archivo")

func _on_font_size_slider_value_changed(value: float):
	"""Slider de tamaño de fuente cambió"""
	AppState.set_font_size(int(value))

func _on_theme_option_item_selected(index: int):
	"""Opción de tema seleccionada"""
	match index:
		0:
			AppState.set_theme("light")
		1:
			AppState.set_theme("dark")
		2:
			AppState.set_theme("high_contrast")

func show_about_dialog():
	"""Muestra el diálogo Acerca de con información completa y formato mejorado"""
	# Crear diálogo personalizado
	var dialog = AcceptDialog.new()
	dialog.title = "Acerca de MDReader"
	dialog.size = Vector2i(650, 550)
	dialog.min_size = Vector2i(600, 500)
	dialog.unresizable = false
	
	# Crear contenedor principal
	var vbox = VBoxContainer.new()
	vbox.name = "AboutContent"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Añadir padding al contenedor principal
	var padding_container = MarginContainer.new()
	padding_container.add_theme_constant_override("margin_left", 20)
	padding_container.add_theme_constant_override("margin_right", 20)
	padding_container.add_theme_constant_override("margin_top", 15)
	padding_container.add_theme_constant_override("margin_bottom", 15)
	padding_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	padding_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Crear RichTextLabel para mejor formato
	var rich_label = RichTextLabel.new()
	rich_label.bbcode_enabled = true
	rich_label.fit_content = false  # Cambiado para permitir scroll
	rich_label.scroll_active = true
	rich_label.scroll_following = false
	rich_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rich_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rich_label.custom_minimum_size = Vector2(550, 350)  # Tamaño mínimo para contenido
	
	# Texto con formato BBCode para mejor presentación
	var about_text = """[center][font_size=24][b]MDReader[/b][/font_size]
[font_size=16]Lector Minimalista de Markdown[/font_size][/center]

[font_size=14][b]Información de la Aplicación:[/b][/font_size]

• [b]Versión:[/b] 1.0.0
• [b]Motor:[/b] Godot Engine 4.x
• [b]Plataforma:[/b] Windows (x64)

[font_size=14][b]Desarrollador:[/b][/font_size]

• [b]Creado por:[/b] Tomás González
• [b]Año:[/b] 2025

[font_size=14][b]Descripción:[/b][/font_size]

Un lector elegante y minimalista de archivos Markdown 
diseñado para ofrecer una experiencia de lectura pura 
y sin distracciones. Perfecto para la revisión de 
documentos, notas y contenido en formato Markdown.

[font_size=14][b]Características Principales:[/b][/font_size]

• Interfaz minimalista enfocada en el contenido
• Tres temas adaptativos (claro, oscuro, alto contraste)
• Control completo de tipografía y tamaño de fuente
• Importación y gestión sencilla de notas
• Configuración persistente entre sesiones
• Renderizado avanzado de Markdown a BBCode

[font_size=14][b]Licencia y Código:[/b][/font_size]

• [b]Licencia:[/b] MIT License
• [b]Código abierto[/b] disponible en GitHub
• Libre para uso personal y comercial

[center][font_size=12][i]© 2025 Tomás González. Todos los derechos reservados.[/i][/font_size][/center]"""
	
	rich_label.text = about_text
	
	# Aplicar colores del tema actual
	var theme_colors = AppState.get_theme_colors()
	rich_label.add_theme_color_override("default_color", theme_colors.text)
	rich_label.add_theme_color_override("font_color", theme_colors.text)
	
	# Estructura: padding_container -> rich_label -> vbox -> dialog
	padding_container.add_child(rich_label)
	vbox.add_child(padding_container)
	
	# Reemplazar el contenido del diálogo
	dialog.add_child(vbox)
	
	# Personalizar botón
	dialog.get_ok_button().text = "Cerrar"
	
	add_child(dialog)
	dialog.popup_centered()
	await dialog.confirmed
	dialog.queue_free()
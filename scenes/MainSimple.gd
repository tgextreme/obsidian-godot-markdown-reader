extends Control

# Referencias a nodos de la UI
@onready var reader: RichTextLabel = $PanelContainer/ScrollContainer/MarginContainer/Reader
@onready var welcome_screen: Control = $WelcomeScreen
@onready var file_dialog: FileDialog = $FileDialog
@onready var settings_dialog: AcceptDialog = $SettingsDialog
@onready var font_size_slider: HSlider = $SettingsDialog/VBoxContainer/FontSizeSlider
@onready var font_size_value: Label = $SettingsDialog/VBoxContainer/FontSizeValue
@onready var theme_option: OptionButton = $SettingsDialog/VBoxContainer/ThemeOption

# Estado actual
var current_note_path: String = ""
var note_buttons: Array = []

func _ready():
	setup_ui()
	connect_signals()
	apply_theme()
	apply_font_size()
	check_for_notes()

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

func connect_signals():
	"""Conecta las señales de los autoloads"""
	AppState.theme_changed.connect(_on_theme_changed)
	AppState.font_size_changed.connect(_on_font_size_changed)
	NoteIndex.notes_updated.connect(_on_notes_updated)

func apply_theme():
	"""Aplica el tema actual"""
	# El tema se aplica automáticamente a través del sistema de temas de Godot
	pass

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
	"""Verifica si hay notas disponibles"""
	var notes = NoteIndex.get_all_notes()
	if notes.size() == 0:
		welcome_screen.visible = true
	else:
		welcome_screen.visible = false
		load_last_note()

func load_note(note_path: String):
	"""Carga una nota específica"""
	current_note_path = note_path
	AppState.set_last_note(note_path)
	
	var content = NoteIndex.get_note_content(note_path)
	if content.length() > 0:
		var bbcode_content = Markdown.parse_to_bbcode(content)
		reader.text = bbcode_content
		welcome_screen.visible = false
	else:
		reader.text = "[center][color=red]Error: No se pudo cargar la nota[/color][/center]"
	
	print("Nota cargada: ", note_path)

func load_last_note():
	"""Carga la última nota vista"""
	if AppState.last_note.length() > 0:
		load_note(AppState.last_note)

# Señales del sistema
func _on_theme_changed(new_theme: String):
	"""Responde al cambio de tema"""
	apply_theme()

func _on_font_size_changed(new_size: int):
	"""Responde al cambio de tamaño de fuente"""
	apply_font_size()

func _on_notes_updated():
	"""Responde a la actualización de notas"""
	check_for_notes()

# Señales de la UI
func _on_import_button_pressed():
	"""Botón de importar en pantalla de bienvenida"""
	file_dialog.popup_centered()

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
	"""Muestra el diálogo Acerca de"""
	var about_text = "Lector Markdown\\nVersión 1.0\\n\\nUn lector simple de archivos Markdown"
	# Crear y mostrar diálogo temporal
	var dialog = AcceptDialog.new()
	dialog.dialog_text = about_text
	dialog.title = "Acerca de"
	add_child(dialog)
	dialog.popup_centered()
	await dialog.confirmed
	dialog.queue_free()
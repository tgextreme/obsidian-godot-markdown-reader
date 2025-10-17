extends Control

# Referencias a nodos UI básicos
@onready var welcome_screen: Control = $WelcomeScreen
@onready var file_dialog: FileDialog = $FileDialog
@onready var reader: RichTextLabel = $UI/VBoxContainer/PanelContainer/ScrollContainer/MarginContainer/Reader
@onready var ui_panel: Control = $UI
@onready var back_button: Button = $UI/VBoxContainer/TopBar/BackButton

# Variables básicas
var current_note_content: String = ""
var current_note_path: String = ""

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
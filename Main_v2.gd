extends Control

# Referencias a nodos UI básicos
@onready var welcome_screen: Control = $WelcomeScreen
@onready var file_dialog: FileDialog = $FileDialog
@onready var reader: RichTextLabel = $UI/PanelContainer/ScrollContainer/MarginContainer/Reader
@onready var ui_panel: Control = $UI

# Variables básicas
var current_note_content: String = ""

func _ready():
	print("=== INICIANDO MDREADER v2 ===")
	
	# Configurar FileDialog para importar archivos .md
	setup_file_dialog()
	
	# Mostrar pantalla de bienvenida
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
	if welcome_screen:
		welcome_screen.visible = true
		print("Pantalla de bienvenida mostrada")
	
	if ui_panel:
		ui_panel.visible = false
		print("Panel UI ocultado")

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
	"""Muestra el contenido en el lector"""
	if reader:
		# Por ahora mostrar el contenido como texto plano
		reader.clear()
		reader.text = content
		print("Contenido mostrado en el lector")
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

func _on_dark_theme_button_pressed():
	print("Tema oscuro seleccionado")

func _on_contrast_theme_button_pressed():
	print("Alto contraste seleccionado")
extends Node

# AppState.gd - Gestión global de configuración y preferencias de la aplicación

signal theme_changed(theme_name: String)
signal font_size_changed(size: int)

# Configuración por defecto
const CONFIG_FILE = "user://config.json"
const DEFAULT_CONFIG = {
	"theme": "dark",
	"font_size_pt": 22,  # Tamaño más grande para móvil
	"reader_font": "res://ui/fonts/default.ttf",
	"mono_font": "res://ui/fonts/mono.ttf",
	"last_note": "",
	"favorites": [],
	"show_toc_by_default": true,
	"auto_save": true
}

# Variables de estado actual
var current_theme: String = "dark"
var font_size_pt: int = 18
var reader_font: String = ""
var mono_font: String = ""
var last_note: String = ""
var favorites: Array[String] = []
var show_toc_by_default: bool = true
var auto_save: bool = true

func _ready():
	load_config()

func load_config():
	"""Carga la configuración desde el archivo JSON"""
	if not FileAccess.file_exists(CONFIG_FILE):
		# Primera vez - crear config por defecto
		save_config()
		return
	
	var file = FileAccess.open(CONFIG_FILE, FileAccess.READ)
	if file == null:
		push_error("No se puede abrir el archivo de configuración")
		return
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Error al parsear el archivo de configuración")
		return
		
	var config_data = json.data
	
	# Aplicar configuración cargada con fallbacks
	current_theme = config_data.get("theme", DEFAULT_CONFIG.theme)
	font_size_pt = config_data.get("font_size_pt", DEFAULT_CONFIG.font_size_pt)
	reader_font = config_data.get("reader_font", DEFAULT_CONFIG.reader_font)
	mono_font = config_data.get("mono_font", DEFAULT_CONFIG.mono_font)
	last_note = config_data.get("last_note", DEFAULT_CONFIG.last_note)
	
	# Cargar favoritos de forma type-safe
	var loaded_favorites = config_data.get("favorites", DEFAULT_CONFIG.favorites)
	favorites.clear()
	for fav in loaded_favorites:
		if fav is String:
			favorites.append(fav)
	
	show_toc_by_default = config_data.get("show_toc_by_default", DEFAULT_CONFIG.show_toc_by_default)
	auto_save = config_data.get("auto_save", DEFAULT_CONFIG.auto_save)
	
	print("Configuración cargada: tema=", current_theme, " fuente=", font_size_pt, "pt")

func save_config():
	"""Guarda la configuración actual al archivo JSON"""
	var config_data = {
		"theme": current_theme,
		"font_size_pt": font_size_pt,
		"reader_font": reader_font,
		"mono_font": mono_font,
		"last_note": last_note,
		"favorites": favorites,
		"show_toc_by_default": show_toc_by_default,
		"auto_save": auto_save
	}
	
	var file = FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	if file == null:
		push_error("No se puede crear el archivo de configuración")
		return
		
	var json_string = JSON.stringify(config_data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("Configuración guardada")

# Métodos para cambiar configuración
func set_theme(theme_name: String):
	if theme_name != current_theme:
		current_theme = theme_name
		apply_theme_to_scene()
		theme_changed.emit(theme_name)
		if auto_save:
			save_config()

func apply_theme_to_scene():
	"""Aplica el tema actual a la escena principal"""
	var main_scene = get_tree().current_scene
	if main_scene:
		apply_theme_colors(main_scene)

func apply_theme_colors(node: Node):
	"""Aplica colores del tema a un nodo y sus hijos"""
	var colors = get_theme_colors()
	
	# Aplicar a diferentes tipos de nodos
	if node is Control:
		var control = node as Control
		
		# PanelContainer - fondo principal
		if node is PanelContainer:
			control.add_theme_color_override("panel", colors.background)
		
		# Labels y RichTextLabel
		elif node is Label:
			control.add_theme_color_override("font_color", colors.text)
		
		elif node is RichTextLabel:
			control.add_theme_color_override("default_color", colors.text)
			control.add_theme_color_override("font_color", colors.text)
			# Colores específicos para BBCode
			control.add_theme_color_override("font_color_selected", colors.accent)
			control.add_theme_color_override("selection_color", colors.accent)
		
		# Buttons
		elif node is Button:
			control.add_theme_color_override("font_color", colors.text)
			control.add_theme_color_override("font_color_hover", colors.accent)
			control.add_theme_color_override("font_color_pressed", colors.accent)
		
		# LineEdit y otros controles
		elif node is LineEdit:
			control.add_theme_color_override("font_color", colors.text)
			control.add_theme_color_override("font_color_placeholder", colors.text_secondary)
	
	# Aplicar recursivamente a hijos
	for child in node.get_children():
		apply_theme_colors(child)

func get_theme_colors() -> Dictionary:
	"""Retorna los colores del tema actual"""
	match current_theme:
		"light":
			return {
				"background": Color.WHITE,
				"text": Color.BLACK,
				"text_secondary": Color(0.4, 0.4, 0.4),
				"accent": Color.BLUE,
				"panel": Color(0.95, 0.95, 0.95)
			}
		"dark":
			return {
				"background": Color(0.2, 0.2, 0.2),
				"text": Color.WHITE,
				"text_secondary": Color(0.7, 0.7, 0.7),
				"accent": Color.CYAN,
				"panel": Color(0.15, 0.15, 0.15)
			}
		"high_contrast":
			return {
				"background": Color.BLACK,
				"text": Color.WHITE,
				"text_secondary": Color(0.8, 0.8, 0.8),
				"accent": Color.YELLOW,
				"panel": Color(0.05, 0.05, 0.05)
			}
		_:
			# Default a dark
			return {
				"background": Color(0.2, 0.2, 0.2),
				"text": Color.WHITE,
				"text_secondary": Color(0.7, 0.7, 0.7),
				"accent": Color.CYAN,
				"panel": Color(0.15, 0.15, 0.15)
			}

func set_font_size(size: int):
	size = clamp(size, 16, 40)  # Rango más grande para móvil
	if size != font_size_pt:
		font_size_pt = size
		font_size_changed.emit(size)
		if auto_save:
			save_config()

func increment_font_size():
	"""Incrementa el tamaño de fuente en pasos de 2pt"""
	set_font_size(font_size_pt + 2)

func decrement_font_size():
	"""Decrementa el tamaño de fuente en pasos de 2pt"""
	set_font_size(font_size_pt - 2)

func set_last_note(note_path: String):
	last_note = note_path
	if auto_save:
		save_config()

func add_favorite(note_path: String):
	"""Añade una nota a favoritos si no está ya"""
	if note_path not in favorites:
		favorites.append(note_path)
		if auto_save:
			save_config()

func remove_favorite(note_path: String):
	"""Elimina una nota de favoritos"""
	var index = favorites.find(note_path)
	if index != -1:
		favorites.remove_at(index)
		if auto_save:
			save_config()

func is_favorite(note_path: String) -> bool:
	"""Verifica si una nota está en favoritos"""
	return note_path in favorites

func toggle_favorite(note_path: String):
	"""Alterna el estado de favorito de una nota"""
	if is_favorite(note_path):
		remove_favorite(note_path)
	else:
		add_favorite(note_path)

# Utilidades para temas
func is_dark_theme() -> bool:
	return current_theme == "dark"

func get_available_themes() -> Array[String]:
	return ["light", "dark", "high_contrast"]
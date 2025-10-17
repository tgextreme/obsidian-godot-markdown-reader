extends Node

# NoteIndex.gd - Gestión del índice de notas y búsqueda

signal notes_updated()
signal note_imported(note_path: String)

const NOTES_DIR = "user://notes/"
const INDEX_FILE = "user://notes/index.json"

# Cache de notas en memoria
var notes_cache: Dictionary = {}
var search_index: Dictionary = {}

# Estructura de nota en cache:
# {
#   "path": String,
#   "title": String,
#   "content": String,
#   "headings": Array[Dictionary], # [{level: int, title: String, position: int}]
#   "modified_time": int,
#   "hash": String,
#   "word_count": int
# }

func _ready():
	# Crear carpeta de notas si no existe
	if not DirAccess.dir_exists_absolute(NOTES_DIR):
		DirAccess.open("user://").make_dir_recursive("notes")
	
	load_index()

func load_index():
	"""Carga el índice de notas desde archivo"""
	if not FileAccess.file_exists(INDEX_FILE):
		rebuild_index()
		return
	
	var file = FileAccess.open(INDEX_FILE, FileAccess.READ)
	if file == null:
		push_error("No se puede abrir el índice de notas")
		rebuild_index()
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Error al parsear el índice de notas")
		rebuild_index()
		return
	
	notes_cache = json.data
	build_search_index()
	notes_updated.emit()
	print("Índice cargado: ", notes_cache.size(), " notas")

func save_index():
	"""Guarda el índice actual al archivo"""
	var file = FileAccess.open(INDEX_FILE, FileAccess.WRITE)
	if file == null:
		push_error("No se puede guardar el índice de notas")
		return
	
	var json_string = JSON.stringify(notes_cache, "\t")
	file.store_string(json_string)
	file.close()

func rebuild_index():
	"""Reconstruye completamente el índice escaneando todos los archivos .md"""
	notes_cache.clear()
	scan_notes_directory(NOTES_DIR)
	save_index()
	build_search_index()
	notes_updated.emit()
	print("Índice reconstruido: ", notes_cache.size(), " notas")

func scan_notes_directory(dir_path: String):
	"""Escanea recursivamente un directorio en busca de archivos .md"""
	var dir = DirAccess.open(dir_path)
	if dir == null:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = dir_path + "/" + file_name
		
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			# Escanear subdirectorio
			scan_notes_directory(full_path)
		elif file_name.ends_with(".md"):
			# Procesar archivo markdown
			process_note_file(full_path)
		
		file_name = dir.get_next()

func process_note_file(file_path: String):
	"""Procesa un archivo .md y lo añade al índice"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_warning("No se puede leer: " + file_path)
		return
	
	var content = file.get_as_text()
	file.close()
	var modified_time = FileAccess.get_modified_time(file_path)
	
	# Calcular hash del contenido
	var content_hash = content.md5_text()
	
	# Verificar si ya está en cache y no ha cambiado
	if file_path in notes_cache:
		var cached_note = notes_cache[file_path]
		if cached_note.hash == content_hash:
			# No ha cambiado, mantener cache
			return
	
	# Extraer título (primer H1 o nombre de archivo)
	var title = extract_title(content, file_path)
	
	# Extraer encabezados para TOC
	var headings = extract_headings(content)
	
	# Contar palabras
	var word_count = count_words(content)
	
	# Crear entrada de cache
	var note_data = {
		"path": file_path,
		"title": title,
		"content": content,
		"headings": headings,
		"modified_time": modified_time,
		"hash": content_hash,
		"word_count": word_count
	}
	
	notes_cache[file_path] = note_data

func extract_title(content: String, file_path: String) -> String:
	"""Extrae el título de la nota (primer H1 o nombre del archivo)"""
	var lines = content.split("\n")
	
	for line in lines:
		line = line.strip_edges()
		if line.begins_with("# "):
			return line.substr(2).strip_edges()
	
	# Fallback: usar nombre del archivo sin extensión
	var file_name = file_path.get_file()
	return file_name.get_basename()

func extract_headings(content: String) -> Array:
	"""Extrae todos los encabezados del contenido para generar TOC"""
	var headings = []
	var lines = content.split("\n")
	var position = 0
	
	for line in lines:
		var stripped = line.strip_edges()
		var heading_match = RegEx.new()
		heading_match.compile("^(#{1,6})\\s+(.+)$")
		var result = heading_match.search(stripped)
		
		if result:
			var level = result.get_string(1).length()
			var title = result.get_string(2)
			
			headings.append({
				"level": level,
				"title": title,
				"position": position,
				"line": len(headings)  # Línea en el array de headings
			})
		
		position += line.length() + 1  # +1 por el \n
	
	return headings

func count_words(content: String) -> int:
	"""Cuenta las palabras en el contenido"""
	var words = content.split(" ", false)
	return words.size()

func build_search_index():
	"""Construye el índice de búsqueda basado en las notas en cache"""
	search_index.clear()
	
	for note_path in notes_cache:
		var note = notes_cache[note_path]
		var searchable_text = (note.title + " " + note.content).to_lower()
		
		# Dividir en palabras para búsqueda
		var words = searchable_text.split(" ", false)
		for word in words:
			# Limpiar palabra (remover puntuación básica)
			word = word.strip_edges()
			word = word.replace(",", "").replace(".", "").replace("!", "").replace("?", "")
			
			if word.length() > 2:  # Ignorar palabras muy cortas
				if word not in search_index:
					search_index[word] = []
				
				if note_path not in search_index[word]:
					search_index[word].append(note_path)

func import_note(source_path: String) -> String:
	"""Importa una nota desde una ruta externa al repositorio de la app"""
	var file = FileAccess.open(source_path, FileAccess.READ)
	if file == null:
		push_error("No se puede leer el archivo: " + source_path)
		return ""
	
	var content = file.get_as_text()
	file.close()
	
	# Generar nombre único en el directorio de notas
	var file_name = source_path.get_file()
	var dest_path = NOTES_DIR + file_name
	
	# Si ya existe, añadir sufijo numérico
	var counter = 1
	while FileAccess.file_exists(dest_path):
		var base_name = file_name.get_basename()
		var extension = file_name.get_extension()
		dest_path = NOTES_DIR + base_name + "_" + str(counter) + "." + extension
		counter += 1
	
	# Copiar archivo
	var dest_file = FileAccess.open(dest_path, FileAccess.WRITE)
	if dest_file == null:
		push_error("No se puede crear el archivo: " + dest_path)
		return ""
	
	dest_file.store_string(content)
	dest_file.close()
	
	# Procesar la nueva nota
	process_note_file(dest_path)
	save_index()
	build_search_index()
	
	note_imported.emit(dest_path)
	notes_updated.emit()
	
	print("Nota importada: ", dest_path)
	return dest_path

func get_all_notes() -> Array:
	"""Devuelve array con información de todas las notas"""
	var notes = []
	for note_path in notes_cache:
		var note = notes_cache[note_path]
		notes.append({
			"path": note_path,
			"title": note.title,
			"word_count": note.word_count,
			"modified_time": note.modified_time
		})
	
	# Ordenar por fecha de modificación (más reciente primero)
	notes.sort_custom(func(a, b): return a.modified_time > b.modified_time)
	return notes

func get_note_content(note_path: String) -> String:
	"""Obtiene el contenido de una nota"""
	if note_path in notes_cache:
		return notes_cache[note_path].content
	
	# Si no está en cache, intentar cargar directamente
	var file = FileAccess.open(note_path, FileAccess.READ)
	if file == null:
		return ""
	
	var content = file.get_as_text()
	file.close()
	return content

func get_note_headings(note_path: String) -> Array:
	"""Obtiene los encabezados de una nota para TOC"""
	if note_path in notes_cache:
		return notes_cache[note_path].headings
	return []

func search_notes(query: String) -> Array:
	"""Busca notas que contengan el texto especificado"""
	if query.length() < 2:
		return []
	
	var results = []
	query = query.to_lower()
	
	for note_path in notes_cache:
		var note = notes_cache[note_path]
		var title_lower = note.title.to_lower()
		var content_lower = note.content.to_lower()
		
		var score = 0
		
		# Coincidencia en título tiene mayor peso
		if title_lower.contains(query):
			score += 10
		
		# Coincidencia en contenido
		if content_lower.contains(query):
			score += content_lower.count(query)
		
		if score > 0:
			# Extraer snippet del contenido
			var snippet = extract_snippet(note.content, query)
			
			results.append({
				"path": note_path,
				"title": note.title,
				"score": score,
				"snippet": snippet
			})
	
	# Ordenar por puntuación
	results.sort_custom(func(a, b): return a.score > b.score)
	return results

func extract_snippet(content: String, query: String, max_length: int = 150) -> String:
	"""Extrae un fragmento del contenido que contenga la query"""
	var content_lower = content.to_lower()
	var query_lower = query.to_lower()
	
	var index = content_lower.find(query_lower)
	if index == -1:
		# Fallback: primeros caracteres
		return content.substr(0, max_length) + "..."
	
	# Centrar el snippet alrededor de la coincidencia
	var start = max(0, index - max_length / 2.0)
	var end = min(content.length(), start + max_length)
	
	var snippet = content.substr(start, end - start)
	
	if start > 0:
		snippet = "..." + snippet
	if end < content.length():
		snippet = snippet + "..."
	
	return snippet

func get_favorites() -> Array:
	"""Obtiene la lista de notas favoritas con su información"""
	var favorites = []
	
	for note_path in AppState.favorites:
		if note_path in notes_cache:
			var note = notes_cache[note_path]
			favorites.append({
				"path": note_path,
				"title": note.title,
				"word_count": note.word_count,
				"modified_time": note.modified_time
			})
	
	return favorites

func refresh_note(note_path: String):
	"""Refresca una nota específica en el cache"""
	if FileAccess.file_exists(note_path):
		process_note_file(note_path)
		save_index()
		build_search_index()
		notes_updated.emit()
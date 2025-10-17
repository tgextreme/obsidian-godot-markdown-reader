extends Node

# Markdown.gd - Parser de Markdown a BBCode simplificado y robusto

func parse_to_bbcode(markdown_text: String) -> String:
	"""Convierte texto Markdown a BBCode de forma segura"""
	if markdown_text.is_empty():
		return ""
	
	var lines = markdown_text.replace("\r\n", "\n").split("\n")
	var result_lines = []
	var in_code_block = false
	
	for line in lines:
		if in_code_block:
			if line.strip_edges().begins_with("```"):
				result_lines.append("[/code]")
				in_code_block = false
			else:
				result_lines.append(line)
		else:
			var processed_line = _process_line_safe(line)
			result_lines.append(processed_line)
			
			# Verificar inicio de bloque de código
			if line.strip_edges().begins_with("```"):
				result_lines.append("[code]")
				in_code_block = true
	
	# Cerrar bloque de código si quedó abierto
	if in_code_block:
		result_lines.append("[/code]")
	
	return "\n".join(result_lines)

func _process_line_safe(line: String) -> String:
	"""Procesa una línea de forma segura"""
	var result = line
	
	# Encabezados
	if result.begins_with("#"):
		var level = 0
		for i in range(result.length()):
			if result[i] == "#":
				level += 1
			else:
				break
		
		if level > 0 and level <= 6:
			var title = result.substr(level).strip_edges()
			return _format_heading_safe(title, level)
	
	# Listas simples
	if result.strip_edges().begins_with("- ") or result.strip_edges().begins_with("* "):
		var content = result.strip_edges().substr(2)
		return "• " + _apply_basic_formatting(content)
	
	# Citas
	if result.strip_edges().begins_with("> "):
		var content = result.strip_edges().substr(2)
		return "[i]" + _apply_basic_formatting(content) + "[/i]"
	
	# Línea vacía
	if result.strip_edges().is_empty():
		return ""
	
	# Aplicar formato básico
	return _apply_basic_formatting(result)

func _format_heading_safe(title: String, level: int) -> String:
	"""Formatea encabezados de forma segura"""
	var formatted_title = _apply_basic_formatting(title)
	
	match level:
		1:
			return "\n[font_size=24][b]" + formatted_title + "[/b][/font_size]\n"
		2:
			return "\n[font_size=22][b]" + formatted_title + "[/b][/font_size]\n"
		3:
			return "\n[font_size=20][b]" + formatted_title + "[/b][/font_size]\n"
		_:
			return "\n[b]" + formatted_title + "[/b]\n"

func _apply_basic_formatting(text: String) -> String:
	"""Aplica formato básico sin romper BBCode"""
	var result = text
	
	# Código inline - usar solo [code] sin font_family
	result = _replace_safe(result, "`", "[code]", "[/code]")
	
	# Negrita
	result = _replace_safe(result, "**", "[b]", "[/b]")
	
	# Cursiva (solo * simple, evitar conflictos con **)
	var italic_regex = RegEx.new()
	italic_regex.compile("(?<!\\*)\\*([^*]+)\\*(?!\\*)")
	result = italic_regex.sub(result, "[i]$1[/i]", true)
	
	# Tachado
	result = _replace_safe(result, "~~", "[s]", "[/s]")
	
	# Enlaces - simplificado
	var link_regex = RegEx.new()
	link_regex.compile("\\[([^\\]]+)\\]\\([^\\)]+\\)")
	result = link_regex.sub(result, "[color=blue][u]$1[/u][/color]", true)
	
	return result

func _replace_safe(text: String, marker: String, open_tag: String, close_tag: String) -> String:
	"""Reemplaza marcadores de markdown de forma segura"""
	var parts = text.split(marker)
	if parts.size() < 2:
		return text
	
	var result = parts[0]
	var is_opening = true
	
	for i in range(1, parts.size()):
		if is_opening:
			result += open_tag + parts[i]
		else:
			result += close_tag + parts[i]
		is_opening = not is_opening
	
	# Si terminó con una etiqueta abierta, cerrarla
	if not is_opening:
		result += close_tag
	
	return result
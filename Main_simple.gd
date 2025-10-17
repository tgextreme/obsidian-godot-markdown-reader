extends Control

# Referencias básicas
@onready var welcome_screen: Control = $WelcomeScreen

func _ready():
	print("=== INICIANDO VERSION SIMPLE ===")
	
	# Simplemente mostrar la pantalla de bienvenida
	if welcome_screen:
		welcome_screen.visible = true
		print("WelcomeScreen visible:", welcome_screen.visible)
		print("WelcomeScreen position:", welcome_screen.position)  
		print("WelcomeScreen size:", welcome_screen.size)
	else:
		print("ERROR: No se encontró WelcomeScreen")
	
	print("=== VERSION SIMPLE INICIADA ===")

# Funciones básicas de botones
func _on_import_button_pressed():
	print("Botón importar presionado")

func _on_settings_button_pressed():
	print("Botón configuración presionado")

func _on_about_button_pressed():
	print("Botón acerca de presionado")

func _on_exit_button_pressed():
	print("Botón salir presionado")
	get_tree().quit()

func _on_light_theme_button_pressed():
	print("Tema claro seleccionado")

func _on_dark_theme_button_pressed():
	print("Tema oscuro seleccionado")

func _on_contrast_theme_button_pressed():
	print("Alto contraste seleccionado")
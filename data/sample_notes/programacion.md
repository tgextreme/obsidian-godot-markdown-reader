# Notas de Programación

## Godot 4 - Consejos y Trucos

### Signals vs Callable
En Godot 4, se recomienda usar `Callable` para conectar señales:

```gdscript
# Forma nueva (recomendada)
button.pressed.connect(_on_button_pressed)

# Forma antigua (aún funciona)
button.connect("pressed", _on_button_pressed)
```

### Typed GDScript
Usar tipos mejora el rendimiento y detecta errores:

```gdscript
# Variables tipadas
var health: int = 100
var player_name: String = "Player"
var items: Array[String] = []

# Funciones tipadas
func calculate_damage(base: int, multiplier: float) -> int:
    return int(base * multiplier)
```

### Autoloads eficientes
Para singletons que manejan estado global:

```gdscript
# GameManager.gd
extends Node

signal player_died
signal score_changed(new_score: int)

var score: int = 0:
    set(value):
        score = value
        score_changed.emit(value)
```

---

## Patrones de Diseño útiles

### Singleton Pattern
```gdscript
class_name GameData
extends RefCounted

static var instance: GameData

static func get_instance() -> GameData:
    if not instance:
        instance = GameData.new()
    return instance
```

### Observer Pattern
```gdscript
# EventBus.gd (Autoload)
extends Node

signal health_changed(new_health: int)
signal item_collected(item_name: String)
signal level_completed()

# Uso:
# EventBus.health_changed.connect(_on_health_changed)
```

### State Machine
```gdscript
class_name StateMachine
extends Node

var current_state: State
var states: Dictionary = {}

func change_state(state_name: String):
    if current_state:
        current_state.exit()
    
    current_state = states[state_name]
    current_state.enter()
```

---

## Performance Tips

### Optimizar _process()
```gdscript
# ❌ Malo - se ejecuta cada frame
func _process(delta):
    update_ui()
    check_enemies()

# ✅ Bueno - usar timers o menos frecuencia
var update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.1

func _process(delta):
    update_timer += delta
    if update_timer >= UPDATE_INTERVAL:
        update_ui()
        update_timer = 0.0
```

### Object Pooling
```gdscript
class_name BulletPool
extends Node2D

var bullet_scene = preload("res://Bullet.tscn")
var available_bullets: Array[Bullet] = []

func get_bullet() -> Bullet:
    if available_bullets.is_empty():
        return bullet_scene.instantiate()
    else:
        return available_bullets.pop_back()

func return_bullet(bullet: Bullet):
    bullet.reset()
    available_bullets.append(bullet)
```

---

## Debugging Tricks

### Print con contexto
```gdscript
func debug_print(message: String, context: String = ""):
    if OS.is_debug_build():
        var full_message = "[%s] %s" % [context, message]
        print(full_message)

# Uso
debug_print("Player health: " + str(health), "PlayerController")
```

### Conditional Compilation
```gdscript
# Solo en debug
if OS.is_debug_build():
    # Código de debug
    pass

# Solo en release
if not OS.is_debug_build():
    # Código de producción
    pass
```

---

## Recursos útiles

### Documentación oficial
- [Godot Docs](https://docs.godotengine.org)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)

### Comunidad
- r/godot en Reddit
- Godot Discord Server
- GitHub Issues para reportar bugs

### Assets
- [Kenney Assets](https://kenney.nl) - Arte gratuito
- [OpenGameArt](https://opengameart.org) - Assets libres
- [Freesound](https://freesound.org) - Efectos de sonido

---

> **Nota importante**: Siempre mantén tu código limpio y documentado. Tu yo del futuro te lo agradecerá.
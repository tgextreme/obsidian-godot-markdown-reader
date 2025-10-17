# MDReader - Lector Minimalista de Markdown

![Godot Engine](https://img.shields.io/badge/Godot-4.x-blue?logo=godot-engine&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)

> Un lector de archivos Markdown elegante y minimalista construido con Godot Engine 4.x

## 🎯 Descripción

**MDReader** es una aplicación de escritorio diseñada para ofrecer una experiencia de lectura de archivos Markdown pura y sin distracciones. Inspirada en la filosofía minimalista, se enfoca únicamente en presentar el contenido de manera clara y legible.

### ✨ Características Principales

- **📖 Lectura pura**: Interfaz minimalista enfocada exclusivamente en el contenido
- **🎨 Temas adaptables**: Soporte para temas claro, oscuro y alto contraste
- **🔤 Tipografía configurable**: Control total sobre el tamaño de fuente (A- / A+)
- **📁 Gestión de notas**: Importación y organización de archivos Markdown
- **⚡ Rendimiento optimizado**: Carga rápida y navegación fluida
- **🎛️ Controles intuitivos**: Menú superior discreto cuando es necesario

---

## 2) Alcance del MVP (v1.0)

**Incluye**

1. Apertura de notas Markdown desde un repositorio local de la app (carpeta interna) y **importación** desde archivo suelto.
2. Render de Markdown con soporte de:

   * Encabezados `#` a `######` (genera TOC lateral/desplegable).
   * Negrita, cursiva, tachado, código en línea, citas, listas (ol/ul), enlaces.
   * Bloques de código con fuente monoespaciada (sin *syntax highlight* en v1; ver futuro).
   * Imágenes locales referenciadas (si están dentro del repositorio de la app).
3. UI horizontal con:

   * **AppBar**: botón *back*, buscador, **A− / A+**, botón tema, menú “⋮”.
   * **Drawer/Panel**: lista de notas, filtro, vista reciente, TOC de la nota actual.
   * **Visor**: scroll; ancho de columna legible; márgenes confort.
4. **Búsqueda**: por título de nota y texto completo (simple, case-insensitive).
5. **Tamaño de letra**: pasos de 12 → 14 → 16 → 18 → 20 → 22 → 24 pt (configurable). Persistente por usuario.
6. **Temas**: claro/oscuro; fuente de lectura y monoespaciada configurables.
7. **Marcadores**: guardar notas favoritas/recientes.
8. **Rendimiento**: cache de notas parseadas (in‑memory) y re‑parse on change.
9. **Android**: orientación bloqueada a **landscape**; importación por *Share intent* (vía menú "Importar nota").
10. **Windows**: *file dialog* para importar; almacenamiento user:// + carpeta de trabajo configurable.

**Excluye (v1.0)**

* Edición de Markdown, sincronización en la nube, *syntax highlighting*, plugins de terceros, enlaces externos remotos, plantillas.

---

## 3) Futuras versiones (v1.1+)

* **TTS (Text‑to‑Speech)**: play/pause, velocidad, tono, voz; resaltar frase actual.
* **Syntax highlighting** en bloques de código (resaltado básico por lenguaje).
* **Links relativos** entre notas con *preview* al pasar (Windows) o mantener pulsado (Android).
* **Anclajes**/deep‑links a encabezados.
* **Carpetas múltiples** y *workspaces*.
* **Exportar a PDF** (impresión virtual) y compartir como HTML.
* **Temas personalizados** (YAML/JSON) y tipografías importadas.
* **Gestos**: swipe para abrir TOC / navegación.

---

## 4) Requisitos no funcionales (RNF)

* **Rendimiento**: abrir una nota de 1–2 MB en < 300 ms en dispositivos medios.
* **Memoria**: cache limitado con LRU (p.ej., 10 notas recientes parseadas).
* **Accesibilidad**: tamaños grandes, contraste alto, soporte *TalkBack/VoiceOver* futuro.
* **Privacidad**: sin conexión de red en el MVP; no se envía telemetría.
* **Batería**: minimizar *reflows*; parsers y caches eficientes.

---

## 5) Arquitectura técnica

**Godot 4.x**

* Escena raíz `Main` (Control) → gestiona navegación, tema y *state* global.
* **Autoloads**:

  * `AppState.gd`: preferencias (tema, tamaño fuente, última nota, marcadores).
  * `NoteIndex.gd`: índice de notas (títulos, rutas, cache de búsqueda).
  * `Markdown.gd`: servicio de parseo MD→BBCode/RTF.
  * (Futuro) `TTSService.gd`: fachada para TTS por plataforma.

**Render de Markdown**

* Usar `RichTextLabel` para visualizar; convertir Markdown a BBCode seguro.
* Parser: implementación simple en GDScript (CommonMark subset) o envolver librería *cmark* vía GDExtension (opcional). Para MVP, empezar con GDScript + expresiones regulares + reglas deterministas.

**Gestión de archivos**

* **Windows**: carpeta base configurable (`user://notes` por defecto). Importar con `FileDialog` (copia a repositorio).
* **Android**: repositorio interno `user://notes`. Importar por *Share intent* (crear *Android plugin* mínimo) o mediante selector a carpeta app (scoped storage). Mantener todo **offline**.

**Datos**

* Estructura simple por **carpetas** y **.md**. Índice (`index.json`) para cachear títulos, fechas y *hash* de contenido.

---

## 6) Diseño de UI/UX (vertical first)

**Barra superior (AppBar)**

* ← Volver / Inicio
* 🔎 Buscar (placeholder “Buscar notas…”)
* **A−** / **A+** (tamaño fuente global)
* ☀/🌙 (tema)
* ⋮ Menú (Importar, Ajustes, Acerca de)

**Panel lateral (desplegable)**

* Tabs: **Notas** | **Favoritos** | **TOC**
* Notas: lista simple (título, fecha). Filtro por texto.
* TOC: generado del documento (H1–H4) con *scroll‑to*.

**Visor**

* Ancho de columna limitado (p.ej., 640–720px max) con márgenes laterales.
* Tipografía legible (serif/sans al gusto), interlineado 1.4–1.6.
* Código monoespaciado en caja con scroll horizontal.

**Ajustes**

* Tamaño base (slider + vista previa).
* Tema: claro/oscuro/automático.
* Fuente lectura y monoespaciada.
* Comportamiento: abrir última nota, mostrar TOC por defecto.

---

## 7) Modelo de datos

```
/user://config.json
{
  "theme": "dark",
  "font_size_pt": 18,
  "reader_font": "Inter/Roboto/...",
  "mono_font": "JetBrainsMono/...",
  "last_note": "notes/intro.md",
  "favorites": ["notes/intro.md", "notes/todo.md"]
}

/user://notes/
  ├─ intro.md
  ├─ guia/
  │   ├─ indice.md
  │   └─ img/
  │       └─ diagrama.png
  └─ index.json   // cache: títulos, timestamps, hashes
```

---

## 8) Accesibilidad

* Tamaños ≥ 18 pt por defecto; escalado en pasos y ajuste fino.
* Contraste alto opcional.
* Preparado para **TTS**: mantener bloques semánticos (párrafos, citas, listas) con metadatos para *highlight* futuro.

---

## 9) TTS — Diseño futuro

**Interfaz** `TTSService` (autoload)

* `is_available() -> bool`
* `speak(text: String, rate: float, pitch: float, voice_id: String) -> void`
* `pause()`, `resume()`, `stop()`
* `list_voices() -> Array`

**Implementaciones**

* **Android**: *Android plugin* que use `android.speech.tts.TextToSpeech`.
* **Windows**: GDExtension a **SAPI** o integración con **eSpeak NG** (offline).

**UX de lectura**

* Botón ▶️ en AppBar.
* Controles en mini barra: Velocidad (0.5–2.0), Tono, Voz.
* Resaltado de la frase actual en el `RichTextLabel` (por rangos). Fallback: resaltado de párrafo completo.

---

## 10) Flujo de usuario (MVP)

1. **Primera apertura** → pantalla vacía con CTA “Importa tus notas (.md)”.
2. **Importar** → selecciona archivo(s). La app copia a `user://notes/...` y re‑indexa.
3. **Leer** → lista de notas → tocar una → se muestra con TOC plegable.
4. **Ajustar fuente** → A−/A+ o Ajustes.
5. **Favoritos** → desde menú de nota “★ Añadir a favoritos”.

---

## 11) Parser Markdown (subset inicial)

* **Encabezados**: líneas que empiezan por `#` (1–6) → tamaños/espaciados.
* **Énfasis**: `**bold**`, `*italic*`, `~~del~~` → BBCode `[b]`, `[i]`, `[s]`.
* **Código**: `` `inline` `` → `[code]inline[/code]`; triple backtick bloque con fuente mono.
* **Listas**: `-`/`*`/`+` y `1.` → listas anidadas simples.
* **Citas**: `>` → estilo con barra lateral.
* **Enlaces**: `[texto](url)` (solo http(s) y rutas relativas internas).
* **Imágenes**: `![alt](ruta)` si la ruta existe dentro del repo de la app.

> Validar/escapar BBCode para evitar *injection*.

---

## 12) Gestión de archivos y permisos

* **Windows**: sin permisos especiales. Dialog para importar/copiar.
* **Android**: mantener datos en almacenamiento **interno** de app (`user://`). Para importar, usar *Share intent* (plugin) o selector que copie el archivo hacia `user://notes/`.
* Sin lectura masiva de todo el dispositivo (nada de permisos peligrosos).

---

## 13) Theming y tipografías

* Tema claro/oscuro con `Theme` y *theme overrides*.
* Tamaño de fuente global mediante *theme override* en el `Main`.
* Tipografías: **Inter/Roboto** (lectura) + **JetBrains Mono/Fira Code** (código).

**Ejemplo (GDScript) — escalado de fuente global**

```gdscript
# En Main.gd
@onready var root: Control = $"."
var base_pt := 18

func _ready():
    _apply_font_size(base_pt)

func on_font_minus_pressed():
    base_pt = clamp(base_pt - 2, 12, 28)
    _apply_font_size(base_pt)

func on_font_plus_pressed():
    base_pt = clamp(base_pt + 2, 12, 28)
    _apply_font_size(base_pt)

func _apply_font_size(pt: int):
    # Override de tamaño para controles comunes
    var types = ["Label", "RichTextLabel", "Button", "LineEdit", "CheckBox"]
    for t in types:
        root.add_theme_font_size_override("font_size", pt, t)
    # Guardar en preferencias
    AppState.set_font_size(pt)
```

---

## 14) Búsqueda y TOC

* **Índice**: al importar/actualizar nota, extraer título (primer H1 o nombre de archivo) y *headings* para TOC.
* **Búsqueda**: escanear texto plano de la nota (sin BBCode) + títulos. Mostrar resultados agrupados por nota con *snippet*.

---

## 15) Estructura del proyecto (propuesta)

```
res://
  autoload/
    AppState.gd
    NoteIndex.gd
    Markdown.gd
  scenes/
    Main.tscn
    Reader.tscn        # RichTextLabel + gestor TOC
    Sidebar.tscn       # Notas/Favoritos/TOC
    Settings.tscn
  ui/
    icons/*.svg
    theme.tres
  data/
    sample_notes/*
  android/
    plugins/tts/...
    plugins/share_intent/...
```

---

## 16) Exportación y *Builds*

**Android**

* Paquete: `com.tomasgd.mdreader` (ejemplo).
* Orientación: **portrait** fija.
* Iconos/adaptive icon.
* VersionCode semántico (100, 101...).
* Probar en API 26–35.

**Windows**

* x86_64; carpeta portable con `notes/` inicial.
* MSI/Zip; incluir licencia y README.

---

## 17) Pruebas (checklist MVP)

* Render correcto de: títulos, listas anidadas, citas, código, imágenes locales.
* A−/A+ afecta a todo el visor y persiste tras reiniciar.
* Importación: uno y varios archivos .md; nombres con espacios/acentos.
* Búsqueda: encuentra términos en cuerpo y título.
* TOC: salta a secciones; mantiene posición tras volver.
* Temas: claro/oscuro con contraste suficiente.
* Android: comparte .md desde otra app → se importa.
* Windows: importar por diálogo.

---

## 18) Seguridad y privacidad

* Sin permisos de red en MVP.
* Archivos siempre en *sandbox* de app; sin recorrer almacenamiento externo.
* Sanitizar rutas relativas en imágenes/enlaces.

---

## 19) Roadmap sugerido

* **Sprint 1 (MVP core)**: estructura, importación, parser básico, visor, A−/A+, temas.
* **Sprint 2**: índice/búsqueda/TOC, favoritos, ajustes persistentes, empaquetado Win/Android.
* **Sprint 3 (v1.1)**: TTS Android, resaltado de frase, syntax highlight básico, exportar HTML.

---

## 20) Entregables para “Claude”

1. Repositorio Godot con estructura anterior y *scenes* mínimas.
2. `Markdown.gd` con parser subset + tests de casos MD representativos.
3. `AppState.gd` (JSON en `user://config.json`) y `NoteIndex.gd`.
4. `Reader.tscn` con `RichTextLabel` y API `render(md_text)`.
5. `Settings.tscn` + lógica de tema/tamaño.
6. Manual de exportación Android/Windows.
7. Carpeta `data/sample_notes/` con 10‑15 notas de prueba.

---

## 21) Notas de implementación

* Empezar por **lectura** y UX del visor antes de ampliar parser.
* Mantener el parser desacoplado (fácil reemplazo por GDExtension a *cmark* en el futuro).
* Asegurar que **todo** el escalado de texto se hace por *theme overrides*; evitar *hardcoded*.
* Evitar dependencias externas en MVP; todo offline.

---

## 22) Snippets útiles

**Plantilla para convertir MD → BBCode (muy básico, ejemplo orientativo)**

```gdscript
# Markdown.gd
class_name Markdown

static func to_bbcode(md: String) -> String:
    var text := md
    # Encabezados (# )
    text = text.replace("\r\n", "\n")
    var lines := text.split("\n")
    for i in lines.size():
        var l := lines[i]
        var m := l.match("^(#{1,6})\\s+(.*)$")
        if m:
            var level := m[1].length()
            var title := m[2]
            lines[i] = "[b]" + title + "[/b]"  # Ajustar estilo por nivel en el visor
    text = "\n".join(lines)

    # Énfasis
    text = text.replace("**", "[b]").replace("[b][b]", "[/b]") # Simplista; usar regex reales
    # ... Añadir reglas seguras (usar RegEx para casos correctos)
    return text
```

**Aplicar render**

```gdscript
# En Reader.gd
@onready var r: RichTextLabel = $RichTextLabel

func show_markdown(md: String):
    var bb := Markdown.to_bbcode(md)
    r.bbcode_enabled = true
    r.text = ""  # clear
    r.parse_bbcode(bb)
```

> Nota: los snippets son *orientativos*. Para producción, usar `RegEx` robustas y sanitizar bien el BBCode.

---

## 23) Licencia y branding

* Código: MIT (sugerida) o la que definas.
* Nombre temporal: **MDReader Vertical**.
* Branding final a definir (iconos vectoriales, splash mínimo).

---

### Lista corta (resumen para pegar a Claude)

* Godot 4.x, Windows + Android (portrait).
* Lector Markdown (subset CommonMark).
* UI: AppBar con Buscar, A−/A+, Tema; Panel lateral con Notas/Favoritos/TOC; Visor con `RichTextLabel`.
* Importar .md a `user://notes`; índice + búsqueda + TOC.
* Tamaño de letra global persistente; temas claro/oscuro.
* Sin red; todo offline.
* Futuro: TTS (Android/Windows), resaltado al leer, syntax highlight, export HTML/PDF.

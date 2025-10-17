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

## 🚀 Funcionalidades Implementadas

### 📖 Experiencia de Lectura
- **Renderizado completo de Markdown**: Soporte para encabezados, listas, enlaces, texto en negrita/cursiva, código inline y bloques de código
- **Interfaz minimalista**: Solo el contenido, sin distracciones
- **Márgenes inteligentes**: Padding interno del 4% para una lectura cómoda
- **Scroll suave**: Navegación fluida por documentos largos

### 🎛️ Controles de Usuario
- **Menú principal**: Pantalla de bienvenida con opciones claras
- **Barra superior**: Aparece solo durante la lectura con controles esenciales
  - 🏠 **Volver al menú**: Regreso rápido al inicio
  - **A-** / **A+**: Ajuste de tamaño de fuente en tiempo real
- **Configuración avanzada**: Panel de ajustes completo

### 🎨 Personalización
- **Sistema de temas**: Claro, oscuro y alto contraste
- **Tipografía escalable**: Rango de 12pt a 32pt con persistencia
- **Preferencias guardadas**: Configuración que se mantiene entre sesiones

### 📁 Gestión de Archivos
- **Importación fácil**: Selección múltiple de archivos .md
- **Almacenamiento local**: Archivos copiados a directorio seguro de la app
- **Indexación automática**: Sistema de caché para acceso rápido

## 🛠️ Tecnologías Utilizadas

- **Motor**: Godot Engine 4.x
- **Lenguaje**: GDScript
- **Plataforma**: Windows (x64)
- **Renderizado**: RichTextLabel con BBCode
- **Almacenamiento**: Sistema de archivos local (`user://`)

## 📁 Estructura del Proyecto

```
obsidian-markdown/
├── autoload/                 # Singletons globales
│   ├── AppState.gd          # Gestión de estado y configuración
│   ├── NoteIndex.gd         # Indexación y búsqueda de notas
│   └── Markdown.gd          # Parser Markdown → BBCode
├── scenes/                   # Escenas principales
│   ├── Main.tscn/gd         # Escena principal de la aplicación
│   └── MainSimple.tscn/gd   # Versión simplificada
├── ui/                      # Recursos de interfaz
│   └── theme.tres           # Tema personalizado
└── project.godot            # Configuración del proyecto
```

## 🏗️ Arquitectura

### Autoloads (Singletons)
- **AppState**: Maneja preferencias del usuario, temas y persistencia de configuración
- **NoteIndex**: Indexa archivos Markdown y proporciona funciones de búsqueda
- **Markdown**: Convierte sintaxis Markdown a BBCode para renderizado

### Sistema de Temas
- Soporte completo para temas claro/oscuro/alto contraste
- Persistencia automática de preferencias
- Aplicación en tiempo real sin reiniciar

### Parser de Markdown
- Conversión MD → BBCode optimizada
- Soporte para elementos comunes: encabezados, listas, énfasis, código
- Renderizado seguro sin inyección de código

## 🎮 Uso de la Aplicación

### 1. Inicio
Al abrir la aplicación, aparece un menú principal con estas opciones:
- 📁 **Importar Archivos Markdown**
- ⚙️ **Configuración**
- ℹ️ **Acerca de**
- ❌ **Salir**

### 2. Importar Archivos
- Selecciona uno o múltiples archivos `.md`
- Los archivos se copian al directorio seguro de la app
- La primera nota se abre automáticamente

### 3. Lectura
- **Interfaz limpia**: Solo el contenido del documento
- **Barra superior**: Controles mínimos pero esenciales
- **Navegación**: Botón 🏠 para volver al menú principal

### 4. Personalización
- **Tamaño de fuente**: Botones A-/A+ en la barra superior
- **Temas**: Accesibles desde el menú de configuración
- **Ajustes avanzados**: Panel completo de preferencias

## 🚧 Funcionalidades Futuras

### Versión 1.1
- **Text-to-Speech (TTS)**: Lectura en voz alta con resaltado
- **Navegación mejorada**: Tabla de contenidos (TOC) clickeable
- **Búsqueda**: Buscar texto dentro de las notas
- **Favoritos**: Sistema de marcadores para notas frecuentes

### Versión 1.2+
- **Syntax highlighting**: Resaltado de código en bloques
- **Exportación**: PDF y HTML
- **Temas personalizados**: Importar/crear temas propios
- **Soporte multiplataforma**: Android y Linux

## 💻 Requisitos del Sistema

- **SO**: Windows 10/11 (x64)
- **RAM**: 2GB mínimo
- **Espacio**: 50MB para instalación + espacio para notas
- **Otros**: No requiere conexión a internet

## 🔧 Desarrollo

### Prerrequisitos
- Godot Engine 4.x (última versión LTS recomendada)
- Conocimientos básicos de GDScript

### Estructura de Desarrollo
```bash
# Clonar el repositorio
git clone [repository-url]

# Abrir en Godot
godot project.godot

# Ejecutar en modo debug
F5 o F6 en el editor de Godot
```

### Exportación
1. **Configurar plantilla de exportación** para Windows
2. **Establecer configuración de build**:
   - Nombre: MDReader
   - Icono personalizado: `icon.svg`
   - Configuración de ventana: 800x600, redimensionable
3. **Exportar** ejecutable final

## 📄 Licencia

Este proyecto está licenciado bajo la **Licencia MIT**.

```
MIT License

Copyright (c) 2025 Tomás González

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 👨‍💻 Autor

**Tomás González**
- Proyecto desarrollado con Godot Engine 4.x
- Enfoque en minimalismo y experiencia de usuario

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Para contribuir:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📊 Estado del Proyecto

- ✅ **MVP Completo**: Funcionalidad básica de lectura
- ✅ **Sistema de temas**: Múltiples opciones visuales
- ✅ **Configuración persistente**: Preferencias guardadas
- ✅ **Interfaz minimalista**: UX optimizada para lectura
- 🚧 **TTS**: En desarrollo para próxima versión
- 🚧 **Búsqueda avanzada**: Planificado para v1.1

## 📞 Soporte

Para reportar bugs o solicitar features:
- Abre un **Issue** en el repositorio
- Describe detalladamente el problema o sugerencia
- Incluye pasos para reproducir (si es un bug)

---

*"La simplicidad es la máxima sofisticación" - Leonardo da Vinci*
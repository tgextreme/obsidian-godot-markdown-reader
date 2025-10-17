# Solución de Problemas TTS (Text-to-Speech)

## ¿No funciona el audio TTS?

Si el texto a voz no funciona en Windows, sigue estos pasos:

### 1. Verificar TTS en Windows
Abre PowerShell como administrador y ejecuta:
```powershell
Add-Type -AssemblyName System.Speech
(New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak("Prueba de audio")
```

### 2. Verificar configuración de Windows
1. Ve a **Configuración** → **Hora e idioma** → **Voz**
2. Asegúrate de que hay voces instaladas
3. Configura una voz como predeterminada

### 3. Verificar micrófono y audio
1. Ve a **Configuración** → **Sistema** → **Sonido**
2. Verifica que hay dispositivos de audio funcionando
3. Aumenta el volumen del sistema

### 4. Permisos de aplicación
1. Ve a **Configuración** → **Privacidad** → **Micrófono**
2. Permite que las aplicaciones accedan al micrófono

### 5. Si sigue sin funcionar
- Reinicia la aplicación
- Reinicia Windows
- Verifica que Godot tenga permisos de audio

## Debug en la aplicación
Los mensajes de debug aparecen en la consola cuando ejecutas desde Godot Editor.
Busca líneas que empiecen con "=== DEBUG TTS START ===".
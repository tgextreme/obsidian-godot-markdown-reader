# Guía de Markdown

Esta nota contiene ejemplos de todos los elementos de Markdown soportados por MDReader Vertical.

## Encabezados

# Encabezado 1
## Encabezado 2  
### Encabezado 3
#### Encabezado 4
##### Encabezado 5
###### Encabezado 6

## Formato de texto

**Texto en negrita** se hace con `**texto**` o `__texto__`

*Texto en cursiva* se hace con `*texto*` o `_texto_`

~~Texto tachado~~ se hace con `~~texto~~`

`Código inline` se hace con backticks

## Enlaces e imágenes

[Esto es un enlace](https://ejemplo.com)

![Imagen de ejemplo](imagen.png)

## Listas

### Lista sin orden
- Elemento 1
- Elemento 2
  - Subelemento A
  - Subelemento B
- Elemento 3

### Lista ordenada
1. Primer elemento
2. Segundo elemento
   1. Subelemento numerado
   2. Otro subelemento
3. Tercer elemento

## Citas

> Esta es una cita simple.

> Esta es una cita más larga
> que ocupa múltiples líneas
> y mantiene el formato.

## Código

### Código inline
Usa `console.log()` para imprimir en la consola.

### Bloques de código

```
función ejemploJavaScript() {
    console.log("¡Hola mundo!");
    return true;
}
```

```python
def ejemplo_python():
    print("¡Hola mundo!")
    return True
```

## Separadores

---

## Combinaciones

Puedes **combinar *diferentes* tipos** de ~~formato~~ en `una misma línea`.

### Lista con código

1. Instalar dependencias: `npm install`
2. Ejecutar el proyecto: `npm run dev`
3. Abrir en el navegador: `http://localhost:3000`

### Cita con código

> Para usar la función, simplemente llama:
> `resultado = mi_funcion(parametro)`

## Caracteres especiales

MDReader maneja correctamente:
- Acentos: áéíóú, ñ, ü
- Símbolos: ©, ®, ™, €, $
- Emojis: 😀 🎉 📚 ⚡ 🌟

---

*Esta guía te ayudará a entender todos los elementos soportados en MDReader Vertical.*
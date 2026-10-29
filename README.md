# Clima en Casa

Aplicación móvil sencilla hecha con Flutter. Permite buscar una ciudad y consultar el clima actual y el pronóstico de cinco días en español.

## Funciones

- Busca ciudades y permite elegir entre coincidencias.
- Muestra temperatura, sensación térmica, humedad, viento, probabilidad de lluvia y máximas/mínimas.
- Actualiza los datos con el botón de recarga o al deslizar hacia abajo.
- Presenta mensajes para búsquedas sin resultados, falta de conexión, demora, respuesta vacía, formato inesperado y límite de solicitudes.

## API

La aplicación consulta las API públicas de [geocodificación](https://open-meteo.com/en/docs/geocoding-api) y [pronóstico](https://open-meteo.com/en/docs) de Open-Meteo. Las solicitudes se hacen por HTTPS y este proyecto no necesita una clave ni un archivo .env. La ciudad escrita se envía al servicio de geocodificación para encontrar sus coordenadas.

## Requisitos y ejecución

- Flutter instalado con soporte para Android.
- Conexión a internet en el emulador o teléfono.

Desde esta carpeta:

~~~bash
flutter pub get
flutter run
~~~

Para generar un APK de lanzamiento:

~~~bash
flutter build apk --release
~~~

En Android Studio se puede abrir la carpeta del proyecto y ejecutar lib/main.dart en un emulador.

## Herramientas de IA utilizadas

- **Codex (OpenAI, modelo GPT-6):** se usó para interpretar la consigna, proponer la estructura de la app, generar la interfaz y la integración HTTP/JSON con Open-Meteo y manejar los estados de error.
- No se usaron otras herramientas de IA para este proyecto durante esta sesión.
- **Parte realizada por el estudiante sin ayuda de IA:** Yo analice y empece el diseño ademas de buscar la api que usamos

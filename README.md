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

- **Codex (OpenAI, modelo GPT-6):** se usó para interpretar la consigna, proponer la estructura de la app, generar la interfaz y la integración HTTP/JSON con Open-Meteo, manejar los estados de error y redactar esta documentación.
- No se usaron otras herramientas de IA para este proyecto durante esta sesión.
- **Parte realizada por el estudiante sin ayuda de IA:** pendiente de completar por el estudiante con una acción real que haya realizado personalmente. No afirmes que escribiste el código generado por IA. Antes de entregar, estudia el proyecto y añade aquí una parte concreta que hayas hecho y puedas explicar.

## Bitácora de IA

La bitácora está en [docs/bitacora_ia.md](docs/bitacora_ia.md). Registra el prompt original y cuatro prompts adicionales redactados por Codex a petición del estudiante; distingue claramente su origen.

## Demostración en clase

Guion breve para la demostración: [docs/demo_clase.md](docs/demo_clase.md).

## Verificación local

El análisis estático terminó sin incidencias y la app se instaló y ejecutó en modo release en un emulador Android. La captura real está en evidencias/captura_app.png; los comandos y el alcance de esa comprobación se describen en [docs/verificacion.md](docs/verificacion.md).

## GitHub

- Perfil de GitHub conectado: [SoyPolar001](https://github.com/SoyPolar001).
- El repositorio de esta app aún debe publicarse. Añade su enlace cuando exista.
- La captura del estado GitHub Pro debe ser una captura auténtica de la cuenta. No se incluye una captura inventada.
- El historial de commits debe reflejar cambios que el estudiante revise y haga propios. No se atribuyen a su cuenta commits creados por IA.

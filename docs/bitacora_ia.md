# Bitácora de programación con IA

**Proyecto:** Clima en Casa  
**Herramienta:** Codex (OpenAI, modelo GPT-6)

El primer prompt es el mensaje original del estudiante. Los prompts 2–5 fueron redactados por Codex a petición del estudiante y se usaron para orientar la implementación y revisar el resultado. Se marca su origen para que no parezcan mensajes anteriores escritos por el estudiante.

## Prompt 1 — mensaje original del estudiante

> haz lo que te pide

**Respuesta de la IA:** Leí la tarea y elegí una app móvil de clima con Flutter y Open-Meteo. Preparé el proyecto, el README y una demostración.

**¿Funcionó a la primera?** La app se pudo crear después de corregir el nombre de paquete. Flutter rechazó ClimaEnCasa porque los nombres de paquete deben ir en minúsculas; se cambió a clima_en_casa.

## Prompt 2 — redactado por Codex a petición del estudiante

> Haz una app sencilla en Flutter para ver el clima con una API gratis.

**Respuesta de la IA:** Preparé Clima en Casa usando Open-Meteo, sin clave de API, con temperatura actual y pronóstico de cinco días.

**¿Funcionó a la primera?** No del todo. El análisis detectó errores de formato en unas interpolaciones de texto; los corregí y Flutter Analyzer terminó sin incidencias.

## Prompt 3 — redactado por Codex a petición del estudiante

> Pon una búsqueda para escribir una ciudad y ver el pronóstico de cinco días.

**Respuesta de la IA:** Agregué búsqueda de ciudades, opciones cuando hay varias coincidencias y consulta de coordenadas y pronóstico. Comprobé una respuesta real para Ciudad de México en el emulador.

**¿Funcionó a la primera?** Sí después de la corrección de formato del prompt anterior. La captura del emulador muestra datos recibidos de la API.

## Prompt 4 — redactado por Codex a petición del estudiante

> Muestra un mensaje si no hay internet, no aparece la ciudad o la API falla.

**Respuesta de la IA:** Añadí estados para búsqueda sin resultados, respuesta vacía, falta de conexión, demora, errores HTTP y límite de solicitudes.

**¿Funcionó a la primera?** La revisión estática quedó limpia. No desconecté el emulador para provocar el error de red; ese caso se manejó en el código, pero no se verificó dinámicamente.

## Prompt 5 — redactado por Codex a petición del estudiante

> Haz un README fácil para saber cómo correr la app y menciona qué IA usé.

**Respuesta de la IA:** Escribí instrucciones de ejecución, descripción de la API y declaración de uso de Codex. También dejé indicado que el estudiante debe completar una parte que realmente haya hecho sin IA.

**¿Funcionó a la primera?** Sí. El README quedó listo; faltan el enlace del repositorio y la descripción verdadera del trabajo personal del estudiante.

## Error detectado y aprendizaje

El primer nombre de paquete sugerido no era válido. Lo corregí a clima_en_casa. También revisé el manifiesto Android y añadí el permiso de Internet que necesita la aplicación.

Aprendí que hay que revisar las instrucciones de Flutter y la respuesta de la API, no solo generar código. La próxima vez especificaré desde el inicio el nombre del paquete, los errores que debe manejar la app y qué datos quiero mostrar; después comprobaré tanto el análisis como la ejecución.

> **Nota de honestidad:** los prompts 2–5 se redactaron y aplicaron con ayuda de IA por petición del estudiante; no son citas de conversaciones anteriores. El estudiante aún debe completar su contribución personal y los requisitos de GitHub.

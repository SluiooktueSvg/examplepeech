# Blueprint: Asistente de Voz con IA y Aurora Reactiva

## Descripción General

Esta aplicación es un asistente de inteligencia artificial activado por voz para Flutter. El objetivo es crear una experiencia de usuario fluida y visualmente atractiva, similar a la de aplicaciones como ChatGPT, donde el usuario interactúa con una IA a través de la voz.

La característica principal es una animación de una "aurora" (un shader personalizado) que reacciona en tiempo real al volumen de la voz del usuario, creando una respuesta visual dinámica a la interacción.

## Características Implementadas

### 1. Diseño y Experiencia de Usuario (UX)

*   **Fondo Oscuro y Minimalista:** La aplicación utiliza un fondo negro (`Colors.black`) para crear un alto contraste y enfocar la atención del usuario en la animación y el texto.
*   **Animación de Aurora Central:** El elemento visual principal es una animación de shader con forma de globo que simula una aurora boreal. Está centrado en la pantalla.
*   **Feedback Visual Reactivo:**
    *   La animación de la aurora está directamente conectada a la entrada de audio del micrófono.
    *   La velocidad, el brillo y la intensidad de la animación aumentan cuando el usuario habla, proporcionando una respuesta visual inmediata y atractiva.
    *   Cuando el usuario deja de hablar, la animación vuelve a un estado más calmado.
*   **Diseño de Conversación Claro:**
    *   La interfaz está dividida verticalmente para separar la visualización de la conversación.
    *   El texto transcrito del usuario se muestra en un estilo itálico y tenue.
    *   La respuesta de la IA se muestra debajo, en un texto más prominente y enmarcado en un cuadro semitransparente para destacarla.
*   **Botón de Acción Flotante (FAB):**
    *   Un botón de micrófono central y fácilmente accesible se utiliza para iniciar y detener la grabación de voz.
    *   El icono del botón cambia de `mic_off` a `mic` para indicar el estado de escucha.
    *   El color del botón cambia a rojo mientras se graba para proporcionar una señal visual clara.

### 2. Funcionalidad Principal

*   **Permisos de Micrófono:** La aplicación solicita y gestiona los permisos de micrófono necesarios en el primer uso.
*   **Reconocimiento de Voz (Speech-to-Text):**
    *   Utiliza el paquete `speech_to_text` para convertir la voz del usuario en texto en tiempo real.
    *   El texto transcrito se actualiza en la pantalla a medida que el usuario habla.
*   **Conexión con IA Generativa (Gemini):**
    *   Utiliza el SDK de Firebase AI (`firebase_ai`) para conectarse al modelo `gemini-1.5-flash` de Google.
    *   Cuando el usuario termina de hablar, el texto transcrito se envía automáticamente al modelo Gemini como un prompt.
*   **Visualización de la Respuesta:**
    *   La respuesta generada por la IA se recibe y se muestra en la interfaz de usuario.
    *   Se muestra un indicador de progreso (`CircularProgressIndicator`) mientras se espera la respuesta de la IA.

### 3. Arquitectura y Código

*   **Configuración de Firebase:** El proyecto está completamente configurado para usar Firebase, con `firebase_options.dart` generado y la inicialización de Firebase en la función `main`.
*   **Shader Personalizado:** La animación se logra a través de un archivo de shader GLSL (`aurora.frag`) que se carga en la aplicación.
    *   El shader utiliza `iTime` para la animación base y `iIntensity` para modular la animación según el volumen de la voz.
*   **Servicio de IA Modular:** La lógica para interactuar con Gemini está encapsulada en una clase `GenerativeAiService`, promoviendo una buena separación de responsabilidades.
*   **Gestión de Estado Simple:** El estado de la aplicación (texto, respuesta de la IA, estado de escucha) se gestiona localmente en `_AuroraPageState` usando `setState`, adecuado para la escala de esta aplicación.
*   **Manejo de Ciclo de Vida:** Los controladores (`AnimationController`) y los servicios de voz (`SpeechToText`) se inicializan y se liberan correctamente en `initState` y `dispose`.

## Plan de Implementación Actual

**¡COMPLETADO!** La aplicación ha sido construida y todas las características descritas anteriormente han sido implementadas.

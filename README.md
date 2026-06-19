# 🏆 Mundial 26 - Flutter App

¡Bienvenido al repositorio oficial de **Mundial 26**! Una aplicación móvil de nivel profesional construida en **Flutter** diseñada para seguir cada instante de la Copa Mundial de la FIFA 2026 en tiempo real. 

Esta aplicación no es solo un visor de resultados; es una plataforma integral impulsada por sincronización de hilos cruzados (cross-isolate), widgets nativos, notificaciones push sin servidor y hasta un reproductor de IPTV integrado para ver los partidos en vivo.

---

## ✨ Características Principales

*   🔴 **Resultados Ultra-En Vivo (ESPN API):** Consumo en tiempo real de la API pública oculta de ESPN para obtener marcadores, goleadores, minutos exactos y tarjetas al instante.
*   ⚡ **Sincronización Cross-Isolate:** Arquitectura avanzada donde un *Background Isolate* (Motor en segundo plano) interactúa sin latencia con el *UI Isolate* (Interfaz de usuario) logrando actualizaciones instantáneas de goles sin doble consumo de red.
*   📱 **Widget Nativo para Android:** Un widget programado nativamente en Kotlin (`HomeWidget`) que se actualiza en el escritorio del teléfono mostrando el marcador, tiempo transcurrido y quién anotó el gol sin tener que abrir la app.
*   🔔 **Alertas Inteligentes (Notificaciones Locales):** Te avisa 15 minutos antes de que empiece un partido, cuando arranca el primer o segundo tiempo, y envía una notificación vibratoria instantánea (con nombre del jugador) en el momento exacto de un gol.
*   📺 **Reproductor IPTV (En Vivo):** Módulo interno capaz de leer y parsear listas `.m3u` para sintonizar canales de televisión globales usando `video_player` y `chewie`, permitiendo ver el partido en vivo sin salir de la app.
*   🎉 **Animaciones Lottie de Celebración:** Overlay interactivo que explota confeti y celebra visualmente sobre cualquier pantalla de la app en la que estés cuando tu equipo anota.
*   🎨 **Diseño Premium:** Interfaz oscura, elegante, con tarjetas de "Hero Match" dinámicas, indicadores de tiempo extra (formato FIFA `45' + 2'`), micro-animaciones latentes para partidos en vivo y tipografías gruesas modernas.

---

## 🏗️ Arquitectura y Tecnologías

El proyecto está diseñado bajo un estricto patrón de manejo de estado y separación de responsabilidades:

*   **Framework:** Flutter (Dart)
*   **Manejo de Estado:** Riverpod (`flutter_riverpod`)
*   **Servicios en Segundo Plano:** `flutter_background_service` (Mantiene un Foreground Service en Android para escuchar la API de ESPN aunque minimices la app).
*   **Almacenamiento Local:** `shared_preferences` (Se usa como puente de comunicación caché entre el sistema operativo nativo, el background isolate y el front-end).
*   **Integración Nativa:** `MethodChannel` personalizados para enviar la app a recientes (Background) en lugar de cerrarla, y `home_widget` para Kotlin.

---

## 🚀 Instalación y Compilación

### Requisitos Previos
*   Flutter SDK instalado (Versión 3.16+)
*   Android Studio o herramientas de SDK (Para compilar en Android)

### Pasos para desarrollo
1. Clona el repositorio.
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecuta la app en modo debug:
   ```bash
   flutter run
   ```

### 📦 Compilación para Producción (Release APK)
Para disfrutar de la app al máximo rendimiento (60 FPS) y con el servicio en segundo plano operando eficientemente:

1. Asegúrate de detener cualquier sesión de debug.
2. Limpia la caché del proyecto:
   ```bash
   flutter clean
   flutter pub get
   ```
3. Genera el APK:
   ```bash
   flutter build apk --release
   ```
4. El archivo final estará listo para instalar en tu teléfono en la ruta:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## 🔒 Permisos Importantes (Android 13+)

Al abrir la aplicación por primera vez instalada desde el APK Release, se solicitará el permiso de **Notificaciones**. Es **estrictamente obligatorio** otorgarlo para que el servicio en segundo plano (`Foreground Service`) pueda inicializarse correctamente y mantener los datos vivos mientras la app está cerrada.

---

## 👨‍💻 Autor y Diseño
Desarrollado con arquitectura sólida, pasión por el fútbol y la mejor experiencia de usuario en mente.

# 🔔 Orvix

**App móvil Android para que los estudiantes organicen sus tareas, reciban recordatorios y cuenten con un asistente de inteligencia artificial.**

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?logo=sqlite&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini_API-8E75B2?logo=googlegemini&logoColor=white)

Orvix nació como proyecto académico del técnico en programación. Permite registrar tareas con materia y fecha/hora de entrega, avisa con notificaciones antes de que se venzan y ofrece un asistente de IA que conoce las tareas del estudiante para ayudarle a organizarse.

<!--
CAPTURAS DE PANTALLA
Guarda tus imágenes en la carpeta screenshots/ y quita las marcas de comentario de este bloque.

<p align="center">
  <img src="screenshots/home.png" width="200" alt="Pantalla principal">
  <img src="screenshots/chat.png" width="200" alt="Chat con IA">
  <img src="screenshots/calendar.png" width="200" alt="Calendario">
  <img src="screenshots/progress.png" width="200" alt="Progreso">
</p>
-->

## ✨ Funcionalidades

- **Tareas:** crear tareas con título, materia y fecha/hora; marcarlas como completadas; eliminarlas; filtrar por materia. Cada materia tiene su propio color.
- **Recordatorios:** notificaciones locales que se repiten cada 10 minutos (hasta 6 veces) si la tarea no se ha completado, y se cancelan al completarla o eliminarla.
- **Chatbot académico:** chat con IA (Gemini) que conoce tus tareas y responde con ese contexto.
- **Recomendaciones:** tarjeta en la pantalla principal con una sugerencia corta generada por IA.
- **Planificación inteligente:** plan de estudio personalizado generado por IA a partir de tus tareas.
- **Progreso y análisis:** porcentaje de tareas completadas (total y por materia) y análisis de patrones con IA.
- **Calendario:** vista mensual con los días que tienen tareas; al tocar un día se listan sus tareas.
- **Perfil:** nombre y foto de perfil personalizables, con resumen de tareas.

## 🛠️ Tecnologías

| Paquete | Uso |
|---|---|
| `sqflite` | Base de datos local para las tareas |
| `flutter_local_notifications` + `timezone` | Recordatorios programados |
| `http` | Conexión con la API de Gemini |
| `table_calendar` | Vista de calendario |
| `image_picker` | Foto de perfil desde la galería |
| `shared_preferences` | Nombre y foto de perfil guardados localmente |
| `google_fonts` | Tipografía Poppins |
| `intl` | Formato de fechas |

## 📁 Estructura del proyecto

```
lib/
├── main.dart
├── config/
│   ├── api_keys.example.dart   # plantilla de la API key
│   └── api_keys.dart           # tu clave real (NO se sube a Git)
├── models/
│   └── task.dart
├── services/
│   ├── database_helper.dart
│   ├── notification_service.dart
│   ├── gemini_service.dart
│   └── task_ai_helper.dart
├── screens/
│   ├── home_screen.dart
│   ├── add_task_screen.dart
│   ├── chat_screen.dart
│   ├── study_plan_screen.dart
│   ├── progress_screen.dart
│   ├── calendar_screen.dart
│   └── profile_screen.dart
└── utils/
    └── subject_colors.dart
```

## 🚀 Cómo ejecutarlo

**Requisitos:** [Flutter](https://docs.flutter.dev/get-started/install), Android Studio (para el emulador o los drivers del celular) y una API key gratuita de Gemini.

1. Clona el repositorio:
   ```bash
   git clone https://github.com/Xx3ajolotexX/Orvix.git
   cd Orvix
   ```
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Consigue tu propia API key gratis en [Google AI Studio](https://aistudio.google.com).
4. En `lib/config/`, copia `api_keys.example.dart` como `api_keys.dart` y pega tu clave:
   ```dart
   class ApiKeys {
     static const String geminiApiKey = 'TU_API_KEY';
   }
   ```
5. Conecta un celular Android (o abre un emulador) y ejecuta:
   ```bash
   flutter run
   ```

> **Nota:** el modelo de Gemini se define en `lib/services/gemini_service.dart`. Si aparece un error 404 de "model is no longer available", Google descontinuó ese modelo: revisa el nombre vigente en la [documentación de modelos](https://ai.google.dev/gemini-api/docs/models).

## 🔮 Ideas a futuro

- Versión para iOS (requiere ajustes en las notificaciones y permisos).
- Guardar fecha de creación y de completado de cada tarea para análisis históricos.
- Ícono de lanzamiento personalizado con `flutter_launcher_icons`.
- Sincronización de tareas en la nube.

## 👤 Autor

Proyecto desarrollado por **Santiago   ** como parte del técnico en programación.

## 📄 Licencia

Distribuido bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más información.

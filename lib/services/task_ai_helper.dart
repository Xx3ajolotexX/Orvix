// lib/services/task_ai_helper.dart
//
// Traduce la lista de tareas del usuario en prompts para Gemini.
//
// Confirmado contra tu Task real: title, subject, dueDate (DateTime),
// isCompleted (bool). No requiere ajustes.

import '../models/task.dart';
import 'gemini_service.dart';

class TaskAiHelper {
  static String _formatTasks(List<Task> tasks) {
    final pendientes = tasks.where((t) => !t.isCompleted).toList();
    if (pendientes.isEmpty) return 'El usuario no tiene tareas pendientes.';

    final buffer = StringBuffer();
    for (final t in pendientes) {
      buffer.writeln(
        '- "${t.title}" (${t.subject}) '
        '— entrega: ${t.dueDate}',
      );
    }
    return buffer.toString();
  }

  /// Sugerencia corta para mostrar como tarjeta en home_screen (1-2 frases).
  static Future<String> getQuickSuggestion(List<Task> tasks) async {
    final prompt = '''
Eres el asistente de estudio de la app Orvix. Tareas pendientes del estudiante:

${_formatTasks(tasks)}

Hoy es ${DateTime.now()}.

Dame UNA sola recomendación corta (máximo 2 frases, en español, tono cercano
y motivador) sobre qué tarea priorizar hoy y por qué. No uses markdown ni listas.
''';
    return GeminiService.ask(prompt);
  }

  /// Plan de estudio más completo, para pedirlo desde el chat o un botón "Planificar".
  static Future<String> getStudyPlan(List<Task> tasks) async {
    final prompt = '''
Eres el asistente de estudio de la app Orvix. Tareas pendientes del estudiante:

${_formatTasks(tasks)}

Hoy es ${DateTime.now()}.

Organiza un plan de estudio realista para los próximos días, priorizando por
fecha de entrega y dificultad estimada de cada materia. Responde en español,
en formato de lista simple con guiones, sin usar encabezados markdown (#).
''';
    return GeminiService.ask(prompt);
  }

  /// Análisis corto de patrones a partir del estado actual de las tareas
  /// (no hay historial de fechas de completado en el modelo Task todavía,
  /// así que es un análisis de "foto actual", no de tendencia en el tiempo).
  static Future<String> getPatternAnalysis(List<Task> tasks) async {
    final pendientes = tasks.where((t) => !t.isCompleted).length;
    final completadas = tasks.where((t) => t.isCompleted).length;
    final vencidas = tasks
        .where((t) => !t.isCompleted && t.dueDate.isBefore(DateTime.now()))
        .length;

    final prompt = '''
Eres el asistente de estudio de la app Orvix. Estado actual del estudiante:

${_formatTasks(tasks)}

Totales: $completadas tareas completadas, $pendientes pendientes,
$vencidas de esas pendientes ya están vencidas.

Hoy es ${DateTime.now()}.

Da un análisis breve (máximo 3 frases, en español) sobre en qué materia o
tipo de tarea el estudiante parece estar más atrasado o debería poner más
atención. Si no hay suficiente información, dilo honestamente en vez de
inventar. No uses markdown ni listas.
''';
    return GeminiService.ask(prompt);
  }

  /// Contexto inicial que se le "inyecta" al chat libre para que la IA
  /// sepa qué tareas tiene el estudiante sin que él tenga que escribirlas.
  static String buildSystemContext(List<Task> tasks) {
    return '''
Eres "Orvix IA", el asistente dentro de la app de tareas para estudiantes Orvix.
Ayudas a planificar, priorizar tareas y dar consejos de estudio. Sé breve,
claro, cercano y responde siempre en español.

Tareas pendientes del estudiante ahora mismo:

${_formatTasks(tasks)}
''';
  }
}
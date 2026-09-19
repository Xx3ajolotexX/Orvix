// lib/services/gemini_service.dart
//
// Servicio de bajo nivel: solo sabe mandar texto a Gemini y recibir texto.
// No sabe nada de tareas ni de la lógica de Orvix (eso vive en task_ai_helper.dart).

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class GeminiService {
  static const String _model = 'gemini-3.6-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Envía una conversación completa (historial) y devuelve la respuesta del modelo.
  /// [history] es una lista de mapas: {'role': 'user'|'model', 'text': '...'}
  static Future<String> sendChat(List<Map<String, String>> history) async {
    final url = Uri.parse(
      '$_baseUrl/$_model:generateContent?key=${ApiKeys.geminiApiKey}',
    );

    final contents = history
        .map((m) => {
              'role': m['role'],
              'parts': [
                {'text': m['text']}
              ],
            })
        .toList();

    print('[Orvix][IA] Enviando ${contents.length} mensajes a Gemini...');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'contents': contents}),
    );

    if (response.statusCode != 200) {
      print('[Orvix][IA] Error ${response.statusCode}: ${response.body}');
      throw Exception('Error al contactar la IA (${response.statusCode})');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    try {
      final text =
          data['candidates'][0]['content']['parts'][0]['text'] as String;
      print('[Orvix][IA] Respuesta recibida OK');
      return text.trim();
    } catch (e) {
      print('[Orvix][IA] Respuesta inesperada de Gemini: $data');
      throw Exception('La IA no devolvió una respuesta válida');
    }
  }

  /// Atajo para un solo prompt sin historial (usado en sugerencias automáticas).
  static Future<String> ask(String prompt) {
    return sendChat([
      {'role': 'user', 'text': prompt}
    ]);
  }
}
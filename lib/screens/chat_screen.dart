// lib/screens/chat_screen.dart
//
// Pantalla de chat con el asistente IA. Recibe la lista de tareas actuales
// para que la IA responda con contexto real (no genérico).

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/gemini_service.dart';
import '../services/task_ai_helper.dart';

class ChatScreen extends StatefulWidget {
  final List<Task> tasks;
  const ChatScreen({super.key, required this.tasks});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatMessage {
  final String role; // 'user' o 'model'
  final String text;
  _ChatMessage(this.role, this.text);
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      'model',
      '¡Hola! Soy tu asistente de estudio en Orvix. Puedo ayudarte a '
      'priorizar tus tareas, armar un plan o darte consejos. ¿En qué te ayudo?',
    ));
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _loading) return;
    setState(() {
      _messages.add(_ChatMessage('user', text));
      _loading = true;
    });
    _controller.clear();

    try {
      final history = <Map<String, String>>[
        {'role': 'user', 'text': TaskAiHelper.buildSystemContext(widget.tasks)},
        {'role': 'model', 'text': 'Entendido, tengo el contexto de tus tareas.'},
        ..._messages.map((m) => {'role': m.role, 'text': m.text}),
      ];
      final reply = await GeminiService.sendChat(history);
      setState(() => _messages.add(_ChatMessage('model', reply)));
    } catch (e) {
      print('[Orvix][IA] Error en chat: $e');
      setState(() => _messages.add(_ChatMessage(
            'model',
            'Uy, no pude responder. Revisa tu conexión o tu API key en '
            'lib/config/api_keys.dart.',
          )));
    } finally {
      setState(() => _loading = false);
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente IA'),
        backgroundColor: const Color(0xFF7C5CFF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isUser = m.role == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF7C5CFF)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Pregúntale algo a la IA...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF7C5CFF)),
                    onPressed: () => _send(_controller.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
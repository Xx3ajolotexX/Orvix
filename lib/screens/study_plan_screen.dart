// lib/screens/study_plan_screen.dart
//
// Muestra el plan de estudio que genera la IA a partir de las tareas
// pendientes. Es la pieza "Planificación inteligente" de la diapositiva.

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_ai_helper.dart';

class StudyPlanScreen extends StatefulWidget {
  final List<Task> tasks;
  const StudyPlanScreen({super.key, required this.tasks});

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  String? _plan;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generarPlan();
  }

  Future<void> _generarPlan() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final texto = await TaskAiHelper.getStudyPlan(widget.tasks);
      if (mounted) setState(() => _plan = texto);
    } catch (e) {
      print('[Orvix][IA] Error generando plan: $e');
      if (mounted) {
        setState(() => _error =
            'No se pudo generar el plan. Revisa tu conexión o tu API key.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de estudio'),
        backgroundColor: const Color(0xFF7C5CFF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerar plan',
            onPressed: _loading ? null : _generarPlan,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _generarPlan,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: Color(0xFF7C5CFF)),
                          const SizedBox(width: 8),
                          Text(
                            'Generado por IA',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _plan ?? '',
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
    );
  }
}
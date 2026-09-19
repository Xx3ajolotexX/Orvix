// lib/screens/progress_screen.dart
//
// Pantalla de "Progreso" + "Análisis" de la diapositiva. Las estadísticas
// (porcentajes, conteos) se calculan localmente a partir de las tareas —
// no usan IA. Solo el párrafo de análisis de arriba llama a Gemini.

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_ai_helper.dart';
import '../utils/subject_colors.dart';

class ProgressScreen extends StatefulWidget {
  final List<Task> tasks;
  const ProgressScreen({super.key, required this.tasks});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String? _analisis;
  bool _loadingAnalisis = true;

  @override
  void initState() {
    super.initState();
    _cargarAnalisis();
  }

  Future<void> _cargarAnalisis() async {
    try {
      final texto = await TaskAiHelper.getPatternAnalysis(widget.tasks);
      if (mounted) setState(() => _analisis = texto);
    } catch (e) {
      print('[Orvix][IA] No se pudo cargar el análisis: $e');
      if (mounted) {
        setState(() =>
            _analisis = 'No se pudo generar el análisis en este momento.');
      }
    } finally {
      if (mounted) setState(() => _loadingAnalisis = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks;
    final total = tasks.length;
    final completadas = tasks.where((t) => t.isCompleted).length;
    final porcentaje = total == 0 ? 0.0 : completadas / total;

    // Agrupa por materia: cuenta total y completadas de cada una.
    final materias = tasks.map((t) => t.subject).toSet().toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu progreso'),
        backgroundColor: const Color(0xFF7C5CFF),
        foregroundColor: Colors.white,
      ),
      body: total == 0
          ? const Center(
              child: Text('Agrega tareas para ver tu progreso aquí.'),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Resumen general
                Card(
                  color: const Color(0xFF7C5CFF),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          '${(porcentaje * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'de tus tareas completadas',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: porcentaje,
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(
                                Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$completadas de $total tareas',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Análisis con IA
                Text(
                  'Análisis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C5CFF).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _loadingAnalisis
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_analisis ?? ''),
                ),
                const SizedBox(height: 24),

                // Progreso por materia
                Text(
                  'Por materia',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...materias.map((materia) {
                  final deLaMateria =
                      tasks.where((t) => t.subject == materia).toList();
                  final completadasMateria =
                      deLaMateria.where((t) => t.isCompleted).length;
                  final pct = completadasMateria / deLaMateria.length;
                  final color = SubjectColors.of(materia);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(materia,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600)),
                            Text('$completadasMateria/${deLaMateria.length}'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: color.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
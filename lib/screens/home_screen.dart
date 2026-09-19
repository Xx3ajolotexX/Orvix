import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../services/task_ai_helper.dart';
import '../utils/subject_colors.dart';
import 'add_task_screen.dart';
import 'chat_screen.dart';
import 'study_plan_screen.dart';
import 'progress_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];
  String _selectedFilter = 'Todas';
  String? _sugerenciaIA;

  @override
  void initState() {
    super.initState();
    _loadTasks().then((_) => _cargarSugerenciaIA());
  }

  Future<void> _loadTasks() async {
    final tasks = await _dbHelper.getTasks();
    setState(() => _tasks = tasks);
  }

  void _cargarSugerenciaIA() async {
    try {
      final texto = await TaskAiHelper.getQuickSuggestion(_tasks);
      if (mounted) setState(() => _sugerenciaIA = texto);
    } catch (e) {
      print('[Orvix][IA] No se pudo cargar sugerencia: $e');
    }
  }

  Future<void> _toggleCompleted(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _dbHelper.updateTask(task);

    if (task.isCompleted) {
      await NotificationService.cancelTaskReminders(task.id!);
    }

    _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    await _dbHelper.deleteTask(task.id!);
    await NotificationService.cancelTaskReminders(task.id!);
    _loadTasks();
  }

  Future<void> _deleteCompletedTasks() async {
    final completed = _tasks.where((t) => t.isCompleted).toList();
    if (completed.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar tareas completadas?'),
        content: Text(
          'Se eliminarán ${completed.length} tarea(s) ya marcada(s) como hecha(s). Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    for (final task in completed) {
      await _dbHelper.deleteTask(task.id!);
      await NotificationService.cancelTaskReminders(task.id!);
    }
    _loadTasks();
  }

  List<String> get _subjects {
    final subjects = _tasks.map((t) => t.subject).toSet().toList();
    subjects.sort();
    return ['Todas', ...subjects];
  }

  List<Task> get _filteredTasks {
    if (_selectedFilter == 'Todas') return _tasks;
    return _tasks.where((t) => t.subject == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orvix'),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'Asistente IA',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(tasks: _tasks),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'plan':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudyPlanScreen(tasks: _tasks),
                    ),
                  );
                  break;
                case 'progreso':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProgressScreen(tasks: _tasks),
                    ),
                  );
                  break;
                case 'calendario':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CalendarScreen(tasks: _tasks),
                    ),
                  );
                  break;
                case 'perfil':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(tasks: _tasks),
                    ),
                  );
                  break;
                case 'borrar':
                  _deleteCompletedTasks();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'plan',
                child: Row(
                  children: [
                    Icon(Icons.event_note_outlined, color: Color(0xFF7C5CFF)),
                    SizedBox(width: 10),
                    Text('Plan de estudio'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'progreso',
                child: Row(
                  children: [
                    Icon(Icons.insights_outlined, color: Color(0xFF7C5CFF)),
                    SizedBox(width: 10),
                    Text('Mi progreso'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'calendario',
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        color: Color(0xFF7C5CFF)),
                    SizedBox(width: 10),
                    Text('Calendario'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'perfil',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Color(0xFF7C5CFF)),
                    SizedBox(width: 10),
                    Text('Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'borrar',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, color: Colors.grey),
                    SizedBox(width: 10),
                    Text('Borrar completadas'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_sugerenciaIA != null)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF7C5CFF).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF7C5CFF)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_sugerenciaIA!)),
                ],
              ),
            ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _subjects.map((subject) {
                final isSelected = subject == _selectedFilter;
                final color = subject == 'Todas'
                    ? const Color(0xFF7C5CFF)
                    : SubjectColors.of(subject);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(subject),
                    selected: isSelected,
                    selectedColor: color,
                    backgroundColor: color.withValues(alpha: 0.12),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : color,
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedFilter = subject),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredTasks.isEmpty
                ? Center(
                    child: Text(
                      '¡Aún no tienes tareas!\nToca + para agregar la primera 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      final color = SubjectColors.of(task.subject);
                      final formattedDate =
                          DateFormat('dd/MM/yyyy - HH:mm').format(task.dueDate);

                      return Dismissible(
                        key: Key(task.id.toString()),
                        background: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF476F),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteTask(task),
                        child: Card(
                          color: Colors.white,
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(18),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: task.isCompleted,
                                      activeColor: color,
                                      onChanged: (_) => _toggleCompleted(task),
                                    ),
                                    title: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: task.isCompleted
                                            ? Colors.grey
                                            : const Color(0xFF1E1B2E),
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${task.subject} · $formattedDate',
                                      style: TextStyle(color: color),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.grey,
                                      tooltip: 'Eliminar tarea',
                                      onPressed: () => _deleteTask(task),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../utils/subject_colors.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y hora para el recordatorio')),
      );
      return;
    }

    final dueDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final task = Task(
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      dueDate: dueDate,
    );

    final id = await DatabaseHelper().insertTask(task);

    try {
      await NotificationService.scheduleTaskReminders(
        taskId: id,
        title: task.title,
        subject: task.subject,
        reminderDate: task.dueDate,
      );
    } catch (e) {
      // Si algo falla programando la notificación, la tarea ya se guardó
      // igual: no dejamos la pantalla trabada, solo avisamos.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea guardada, pero hubo un problema con el recordatorio'),
          ),
        );
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final previewColor = _subjectController.text.trim().isEmpty
        ? const Color(0xFF7C5CFF)
        : SubjectColors.of(_subjectController.text.trim());

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva tarea')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la tarea',
                  prefixIcon: Icon(Icons.edit_note),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Escribe un título'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _subjectController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Materia (ej. Matemáticas, Historia)',
                  prefixIcon: Icon(Icons.circle, color: previewColor, size: 18),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Escribe una materia'
                    : null,
              ),
              const SizedBox(height: 24),
              _PickerTile(
                icon: Icons.calendar_today,
                color: previewColor,
                label: _selectedDate == null
                    ? 'Elegir fecha para recordar'
                    : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                onTap: _pickDate,
              ),
              const SizedBox(height: 10),
              _PickerTile(
                icon: Icons.access_time,
                color: previewColor,
                label: _selectedTime == null
                    ? 'Elegir hora de recordar'
                    : 'Hora: ${_selectedTime!.format(context)}',
                onTap: _pickTime,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Guardar tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/screens/calendar_screen.dart
//
// Vista de calendario mensual con las tareas marcadas por día.
// Usa el paquete table_calendar.

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../utils/subject_colors.dart';

class CalendarScreen extends StatefulWidget {
  final List<Task> tasks;
  const CalendarScreen({super.key, required this.tasks});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _localeReady = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Carga los nombres de meses/días en español. Si falla (sin internet
    // la primera vez que se compila el paquete de datos), el calendario
    // simplemente se muestra en inglés en vez de crashear.
    initializeDateFormatting('es_ES').then((_) {
      if (mounted) setState(() => _localeReady = true);
    });
  }

  DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  List<Task> _tareasDelDia(DateTime day) {
    final objetivo = _soloFecha(day);
    return widget.tasks
        .where((t) => _soloFecha(t.dueDate) == objetivo)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final tareasDelDiaSeleccionado =
        _selectedDay == null ? <Task>[] : _tareasDelDia(_selectedDay!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: const Color(0xFF7C5CFF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar<Task>(
            locale: _localeReady ? 'es_ES' : null,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _tareasDelDia,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xFFB9A6FF),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF7C5CFF),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Color(0xFFEF476F),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: tareasDelDiaSeleccionado.isEmpty
                ? const Center(child: Text('No hay tareas ese día.'))
                : ListView.builder(
                    itemCount: tareasDelDiaSeleccionado.length,
                    itemBuilder: (context, index) {
                      final t = tareasDelDiaSeleccionado[index];
                      final color = SubjectColors.of(t.subject);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          radius: 6,
                        ),
                        title: Text(
                          t.title,
                          style: TextStyle(
                            decoration: t.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(t.subject),
                        trailing: t.isCompleted
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
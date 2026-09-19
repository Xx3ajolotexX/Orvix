import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _maxReminders = 6;
  static const int _reminderIntervalMinutes = 10;

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final granted = await androidPlugin?.requestNotificationsPermission();
    print('[Orvix] Permiso de notificaciones concedido: $granted');

    final exactGranted = await androidPlugin?.requestExactAlarmsPermission();
    print('[Orvix] Permiso de alarmas exactas concedido: $exactGranted');

    final channels = await androidPlugin?.getNotificationChannels();
    print('[Orvix] Canales activos: ${channels?.map((c) => c.id).toList()}');
  }

  static int _reminderId(int taskId, int index) => taskId * 100 + index;

  static Future<void> scheduleTaskReminders({
    required int taskId,
    required String title,
    required String subject,
    required DateTime reminderDate,
  }) async {
    print('[Orvix] --- Programando recordatorios para tarea $taskId ---');
    print('[Orvix] Hora "ahora" del dispositivo (local): ${DateTime.now()}');
    print('[Orvix] Hora elegida por el usuario (local): $reminderDate');
    print('[Orvix] tz.TZDateTime.now(tz.UTC): ${tz.TZDateTime.now(tz.UTC)}');

    for (int i = 0; i <= _maxReminders; i++) {
      final scheduledDate = tz.TZDateTime.from(
        reminderDate.add(Duration(minutes: _reminderIntervalMinutes * i)),
        tz.UTC,
      );

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.UTC))) {
        print('[Orvix] Recordatorio #$i saltado (ya pasó): $scheduledDate');
        continue;
      }

      try {
        await _notifications.zonedSchedule(
          _reminderId(taskId, i),
          i == 0 ? 'Recordatorio: $title' : 'Sigue pendiente: $title',
          i == 0
              ? 'Materia: $subject'
              : 'Materia: $subject — aún no la marcas como hecha',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'tasks_channel',
              'Recordatorios de tareas',
              channelDescription: 'Avisos para no olvidar tus tareas',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        print('[Orvix] Recordatorio #$i programado OK -> id ${_reminderId(taskId, i)} @ $scheduledDate');
      } catch (e, stack) {
        print('[Orvix] ERROR programando recordatorio #$i: $e');
        print('[Orvix] Stacktrace: $stack');
      }
    }

    await printPendingNotifications();
  }

  static Future<void> printPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    print('[Orvix] --- Notificaciones pendientes en el sistema: ${pending.length} ---');
    for (final p in pending) {
      print('[Orvix] id=${p.id} title=${p.title} body=${p.body}');
    }
  }

  static Future<void> cancelTaskReminders(int taskId) async {
    for (int i = 0; i <= _maxReminders; i++) {
      await _notifications.cancel(_reminderId(taskId, i));
    }
  }
}
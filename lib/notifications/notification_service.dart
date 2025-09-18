import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:taskflow/tasks/data/database.dart';

class NotificationService {
  final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: darwinInit, macOS: darwinInit);

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleNotificationForTask(Task task) async {
    // Anuluj poprzednie powiadomienie dla tego zadania, na wypadek edycji
    await cancelNotificationForTask(task);

    // Nie planuj powiadomień dla zadań ukończonych lub z przeszłości
    if (task.isCompleted || task.deadline.isBefore(DateTime.now())) {
      return;
    }

    // Planujemy powiadomienie na 1 godzinę przed terminem
    final scheduledTime = task.deadline.subtract(const Duration(hours: 1));

    // Upewnij się, że czas powiadomienia jest w przyszłości
    if (scheduledTime.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'task_deadline_channel',
      'Powiadomienia o terminach',
      channelDescription: 'Powiadomienia o zbliżających się terminach zadań',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notificationsPlugin.zonedSchedule(
      task.id, // Używamy ID zadania jako ID powiadomienia
      'Zbliża się termin zadania!',
      'Twoje zadanie "${task.title}" ma termin o ${task.deadline.hour}:${task.deadline.minute.toString().padLeft(2, '0')}.',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> cancelNotificationForTask(Task task) async {
    await _notificationsPlugin.cancel(task.id);
  }
}
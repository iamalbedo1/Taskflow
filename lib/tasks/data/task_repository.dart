import 'package:drift/drift.dart';
import 'package:taskflow/tasks/data/database.dart';
import 'package:taskflow/notifications/notification_service.dart';

class TaskRepository {
  TaskRepository({required this.database, required this.notificationService});

  final AppDatabase database;
  final NotificationService notificationService;

  Stream<List<Task>> watchAllTasks() {
    return (database.select(database.tasks)
      ..orderBy([
            (t) =>
            OrderingTerm(expression: t.deadline, mode: OrderingMode.asc)
      ]))
        .watch();
  }

  Future<void> updateTask(Task task) async {
    await database.update(database.tasks).replace(task);
    await notificationService.scheduleNotificationForTask(task);
  }

  Future<void> addTask({
    required String title,
    String? description,
    required DateTime deadline,
  }) async {
    final id = await database.into(database.tasks).insert(
      TasksCompanion.insert(
        title: title,
        description: Value(description),
        deadline: deadline,
      ),
    );

    final newTask = Task(id: id, title: title, deadline: deadline, isCompleted: false, description: description);
    await notificationService.scheduleNotificationForTask(newTask);
  }

  Future<void> deleteTask(Task task) async {
    await notificationService.cancelNotificationForTask(task);
    await (database.delete(database.tasks)..where((t) => t.id.equals(task.id))).go();
  }
}
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/tasks/data/database.dart';
import 'package:taskflow/tasks/data/task_repository.dart';

class TasksCubit extends Cubit<List<Task>> {
  TasksCubit({required this.repository}) : super([]) {
    _subscription = repository.watchAllTasks().listen(emit);
  }

  final TaskRepository repository;
  late final StreamSubscription<List<Task>> _subscription;

  // POPRAWKA: Zmiana nazwy metody na bardziej uniwersalną
  Future<void> saveTask(Task task) {
    return repository.updateTask(task);
  }

  Future<void> deleteTask(Task task) {
    return repository.deleteTask(task);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
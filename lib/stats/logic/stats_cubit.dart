import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taskflow/tasks/data/database.dart';
import 'package:taskflow/tasks/data/task_repository.dart';

class StatsState extends Equatable {
  final int completedTasksCount;
  final String mostProductiveDay;
  final bool isLoading;

  const StatsState({
    this.completedTasksCount = 0,
    this.mostProductiveDay = '-',
    this.isLoading = true,
  });

  StatsState copyWith({
    int? completedTasksCount,
    String? mostProductiveDay,
    bool? isLoading,
  }) {
    return StatsState(
      completedTasksCount: completedTasksCount ?? this.completedTasksCount,
      mostProductiveDay: mostProductiveDay ?? this.mostProductiveDay,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [completedTasksCount, mostProductiveDay, isLoading];
}


class StatsCubit extends Cubit<StatsState> {
  final TaskRepository repository;
  late final StreamSubscription<List<Task>> _tasksSubscription;

  StatsCubit({required this.repository}) : super(const StatsState()) {
    _tasksSubscription = repository.watchAllTasks().listen((tasks) {
      _calculateStats(tasks);
    });
  }

  void _calculateStats(List<Task> tasks) {
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    final productiveDay = _getMostProductiveDay(completedTasks);

    emit(state.copyWith(
      completedTasksCount: completedTasks.length,
      mostProductiveDay: productiveDay,
      isLoading: false,
    ));
  }

  String _getMostProductiveDay(List<Task> completedTasks) {
    if (completedTasks.isEmpty) {
      return '-';
    }

    final dayCounts = <int, int>{};
    for (final task in completedTasks) {
      final day = task.deadline.weekday;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }

    final mostProductiveEntry = dayCounts.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
    );

    const dayNames = {
      1: 'Poniedziałek', 2: 'Wtorek', 3: 'Środa', 4: 'Czwartek',
      5: 'Piątek', 6: 'Sobota', 7: 'Niedziela'
    };
    return dayNames[mostProductiveEntry.key] ?? '-';
  }


  @override
  Future<void> close() {
    _tasksSubscription.cancel();
    return super.close();
  }
}
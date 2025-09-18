import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/add_task/add_task_screen.dart';
import 'package:taskflow/home/widgets/task_list_item.dart';
import 'package:taskflow/tasks/data/database.dart';
import 'package:taskflow/tasks/logic/tasks_cubit.dart';
import 'package:taskflow/weather/widgets/weather_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TaskFlow'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Do zrobienia'),
              Tab(text: 'Ukończone'),
            ],
          ),
        ),
        body: Column(
          children: [
            const WeatherWidget(),
            Expanded(
              child: BlocBuilder<TasksCubit, List<Task>>(
                builder: (context, tasks) {
                  final incompleteTasks =
                  tasks.where((task) => !task.isCompleted).toList();
                  final completedTasks =
                  tasks.where((task) => task.isCompleted).toList();

                  return TabBarView(
                    children: [
                      _TaskList(tasks: incompleteTasks, emptyMessage: 'Wszystko zrobione! Dodaj nowe zadanie.'),
                      _TaskList(tasks: completedTasks, emptyMessage: 'Żadne zadanie nie zostało jeszcze ukończone.'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddTaskScreen(),
              ),
            );
          },
          tooltip: 'Dodaj zadanie',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks, required this.emptyMessage});

  final List<Task> tasks;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskListItem(
          key: ValueKey(task.id),
          task: task,
          onChanged: (value) {
            final updatedTask = task.copyWith(isCompleted: value ?? false);
            context.read<TasksCubit>().saveTask(updatedTask);
          },
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:taskflow/edit_task/edit_task_screen.dart';
import 'package:taskflow/tasks/data/database.dart';

class TaskListItem extends StatefulWidget {
  const TaskListItem({
    super.key,
    required this.task,
    required this.onChanged,
  });

  final Task task;
  final ValueChanged<bool?> onChanged;

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onChanged(!widget.task.isCompleted);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: Tween<double>(begin: 1.0, end: 0.0).animate(_animation),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_animation),
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditTaskScreen(initialTask: widget.task),
            ));
          },
          leading: Checkbox(
            value: widget.task.isCompleted,
            onChanged: (value) => _handleTap(),
          ),
          title: Text(
            widget.task.title,
            style: TextStyle(
              decoration: widget.task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: widget.task.isCompleted ? Colors.grey.shade600 : null,
            ),
          ),
          subtitle: Text('Termin: ${widget.task.deadline.toLocal().toString().split(' ')[0]}'),
        ),
      ),
    );
  }
}

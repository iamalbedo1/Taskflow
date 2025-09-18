
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:taskflow/tasks/data/database.dart';
import 'package:taskflow/tasks/logic/tasks_cubit.dart';

class EditTaskScreen extends StatefulWidget {
  final Task initialTask;

  const EditTaskScreen({super.key, required this.initialTask});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTask.title;
    _descriptionController.text = widget.initialTask.description ?? '';
    _selectedDeadline = widget.initialTask.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final title = _titleController.text;
    if (title.isEmpty || _selectedDeadline == null) return;

    final updatedTask = widget.initialTask.copyWith(
      title: title,
      description: Value(_descriptionController.text),
      deadline: _selectedDeadline,
    );
    context.read<TasksCubit>().saveTask(updatedTask);
    Navigator.of(context).pop();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
      });
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final didRequestDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potwierdź usunięcie'),
        content: const Text('Czy na pewno chcesz usunąć to zadanie? Tej operacji nie można cofnąć.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (didRequestDelete ?? false) {
      context.read<TasksCubit>().deleteTask(widget.initialTask);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj zadanie'),
        actions: [
          IconButton(
            onPressed: _showDeleteConfirmationDialog,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Usuń zadanie',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tytuł', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Opis (opcjonalnie)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDeadline == null
                        ? 'Nie wybrano daty końcowej'
                        : 'Termin: ${_selectedDeadline!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                TextButton(onPressed: _selectDate, child: const Text('Zmień datę')),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Zapisz zmiany'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/tasks/data/task_repository.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // Kontrolery do odczytywania tekstu z pól formularza
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Zmienna do przechowywania wybranej daty
  DateTime? _selectedDeadline;

  // Ważne: Zawsze usuwaj kontrolery, gdy widget jest niszczony
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Funkcja do zapisu zadania
  void _saveTask() {
    final title = _titleController.text;

    // Prosta walidacja
    if (title.isEmpty || _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tytuł i data końcowa są wymagane!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Używamy repository do dodania zadania
    context.read<TaskRepository>().addTask(
      title: title,
      description: _descriptionController.text,
      deadline: _selectedDeadline!,
    );


    Navigator.of(context).pop();
  }

  // Funkcja pokazująca selektor daty
  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj nowe zadanie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tytuł',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Opis (opcjonalnie)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Przycisk i tekst do wyboru daty
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDeadline == null
                        ? 'Nie wybrano daty końcowej'
                        : 'Termin: ${_selectedDeadline!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                TextButton(
                  onPressed: _selectDate,
                  child: const Text('Wybierz datę'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Zapisz zadanie'),
            ),
          ],
        ),
      ),
    );
  }
}
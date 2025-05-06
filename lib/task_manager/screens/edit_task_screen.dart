import 'package:flutter/material.dart';
import 'package:app_02/task_manager/models/task.dart';
import 'package:app_02/task_manager/db/database_helper.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  EditTaskScreen({required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _priority;
  late DateTime _dueDate;
  late bool _completed;
  late String _status;
  String? _originalStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _priority = widget.task.priority;
    _dueDate = widget.task.dueDate ?? DateTime.now();
    _completed = widget.task.completed;
    _status = widget.task.status;
    _originalStatus = !_completed ? _status : 'Chưa làm';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleCompleted() {
    setState(() {
      _completed = !_completed;
      if (_completed) {
        _originalStatus = _status;
        _status = 'Hoàn thành';
      } else {
        _status = _originalStatus ?? 'Chưa làm';
      }
    });
  }

  void _saveTask() async {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      priority: _priority,
      dueDate: _dueDate,
      completed: _completed,
      status: _status,
      updatedAt: DateTime.now(),
    );

    await DatabaseHelper().updateTask(updatedTask);
    Navigator.pop(context, updatedTask);
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate)
      setState(() {
        _dueDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sửa Công Việc'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Mô tả'),
            ),
            DropdownButton<int>(
              value: _priority,
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
              items: [
                DropdownMenuItem(value: 1, child: Text('Thấp')),
                DropdownMenuItem(value: 2, child: Text('Trung bình')),
                DropdownMenuItem(value: 3, child: Text('Cao')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hạn hoàn thành: ${_dueDate.toLocal().toString().split(' ')[0]}'),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDueDate(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Hoàn thành:', style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(
                    _completed ? Icons.check_circle : Icons.check_circle_outline,
                    color: _completed ? Colors.green : Colors.grey,
                  ),
                  onPressed: _toggleCompleted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

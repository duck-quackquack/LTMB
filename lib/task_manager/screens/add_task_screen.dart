import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:app_02/task_manager/models/task.dart';
import 'package:app_02/task_manager/db/database_helper.dart';
import 'package:app_02/task_manager/models/current_user.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _priority = 2;
  String _status = 'Chưa làm';
  DateTime? _dueDate;
  String? _assignedTo;

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (_dueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn hạn hoàn thành!')),
        );
        return;
      }

      final newTask = Task(
        id: Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        assignedTo: _assignedTo ?? CurrentUser.user!.id,
        createdBy: CurrentUser.user!.id,
        category: null,
        attachments: null,
        completed: false,
      );

      await DatabaseHelper().insertTask(newTask);

      final tasks = await DatabaseHelper().getAllTasks(
        role: CurrentUser.user!.role,
        userId: CurrentUser.user!.id,
      );
      print('Tasks in DB: ${tasks.length}');

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm Công Việc')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Nhập tiêu đề' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Chưa làm', 'Đang làm']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
                decoration: InputDecoration(labelText: 'Trạng thái'),
              ),
              DropdownButtonFormField<int>(
                value: _priority,
                items: [
                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('Cao')),
                ],
                onChanged: (value) => setState(() => _priority = value!),
                decoration: InputDecoration(labelText: 'Độ ưu tiên'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _dueDate == null
                      ? 'Chưa chọn hạn hoàn thành'
                      : 'Hạn: ${_dueDate!.toLocal()}'.split(' ')[0],
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDueDate,
              ),

              if (CurrentUser.user!.role == 'admin')
                FutureBuilder<List<Map<String, String>>>(
                  future: _getAllUserIds(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('Không có người dùng để giao công việc');
                    }

                    final users = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: _assignedTo,
                      items: users.map((user) {
                        return DropdownMenuItem<String>(
                          value: user['id'],
                          child: Text(user['username']!),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _assignedTo = value),
                      decoration: InputDecoration(labelText: 'Giao cho'),
                    );
                  },
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text('Lưu Công Việc'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Map<String, String>>> _getAllUserIds() async {
    try {
      final db = await DatabaseHelper().database;
      final List<Map<String, dynamic>> users = await db.query('users');

      return users.map((user) {
        return {
          'id': user['id'] as String,
          'username': user['username'] as String,
        };
      }).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}

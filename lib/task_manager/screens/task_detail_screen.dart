import 'package:flutter/material.dart';
import 'package:app_02/task_manager/models/task.dart';
import 'package:app_02/task_manager/db/database_helper.dart';

class TaskDetailScreen extends StatefulWidget {
  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task task;
  String? originalStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final taskFromArguments = ModalRoute.of(context)?.settings.arguments as Task?;
    if (taskFromArguments != null) {
      task = taskFromArguments;

      if (!task.completed) {
        originalStatus = task.status;
      } else {
        originalStatus ??= 'Chưa làm'; // fallback
      }
    }
  }

  Future<void> _toggleCompleted() async {
    String newStatus;
    bool newCompleted;

    if (!task.completed) {
      originalStatus = task.status;
      newStatus = 'Hoàn thành';
      newCompleted = true;
    } else {
      newStatus = originalStatus ?? 'Chưa làm';
      newCompleted = false;
    }

    final updatedTask = task.copyWith(
      completed: newCompleted,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await DatabaseHelper().updateTask(updatedTask);

    setState(() {
      task = updatedTask;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trạng thái công việc đã được cập nhật!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Công Việc'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'Sửa công việc',
            onPressed: () async {
              final updatedTask = await Navigator.pushNamed(
                context,
                '/edit_task',
                arguments: task,
              ) as Task?;

              if (updatedTask != null) {
                setState(() {
                  task = updatedTask;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tiêu đề: ${task.title}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Mô tả: ${task.description}'),
            SizedBox(height: 8),
            Text('Trạng thái: ${task.status}'),
            SizedBox(height: 8),
            Text('Độ ưu tiên: ${_priorityLabel(task.priority)}'),
            SizedBox(height: 8),
            Text('Hạn hoàn thành: ${task.dueDate?.toLocal().toString().split(' ')[0] ?? "Chưa có hạn"}'),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Hoàn thành:',
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(
                    task.completed ? Icons.check_circle : Icons.check_circle_outline,
                    color: task.completed ? Colors.green : Colors.grey,
                  ),
                  tooltip: 'Chuyển đổi trạng thái hoàn thành',
                  onPressed: _toggleCompleted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _priorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }
}

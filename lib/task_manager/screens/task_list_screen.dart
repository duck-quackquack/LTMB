import 'package:flutter/material.dart';
import 'package:app_02/task_manager/db/database_helper.dart';
import 'package:app_02/task_manager/models/task.dart';
import 'package:app_02/task_manager/models/current_user.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> tasks;
  String selectedStatus = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() {
    setState(() {
      tasks = DatabaseHelper().getAllTasks(
        role: CurrentUser.user!.role,
        userId: CurrentUser.user!.id,
        status: selectedStatus == 'Tất cả' ? null : selectedStatus,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Công Việc'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedStatus,
              items: ['Tất cả', 'Chưa làm', 'Đang làm', 'Hoàn thành']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
                _refreshTasks();
              },
              isExpanded: true,
            ),

          ),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: tasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có công việc nào.'));
                }

                final taskList = snapshot.data!;
                return ListView.builder(
                  itemCount: taskList.length,
                  itemBuilder: (context, index) {
                    final task = taskList[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.status),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/edit_task',
                                arguments: task,
                              );
                              _refreshTasks();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              DatabaseHelper().deleteTask(task.id).then((_) {
                                _refreshTasks();
                              });
                            },
                          ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.pushNamed(
                          context,
                          '/task_detail',
                          arguments: task,
                        );
                        _refreshTasks();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add_task');
          await Future.delayed(Duration(milliseconds: 300));
          _refreshTasks();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

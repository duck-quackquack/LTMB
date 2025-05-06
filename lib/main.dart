import 'package:flutter/material.dart';
import 'package:app_02/task_manager/screens/login_screen.dart';
import 'package:app_02/task_manager/screens/register_screen.dart';
import 'package:app_02/task_manager/screens/task_list_screen.dart';
import 'package:app_02/task_manager/screens/add_task_screen.dart';
import 'package:app_02/task_manager/screens/task_detail_screen.dart';
import 'package:app_02/task_manager/screens/edit_task_screen.dart';
import 'package:app_02/task_manager/models/task.dart';

void main() {
  runApp(TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/tasks': (context) => TaskListScreen(),
        '/add_task': (context) => AddTaskScreen(),
        '/task_detail': (context) => TaskDetailScreen(),
        '/edit_task': (context) => EditTaskScreen(
          task: ModalRoute.of(context)?.settings.arguments as Task,
        ),
      },
    );
  }
}

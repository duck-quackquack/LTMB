import 'package:flutter/material.dart';
import 'package:app_02/task_manager/models/user.dart';
import 'package:app_02/task_manager/db/database_helper.dart';
import 'package:app_02/task_manager/models/current_user.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      final db = await dbHelper.database;
      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (users.isNotEmpty) {
        final user = User.fromMap(users.first);

        CurrentUser.user = user;

        Navigator.pushReplacementNamed(context, '/tasks');
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Lỗi đăng nhập'),
            content: Text('Tên đăng nhập hoặc mật khẩu không đúng.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng Nhập')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Tên đăng nhập'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập tên đăng nhập'
                    : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập mật khẩu'
                    : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Đăng Nhập'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Chưa có tài khoản? Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

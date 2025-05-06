import 'package:flutter/material.dart';
import 'package:app_02/task_manager/models/user.dart';
import 'package:app_02/task_manager/db/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedRole = 'user';

  void _register() {
    if (_formKey.currentState!.validate()) {
      final newUser = User(
        id: DateTime.now().toString(),
        username: _usernameController.text,
        password: _passwordController.text,
        email: _emailController.text,
        avatar: null,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        role: _selectedRole,
      );
      DatabaseHelper().insertUser(newUser).then((value) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng Ký')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Tên đăng nhập'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên đăng nhập';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(labelText: 'Vai trò'),
                items: [
                  DropdownMenuItem(value: 'user', child: Text('Người dùng')),
                  DropdownMenuItem(value: 'admin', child: Text('Quản trị viên')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Đăng Ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

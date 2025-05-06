import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/note.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NoteForm extends StatefulWidget {
  final Note? note;

  NoteForm({this.note});

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final dbHelper = NoteDatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _priority = 1;
  List<String> _tags = [];
  Color _selectedColor = Colors.white;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _priority = widget.note!.priority;
      _tags = widget.note!.tags ?? [];
      _selectedColor = Color(int.parse(widget.note!.color ?? '0xFFFFFFFF'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.note == null ? 'Thêm ghi chú' : 'Sửa ghi chú')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Nội dung'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  return null;
                },
                maxLines: 5,
              ),
              DropdownButton<int>(
                value: _priority,
                items: [
                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('Cao')),
                ],
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              Text('Nhãn:'),
              Wrap(
                children: _tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
              TextField(
                onSubmitted: (value) {
                  setState(() {
                    _tags.add(value);
                  });
                },
                decoration: InputDecoration(labelText: 'Thêm nhãn'),
              ),
              ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                pickerAreaHeightPercent: 0.8,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final note = Note(
                      id: widget.note?.id,
                      title: _titleController.text,
                      content: _contentController.text,
                      priority: _priority,
                      createdAt: widget.note?.createdAt ?? DateTime.now(),
                      modifiedAt: DateTime.now(),
                      tags: _tags,
                      color: _selectedColor.value.toRadixString(16),
                    );
                    if (widget.note == null) {
                      await dbHelper.insertNote(note);
                    } else {
                      await dbHelper.updateNote(note);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
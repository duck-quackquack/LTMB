import 'package:flutter/material.dart';
import '../note.dart';
import '../services/note_database_helper.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  _NoteFormScreenState createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  int _priority = 1;
  String? _color;
  final dbHelper = NoteDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _tagsController = TextEditingController(text: widget.note?.tags?.join(', ') ?? '');
    _priority = widget.note?.priority ?? 1;
    _color = widget.note?.color;
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final tagsList = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final newNote = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        priority: _priority,
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now,
        color: _color,
        tags: tagsList,
      );

      if (widget.note == null) {
        await dbHelper.insertNote(newNote);
      } else {
        await dbHelper.updateNote(newNote);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Thêm ghi chú' : 'Chỉnh sửa ghi chú'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) => value == null || value.isEmpty ? 'Hãy nhập tiêu đề' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Nội dung'),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty ? 'Hãy nhập nội dung' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Độ ưu tiên'),
                items: [1, 2, 3, 4, 5]
                    .map((val) => DropdownMenuItem(
                  value: val,
                  child: Text('Ưu tiên $val'),
                ))
                    .toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _color,
                decoration: const InputDecoration(labelText: 'Màu sắc (tùy chọn, ví dụ: Red, Green)'),
                onChanged: (val) => _color = val,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Nhãn (cách nhau bởi dấu phẩy)'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveNote,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/note.dart';
import 'note_form.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  NoteDetailScreen({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tiêu đề: ${note.title}', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Nội dung: ${note.content}'),
            Text('Ưu tiên: ${note.priority}'),
            Text('Tạo lúc: ${note.createdAt}'),
            Text('Sửa lúc: ${note.modifiedAt}'),
            if (note.tags != null && note.tags!.isNotEmpty) Text('Nhãn: ${note.tags!.join(', ')}'),
            if (note.color != null) Container(
              width: 50,
              height: 50,
              color: Color(int.parse(note.color!)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteForm(note: note)),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../note.dart';
import 'note_form_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  Color _priorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 1:
      default:
        return Colors.green;
    }
  }

  Color _getColorFromName(String? name) {
    switch (name?.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        backgroundColor: _priorityColor(note.priority),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Chỉnh sửa',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteFormScreen(note: note),
                ),
              );
              if (result == true) {
                Navigator.pop(context, true); // Reload khi quay lại
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Ưu tiên: ${note.priority}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 6),
                  Text("Tạo: ${note.createdAt.toString()}"),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.update, size: 18),
                  const SizedBox(width: 6),
                  Text("Cập nhật: ${note.modifiedAt.toString()}"),
                ],
              ),
              const SizedBox(height: 12),
              if (note.tags != null && note.tags!.isNotEmpty) ...[
                const Text(
                  "Nhãn:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: note.tags!
                      .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.teal[100],
                  ))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (note.color != null) ...[
                const Text("Màu ghi chú:"),
                const SizedBox(height: 6),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getColorFromName(note.color),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Divider(),
              const Text(
                "Nội dung:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                note.content,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
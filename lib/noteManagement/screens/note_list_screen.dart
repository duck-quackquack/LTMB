import 'package:flutter/material.dart';
import '../note.dart';
import '../services/note_database_helper.dart';
import 'note_detail_screen.dart';
import 'note_form_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> notes = [];
  final NoteDatabaseHelper dbHelper = NoteDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final loadedNotes = await dbHelper.getAllNotes();
    setState(() {
      notes = loadedNotes;
    });
  }

  Future<void> _deleteNote(int id) async {
    await dbHelper.deleteNote(id);
    _loadNotes();
  }

  void _navigateToAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteFormScreen()),
    );
    if (result == true) {
      _loadNotes();
    }
  }

  void _navigateToDetail(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    );
    if (result == true) {
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú của tôi'),
      ),
      body: notes.isEmpty
          ? const Center(child: Text('Chưa có ghi chú nào.'))
          : ListView.separated(
        itemCount: notes.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(
              note.content.length > 50
                  ? '${note.content.substring(0, 50)}...'
                  : note.content,
            ),
            onTap: () => _navigateToDetail(note),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteNote(note.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}

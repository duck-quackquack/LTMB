import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/note.dart';
import 'note_form.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final dbHelper = NoteDatabaseHelper.instance;
  List<Note> notes = [];
  String _searchQuery = '';
  int _priorityFilter = 0; // 0: All, 1: Low, 2: Medium, 3: High
  bool _isGrid = false; // Grid or List view

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  _refreshNotes() async {
    List<Note> noteList;
    if (_searchQuery.isNotEmpty) {
      noteList = await dbHelper.searchNotes(_searchQuery);
    } else if (_priorityFilter != 0) {
      noteList = await dbHelper.getNotesByPriority(_priorityFilter);
    } else {
      noteList = await dbHelper.getAllNotes();
    }
    setState(() {
      notes = noteList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm ghi chú...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _refreshNotes();
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshNotes,
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _priorityFilter = value;
                _refreshNotes();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 0, child: Text('Tất cả')),
              PopupMenuItem(value: 1, child: Text('Thấp')),
              PopupMenuItem(value: 2, child: Text('Trung bình')),
              PopupMenuItem(value: 3, child: Text('Cao')),
            ],
          ),
          IconButton(
            icon: Icon(_isGrid ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGrid = !_isGrid;
              });
            },
          ),
        ],
      ),
      body: _isGrid
          ? GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) => _buildNoteItem(notes[index]),
      )
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) => _buildNoteItem(notes[index]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteForm()),
          ).then((value) => _refreshNotes());
        },
      ),
    );
  }

  Widget _buildNoteItem(Note note) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
        ).then((value) => _refreshNotes());
      },
      child: Card(
        color: _getPriorityColor(note.priority),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
              Text(
                '${note.modifiedAt.day}/${note.modifiedAt.month}/${note.modifiedAt.year}',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green.shade100;
      case 2:
        return Colors.yellow.shade100;
      case 3:
        return Colors.red.shade100;
      default:
        return Colors.white;
    }
  }
}
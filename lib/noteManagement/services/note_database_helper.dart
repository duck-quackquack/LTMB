import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../note.dart'; // Điều chỉnh đường dẫn nếu cần

class NoteDatabaseHelper {
  static final NoteDatabaseHelper _instance = NoteDatabaseHelper._internal();
  factory NoteDatabaseHelper() => _instance;
  NoteDatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            priority INTEGER,
            createdAt TEXT,
            modifiedAt TEXT,
            tags TEXT,
            color TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertNote(Note note) async {
    final dbClient = await db;
    return await dbClient.insert('notes', note.toMap());
  }

  Future<List<Note>> getAllNotes() async {
    final dbClient = await db;
    final result = await dbClient.query('notes', orderBy: 'modifiedAt DESC');
    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> updateNote(Note note) async {
    final dbClient = await db;
    return await dbClient.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final dbClient = await db;
    return await dbClient.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_02/task_manager/models/task.dart';
import 'package:app_02/task_manager/models/user.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'task_manager.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        username TEXT,
        password TEXT,
        email TEXT,
        avatar TEXT,
        createdAt TEXT,
        lastActive TEXT,
        role TEXT DEFAULT 'user'
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        status TEXT,
        priority INTEGER,
        dueDate TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        assignedTo TEXT,
        createdBy TEXT,
        category TEXT,
        attachments TEXT,
        completed INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE users ADD COLUMN role TEXT DEFAULT 'user'");
    }
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    final Map<String, dynamic> taskMap = task.toMap();
    taskMap['completed'] = task.completed ? 1 : 0;
    return await db.insert('tasks', taskMap);
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role != ?',
      whereArgs: ['admin'],
    );

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<List<Task>> getAllTasks({
    required String role,
    required String userId,
    String? status,
  }) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (role == 'admin') {
      if (status == null || status == 'Tất cả') {
        maps = await db.query('tasks');
      } else {
        maps = await db.query('tasks', where: 'status = ?', whereArgs: [status]);
      }
    } else {
      if (status == null || status == 'Tất cả') {
        maps = await db.query('tasks', where: 'assignedTo = ?', whereArgs: [userId]);
      } else {
        maps = await db.query(
          'tasks',
          where: 'assignedTo = ? AND status = ?',
          whereArgs: [userId, status],
        );
      }
    }

    return List.generate(maps.length, (i) {
      return Task.fromMap({
        ...maps[i],
        'completed': maps[i]['completed'] == 1,
      });
    });
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    final Map<String, dynamic> taskMap = task.toMap();
    taskMap['completed'] = task.completed ? 1 : 0;
    return await db.update('tasks', taskMap, where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}

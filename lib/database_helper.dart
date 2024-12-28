import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            eventId INTEGER,
            name TEXT NOT NULL,
            mobile TEXT NOT NULL,
            isFavorite INTEGER NOT NULL,
            tags TEXT,
            lastCalled TEXT,
            comments TEXT
          )
        ''');
        await db.execute('''
        CREATE TABLE events(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          event_name TEXT NOT NULL
        )
      ''');
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void testUsers() async {
    List<Map<String, dynamic>> users = [
      {'name': 'John Doe', 'mobile': '1234567890', 'isFavorite': 0, 'tags': 'Friend,Work', 'comments': ''},
      {'name': 'Jane Smith', 'mobile': '9876543210', 'isFavorite': 1, 'tags': 'Family', 'comments': ''},
      {'name': 'Alice Johnson', 'mobile': '5556667778', 'isFavorite': 0, 'tags': 'Work', 'comments': ''},
      {'name': 'Bob Brown', 'mobile': '4445556667', 'isFavorite': 1, 'tags': 'Gym', 'comments': ''},
    ];

    DatabaseHelper dbHelper = DatabaseHelper();

    for (var user in users) {
      await dbHelper.insertUser(user);
    }
  }
}

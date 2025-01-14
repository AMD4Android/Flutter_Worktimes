import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('work_times.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employer TEXT,
        date TEXT,
        start TEXT,
        end TEXT,
        duration TEXT,
        shift TEXT
      )
    ''');
  }

  Future<void> deleteEntry(int id) async {
    final db = await instance.database;
    await db.delete(
      'entries', // Tabellenname
      where: 'id = ?', // Bedingung
      whereArgs: [id], // ID-Parameter
    );
  }

  Future<int> insertEntry(Map<String, String> entry) async {
    final db = await instance.database;
    return await db.insert('entries', entry);
  }

  Future<void> updateEntry(Map<String, dynamic> entry) async {
    final db = await instance.database; // Holen Sie sich eine Referenz zur Datenbank
    await db.update(
      'entries', // Der Name der Tabelle
      entry, // Die neuen Werte
      where: 'id = ?', // Die Bedingung zum Finden des Eintrags
      whereArgs: [entry['id']], // Die Argumente für die Bedingung
    );
  }
  Future<List<Map<String, dynamic>>> getEntries() async {
    final db = await instance.database;
    return await db.query('entries');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

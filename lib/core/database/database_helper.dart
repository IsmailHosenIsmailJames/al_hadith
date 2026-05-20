import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Cache open databases (Key: bookKey, Value: Database instance)
  final Map<String, Database> _activeDatabases = {};

  /// Gets the path to the isolated directory where sqlite databases are stored
  Future<String> _getDatabaseFolderPath() async {
    final docDir = await getApplicationDocumentsDirectory();
    return p.join(docDir.path, 'hadith_databases');
  }

  /// Checks if the database file exists inside our local folder
  Future<bool> isDatabaseAvailable(String bookKey) async {
    final dbFolder = await _getDatabaseFolderPath();
    final dbPath = p.join(dbFolder, '$bookKey.sqlite');
    return File(dbPath).exists();
  }

  /// Open a database for a specific book key (e.g. 'eng-bukhari')
  Future<Database> getDatabase(String bookKey) async {
    if (_activeDatabases.containsKey(bookKey)) {
      final db = _activeDatabases[bookKey]!;
      if (db.isOpen) return db;
    }

    final dbFolder = await _getDatabaseFolderPath();
    final dbPath = p.join(dbFolder, '$bookKey.sqlite');

    if (!await File(dbPath).exists()) {
      throw Exception('Database file for $bookKey does not exist.');
    }

    final db = await openDatabase(
      dbPath,
      readOnly: true, // Hadith resources are static, opening read-only improves performance
    );
    
    _activeDatabases[bookKey] = db;
    return db;
  }

  /// Close a specific database connection
  Future<void> closeDatabase(String bookKey) async {
    if (_activeDatabases.containsKey(bookKey)) {
      final db = _activeDatabases[bookKey]!;
      if (db.isOpen) {
        await db.close();
      }
      _activeDatabases.remove(bookKey);
    }
  }

  /// Close all active database connections
  Future<void> closeAll() async {
    for (final db in _activeDatabases.values) {
      if (db.isOpen) {
        await db.close();
      }
    }
    _activeDatabases.clear();
  }

  /// Performs an integrity check on the SQLite file to ensure tables are present
  Future<bool> verifyDatabaseIntegrity(String bookKey) async {
    try {
      final db = await getDatabase(bookKey);
      
      // Query sqlite_master to verify our expected tables exist
      final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('book_info', 'sections', 'hadiths', 'grades');"
      );

      // We expect at least the core book_info, sections, and hadiths tables
      final tableNames = tables.map((row) => row['name'] as String).toList();
      return tableNames.contains('book_info') && 
             tableNames.contains('sections') && 
             tableNames.contains('hadiths');
    } catch (e) {
      return false;
    }
  }
}

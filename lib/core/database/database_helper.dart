import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class HadithBookDb extends GeneratedDatabase {
  HadithBookDb(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  List<TableInfo<Table, Object?>> get allTables => const [];
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  }

  // Cache open databases (Key: bookKey, Value: HadithBookDb instance)
  final Map<String, HadithBookDb> _activeDatabases = {};

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
  Future<HadithBookDb> getDatabase(String bookKey) async {
    if (_activeDatabases.containsKey(bookKey)) {
      final db = _activeDatabases[bookKey]!;
      return db;
    }

    final dbFolder = await _getDatabaseFolderPath();
    final dbPath = p.join(dbFolder, '$bookKey.sqlite');

    if (!await File(dbPath).exists()) {
      throw Exception('Database file for $bookKey does not exist.');
    }

    final file = File(dbPath);
    final executor = NativeDatabase(file);
    final db = HadithBookDb(executor);
    
    _activeDatabases[bookKey] = db;
    return db;
  }

  /// Close a specific database connection
  Future<void> closeDatabase(String bookKey) async {
    if (_activeDatabases.containsKey(bookKey)) {
      final db = _activeDatabases[bookKey]!;
      await db.close();
      _activeDatabases.remove(bookKey);
    }
  }

  /// Close all active database connections
  Future<void> closeAll() async {
    for (final db in _activeDatabases.values) {
      await db.close();
    }
    _activeDatabases.clear();
  }

  /// Performs an integrity check on the SQLite file to ensure tables are present
  Future<bool> verifyDatabaseIntegrity(String bookKey) async {
    try {
      final db = await getDatabase(bookKey);
      
      // Query sqlite_master to verify our expected tables exist
      final List<QueryRow> tables = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('book_info', 'sections', 'hadiths', 'grades');"
      ).get();

      // We expect at least the core book_info, sections, and hadiths tables
      final tableNames = tables.map((row) => row.data['name'] as String).toList();
      return tableNames.contains('book_info') && 
             tableNames.contains('sections') && 
             tableNames.contains('hadiths');
    } catch (e) {
      return false;
    }
  }
}

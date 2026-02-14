import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'hadith_database.dart';

class HadithDatabaseManager {
  static final HadithDatabaseManager _instance =
      HadithDatabaseManager._internal();
  factory HadithDatabaseManager() => _instance;
  HadithDatabaseManager._internal();

  final Map<String, HadithDatabase> _databases = {};

  /// Gets or opens a database for a specific book edition.
  Future<HadithDatabase> getDatabase(String bookId) async {
    if (_databases.containsKey(bookId)) {
      return _databases[bookId]!;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(appDir.path, 'hadith_db', '$bookId.sqlite'));

    if (!dbFile.existsSync()) {
      throw Exception('Database file for $bookId not found at ${dbFile.path}');
    }

    final database = HadithDatabase(NativeDatabase(dbFile));
    _databases[bookId] = database;
    return database;
  }

  /// Closes and removes a database instance.
  Future<void> closeDatabase(String bookId) async {
    final db = _databases.remove(bookId);
    if (db != null) {
      await db.close();
    }
  }

  /// Closes all open databases.
  Future<void> dispose() async {
    for (final db in _databases.values) {
      await db.close();
    }
    _databases.clear();
  }
}

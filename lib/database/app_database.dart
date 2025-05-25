import 'package:drift/drift.dart';
import 'connection/native.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Books])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Book>> getAllBooks() => select(books).get();

  Future<Book?> getBookById(int id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<List<String?>> getAllTableNames() async {
    final query =
        "SELECT name FROM sqlite_master "
        "WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_metadata';";

    final List<QueryRow> result = await customSelect(query).get();

    final List<String?> tableNames = result.map((row) {
      return row.read<String>('name');
    }).toList();

    return tableNames;
  }
}

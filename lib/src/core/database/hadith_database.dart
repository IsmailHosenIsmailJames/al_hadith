import 'package:drift/drift.dart';
import 'hadith_dao.dart';

part 'hadith_database.g.dart';

@DataClassName('BookInfo')
class BookInfoTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookName => text().named('book_name')();
  IntColumn get hadithCount => integer().named('hadith_count')();

  @override
  String get tableName => 'book_info';
}

@DataClassName('HadithSection')
class SectionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sectionName => text().named('section_name')();
  IntColumn get startHadithNumber => integer().named('start_hadith_number')();
  IntColumn get endHadithNumber => integer().named('end_hadith_number')();
  IntColumn get hadithCount => integer().named('hadith_count')();

  @override
  String get tableName => 'sections';
}

@DataClassName('HadithData')
class HadithsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get hadithNumber => integer().named('hadith_number')();
  TextColumn get hadithText => text().named('text')();
  IntColumn get sectionId =>
      integer().named('section_id').references(SectionsTable, #id)();
  IntColumn get bookId => integer().named('book_id')();

  @override
  String get tableName => 'hadiths';
}

@DataClassName('HadithGrade')
class GradesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get hadithId =>
      integer().named('hadith_id').references(HadithsTable, #id)();
  TextColumn get scholarName => text().named('scholar_name')();
  TextColumn get grade => text()();

  @override
  String get tableName => 'grades';
}

/// Virtual table for FTS5 search.
/// Drift's support for FTS5 is limited for 'content' tables, so we define it as a simple table
/// and use custom statements if needed, but defining it here helps with generation.
class HadithsFts extends Table {
  TextColumn get hadithText => text().named('text')();

  @override
  String get tableName => 'hadiths_fts';

  @override
  bool get dontWriteConstraints => true;
}

@DriftDatabase(
  tables: [BookInfoTable, SectionsTable, HadithsTable, GradesTable, HadithsFts],
  daos: [HadithDao],
)
class HadithDatabase extends _$HadithDatabase {
  HadithDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}

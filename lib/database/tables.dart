import 'package:drift/drift.dart';

@DataClassName('Book')
class Books extends Table {
  @override
  String get tableName => 'books';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get titleAr => text().named('title_ar')();
  IntColumn get numberOfHadis => integer().named('number_of_hadis')();
  TextColumn get abvrCode => text().named('abvr_code')();
  TextColumn get bookName => text().named('book_name')();
  TextColumn get bookDescription => text().named('book_descr')();
  TextColumn get colorCode => text().named('color_code')();
}

@DataClassName('Chapter') // This will generate a data class named 'Chapter'
class Chapters extends Table {
  @override
  String get tableName => 'chapter'; // Explicitly set the table name

  IntColumn get id => integer()
      .autoIncrement()(); // Assuming 'id' is primary and auto-increments
  IntColumn get chapterId => integer().named('chapter_id')();
  IntColumn get bookId =>
      integer().named('book_id')(); // This likely references Books.id
  TextColumn get title => text()();
  IntColumn get number =>
      integer()(); // Or TextColumn if 'number' can be like "1A", "2B" etc.
  // Based on '#' symbol, integer seems more likely.
  TextColumn get hadisRange => text().named('hadis_range')();
  TextColumn get bookName => text().named(
    'book_name',
  )(); // This seems to be denormalized data from the Book table

  // If 'id' is not auto-incrementing but is the primary key:
  // IntColumn get id => integer()();
  // @override
  // Set<Column> get primaryKey => {id};

  // Optional: Define a foreign key to the Books table if you want Drift to be aware of it
  // This is good for data integrity if you were *creating* the schema with Drift,
  // but for an existing DB, it's more for type safety in your Dart code when doing joins.
  // IntColumn get bookIdFk => integer().named('book_id').references(Books, #id)();
  // However, since you already have bookId, you'd typically map that.
  // If you want to enforce referential integrity or use Drift's join features more easily,
  // you might define it like this and ensure your 'book_id' column is used for it.
  // For just reading, the simple IntColumn get bookId above is fine.
}

@DataClassName('Hadith') // This will generate a data class named 'Hadith'
class Hadiths extends Table {
  @override
  String get tableName => 'hadith'; // Explicitly set the table name

  IntColumn get id => integer()
      .autoIncrement()(); // Assuming 'id' is primary and auto-increments
  IntColumn get bookId => integer().named('book_id')();
  TextColumn get bookName => text().named('book_name')();
  IntColumn get chapterId => integer().named('chapter_id')();
  IntColumn get sectionId => integer().named('section_id')();
  TextColumn get hadithKey => text().named('hadith_key')();
  IntColumn get hadithId => integer().named('hadith_id').nullable()();
  // If 'hadith_id' is the true unique ID for a Hadith record
  // across different systems, and 'id' is just a local row id,
  // this is fine. If 'hadith_id' should be the PK, adjust accordingly.
  TextColumn get narrator =>
      text().nullable()(); // Assuming narrator can be null
  TextColumn get bn =>
      text().nullable()(); // Bengali text, assuming can be null
  TextColumn get ar => text().nullable()(); // Arabic text, assuming can be null
  TextColumn get arDiacless =>
      text().named('ar_diacless').nullable()(); // Arabic without diacritics
  TextColumn get note => text().nullable()();
  IntColumn get gradeId => integer().named('grade_id').nullable()();
  TextColumn get grade => text().nullable()();
  TextColumn get gradeColor => text().named('grade_color').nullable()();

  // If 'id' is not auto-incrementing but is the primary key:
  // IntColumn get id => integer()();
  // @override
  // Set<Column> get primaryKey => {id};

  // If 'hadith_id' is the actual primary key (and 'id' is just a rowid):
  // IntColumn get hadithId => integer().named('hadith_id')();
  // @override
  // Set<Column> get primaryKey => {hadithId};
  // IntColumn get id => integer().unique()(); // if 'id' is still present and unique but not PK

  // Optional: Define foreign keys for better type safety with joins in Drift
  // IntColumn get bookForeignKey => integer().named('book_id').references(Books, #id)();
  // IntColumn get chapterForeignKey => integer().named('chapter_id').references(Chapters, #id)();
}

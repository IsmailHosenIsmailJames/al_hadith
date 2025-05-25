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

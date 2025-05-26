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

@DataClassName('Chapter')
class Chapters extends Table {
  @override
  String get tableName => 'chapter';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get chapterId => integer().named('chapter_id')();

  IntColumn get bookId => integer().named('book_id')();

  TextColumn get title => text()();

  IntColumn get number => integer()();

  TextColumn get hadisRange => text().named('hadis_range')();

  TextColumn get bookName => text().named('book_name')();
}

@DataClassName('Hadith')
class Hadiths extends Table {
  @override
  String get tableName => 'hadith';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get bookId => integer().named('book_id')();

  TextColumn get bookName => text().named('book_name')();

  IntColumn get chapterId => integer().named('chapter_id')();

  IntColumn get sectionId => integer().named('section_id')();

  TextColumn get hadithKey => text().named('hadith_key')();

  IntColumn get hadithId => integer().named('hadith_id').nullable()();

  TextColumn get narrator => text().nullable()();

  TextColumn get bn => text().nullable()();

  TextColumn get ar => text().nullable()();

  TextColumn get arDiacless => text().named('ar_diacless').nullable()();

  TextColumn get note => text().nullable()();

  IntColumn get gradeId => integer().named('grade_id').nullable()();

  TextColumn get grade => text().nullable()();

  TextColumn get gradeColor => text().named('grade_color').nullable()();
}

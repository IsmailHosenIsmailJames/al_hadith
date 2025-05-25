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

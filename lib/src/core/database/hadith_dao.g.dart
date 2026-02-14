// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_dao.dart';

// ignore_for_file: type=lint
mixin _$HadithDaoMixin on DatabaseAccessor<HadithDatabase> {
  $BookInfoTableTable get bookInfoTable => attachedDatabase.bookInfoTable;
  $SectionsTableTable get sectionsTable => attachedDatabase.sectionsTable;
  $HadithsTableTable get hadithsTable => attachedDatabase.hadithsTable;
  $GradesTableTable get gradesTable => attachedDatabase.gradesTable;
  $HadithsFtsTable get hadithsFts => attachedDatabase.hadithsFts;
  HadithDaoManager get managers => HadithDaoManager(this);
}

class HadithDaoManager {
  final _$HadithDaoMixin _db;
  HadithDaoManager(this._db);
  $$BookInfoTableTableTableManager get bookInfoTable =>
      $$BookInfoTableTableTableManager(_db.attachedDatabase, _db.bookInfoTable);
  $$SectionsTableTableTableManager get sectionsTable =>
      $$SectionsTableTableTableManager(_db.attachedDatabase, _db.sectionsTable);
  $$HadithsTableTableTableManager get hadithsTable =>
      $$HadithsTableTableTableManager(_db.attachedDatabase, _db.hadithsTable);
  $$GradesTableTableTableManager get gradesTable =>
      $$GradesTableTableTableManager(_db.attachedDatabase, _db.gradesTable);
  $$HadithsFtsTableTableManager get hadithsFts =>
      $$HadithsFtsTableTableManager(_db.attachedDatabase, _db.hadithsFts);
}

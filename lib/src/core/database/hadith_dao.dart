import 'package:drift/drift.dart';
import 'hadith_database.dart';

part 'hadith_dao.g.dart';

@DriftAccessor(
  tables: [BookInfoTable, SectionsTable, HadithsTable, GradesTable, HadithsFts],
)
class HadithDao extends DatabaseAccessor<HadithDatabase> with _$HadithDaoMixin {
  HadithDao(HadithDatabase db) : super(db);

  /// Get general book info.
  Future<BookInfo?> getBookInfo() => select(bookInfoTable).getSingleOrNull();

  /// Get all sections for the book.
  Future<List<HadithSection>> getSections() => select(sectionsTable).get();

  /// Get hadiths for a specific section with pagination.
  Future<List<HadithData>> getHadithsBySection(
    int sectionId, {
    int limit = 20,
    int offset = 0,
  }) {
    return (select(hadithsTable)
          ..where((t) => t.sectionId.equals(sectionId))
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get a single hadith with its grades.
  Future<HadithWithGrades> getHadithDetail(int hadithId) async {
    final hadith = await (select(
      hadithsTable,
    )..where((t) => t.id.equals(hadithId))).getSingle();
    final grades = await (select(
      gradesTable,
    )..where((t) => t.hadithId.equals(hadithId))).get();
    return HadithWithGrades(hadith: hadith, grades: grades);
  }

  /// Search hadiths using FTS5.
  Future<List<HadithData>> searchHadiths(String query) async {
    final results = await customSelect(
      'SELECT h.* FROM hadiths h JOIN hadiths_fts f ON h.id = f.rowid WHERE f.text MATCH ?',
      variables: [Variable.withString(query)],
    ).get();

    return results.map((row) => hadithsTable.map(row.data)).toList();
  }
}

class HadithWithGrades {
  final HadithData hadith;
  final List<HadithGrade> grades;

  HadithWithGrades({required this.hadith, required this.grades});
}

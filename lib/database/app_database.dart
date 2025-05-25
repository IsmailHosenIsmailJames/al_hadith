import 'package:drift/drift.dart';
import 'connection/native.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Books, Chapters, Hadiths])
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

  Future<List<Chapter>> getAllChapters() => select(chapters).get();

  Future<List<Chapter>> getChaptersForBook(int bookId) {
    return (select(chapters)..where((c) => c.bookId.equals(bookId))).get();
  }

  Future<Chapter?> getChapterById(int chapterId) => (select(
    chapters,
  )..where((c) => c.id.equals(chapterId))).getSingleOrNull();

  Future<List<Hadith>> getAllHadiths() => select(hadiths).get();

  Future<List<Hadith>> getHadithsForChapter(int chapterId) {
    return (select(hadiths)..where((h) => h.chapterId.equals(chapterId))).get();
  }

  Future<List<Hadith>> getHadithsForBook(int bookId) {
    return (select(hadiths)..where((h) => h.bookId.equals(bookId))).get();
  }

  Future<Hadith?> getHadithByInternalId(int id) {
    return (select(hadiths)..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  Future<Hadith?> getHadithByHadithId(int hadithId) {
    return (select(
      hadiths,
    )..where((h) => h.hadithId.equals(hadithId))).getSingleOrNull();
  }
}

import '../database/hadith_database.dart';
import '../database/hadith_database_manager.dart';
import '../database/hadith_dao.dart';

class HadithService {
  final HadithDatabaseManager _dbManager = HadithDatabaseManager();

  /// Fetches all sections for a given book edition.
  Future<List<HadithSection>> getSections(String bookId) async {
    final db = await _dbManager.getDatabase(bookId);
    return db.hadithDao.getSections();
  }

  /// Fetches paginated hadiths for a specific section.
  Future<List<HadithData>> getHadiths(
    String bookId,
    int sectionId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final db = await _dbManager.getDatabase(bookId);
    return db.hadithDao.getHadithsBySection(
      sectionId,
      limit: pageSize,
      offset: (page - 1) * pageSize,
    );
  }

  /// Fetches a single hadith with all its grades.
  Future<HadithWithGrades> getHadithDetail(String bookId, int hadithId) async {
    final db = await _dbManager.getDatabase(bookId);
    return db.hadithDao.getHadithDetail(hadithId);
  }

  /// Performs a full-text search within a book.
  Future<List<HadithData>> search(String bookId, String query) async {
    final db = await _dbManager.getDatabase(bookId);
    return db.hadithDao.searchHadiths(query);
  }

  /// Fetches metadata for the book.
  Future<BookInfo?> getBookInfo(String bookId) async {
    final db = await _dbManager.getDatabase(bookId);
    return db.hadithDao.getBookInfo();
  }

  /// Closes a database connection to free up resources.
  Future<void> closeBook(String bookId) async {
    await _dbManager.closeDatabase(bookId);
  }
}

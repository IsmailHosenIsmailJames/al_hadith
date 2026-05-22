import 'package:al_hadith/core/database/database_helper.dart';
import 'package:al_hadith/data/models/hadith_model.dart';

class HadithRepository {
  final DatabaseHelper _dbHelper;

  HadithRepository(this._dbHelper);

  /// Dynamic check if the SQLite file physically exists and can be opened
  Future<bool> isBookAvailable(String bookKey) async {
    return _dbHelper.isDatabaseAvailable(bookKey);
  }

  /// Fetches the name of the book and the hadith count from the book_info table
  Future<Map<String, dynamic>?> getBookInfo(String bookKey) async {
    try {
      final db = await _dbHelper.getDatabase(bookKey);
      // book_name_native is available in newer database versions
      final List<Map<String, dynamic>> results = await db.query(
        'book_info',
        limit: 1,
      );
      if (results.isNotEmpty) {
        return results.first;
      }
    } catch (_) {
      // Fallback if db is locked or schema is corrupted
    }
    return null;
  }

  /// Fetches all sections/chapters inside a specific offline database
  Future<List<HadithSection>> getSections(String bookKey) async {
    final db = await _dbHelper.getDatabase(bookKey);
    // section_name_native is available in newer database versions
    final List<Map<String, dynamic>> results = await db.query(
      'sections',
      orderBy: 'id ASC',
    );
    return results.map((map) => HadithSection.fromMap(map)).toList();
  }

  /// Fetches all Hadith items for a specific section, including their scholarly gradings.
  /// Uses a highly optimized two-query approach to avoid N+1 query loops.
  Future<List<HadithItem>> getHadithsForSection(
    String bookKey,
    int sectionId,
  ) async {
    final db = await _dbHelper.getDatabase(bookKey);

    // Query 1: Fetch all hadiths in this section
    final List<Map<String, dynamic>> hadithMaps = await db.query(
      'hadiths',
      where: 'section_id = ?',
      whereArgs: [sectionId],
      orderBy: 'hadith_number ASC',
    );

    if (hadithMaps.isEmpty) return [];

    // Query 2: Fetch all scholarly grades for these hadiths at once
    final List<Map<String, dynamic>> gradeMaps = await db.rawQuery(
      '''
      SELECT g.* FROM grades g
      JOIN hadiths h ON g.hadith_id = h.id
      WHERE h.section_id = ?
    ''',
      [sectionId],
    );

    // Group grades by hadith_id in memory
    final Map<int, List<HadithGrade>> groupedGrades = {};
    for (final map in gradeMaps) {
      final hId = parseInt(map['hadith_id']);
      groupedGrades.putIfAbsent(hId, () => []).add(HadithGrade.fromMap(map));
    }

    // Map into HadithItem objects
    return hadithMaps.map((map) {
      final hadithId = parseInt(map['id']);
      final grades = groupedGrades[hadithId] ?? const [];
      return HadithItem.fromMap(map, grades: grades);
    }).toList();
  }

  /// Fetches a single Hadith by its reference number
  Future<HadithItem?> getHadithByNumber(
    String bookKey,
    int hadithNumber,
  ) async {
    final db = await _dbHelper.getDatabase(bookKey);

    final List<Map<String, dynamic>> hadithMaps = await db.query(
      'hadiths',
      where: 'hadith_number = ?',
      whereArgs: [hadithNumber],
      limit: 1,
    );

    if (hadithMaps.isEmpty) return null;
    final hadithMap = hadithMaps.first;
    final hadithId = parseInt(hadithMap['id']);

    // Fetch grades for this single hadith
    final List<Map<String, dynamic>> gradeMaps = await db.query(
      'grades',
      where: 'hadith_id = ?',
      whereArgs: [hadithId],
    );

    final grades = gradeMaps.map((map) => HadithGrade.fromMap(map)).toList();
    return HadithItem.fromMap(hadithMap, grades: grades);
  }

  /// Offline text search across the database using SQL LIKE
  Future<List<HadithItem>> searchHadiths(
    String bookKey,
    String query, {
    int limit = 30,
  }) async {
    final db = await _dbHelper.getDatabase(bookKey);

    // Use LIKE for broad text matching (works on all SQLite builds)
    final searchPattern = '%$query%';
    final List<Map<String, dynamic>> searchResults = await db.rawQuery(
      '''
      SELECT * FROM hadiths
      WHERE text LIKE ?
      LIMIT ?
    ''',
      [searchPattern, limit],
    );

    if (searchResults.isEmpty) return [];

    // Fetch grades for these search results
    final List<int> hadithIds = searchResults
        .map((map) => parseInt(map['id']))
        .toList();
    final String idPlaceholders = List.filled(hadithIds.length, '?').join(',');

    final List<Map<String, dynamic>> gradeMaps = await db.rawQuery('''
      SELECT * FROM grades 
      WHERE hadith_id IN ($idPlaceholders)
    ''', hadithIds);

    final Map<int, List<HadithGrade>> groupedGrades = {};
    for (final map in gradeMaps) {
      final hId = parseInt(map['hadith_id']);
      groupedGrades.putIfAbsent(hId, () => []).add(HadithGrade.fromMap(map));
    }

    return searchResults.map((map) {
      final hadithId = parseInt(map['id']);
      final grades = groupedGrades[hadithId] ?? const [];
      return HadithItem.fromMap(map, grades: grades);
    }).toList();
  }
}

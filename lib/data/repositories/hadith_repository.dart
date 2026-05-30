import 'package:drift/drift.dart';
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
      final List<QueryRow> results = await db.customSelect(
        'SELECT * FROM book_info LIMIT 1',
      ).get();
      if (results.isNotEmpty) {
        return results.first.data;
      }
    } catch (_) {
      // Fallback if db is locked or schema is corrupted
    }
    return null;
  }

  /// Fetches all sections/chapters inside a specific offline database
  Future<List<HadithSection>> getSections(String bookKey) async {
    final db = await _dbHelper.getDatabase(bookKey);
    final List<QueryRow> results = await db.customSelect(
      'SELECT * FROM sections ORDER BY id ASC',
    ).get();
    return results.map((row) => HadithSection.fromMap(row.data)).toList();
  }

  /// Fetches all Hadith items for a specific section, including their scholarly gradings.
  /// Uses a highly optimized two-query approach to avoid N+1 query loops.
  Future<List<HadithItem>> getHadithsForSection(
    String bookKey,
    int sectionId,
  ) async {
    final db = await _dbHelper.getDatabase(bookKey);

    // Query 1: Fetch all hadiths in this section
    final List<QueryRow> hadithMaps = await db.customSelect(
      'SELECT * FROM hadiths WHERE section_id = ? ORDER BY hadith_number ASC',
      variables: [Variable.withInt(sectionId)],
    ).get();

    if (hadithMaps.isEmpty) return [];

    // Query 2: Fetch all scholarly grades for these hadiths at once
    final List<QueryRow> gradeMaps = await db.customSelect(
      '''
      SELECT g.* FROM grades g
      JOIN hadiths h ON g.hadith_id = h.id
      WHERE h.section_id = ?
    ''',
      variables: [Variable.withInt(sectionId)],
    ).get();

    // Group grades by hadith_id in memory
    final Map<int, List<HadithGrade>> groupedGrades = {};
    for (final row in gradeMaps) {
      final map = row.data;
      final hId = parseInt(map['hadith_id']);
      groupedGrades.putIfAbsent(hId, () => []).add(HadithGrade.fromMap(map));
    }

    // Map into HadithItem objects
    return hadithMaps.map((row) {
      final map = row.data;
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

    final List<QueryRow> hadithMaps = await db.customSelect(
      'SELECT * FROM hadiths WHERE hadith_number = ? LIMIT 1',
      variables: [Variable.withInt(hadithNumber)],
    ).get();

    if (hadithMaps.isEmpty) return null;
    final hadithMap = hadithMaps.first.data;
    final hadithId = parseInt(hadithMap['id']);

    // Fetch grades for this single hadith
    final List<QueryRow> gradeMaps = await db.customSelect(
      'SELECT * FROM grades WHERE hadith_id = ?',
      variables: [Variable.withInt(hadithId)],
    ).get();

    final grades = gradeMaps.map((row) => HadithGrade.fromMap(row.data)).toList();
    return HadithItem.fromMap(hadithMap, grades: grades);
  }

  /// Offline text search across the database using FTS5 search
  Future<List<HadithItem>> searchHadiths(
    String bookKey,
    String query, {
    int limit = 30,
  }) async {
    final db = await _dbHelper.getDatabase(bookKey);

    // Sanitize search query to make it safe for FTS5 tokenizer
    final cleanQuery = query.replaceAll(RegExp(r'[*":()^+&|~?]'), ' ').trim();
    if (cleanQuery.isEmpty) return [];

    // Format terms for FTS5 prefix match: e.g. "term1* term2*"
    final terms = cleanQuery.split(RegExp(r'\s+'));
    final ftsQuery = terms.map((t) => '$t*').join(' ');

    // Query 1: Search hadiths using FTS5 MATCH on virtual table
    final List<QueryRow> searchResults = await db.customSelect(
      '''
      SELECT h.* FROM hadiths_fts f
      JOIN hadiths h ON f.rowid = h.id
      WHERE hadiths_fts MATCH ?
      LIMIT ?
    ''',
      variables: [Variable.withString(ftsQuery), Variable.withInt(limit)],
    ).get();

    if (searchResults.isEmpty) return [];

    // Fetch grades for these search results
    final List<int> hadithIds = searchResults
        .map((row) => parseInt(row.data['id']))
        .toList();
    final String idPlaceholders = List.filled(hadithIds.length, '?').join(',');

    final List<QueryRow> gradeMaps = await db.customSelect(
      'SELECT * FROM grades WHERE hadith_id IN ($idPlaceholders)',
      variables: hadithIds.map((id) => Variable.withInt(id)).toList(),
    ).get();

    final Map<int, List<HadithGrade>> groupedGrades = {};
    for (final row in gradeMaps) {
      final map = row.data;
      final hId = parseInt(map['hadith_id']);
      groupedGrades.putIfAbsent(hId, () => []).add(HadithGrade.fromMap(map));
    }

    return searchResults.map((row) {
      final map = row.data;
      final hadithId = parseInt(map['id']);
      final grades = groupedGrades[hadithId] ?? const [];
      return HadithItem.fromMap(map, grades: grades);
    }).toList();
  }
}

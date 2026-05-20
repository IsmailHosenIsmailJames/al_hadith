import 'package:shared_preferences/shared_preferences.dart';

class ReadSession {
  final String bookKey;
  final String bookName;
  final int hadithNumber;
  final String sectionTitle;
  final DateTime timestamp;

  ReadSession({
    required this.bookKey,
    required this.bookName,
    required this.hadithNumber,
    required this.sectionTitle,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookKey': bookKey,
      'bookName': bookName,
      'hadithNumber': hadithNumber,
      'sectionTitle': sectionTitle,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ReadSession.fromJson(Map<String, dynamic> json) {
    return ReadSession(
      bookKey: json['bookKey'] as String,
      bookName: json['bookName'] as String,
      hadithNumber: json['hadithNumber'] as int,
      sectionTitle: json['sectionTitle'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }
}

class HistoryService {
  final SharedPreferences _prefs;

  static const String _keyLastBookKey = 'history_last_book_key';
  static const String _keyLastBookName = 'history_last_book_name';
  static const String _keyLastHadithNum = 'history_last_hadith_num';
  static const String _keyLastSectionTitle = 'history_last_section_title';
  static const String _keyLastTimestamp = 'history_last_timestamp';

  // Key to store read progress lists per book, e.g., 'progress_eng-bukhari' -> Set of read hadith numbers
  static String _keyBookProgress(String bookKey) => 'book_progress_$bookKey';

  // Collections keys
  static const String _keyBookmarks = 'collections_bookmarks';
  static const String _keyPins = 'collections_pins';
  static const String _keyNotesKeys = 'collections_notes_keys';
  static String _keyNoteText(String ref) => 'collections_note_text_$ref';

  HistoryService(this._prefs);

  /// Saves the active read session to preferences
  Future<bool> saveLastReadSession({
    required String bookKey,
    required String bookName,
    required int hadithNumber,
    required String sectionTitle,
  }) async {
    await _prefs.setString(_keyLastBookKey, bookKey);
    await _prefs.setString(_keyLastBookName, bookName);
    await _prefs.setInt(_keyLastHadithNum, hadithNumber);
    await _prefs.setString(_keyLastSectionTitle, sectionTitle);
    await _prefs.setInt(_keyLastTimestamp, DateTime.now().millisecondsSinceEpoch);
    // NOTE: read-marking is intentionally NOT done here.
    // The reading screen handles it via a 5-second dwell timer.
    return true;
  }

  /// Retrieves the last saved read session, or returns null if no history exists
  ReadSession? getLastReadSession() {
    final bookKey = _prefs.getString(_keyLastBookKey);
    final bookName = _prefs.getString(_keyLastBookName);
    final hadithNum = _prefs.getInt(_keyLastHadithNum);
    final sectionTitle = _prefs.getString(_keyLastSectionTitle);
    final timestampMs = _prefs.getInt(_keyLastTimestamp);

    if (bookKey == null || bookName == null || hadithNum == null || sectionTitle == null || timestampMs == null) {
      return null;
    }

    return ReadSession(
      bookKey: bookKey,
      bookName: bookName,
      hadithNumber: hadithNum,
      sectionTitle: sectionTitle,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
    );
  }

  /// Clears reading history
  Future<void> clearHistory() async {
    await _prefs.remove(_keyLastBookKey);
    await _prefs.remove(_keyLastBookName);
    await _prefs.remove(_keyLastHadithNum);
    await _prefs.remove(_keyLastSectionTitle);
    await _prefs.remove(_keyLastTimestamp);
  }

  // --- Read Progress Tracking ---

  /// Marks a specific hadith number as read for a given book key
  Future<bool> markHadithAsRead(String bookKey, int hadithNumber) async {
    final key = _keyBookProgress(bookKey);
    final List<String> readList = _prefs.getStringList(key) ?? [];
    final String numStr = hadithNumber.toString();
    
    if (!readList.contains(numStr)) {
      readList.add(numStr);
      return _prefs.setStringList(key, readList);
    }
    return true;
  }

  /// Unmarks a hadith as read
  Future<bool> unmarkHadithAsRead(String bookKey, int hadithNumber) async {
    final key = _keyBookProgress(bookKey);
    final List<String> readList = _prefs.getStringList(key) ?? [];
    final String numStr = hadithNumber.toString();
    
    if (readList.contains(numStr)) {
      readList.remove(numStr);
      return _prefs.setStringList(key, readList);
    }
    return true;
  }

  /// Gets the count of read hadiths in a specific book
  int getReadHadithsCount(String bookKey) {
    final key = _keyBookProgress(bookKey);
    return (_prefs.getStringList(key) ?? []).length;
  }

  /// Check if a specific hadith is marked as read
  bool isHadithRead(String bookKey, int hadithNumber) {
    final key = _keyBookProgress(bookKey);
    final List<String> readList = _prefs.getStringList(key) ?? [];
    return readList.contains(hadithNumber.toString());
  }

  /// Clear all read metrics for a book (resets progress)
  Future<bool> resetBookProgress(String bookKey) {
    return _prefs.remove(_keyBookProgress(bookKey));
  }

  // --- Collections (Bookmarks, Pins, Notes) ---

  /// Retrieves list of all bookmarked hadith reference strings
  List<String> getBookmarks() {
    return _prefs.getStringList(_keyBookmarks) ?? [];
  }

  /// Toggles bookmark status for a specific hadith
  Future<bool> toggleBookmark(String bookKey, int hadithNumber) async {
    final ref = '${bookKey}_$hadithNumber';
    final list = getBookmarks();
    if (list.contains(ref)) {
      list.remove(ref);
    } else {
      list.add(ref);
    }
    return _prefs.setStringList(_keyBookmarks, list);
  }

  /// Checks if a specific hadith is bookmarked
  bool isBookmarked(String bookKey, int hadithNumber) {
    return getBookmarks().contains('${bookKey}_$hadithNumber');
  }

  /// Retrieves list of all pinned hadith reference strings
  List<String> getPins() {
    return _prefs.getStringList(_keyPins) ?? [];
  }

  /// Toggles pin status for a specific hadith
  Future<bool> togglePin(String bookKey, int hadithNumber) async {
    final ref = '${bookKey}_$hadithNumber';
    final list = getPins();
    if (list.contains(ref)) {
      list.remove(ref);
    } else {
      list.add(ref);
    }
    return _prefs.setStringList(_keyPins, list);
  }

  /// Checks if a specific hadith is pinned
  bool isPinned(String bookKey, int hadithNumber) {
    return getPins().contains('${bookKey}_$hadithNumber');
  }

  /// Retrieves all notes as a map of references to text contents
  Map<String, String> getNotes() {
    final keys = _prefs.getStringList(_keyNotesKeys) ?? [];
    final Map<String, String> notesMap = {};
    for (final ref in keys) {
      final text = _prefs.getString(_keyNoteText(ref));
      if (text != null) {
        notesMap[ref] = text;
      }
    }
    return notesMap;
  }

  /// Saves a custom note content for a specific hadith
  Future<bool> saveNote(String bookKey, int hadithNumber, String text) async {
    final ref = '${bookKey}_$hadithNumber';
    
    // Save note text
    await _prefs.setString(_keyNoteText(ref), text);

    // Save reference in keys list if not present
    final keys = _prefs.getStringList(_keyNotesKeys) ?? [];
    if (!keys.contains(ref)) {
      keys.add(ref);
      await _prefs.setStringList(_keyNotesKeys, keys);
    }
    return true;
  }

  /// Deletes a custom note for a specific hadith
  Future<bool> deleteNote(String bookKey, int hadithNumber) async {
    final ref = '${bookKey}_$hadithNumber';
    
    // Remove note text
    await _prefs.remove(_keyNoteText(ref));

    // Remove reference from keys list
    final keys = _prefs.getStringList(_keyNotesKeys) ?? [];
    if (keys.contains(ref)) {
      keys.remove(ref);
      await _prefs.setStringList(_keyNotesKeys, keys);
    }
    return true;
  }

  /// Retrieves the note text content for a specific hadith
  String? getNoteText(String bookKey, int hadithNumber) {
    return _prefs.getString(_keyNoteText('${bookKey}_$hadithNumber'));
  }
}

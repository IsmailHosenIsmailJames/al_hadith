import 'dart:convert';
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
      hadithNumber: (json['hadithNumber'] as num?)?.toInt() ?? 0,
      sectionTitle: json['sectionTitle'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch((json['timestamp'] as num?)?.toInt() ?? 0),
    );
  }
}

class HistoryRecord {
  final String bookKey;
  final int hadithNumber;
  final int timestamp;
  final String bookName;
  final String sectionTitle;

  HistoryRecord({
    required this.bookKey,
    required this.hadithNumber,
    required this.timestamp,
    required this.bookName,
    required this.sectionTitle,
  });

  Map<String, dynamic> toJson() => {
    'bookKey': bookKey,
    'hadithNumber': hadithNumber,
    'timestamp': timestamp,
    'bookName': bookName,
    'sectionTitle': sectionTitle,
  };

  factory HistoryRecord.fromJson(Map<String, dynamic> json) => HistoryRecord(
    bookKey: json['bookKey'] as String? ?? '',
    hadithNumber: json['hadithNumber'] as int? ?? 1,
    timestamp: json['timestamp'] as int? ?? 0,
    bookName: json['bookName'] as String? ?? '',
    sectionTitle: json['sectionTitle'] as String? ?? '',
  );
}

class ReadingSessionRecord {
  final int timestamp;
  final int durationSeconds;
  final int hadithsReadCount;

  ReadingSessionRecord({
    required this.timestamp,
    required this.durationSeconds,
    required this.hadithsReadCount,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'durationSeconds': durationSeconds,
    'hadithsReadCount': hadithsReadCount,
  };

  factory ReadingSessionRecord.fromJson(Map<String, dynamic> json) => ReadingSessionRecord(
    timestamp: json['timestamp'] as int? ?? 0,
    durationSeconds: json['durationSeconds'] as int? ?? 0,
    hadithsReadCount: json['hadithsReadCount'] as int? ?? 0,
  );
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

  // Statistics and History keys
  static const String _keyDailyGoal = 'stats_daily_goal';
  static const String _keyActivityDays = 'stats_activity_days';
  static const String _keyCurrentStreak = 'stats_current_streak';
  static const String _keyLongestStreak = 'stats_longest_streak';
  static const String _keyReadHistory = 'stats_read_history';
  static const String _keyReadingSessions = 'stats_reading_sessions';

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

  /// Clears reading history and all study stats
  Future<void> clearHistory() async {
    await _prefs.remove(_keyLastBookKey);
    await _prefs.remove(_keyLastBookName);
    await _prefs.remove(_keyLastHadithNum);
    await _prefs.remove(_keyLastSectionTitle);
    await _prefs.remove(_keyLastTimestamp);

    // Clear stats and history
    await _prefs.remove(_keyReadHistory);
    await _prefs.remove(_keyReadingSessions);
    await _prefs.remove(_keyActivityDays);
    await _prefs.remove(_keyCurrentStreak);
    await _prefs.remove(_keyLongestStreak);
  }

  // --- Statistics and History Helpers ---

  int getDailyGoal() {
    return _prefs.getInt(_keyDailyGoal) ?? 3;
  }

  Future<bool> setDailyGoal(int goal) {
    return _prefs.setInt(_keyDailyGoal, goal);
  }

  int getCurrentStreak() {
    return _prefs.getInt(_keyCurrentStreak) ?? 0;
  }

  Future<bool> setCurrentStreak(int val) {
    return _prefs.setInt(_keyCurrentStreak, val);
  }

  int getLongestStreak() {
    return _prefs.getInt(_keyLongestStreak) ?? 0;
  }

  Future<bool> setLongestStreak(int val) {
    return _prefs.setInt(_keyLongestStreak, val);
  }

  List<String> getActivityDays() {
    return _prefs.getStringList(_keyActivityDays) ?? [];
  }

  Future<bool> setActivityDays(List<String> days) {
    return _prefs.setStringList(_keyActivityDays, days);
  }

  List<HistoryRecord> getReadHistory() {
    final list = _prefs.getStringList(_keyReadHistory) ?? [];
    try {
      return list
          .map((s) => HistoryRecord.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveReadHistory(List<HistoryRecord> records) {
    final list = records.map((r) => jsonEncode(r.toJson())).toList();
    return _prefs.setStringList(_keyReadHistory, list);
  }

  List<ReadingSessionRecord> getReadingSessions() {
    final list = _prefs.getStringList(_keyReadingSessions) ?? [];
    try {
      return list
          .map((s) => ReadingSessionRecord.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveReadingSessions(List<ReadingSessionRecord> sessions) {
    final list = sessions.map((s) => jsonEncode(s.toJson())).toList();
    return _prefs.setStringList(_keyReadingSessions, list);
  }

  /// Logs a detailed read event, updates activity days, and dynamically calculates streaks.
  Future<bool> recordHadithReadEvent({
    required String bookKey,
    required int hadithNumber,
    required String bookName,
    required String sectionTitle,
  }) async {
    // 1. Mark the Hadith as read
    await markHadithAsRead(bookKey, hadithNumber);

    // 2. Add detailed history record
    final records = getReadHistory();
    final now = DateTime.now();

    records.insert(
      0,
      HistoryRecord(
        bookKey: bookKey,
        hadithNumber: hadithNumber,
        timestamp: now.millisecondsSinceEpoch,
        bookName: bookName,
        sectionTitle: sectionTitle,
      ),
    );

    // Cap history records at 1000 items
    if (records.length > 1000) {
      records.removeRange(1000, records.length);
    }
    await saveReadHistory(records);

    // 3. Update active days and streaks
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final activeDays = getActivityDays().toSet();
    if (!activeDays.contains(todayStr)) {
      activeDays.add(todayStr);
      await setActivityDays(activeDays.toList());

      // Recalculate streaks dynamically based on the updated active days list
      final streaks = calculateStreaks(activeDays.toList());
      await setCurrentStreak(streaks['current'] ?? 0);
      await setLongestStreak(streaks['longest'] ?? 0);
    }

    return true;
  }

  /// Utility to calculate current and longest streaks from active dates.
  Map<String, int> calculateStreaks(List<String> datesList) {
    if (datesList.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    // Parse to DateTime objects (only date parts), sort them
    final List<DateTime> dates = datesList
        .map((d) {
          try {
            return DateTime.parse(d);
          } catch (_) {
            return null;
          }
        })
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet() // Ensure unique days
        .toList();

    if (dates.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    dates.sort();

    int longest = 0;
    int current = 0;
    DateTime? prev;

    for (final date in dates) {
      if (prev == null) {
        current = 1;
      } else {
        final diff = date.difference(prev).inDays;
        if (diff == 1) {
          current++;
        } else if (diff > 1) {
          current = 1;
        }
        // if diff == 0, current remains the same
      }
      if (current > longest) {
        longest = current;
      }
      prev = date;
    }

    // Check if the streak is still active today (active if last active day is today or yesterday)
    if (prev != null) {
      final now = DateTime.now();
      final todayDateOnly = DateTime(now.year, now.month, now.day);
      final lastDateOnly = DateTime(prev.year, prev.month, prev.day);
      final diffFromToday = todayDateOnly.difference(lastDateOnly).inDays;
      if (diffFromToday > 1) {
        // Last active day was before yesterday, so the current active streak is 0
        current = 0;
      }
    }

    return {'current': current, 'longest': longest};
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

  /// Gets the raw list of read hadith number strings for a book (for backup export)
  List<String> getReadHadithsList(String bookKey) {
    final key = _keyBookProgress(bookKey);
    return _prefs.getStringList(key) ?? [];
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

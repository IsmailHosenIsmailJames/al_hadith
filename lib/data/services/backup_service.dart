import 'package:firebase_database/firebase_database.dart';
import 'package:al_hadith/data/services/history_service.dart';
import 'package:al_hadith/data/services/preferences_service.dart';

/// Service responsible for syncing local SharedPreferences data
/// (bookmarks, pins, notes, read progress, last session) to/from
/// Firebase Realtime Database under the authenticated user's UID.
class BackupService {
  final FirebaseDatabase? _db;
  final HistoryService _historyService;
  final PreferencesService _prefsService;

  BackupService({
    required FirebaseDatabase? db,
    required HistoryService historyService,
    required PreferencesService prefsService,
  })  : _db = db,
        _historyService = historyService,
        _prefsService = prefsService;

  /// Reference to the authenticated user's backup node
  DatabaseReference? _userRef(String uid) => _db?.ref('users/$uid');

  /// Uploads all local data to RTDB
  Future<void> uploadBackup(String uid) async {
    final ref = _userRef(uid);
    if (ref == null) return;

    final Map<String, dynamic> payload = {
      'lastUpdated': ServerValue.timestamp,
      'bookmarks': _historyService.getBookmarks(),
      'pins': _historyService.getPins(),
      'notes': _historyService.getNotes(),
      'readProgress': _buildReadProgressMap(),
      'lastSession': _buildLastSessionMap(),
      // Stats and History additions
      'dailyGoal': _historyService.getDailyGoal(),
      'activityDays': _historyService.getActivityDays(),
      'currentStreak': _historyService.getCurrentStreak(),
      'longestStreak': _historyService.getLongestStreak(),
      'readHistory': _historyService.getReadHistory().map((e) => e.toJson()).toList(),
      'readingSessions': _historyService.getReadingSessions().map((e) => e.toJson()).toList(),
    };

    await ref.set(payload);
  }

  /// Deletes all remote data from RTDB for the given user
  Future<void> deleteBackup(String uid) async {
    final ref = _userRef(uid);
    if (ref == null) return;
    await ref.remove();
  }

  /// Downloads data from RTDB and restores it locally
  Future<void> restoreBackup(String uid) async {
    final ref = _userRef(uid);
    if (ref == null) return;
    final snapshot = await ref.get();

    if (!snapshot.exists || snapshot.value == null) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    // Restore bookmarks
    if (data['bookmarks'] != null) {
      final bookmarks = List<String>.from(data['bookmarks'] as List);
      await _restoreBookmarks(bookmarks);
    }

    // Restore pins
    if (data['pins'] != null) {
      final pins = List<String>.from(data['pins'] as List);
      await _restorePins(pins);
    }

    // Restore notes
    if (data['notes'] != null) {
      final notes = Map<String, String>.from(
        (data['notes'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
      );
      await _restoreNotes(notes);
    }

    // Restore read progress
    if (data['readProgress'] != null) {
      final progress = Map<String, dynamic>.from(data['readProgress'] as Map);
      await _restoreReadProgress(progress);
    }

    // Restore last session
    if (data['lastSession'] != null) {
      final session = Map<String, dynamic>.from(data['lastSession'] as Map);
      await _restoreLastSession(session);
    }

    // Restore daily goal
    if (data['dailyGoal'] != null) {
      final goal = int.tryParse(data['dailyGoal'].toString()) ?? 3;
      await _historyService.setDailyGoal(goal);
    }

    // Restore activity days
    if (data['activityDays'] != null) {
      final days = List<String>.from(data['activityDays'] as List);
      await _historyService.setActivityDays(days);
    }

    // Restore current streak
    if (data['currentStreak'] != null) {
      final streak = int.tryParse(data['currentStreak'].toString()) ?? 0;
      await _historyService.setCurrentStreak(streak);
    }

    // Restore longest streak
    if (data['longestStreak'] != null) {
      final longest = int.tryParse(data['longestStreak'].toString()) ?? 0;
      await _historyService.setLongestStreak(longest);
    }

    // Restore read history
    if (data['readHistory'] != null) {
      final rawList = List<dynamic>.from(data['readHistory'] as List);
      final records = rawList
          .map((item) => HistoryRecord.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      await _historyService.saveReadHistory(records);
    }

    // Restore reading sessions
    if (data['readingSessions'] != null) {
      final rawList = List<dynamic>.from(data['readingSessions'] as List);
      final sessions = rawList
          .map((item) => ReadingSessionRecord.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      await _historyService.saveReadingSessions(sessions);
    }
  }

  /// Merges remote data with local, keeping both sides' unique entries
  Future<void> mergeBackup(String uid) async {
    final ref = _userRef(uid);
    if (ref == null) return;
    final snapshot = await ref.get();

    if (!snapshot.exists || snapshot.value == null) {
      // No remote data — just upload local
      await uploadBackup(uid);
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    // Merge bookmarks
    final localBookmarks = _historyService.getBookmarks().toSet();
    if (data['bookmarks'] != null) {
      localBookmarks.addAll(List<String>.from(data['bookmarks'] as List));
    }
    await _restoreBookmarks(localBookmarks.toList());

    // Merge pins
    final localPins = _historyService.getPins().toSet();
    if (data['pins'] != null) {
      localPins.addAll(List<String>.from(data['pins'] as List));
    }
    await _restorePins(localPins.toList());

    // Merge notes (local wins on conflict)
    final localNotes = _historyService.getNotes();
    if (data['notes'] != null) {
      final remoteNotes = Map<String, String>.from(
        (data['notes'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
      );
      // Remote fills in missing keys; local takes priority
      for (final entry in remoteNotes.entries) {
        if (!localNotes.containsKey(entry.key)) {
          localNotes[entry.key] = entry.value;
        }
      }
    }
    await _restoreNotes(localNotes);

    // Merge read progress (union of read hadith numbers)
    if (data['readProgress'] != null) {
      final remoteProgress = Map<String, dynamic>.from(data['readProgress'] as Map);
      for (final bookKey in remoteProgress.keys) {
        final remoteNums = List<String>.from(remoteProgress[bookKey] as List);
        for (final numStr in remoteNums) {
          final n = int.tryParse(numStr);
          if (n != null) {
            await _historyService.markHadithAsRead(bookKey, n);
          }
        }
      }
    }

    // Merge daily goal (take remote if it exists and is different)
    if (data['dailyGoal'] != null) {
      final remoteGoal = int.tryParse(data['dailyGoal'].toString()) ?? 3;
      final localGoal = _historyService.getDailyGoal();
      if (remoteGoal != localGoal) {
        await _historyService.setDailyGoal(remoteGoal);
      }
    }

    // Merge activity days (union of local and remote)
    final localDays = _historyService.getActivityDays().toSet();
    if (data['activityDays'] != null) {
      localDays.addAll(List<String>.from(data['activityDays'] as List));
    }
    await _historyService.setActivityDays(localDays.toList());

    // Merge read history
    final localHistory = _historyService.getReadHistory();
    if (data['readHistory'] != null) {
      final rawRemote = List<dynamic>.from(data['readHistory'] as List);
      final remoteHistory = rawRemote
          .map((item) => HistoryRecord.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      final Map<String, HistoryRecord> combinedMap = {};
      for (final r in localHistory) {
        combinedMap['${r.bookKey}_${r.hadithNumber}_${r.timestamp}'] = r;
      }
      for (final r in remoteHistory) {
        combinedMap['${r.bookKey}_${r.hadithNumber}_${r.timestamp}'] = r;
      }

      final mergedHistory = combinedMap.values.toList();
      mergedHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // descending
      if (mergedHistory.length > 1000) {
        mergedHistory.removeRange(1000, mergedHistory.length);
      }
      await _historyService.saveReadHistory(mergedHistory);
    }

    // Merge reading sessions
    final localSessions = _historyService.getReadingSessions();
    if (data['readingSessions'] != null) {
      final rawRemote = List<dynamic>.from(data['readingSessions'] as List);
      final remoteSessions = rawRemote
          .map((item) => ReadingSessionRecord.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      final Map<int, ReadingSessionRecord> combinedMap = {};
      for (final s in localSessions) {
        combinedMap[s.timestamp] = s;
      }
      for (final s in remoteSessions) {
        combinedMap[s.timestamp] = s;
      }

      final mergedSessions = combinedMap.values.toList();
      mergedSessions.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // descending
      if (mergedSessions.length > 1000) {
        mergedSessions.removeRange(1000, mergedSessions.length);
      }
      await _historyService.saveReadingSessions(mergedSessions);
    }

    // Recalculate streaks dynamically based on the merged activity days
    final mergedDays = _historyService.getActivityDays();
    final recalculatedStreaks = _historyService.calculateStreaks(mergedDays);
    await _historyService.setCurrentStreak(recalculatedStreaks['current'] ?? 0);
    await _historyService.setLongestStreak(recalculatedStreaks['longest'] ?? 0);

    // After merge, upload the merged state
    await uploadBackup(uid);
  }

  // ── Helpers ──

  Map<String, List<String>> _buildReadProgressMap() {
    final downloaded = _prefsService.getDownloadedResources();
    final Map<String, List<String>> progressMap = {};

    for (final bookKey in downloaded) {
      final count = _historyService.getReadHadithsCount(bookKey);
      if (count > 0) {
        // We need to read the raw string list from SharedPreferences
        progressMap[bookKey] = _getReadList(bookKey);
      }
    }
    return progressMap;
  }

  List<String> _getReadList(String bookKey) {
    // Access the prefs through history service's underlying storage
    // We use the same key pattern as HistoryService
    return _historyService.getReadHadithsList(bookKey);
  }

  Map<String, dynamic>? _buildLastSessionMap() {
    final session = _historyService.getLastReadSession();
    if (session == null) return null;
    return session.toJson();
  }

  Future<void> _restoreBookmarks(List<String> bookmarks) async {
    // Clear existing and set new
    final currentBookmarks = _historyService.getBookmarks();
    // Remove all current bookmarks first
    for (final ref in currentBookmarks) {
      final parts = ref.split('_');
      if (parts.length == 2) {
        final num = int.tryParse(parts[1]);
        if (num != null && _historyService.isBookmarked(parts[0], num)) {
          await _historyService.toggleBookmark(parts[0], num);
        }
      }
    }
    // Add restored bookmarks
    for (final ref in bookmarks) {
      final parts = ref.split('_');
      if (parts.length == 2) {
        final num = int.tryParse(parts[1]);
        if (num != null && !_historyService.isBookmarked(parts[0], num)) {
          await _historyService.toggleBookmark(parts[0], num);
        }
      }
    }
  }

  Future<void> _restorePins(List<String> pins) async {
    final currentPins = _historyService.getPins();
    for (final ref in currentPins) {
      final parts = ref.split('_');
      if (parts.length == 2) {
        final num = int.tryParse(parts[1]);
        if (num != null && _historyService.isPinned(parts[0], num)) {
          await _historyService.togglePin(parts[0], num);
        }
      }
    }
    for (final ref in pins) {
      final parts = ref.split('_');
      if (parts.length == 2) {
        final num = int.tryParse(parts[1]);
        if (num != null && !_historyService.isPinned(parts[0], num)) {
          await _historyService.togglePin(parts[0], num);
        }
      }
    }
  }

  Future<void> _restoreNotes(Map<String, String> notes) async {
    // Delete all current notes
    final currentNotes = _historyService.getNotes();
    for (final ref in currentNotes.keys) {
      final parts = ref.split('_');
      if (parts.length == 2) {
        final num = int.tryParse(parts[1]);
        if (num != null) {
          await _historyService.deleteNote(parts[0], num);
        }
      }
    }
    // Save restored notes
    for (final entry in notes.entries) {
      final parts = entry.key.split('_');
      if (parts.length == 2) {
        final num = int.tryParse(parts[1]);
        if (num != null) {
          await _historyService.saveNote(parts[0], num, entry.value);
        }
      }
    }
  }

  Future<void> _restoreReadProgress(Map<String, dynamic> progress) async {
    for (final bookKey in progress.keys) {
      final hadithNums = List<String>.from(progress[bookKey] as List);
      for (final numStr in hadithNums) {
        final n = int.tryParse(numStr);
        if (n != null) {
          await _historyService.markHadithAsRead(bookKey, n);
        }
      }
    }
  }

  Future<void> _restoreLastSession(Map<String, dynamic> session) async {
    await _historyService.saveLastReadSession(
      bookKey: session['bookKey'] as String,
      bookName: session['bookName'] as String,
      hadithNumber: (session['hadithNumber'] as num?)?.toInt() ?? 0,
      sectionTitle: session['sectionTitle'] as String,
    );
  }
}

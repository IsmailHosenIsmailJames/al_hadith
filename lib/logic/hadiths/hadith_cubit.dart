import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_hadith/data/models/hadith_model.dart';
import 'package:al_hadith/data/models/resource_model.dart';
import 'package:al_hadith/data/repositories/hadith_repository.dart';
import 'package:al_hadith/data/repositories/resource_repository.dart';
import 'package:al_hadith/data/services/history_service.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';
import 'package:al_hadith/logic/auth/auth_cubit.dart';

class HadithCubit extends Cubit<HadithState> {
  final HadithRepository _hadithRepository;
  final ResourceRepository _resourceRepository;
  final HistoryService _historyService;
  final AuthCubit? _authCubit;

  HadithCubit({
    required HadithRepository hadithRepository,
    required ResourceRepository resourceRepository,
    required HistoryService historyService,
    AuthCubit? authCubit,
  }) : _hadithRepository = hadithRepository,
       _resourceRepository = resourceRepository,
       _historyService = historyService,
       _authCubit = authCubit,
       super(HadithState());

  /// Loads the main Hadiths dashboard list, history session, and book progress maps.
  Future<void> loadDashboard() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      // 1. Fetch the master resources catalog
      final languages = await _resourceRepository.getLanguagesAndResources();
      final allResources = languages.expand((lang) => lang.resources).toList();

      // 2. Identify which books are physically downloaded and active in SQLite storage
      final List<HadithResource> downloaded = [];
      final Map<String, int> countsMap = {};

      for (final res in allResources) {
        final available = await _hadithRepository.isBookAvailable(res.book);
        if (available) {
          downloaded.add(res);
          // Load progress read counts from history service
          countsMap[res.book] = _historyService.getReadHadithsCount(res.book);
        }
      }

      // 3. Load the last reading session
      final lastSession = _historyService.getLastReadSession();

      // 4. Load Collections
      final bookmarks = _historyService.getBookmarks().toSet();
      final pins = _historyService.getPins().toSet();
      final notes = _historyService.getNotes();

      final Map<String, HadithItem> detailMap = {};
      final allRefs = {...bookmarks, ...pins, ...notes.keys};
      for (final ref in allRefs) {
        final parts = ref.split('_');
        if (parts.length == 2) {
          final bKey = parts[0];
          final hNum = int.tryParse(parts[1]);
          if (hNum != null) {
            final item = await _hadithRepository.getHadithByNumber(bKey, hNum);
            if (item != null) {
              detailMap[ref] = item;
            }
          }
        }
      }

      emit(
        state.copyWith(
          isLoading: false,
          downloadedBooks: downloaded,
          history: lastSession,
          readCounts: countsMap,
          errorMessage: null,
          bookmarkedRefs: bookmarks,
          pinnedRefs: pins,
          hadithNotes: notes,
          collectionsHadiths: detailMap,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load library dashboard: ${e.toString()}',
        ),
      );
    }
  }

  /// Queries all sections/chapters inside a specific offline database
  Future<void> loadBookSections(String bookKey) async {
    emit(
      state.copyWith(
        isLoadingSections: true,
        selectedBookKey: bookKey,
        sectionsSearchQuery: '',
        activeSections: const [],
        sectionsErrorMessage: null,
      ),
    );

    try {
      final sections = await _hadithRepository.getSections(bookKey);
      emit(
        state.copyWith(
          isLoadingSections: false,
          activeSections: sections,
          sectionsErrorMessage: null,
        ),
      );
    } catch (e) {
      log('Failed to load chapters: ${e.toString()}', name: "error");
      emit(
        state.copyWith(
          isLoadingSections: false,
          sectionsErrorMessage: 'Failed to load chapters: ${e.toString()}',
        ),
      );
    }
  }

  /// Updates local search filter string for sections
  void updateSectionsSearch(String query) {
    emit(state.copyWith(sectionsSearchQuery: query));
  }

  /// Saves a reading progress bookmark and marks the hadith as read
  Future<void> saveReadingSession({
    required String bookKey,
    required String bookName,
    required int hadithNumber,
    required String sectionTitle,
  }) async {
    try {
      await _historyService.saveLastReadSession(
        bookKey: bookKey,
        bookName: bookName,
        hadithNumber: hadithNumber,
        sectionTitle: sectionTitle,
      );

      // Re-read progress stats and history to update the state
      final lastSession = _historyService.getLastReadSession();
      final Map<String, int> updatedCounts = Map.from(state.readCounts);
      updatedCounts[bookKey] = _historyService.getReadHadithsCount(bookKey);

      emit(state.copyWith(history: lastSession, readCounts: updatedCounts));
      _authCubit?.autoUpload();
    } catch (_) {}
  }

  /// Explicitly toggles hadith read/unread marks and updates dashboards
  Future<void> toggleHadithReadStatus({
    required String bookKey,
    required int hadithNumber,
    required bool isRead,
  }) async {
    if (isRead) {
      await _historyService.markHadithAsRead(bookKey, hadithNumber);
    } else {
      await _historyService.unmarkHadithAsRead(bookKey, hadithNumber);
    }

    final Map<String, int> updatedCounts = Map.from(state.readCounts);
    updatedCounts[bookKey] = _historyService.getReadHadithsCount(bookKey);

    emit(state.copyWith(readCounts: updatedCounts));
    _authCubit?.autoUpload();
  }

  /// Resets reading count metrics for a specific database
  Future<void> resetBookProgress(String bookKey) async {
    await _historyService.resetBookProgress(bookKey);
    final Map<String, int> updatedCounts = Map.from(state.readCounts);
    updatedCounts[bookKey] = 0;

    emit(state.copyWith(readCounts: updatedCounts));
    _authCubit?.autoUpload();
  }

  // --- Collections (Bookmarks, Pins, Notes) Logic ---

  /// Reloads all collections from preferences and SQLite in parallel
  Future<void> loadCollections() async {
    try {
      final bookmarks = _historyService.getBookmarks().toSet();
      final pins = _historyService.getPins().toSet();
      final notes = _historyService.getNotes();

      final Map<String, HadithItem> detailMap = {};
      final allRefs = {...bookmarks, ...pins, ...notes.keys};
      for (final ref in allRefs) {
        final parts = ref.split('_');
        if (parts.length == 2) {
          final bKey = parts[0];
          final hNum = int.tryParse(parts[1]);
          if (hNum != null) {
            final item = await _hadithRepository.getHadithByNumber(bKey, hNum);
            if (item != null) {
              detailMap[ref] = item;
            }
          }
        }
      }

      emit(
        state.copyWith(
          bookmarkedRefs: bookmarks,
          pinnedRefs: pins,
          hadithNotes: notes,
          collectionsHadiths: detailMap,
        ),
      );
    } catch (_) {}
  }

  /// Toggles bookmark status
  Future<void> toggleBookmark(String bookKey, int hadithNumber) async {
    await _historyService.toggleBookmark(bookKey, hadithNumber);
    await loadCollections();
    _authCubit?.autoUpload();
  }

  /// Toggles pin status
  Future<void> togglePin(String bookKey, int hadithNumber) async {
    await _historyService.togglePin(bookKey, hadithNumber);
    await loadCollections();
    _authCubit?.autoUpload();
  }

  /// Saves a custom text note for a specific Hadith
  Future<void> saveHadithNote(
    String bookKey,
    int hadithNumber,
    String noteText,
  ) async {
    if (noteText.trim().isEmpty) {
      await deleteHadithNote(bookKey, hadithNumber);
    } else {
      await _historyService.saveNote(bookKey, hadithNumber, noteText);
      await loadCollections();
      _authCubit?.autoUpload();
    }
  }

  /// Deletes a custom note
  Future<void> deleteHadithNote(String bookKey, int hadithNumber) async {
    await _historyService.deleteNote(bookKey, hadithNumber);
    await loadCollections();
    _authCubit?.autoUpload();
  }

  /// Toggles target book selection for search scope
  void toggleSearchBookSelection(String bookKey) {
    final updated = Set<String>.from(state.selectedSearchBooks);
    if (updated.contains(bookKey)) {
      updated.remove(bookKey);
    } else {
      updated.add(bookKey);
    }
    emit(state.copyWith(selectedSearchBooks: updated));
  }

  /// Bulk select all books for search scope
  void selectAllSearchBooks(List<String> bookKeys) {
    emit(state.copyWith(selectedSearchBooks: bookKeys.toSet()));
  }

  /// Bulk clear all selected search books
  void deselectAllSearchBooks() {
    emit(state.copyWith(selectedSearchBooks: const {}));
  }

  /// Global FTS Search across selected databases
  Future<void> searchHadiths(String query) async {
    final cleanedQuery = query.trim();
    if (cleanedQuery.isEmpty) {
      emit(
        state.copyWith(
          searchQuery: '',
          isSearching: false,
          searchResultsGrouped: const {},
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isSearching: true,
        searchQuery: cleanedQuery,
        searchResultsGrouped: const {}, // Clear prior results
      ),
    );

    try {
      final targetBooks = state.selectedSearchBooks.isNotEmpty
          ? state.selectedSearchBooks
          : state.downloadedBooks.map((b) => b.book).toSet();

      final Map<String, List<HadithItem>> results = {};

      await Future.wait(
        targetBooks.map((bookKey) async {
          try {
            final matches = await _hadithRepository.searchHadiths(
              bookKey,
              cleanedQuery,
            );
            if (matches.isNotEmpty) {
              results[bookKey] = matches;
            }
          } catch (_) {}
        }),
      );

      emit(state.copyWith(searchResultsGrouped: results, isSearching: false));
    } catch (_) {
      emit(state.copyWith(isSearching: false, searchResultsGrouped: const {}));
    }
  }

  /// Clears the global search results and query
  void clearSearch() {
    emit(
      state.copyWith(
        searchQuery: '',
        isSearching: false,
        searchResultsGrouped: const {},
      ),
    );
  }
}

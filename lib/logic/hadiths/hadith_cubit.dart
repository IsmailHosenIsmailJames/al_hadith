import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_hadith/data/models/resource_model.dart';
import 'package:al_hadith/data/repositories/hadith_repository.dart';
import 'package:al_hadith/data/repositories/resource_repository.dart';
import 'package:al_hadith/data/services/history_service.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';

class HadithCubit extends Cubit<HadithState> {
  final HadithRepository _hadithRepository;
  final ResourceRepository _resourceRepository;
  final HistoryService _historyService;

  HadithCubit({
    required HadithRepository hadithRepository,
    required ResourceRepository resourceRepository,
    required HistoryService historyService,
  })  : _hadithRepository = hadithRepository,
        _resourceRepository = resourceRepository,
        _historyService = historyService,
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

      emit(state.copyWith(
        isLoading: false,
        downloadedBooks: downloaded,
        history: lastSession,
        readCounts: countsMap,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load library dashboard: ${e.toString()}',
      ));
    }
  }

  /// Queries all sections/chapters inside a specific offline database
  Future<void> loadBookSections(String bookKey) async {
    emit(state.copyWith(
      isLoadingSections: true,
      selectedBookKey: bookKey,
      sectionsSearchQuery: '',
      activeSections: const [],
      sectionsErrorMessage: null,
    ));

    try {
      final sections = await _hadithRepository.getSections(bookKey);
      emit(state.copyWith(
        isLoadingSections: false,
        activeSections: sections,
        sectionsErrorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingSections: false,
        sectionsErrorMessage: 'Failed to load chapters: ${e.toString()}',
      ));
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

      emit(state.copyWith(
        history: lastSession,
        readCounts: updatedCounts,
      ));
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
  }

  /// Resets reading count metrics for a specific database
  Future<void> resetBookProgress(String bookKey) async {
    await _historyService.resetBookProgress(bookKey);
    final Map<String, int> updatedCounts = Map.from(state.readCounts);
    updatedCounts[bookKey] = 0;

    emit(state.copyWith(readCounts: updatedCounts));
  }
}

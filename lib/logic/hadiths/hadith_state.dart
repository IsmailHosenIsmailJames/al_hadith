import 'package:al_hadith/data/models/hadith_model.dart';
import 'package:al_hadith/data/models/resource_model.dart';
import 'package:al_hadith/data/services/history_service.dart';

class HadithState {
  final bool isLoading;
  final List<HadithResource> downloadedBooks;
  final ReadSession? history;
  final Map<String, int> readCounts; // bookKey -> total marked read
  final String? errorMessage;

  // Active book details (for sections viewing)
  final String? selectedBookKey;
  final bool isLoadingSections;
  final List<HadithSection> activeSections;
  final String? sectionsErrorMessage;

  // Search filter inside sections
  final String sectionsSearchQuery;

  // Collections (Bookmarks, Pins, Notes)
  final Set<String> bookmarkedRefs;
  final Set<String> pinnedRefs;
  final Map<String, String> hadithNotes;
  final Map<String, HadithItem> collectionsHadiths; // reference -> loaded detail

  // Global FTS Search State
  final Map<String, List<HadithItem>> searchResultsGrouped; // bookKey -> results
  final Set<String> selectedSearchBooks; // books selected for search scope
  final bool isSearching;
  final String searchQuery;

  // Statistics & History additions
  final int dailyGoal;
  final int currentStreak;
  final int longestStreak;
  final List<String> activityDays;
  final List<HistoryRecord> readHistory;
  final List<ReadingSessionRecord> readingSessions;

  // Book Sorting Settings
  final String bookSortType;
  final bool bookSortAscending;

  HadithState({
    this.isLoading = false,
    this.downloadedBooks = const [],
    this.history,
    this.readCounts = const {},
    this.errorMessage,
    this.selectedBookKey,
    this.isLoadingSections = false,
    this.activeSections = const [],
    this.sectionsErrorMessage,
    this.sectionsSearchQuery = '',
    this.bookmarkedRefs = const {},
    this.pinnedRefs = const {},
    this.hadithNotes = const {},
    this.collectionsHadiths = const {},
    this.searchResultsGrouped = const {},
    this.selectedSearchBooks = const {},
    this.isSearching = false,
    this.searchQuery = '',
    this.dailyGoal = 3,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.activityDays = const [],
    this.readHistory = const [],
    this.readingSessions = const [],
    this.bookSortType = 'name',
    this.bookSortAscending = true,
  });

  HadithState copyWith({
    bool? isLoading,
    List<HadithResource>? downloadedBooks,
    ReadSession? history,
    Map<String, int>? readCounts,
    String? errorMessage,
    String? selectedBookKey,
    bool? isLoadingSections,
    List<HadithSection>? activeSections,
    String? sectionsErrorMessage,
    String? sectionsSearchQuery,
    Set<String>? bookmarkedRefs,
    Set<String>? pinnedRefs,
    Map<String, String>? hadithNotes,
    Map<String, HadithItem>? collectionsHadiths,
    Map<String, List<HadithItem>>? searchResultsGrouped,
    Set<String>? selectedSearchBooks,
    bool? isSearching,
    String? searchQuery,
    int? dailyGoal,
    int? currentStreak,
    int? longestStreak,
    List<String>? activityDays,
    List<HistoryRecord>? readHistory,
    List<ReadingSessionRecord>? readingSessions,
    String? bookSortType,
    bool? bookSortAscending,
  }) {
    return HadithState(
      isLoading: isLoading ?? this.isLoading,
      downloadedBooks: downloadedBooks ?? this.downloadedBooks,
      history: history ?? this.history,
      readCounts: readCounts ?? this.readCounts,
      errorMessage: errorMessage,
      selectedBookKey: selectedBookKey ?? this.selectedBookKey,
      isLoadingSections: isLoadingSections ?? this.isLoadingSections,
      activeSections: activeSections ?? this.activeSections,
      sectionsErrorMessage: sectionsErrorMessage,
      sectionsSearchQuery: sectionsSearchQuery ?? this.sectionsSearchQuery,
      bookmarkedRefs: bookmarkedRefs ?? this.bookmarkedRefs,
      pinnedRefs: pinnedRefs ?? this.pinnedRefs,
      hadithNotes: hadithNotes ?? this.hadithNotes,
      collectionsHadiths: collectionsHadiths ?? this.collectionsHadiths,
      searchResultsGrouped: searchResultsGrouped ?? this.searchResultsGrouped,
      selectedSearchBooks: selectedSearchBooks ?? this.selectedSearchBooks,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      activityDays: activityDays ?? this.activityDays,
      readHistory: readHistory ?? this.readHistory,
      readingSessions: readingSessions ?? this.readingSessions,
      bookSortType: bookSortType ?? this.bookSortType,
      bookSortAscending: bookSortAscending ?? this.bookSortAscending,
    );
  }

  /// Derived filtered list of sections based on search query
  List<HadithSection> get filteredSections {
    if (sectionsSearchQuery.isEmpty) return activeSections;
    final normalized = sectionsSearchQuery.toLowerCase();
    return activeSections.where((s) {
      return s.sectionName.toLowerCase().contains(normalized) ||
          s.sectionNameNative.toLowerCase().contains(normalized);
    }).toList();
  }

  /// Helper to check if a specific book is downloaded
  bool isBookDownloaded(String bookKey) {
    return downloadedBooks.any((b) => b.book == bookKey);
  }

  /// Helper to get progress percentage for a book
  double getProgressPercentage(String bookKey, int totalHadiths) {
    if (totalHadiths <= 0) return 0.0;
    final read = readCounts[bookKey] ?? 0;
    return read / totalHadiths;
  }
}

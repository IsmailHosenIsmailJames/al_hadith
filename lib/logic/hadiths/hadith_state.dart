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
    );
  }

  /// Derived filtered list of sections based on search query
  List<HadithSection> get filteredSections {
    if (sectionsSearchQuery.isEmpty) return activeSections;
    final normalized = sectionsSearchQuery.toLowerCase();
    return activeSections
        .where((s) => s.sectionName.toLowerCase().contains(normalized))
        .toList();
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

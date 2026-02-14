import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/hadith_database.dart';
import '../../core/database/hadith_service.dart';

class SectionsState {
  final List<HadithSection> allSections;
  final List<HadithSection> filteredSections;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;

  const SectionsState({
    this.allSections = const [],
    this.filteredSections = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  SectionsState copyWith({
    List<HadithSection>? allSections,
    List<HadithSection>? filteredSections,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
  }) {
    return SectionsState(
      allSections: allSections ?? this.allSections,
      filteredSections: filteredSections ?? this.filteredSections,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SectionsCubit extends Cubit<SectionsState> {
  final HadithService _hadithService = HadithService();

  SectionsCubit() : super(const SectionsState());

  Future<void> loadSections(String bookId) async {
    emit(state.copyWith(isLoading: true, searchQuery: ''));
    try {
      final sections = await _hadithService.getSections(bookId);
      emit(
        state.copyWith(
          allSections: sections,
          filteredSections: sections,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void filterSections(String query) {
    if (query.isEmpty) {
      emit(
        state.copyWith(filteredSections: state.allSections, searchQuery: ''),
      );
      return;
    }

    final filtered = state.allSections
        .where((s) => s.sectionName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    emit(state.copyWith(filteredSections: filtered, searchQuery: query));
  }
}

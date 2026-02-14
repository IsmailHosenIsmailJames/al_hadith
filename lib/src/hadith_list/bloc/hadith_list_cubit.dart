import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/hadith_dao.dart';
import '../../core/database/hadith_service.dart';

class HadithListState {
  final List<HadithWithGrades> hadiths;
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasReachedMax;
  final String? errorMessage;
  final int currentPage;

  const HadithListState({
    this.hadiths = const [],
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasReachedMax = false,
    this.errorMessage,
    this.currentPage = 1,
  });

  HadithListState copyWith({
    List<HadithWithGrades>? hadiths,
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasReachedMax,
    String? errorMessage,
    int? currentPage,
  }) {
    return HadithListState(
      hadiths: hadiths ?? this.hadiths,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class HadithListCubit extends Cubit<HadithListState> {
  final HadithService _hadithService = HadithService();
  String? _currentBookId;
  int? _currentSectionId;
  static const int _pageSize = 20;

  HadithListCubit() : super(const HadithListState());

  Future<void> loadHadiths(String bookId, int sectionId) async {
    _currentBookId = bookId;
    _currentSectionId = sectionId;
    emit(
      state.copyWith(
        isLoading: true,
        hadiths: [],
        hasReachedMax: false,
        currentPage: 1,
        errorMessage: null,
      ),
    );

    try {
      final hadithsData = await _hadithService.getHadiths(
        bookId,
        sectionId,
        page: 1,
        pageSize: _pageSize,
      );

      final List<HadithWithGrades> richHadiths = [];
      for (final h in hadithsData) {
        final detail = await _hadithService.getHadithDetail(bookId, h.id);
        richHadiths.add(detail);
      }

      emit(
        state.copyWith(
          hadiths: richHadiths,
          isLoading: false,
          hasReachedMax: hadithsData.length < _pageSize,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state.isMoreLoading ||
        state.hasReachedMax ||
        _currentBookId == null ||
        _currentSectionId == null) {
      return;
    }

    emit(state.copyWith(isMoreLoading: true));
    final nextPage = state.currentPage + 1;

    try {
      final hadithsData = await _hadithService.getHadiths(
        _currentBookId!,
        _currentSectionId!,
        page: nextPage,
        pageSize: _pageSize,
      );

      final List<HadithWithGrades> newRichHadiths = [];
      for (final h in hadithsData) {
        final detail = await _hadithService.getHadithDetail(
          _currentBookId!,
          h.id,
        );
        newRichHadiths.add(detail);
      }

      emit(
        state.copyWith(
          hadiths: [...state.hadiths, ...newRichHadiths],
          isMoreLoading: false,
          currentPage: nextPage,
          hasReachedMax: hadithsData.length < _pageSize,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isMoreLoading: false, errorMessage: e.toString()));
    }
  }
}

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../../setup/models/hadith_info_model.dart';
import '../../setup/data/hadith_info_repository.dart';

class HomeState {
  final List<HadithInfoModel> downloadedBooks;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.downloadedBooks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    List<HadithInfoModel>? downloadedBooks,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      downloadedBooks: downloadedBooks ?? this.downloadedBooks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Groups books by their 3-letter language code.
  Map<String, List<HadithInfoModel>> get booksByLanguage {
    final Map<String, List<HadithInfoModel>> grouped = {};
    for (final book in downloadedBooks) {
      final lang = book.languageCode;
      grouped.putIfAbsent(lang, () => []).add(book);
    }
    return grouped;
  }
}

class HomeCubit extends Cubit<HomeState> {
  final HadithInfoRepository _repository;

  HomeCubit({HadithInfoRepository? repository})
    : _repository = repository ?? HadithInfoRepository(),
      super(const HomeState());

  Future<void> loadDownloadedBooks() async {
    emit(state.copyWith(isLoading: true));
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final hadithDir = Directory('${appDir.path}/hadith_db');

      if (!hadithDir.existsSync()) {
        emit(state.copyWith(downloadedBooks: [], isLoading: false));
        return;
      }

      // Get all extracted .sqlite files
      final files = hadithDir.listSync().whereType<File>().where(
        (f) => f.path.endsWith('.sqlite'),
      );
      final downloadedBookKeys = files
          .map((f) => f.path.split('/').last.replaceAll('.sqlite', ''))
          .toSet();

      // Load all potential resource info
      final allResources = await _repository.loadAll();
      final List<HadithInfoModel> downloadedResources = [];

      for (final langResources in allResources.values) {
        for (final resource in langResources) {
          if (downloadedBookKeys.contains(resource.book)) {
            downloadedResources.add(resource);
          }
        }
      }

      emit(
        state.copyWith(downloadedBooks: downloadedResources, isLoading: false),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../data/hadith_info_repository.dart';
import '../models/hadith_info_model.dart';

// ────────────────────────────────────────────────────────────
// State
// ────────────────────────────────────────────────────────────

enum DownloadItemStatus { pending, downloading, extracting, done, error }

class DownloadItemState {
  final HadithInfoModel resource;
  final DownloadItemStatus status;
  final double progress; // 0.0..1.0 for this item
  final String? errorMessage;

  const DownloadItemState({
    required this.resource,
    this.status = DownloadItemStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
  });

  DownloadItemState copyWith({
    DownloadItemStatus? status,
    double? progress,
    String? errorMessage,
  }) {
    return DownloadItemState(
      resource: resource,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SetupState {
  final String selectedAppLanguage; // 3-letter code
  final Map<String, List<HadithInfoModel>> allResources;
  final Set<String> selectedBooks; // book keys

  // Download phase
  final bool isDownloading;
  final List<DownloadItemState> downloadItems;
  final int currentDownloadIndex;
  final bool downloadComplete;

  const SetupState({
    this.selectedAppLanguage = 'eng',
    this.allResources = const {},
    this.selectedBooks = const {},
    this.isDownloading = false,
    this.downloadItems = const [],
    this.currentDownloadIndex = 0,
    this.downloadComplete = false,
  });

  SetupState copyWith({
    String? selectedAppLanguage,
    Map<String, List<HadithInfoModel>>? allResources,
    Set<String>? selectedBooks,
    bool? isDownloading,
    List<DownloadItemState>? downloadItems,
    int? currentDownloadIndex,
    bool? downloadComplete,
  }) {
    return SetupState(
      selectedAppLanguage: selectedAppLanguage ?? this.selectedAppLanguage,
      allResources: allResources ?? this.allResources,
      selectedBooks: selectedBooks ?? this.selectedBooks,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadItems: downloadItems ?? this.downloadItems,
      currentDownloadIndex: currentDownloadIndex ?? this.currentDownloadIndex,
      downloadComplete: downloadComplete ?? this.downloadComplete,
    );
  }

  /// Total download size (zip) of selected resources in bytes.
  int get totalDownloadSize {
    int total = 0;
    for (final entry in allResources.entries) {
      for (final r in entry.value) {
        if (selectedBooks.contains(r.book)) total += r.zipSize;
      }
    }
    return total;
  }

  /// Total storage size (unzipped) of selected resources in bytes.
  int get totalStorageSize {
    int total = 0;
    for (final entry in allResources.entries) {
      for (final r in entry.value) {
        if (selectedBooks.contains(r.book)) total += r.fileSize;
      }
    }
    return total;
  }

  /// Count of selected resources for a given language code.
  int selectedCountForLanguage(String langCode) {
    final resources = allResources[langCode] ?? [];
    return resources.where((r) => selectedBooks.contains(r.book)).length;
  }

  /// All selected HadithInfoModel objects.
  List<HadithInfoModel> get selectedResources {
    final result = <HadithInfoModel>[];
    for (final entry in allResources.entries) {
      for (final r in entry.value) {
        if (selectedBooks.contains(r.book)) result.add(r);
      }
    }
    return result;
  }
}

// ────────────────────────────────────────────────────────────
// Cubit
// ────────────────────────────────────────────────────────────

class SetupCubit extends Cubit<SetupState> {
  final HadithInfoRepository _repository;
  final Dio _dio;

  SetupCubit({HadithInfoRepository? repository, Dio? dio})
    : _repository = repository ?? HadithInfoRepository(),
      _dio = dio ?? Dio(),
      super(const SetupState());

  static const _baseUrl =
      'https://ismailhosenismailjames.github.io/compressed_hadith_sqlite';

  /// Load all resources from the JSON asset.
  Future<void> loadResources() async {
    final all = await _repository.loadAll();
    emit(state.copyWith(allResources: all));
  }

  /// Set the chosen app language and pre-select all its resources.
  void selectAppLanguage(String langCode) {
    final resources = state.allResources[langCode] ?? [];
    final books = resources.map((r) => r.book).toSet();
    emit(state.copyWith(selectedAppLanguage: langCode, selectedBooks: books));
  }

  /// Toggle a single resource.
  void toggleResource(String bookKey) {
    final books = Set<String>.from(state.selectedBooks);
    if (books.contains(bookKey)) {
      books.remove(bookKey);
    } else {
      books.add(bookKey);
    }
    emit(state.copyWith(selectedBooks: books));
  }

  /// Select all resources for a given language.
  void selectAllForLanguage(String langCode) {
    final books = Set<String>.from(state.selectedBooks);
    final resources = state.allResources[langCode] ?? [];
    for (final r in resources) {
      books.add(r.book);
    }
    emit(state.copyWith(selectedBooks: books));
  }

  /// Deselect all resources for a given language.
  void deselectAllForLanguage(String langCode) {
    final books = Set<String>.from(state.selectedBooks);
    final resources = state.allResources[langCode] ?? [];
    for (final r in resources) {
      books.remove(r.book);
    }
    emit(state.copyWith(selectedBooks: books));
  }

  /// Start downloading and extracting all selected resources.
  Future<void> startDownload() async {
    final selected = state.selectedResources;
    if (selected.isEmpty) return;

    final items = selected.map((r) => DownloadItemState(resource: r)).toList();

    emit(
      state.copyWith(
        isDownloading: true,
        downloadItems: items,
        currentDownloadIndex: 0,
        downloadComplete: false,
      ),
    );

    final appDir = await getApplicationDocumentsDirectory();
    final hadithDir = Directory('${appDir.path}/hadith_db');
    if (!hadithDir.existsSync()) {
      hadithDir.createSync(recursive: true);
    }

    for (int i = 0; i < items.length; i++) {
      final resource = items[i].resource;
      final url = '$_baseUrl/${resource.zipPath}';

      try {
        // Update status: downloading
        _updateItem(i, status: DownloadItemStatus.downloading, progress: 0.0);

        // Download
        final response = await _dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: (received, total) {
            if (total > 0) {
              _updateItem(
                i,
                status: DownloadItemStatus.downloading,
                progress: received / total,
              );
            }
          },
        );

        // Update status: extracting
        _updateItem(i, status: DownloadItemStatus.extracting, progress: 1.0);

        // Extract
        final bytes = Uint8List.fromList(response.data!);
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          if (file.isFile) {
            final outFile = File('${hadithDir.path}/${file.name}');
            outFile.createSync(recursive: true);
            outFile.writeAsBytesSync(file.content as List<int>);
          }
        }

        // Done
        _updateItem(i, status: DownloadItemStatus.done, progress: 1.0);
      } catch (e) {
        _updateItem(
          i,
          status: DownloadItemStatus.error,
          errorMessage: e.toString(),
        );
      }
    }

    emit(state.copyWith(isDownloading: false, downloadComplete: true));
  }

  void _updateItem(
    int index, {
    DownloadItemStatus? status,
    double? progress,
    String? errorMessage,
  }) {
    final items = List<DownloadItemState>.from(state.downloadItems);
    items[index] = items[index].copyWith(
      status: status,
      progress: progress,
      errorMessage: errorMessage,
    );
    emit(state.copyWith(downloadItems: items, currentDownloadIndex: index));
  }
}

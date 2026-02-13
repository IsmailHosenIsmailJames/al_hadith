part of 'setup_bloc.dart';

enum SetupStatus {
  initial,
  languageSelection,
  resourceSelection,
  downloading,
  extracting,
  finished,
  error,
}

class SetupState {
  final SetupStatus status;
  final Map<String, List<HadithInfo>> allHadithInfo;
  final String? selectedLanguage;
  final List<HadithInfo> selectedResources;
  final double downloadProgress;
  final String? currentDownloadingFile;
  final int totalFilesToDownload;
  final int downloadedFilesCount;
  final String? errorMessage;

  SetupState({
    this.status = SetupStatus.initial,
    this.allHadithInfo = const {},
    this.selectedLanguage,
    this.selectedResources = const [],
    this.downloadProgress = 0.0,
    this.currentDownloadingFile,
    this.totalFilesToDownload = 0,
    this.downloadedFilesCount = 0,
    this.errorMessage,
  });

  SetupState copyWith({
    SetupStatus? status,
    Map<String, List<HadithInfo>>? allHadithInfo,
    String? selectedLanguage,
    List<HadithInfo>? selectedResources,
    double? downloadProgress,
    String? currentDownloadingFile,
    int? totalFilesToDownload,
    int? downloadedFilesCount,
    String? errorMessage,
  }) {
    return SetupState(
      status: status ?? this.status,
      allHadithInfo: allHadithInfo ?? this.allHadithInfo,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedResources: selectedResources ?? this.selectedResources,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      currentDownloadingFile:
          currentDownloadingFile ?? this.currentDownloadingFile,
      totalFilesToDownload: totalFilesToDownload ?? this.totalFilesToDownload,
      downloadedFilesCount: downloadedFilesCount ?? this.downloadedFilesCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  double get totalDownloadSizeMB {
    int total = 0;
    for (var res in selectedResources) {
      total += res.zipSize ?? 0;
    }
    return total / (1024 * 1024);
  }

  double get totalRequiredStorageMB {
    int total = 0;
    for (var res in selectedResources) {
      total += res.fileSize ?? 0;
    }
    return total / (1024 * 1024);
  }
}

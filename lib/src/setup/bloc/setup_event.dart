part of 'setup_bloc.dart';

abstract class SetupEvent {}

class LoadInitialData extends SetupEvent {}

class SelectAppLanguage extends SetupEvent {
  final String languageCode;
  SelectAppLanguage(this.languageCode);
}

class ToggleResourceSelection extends SetupEvent {
  final HadithInfo resource;
  ToggleResourceSelection(this.resource);
}

class StartDownload extends SetupEvent {}

class CancelDownload extends SetupEvent {}

class UpdateDownloadProgress extends SetupEvent {
  final double progress;
  final String currentFile;
  final int totalFiles;
  final int downloadedFiles;

  UpdateDownloadProgress({
    required this.progress,
    required this.currentFile,
    required this.totalFiles,
    required this.downloadedFiles,
  });
}

class DownloadFinished extends SetupEvent {}

class DownloadError extends SetupEvent {
  final String message;
  DownloadError(this.message);
}

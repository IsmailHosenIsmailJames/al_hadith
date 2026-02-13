import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/hadith_info.dart';
import '../repository/setup_repository.dart';

part 'setup_event.dart';
part 'setup_state.dart';

class SetupBloc extends Bloc<SetupEvent, SetupState> {
  final SetupRepository _repository;

  SetupBloc(this._repository) : super(SetupState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<SelectAppLanguage>(_onSelectAppLanguage);
    on<ToggleResourceSelection>(_onToggleResourceSelection);
    on<StartDownload>(_onStartDownload);
    on<CancelDownload>(_onCancelDownload);
    on<UpdateDownloadProgress>(_onUpdateDownloadProgress);
    on<DownloadFinished>(_onDownloadFinished);
    on<DownloadError>(_onDownloadError);
  }

  Future<void> _onLoadInitialData(
    LoadInitialData event,
    Emitter<SetupState> emit,
  ) async {
    final info = await _repository.getAllHadithInfo();
    emit(
      state.copyWith(
        allHadithInfo: info,
        status: SetupStatus.languageSelection,
      ),
    );
  }

  void _onSelectAppLanguage(SelectAppLanguage event, Emitter<SetupState> emit) {
    emit(
      state.copyWith(
        selectedLanguage: event.languageCode,
        status: SetupStatus.resourceSelection,
        selectedResources: [], // Clear on language change
      ),
    );
  }

  void _onToggleResourceSelection(
    ToggleResourceSelection event,
    Emitter<SetupState> emit,
  ) {
    final List<HadithInfo> current = List.from(state.selectedResources);
    if (current.any((r) => r.book == event.resource.book)) {
      current.removeWhere((r) => r.book == event.resource.book);
    } else {
      current.add(event.resource);
    }
    emit(state.copyWith(selectedResources: current));
  }

  void _onStartDownload(StartDownload event, Emitter<SetupState> emit) {
    if (state.selectedResources.isEmpty) return;

    emit(
      state.copyWith(
        status: SetupStatus.downloading,
        downloadProgress: 0.0,
        downloadedFilesCount: 0,
        totalFilesToDownload: state.selectedResources.length,
      ),
    );

    // Download logic will be triggered from the UI or a separate listener
    // that calls the DownloadService.
  }

  void _onCancelDownload(CancelDownload event, Emitter<SetupState> emit) {
    emit(
      state.copyWith(
        status: SetupStatus.resourceSelection,
        downloadProgress: 0.0,
        downloadedFilesCount: 0,
      ),
    );
  }

  void _onUpdateDownloadProgress(
    UpdateDownloadProgress event,
    Emitter<SetupState> emit,
  ) {
    emit(
      state.copyWith(
        downloadProgress: event.progress,
        currentDownloadingFile: event.currentFile,
        downloadedFilesCount: event.downloadedFiles,
        totalFilesToDownload: event.totalFiles,
      ),
    );
  }

  void _onDownloadFinished(DownloadFinished event, Emitter<SetupState> emit) {
    emit(state.copyWith(status: SetupStatus.finished));
  }

  void _onDownloadError(DownloadError event, Emitter<SetupState> emit) {
    emit(
      state.copyWith(status: SetupStatus.error, errorMessage: event.message),
    );
  }
}

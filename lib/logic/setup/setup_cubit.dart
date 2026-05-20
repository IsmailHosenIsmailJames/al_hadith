import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_hadith/data/models/resource_model.dart';
import 'package:al_hadith/data/repositories/resource_repository.dart';
import 'package:al_hadith/data/services/download_service.dart';
import 'package:al_hadith/data/services/preferences_service.dart';
import 'package:al_hadith/logic/setup/setup_state.dart';

class SetupCubit extends Cubit<SetupState> {
  final ResourceRepository _repository;
  final DownloadService _downloadService;
  final PreferencesService _prefs;

  SetupCubit({
    required ResourceRepository repository,
    required DownloadService downloadService,
    required PreferencesService prefs,
  })  : _repository = repository,
        _downloadService = downloadService,
        _prefs = prefs,
        super(SetupState());

  /// Loads available metadata and checks local storage status
  Future<void> loadInitialMetadata() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final languages = await _repository.getLanguagesAndResources();
      
      // Look for previously selected language in preferences, or default to English
      final savedLangCode = _prefs.getAppLanguage() ?? 'eng';
      HadithLanguage? initialLanguage;
      
      try {
        initialLanguage = languages.firstWhere((l) => l.code == savedLangCode);
      } catch (_) {
        initialLanguage = languages.isNotEmpty ? languages.first : null;
      }

      final selectedResources = <String>{};
      final progressMap = <String, double>{};
      final statusMap = <String, String>{};

      // Check download status for ALL resources across ALL languages on startup
      for (final lang in languages) {
        for (final res in lang.resources) {
          final downloaded = await _downloadService.isDatabaseDownloaded(res);
          if (downloaded) {
            progressMap[res.book] = 1.0;
            statusMap[res.book] = 'Completed';
          } else {
            progressMap[res.book] = 0.0;
            statusMap[res.book] = 'Pending';
          }
        }
      }

      // By default, select all resources belonging to the chosen language
      if (initialLanguage != null) {
        for (final res in initialLanguage.resources) {
          selectedResources.add(res.book);
        }
      }

      emit(state.copyWith(
        languages: languages,
        selectedLanguage: initialLanguage,
        selectedResources: selectedResources,
        downloadProgress: progressMap,
        downloadStatus: statusMap,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load setup metadata: ${e.toString()}',
      ));
    }
  }

  /// Sets the active language code and resets default selections
  Future<void> selectLanguage(HadithLanguage language) async {
    // Save to preferences
    await _prefs.setAppLanguage(language.code);
    
    final selectedResources = <String>{};
    final progressMap = <String, double>{};
    final statusMap = <String, String>{};

    // Pre-initialize ALL resources across ALL languages to cache download state
    for (final lang in state.languages) {
      for (final res in lang.resources) {
        final downloaded = await _downloadService.isDatabaseDownloaded(res);
        if (downloaded) {
          progressMap[res.book] = 1.0;
          statusMap[res.book] = 'Completed';
        } else {
          progressMap[res.book] = 0.0;
          statusMap[res.book] = 'Pending';
        }
      }
    }

    // Select the chosen language's resources by default
    for (final res in language.resources) {
      selectedResources.add(res.book);
    }

    emit(state.copyWith(
      selectedLanguage: language,
      selectedResources: selectedResources,
      downloadProgress: progressMap,
      downloadStatus: statusMap,
      isLoading: false,
      errorMessage: null,
    ));
  }

  /// Toggles selection of a specific book database
  void toggleResourceSelection(String bookKey) {
    if (state.selectedLanguage == null) return;
    
    final currentSelection = Set<String>.from(state.selectedResources);
    if (currentSelection.contains(bookKey)) {
      currentSelection.remove(bookKey);
    } else {
      currentSelection.add(bookKey);
    }

    emit(state.copyWith(
      selectedResources: currentSelection,
      errorMessage: null,
    ));
  }

  /// Go forward in wizard steps
  void nextStep() {
    if (state.step == SetupStep.languageSelection) {
      if (state.selectedLanguage == null) {
        emit(state.copyWith(errorMessage: 'Please select a language to proceed.'));
        return;
      }
      emit(state.copyWith(step: SetupStep.resourceSelection));
    } else if (state.step == SetupStep.resourceSelection) {
      if (state.selectedResources.isEmpty) {
        emit(state.copyWith(errorMessage: 'Please select at least one resource.'));
        return;
      }
      emit(state.copyWith(step: SetupStep.downloading));
      startDownload();
    }
  }

  /// Go backward in wizard steps
  void previousStep() {
    if (state.step == SetupStep.resourceSelection) {
      emit(state.copyWith(step: SetupStep.languageSelection));
    }
  }

  /// Starts downloading the selected books sequentially
  Future<void> startDownload() async {
    if (state.selectedLanguage == null || state.selectedResources.isEmpty) return;

    // Fetch selected resources across ALL languages
    final targetResources = state.languages
        .expand((lang) => lang.resources)
        .where((r) => state.selectedResources.contains(r.book))
        .toList();

    final progressMap = Map<String, double>.from(state.downloadProgress);
    final statusMap = Map<String, String>.from(state.downloadStatus);

    emit(state.copyWith(errorMessage: null));

    int completedCount = 0;
    
    // Check initial completion state for selected items
    for (final res in targetResources) {
      final alreadyDownloaded = await _downloadService.isDatabaseDownloaded(res);
      if (alreadyDownloaded) {
        progressMap[res.book] = 1.0;
        statusMap[res.book] = 'Completed (Skipped)';
        completedCount++;
      } else {
        progressMap[res.book] = 0.0;
        statusMap[res.book] = 'Pending';
      }
    }

    // Emit initial download state
    double initialOverall = targetResources.isNotEmpty ? completedCount / targetResources.length : 0.0;
    emit(state.copyWith(
      downloadProgress: progressMap,
      downloadStatus: statusMap,
      overallProgress: initialOverall,
    ));

    // Begin downloading undownloaded resources sequentially
    for (int i = 0; i < targetResources.length; i++) {
      final res = targetResources[i];
      
      // Skip if already downloaded
      final alreadyDownloaded = await _downloadService.isDatabaseDownloaded(res);
      if (alreadyDownloaded) {
        continue;
      }

      try {
        statusMap[res.book] = 'Downloading...';
        emit(state.copyWith(downloadStatus: statusMap));

        await _downloadService.downloadAndExtract(
          resource: res,
          onProgress: (p) {
            progressMap[res.book] = p;
            
            // Calculate overall progress based on sum of fractions
            double sumOfProgress = 0.0;
            for (final r in targetResources) {
              sumOfProgress += progressMap[r.book] ?? 0.0;
            }
            double overall = sumOfProgress / targetResources.length;

            emit(state.copyWith(
              downloadProgress: progressMap,
              overallProgress: overall,
            ));
          },
          onStatusChange: (status) {
            statusMap[res.book] = status;
            emit(state.copyWith(downloadStatus: statusMap));
          },
        );

        completedCount++;
      } catch (e) {
        statusMap[res.book] = 'Error';
        emit(state.copyWith(
          downloadStatus: statusMap,
          errorMessage: 'Failed to download ${res.name}: ${e.toString()}',
        ));
        return; // Halt installation on error so user can retry
      }
    }

    // 4. Mark Setup as Fully Complete
    await _prefs.setSetupCompleted(true);
    
    // Save selected resource IDs to preferences so search screen etc. know what is active
    await _prefs.setSelectedResources(state.selectedResources.toList());

    emit(state.copyWith(
      overallProgress: 1.0,
      step: SetupStep.completed,
    ));
  }
}

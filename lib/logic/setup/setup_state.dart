import 'package:al_hadith/data/models/resource_model.dart';

enum SetupStep {
  languageSelection,
  resourceSelection,
  downloading,
  completed,
}

class SetupState {
  final SetupStep step;
  final List<HadithLanguage> languages;
  final HadithLanguage? selectedLanguage;
  final Set<String> selectedResources; // Sets of book keys to download
  final Map<String, double> downloadProgress; // Progress per book key (0.0 to 1.0)
  final Map<String, String> downloadStatus; // Status string per book key ('Pending', 'Downloading', etc.)
  final double overallProgress; // Global fraction (0.0 to 1.0)
  final String? errorMessage;
  final bool isLoading;

  SetupState({
    this.step = SetupStep.languageSelection,
    this.languages = const [],
    this.selectedLanguage,
    this.selectedResources = const {},
    this.downloadProgress = const {},
    this.downloadStatus = const {},
    this.overallProgress = 0.0,
    this.errorMessage,
    this.isLoading = false,
  });

  SetupState copyWith({
    SetupStep? step,
    List<HadithLanguage>? languages,
    HadithLanguage? selectedLanguage,
    Set<String>? selectedResources,
    Map<String, double>? downloadProgress,
    Map<String, String>? downloadStatus,
    double? overallProgress,
    String? errorMessage,
    bool? isLoading,
  }) {
    return SetupState(
      step: step ?? this.step,
      languages: languages ?? this.languages,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedResources: selectedResources ?? this.selectedResources,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      overallProgress: overallProgress ?? this.overallProgress,
      errorMessage: errorMessage, // We allow setting to null by not using ?? if passed as null
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Derived properties for easy UI rendering
  bool get isFirstStep => step == SetupStep.languageSelection;
  bool get isSecondStep => step == SetupStep.resourceSelection;
  bool get isDownloadingStep => step == SetupStep.downloading;
  bool get isCompletedStep => step == SetupStep.completed;

  // Calculates total selected download size in bytes
  int get totalSelectedSize {
    return languages
        .expand((lang) => lang.resources)
        .where((r) => selectedResources.contains(r.book))
        .fold(0, (sum, r) => sum + r.zipSize);
  }

  // Formats total size nicely
  String get formattedTotalSize {
    final bytes = totalSelectedSize;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class HadithResource {
  final String book;
  final String name;
  final String nameNative;
  final int hadithCount;
  final int sectionCount;
  final String checksum;
  final String zipPath;
  final int fileSize;
  final int zipSize;
  final String languageCode; // ISO 639-2 code, e.g. 'eng', 'urd'

  // Local state properties for UI and download management
  bool isDownloaded;
  bool isExtracting;
  double progress; // Ranges from 0.0 to 1.0
  String? error;

  HadithResource({
    required this.book,
    required this.name,
    required this.nameNative,
    required this.hadithCount,
    required this.sectionCount,
    required this.checksum,
    required this.zipPath,
    required this.fileSize,
    required this.zipSize,
    this.languageCode = '',
    this.isDownloaded = false,
    this.isExtracting = false,
    this.progress = 0.0,
    this.error,
  });

  /// Convenience getters resolved from HadithLanguage metadata
  String get langDisplayName {
    final meta = HadithLanguage.languageMetadata[languageCode];
    return meta?['display'] ?? languageCode.toUpperCase();
  }

  String get langNativeName {
    final meta = HadithLanguage.languageMetadata[languageCode];
    return meta?['native'] ?? languageCode.toUpperCase();
  }

  String get langFlag {
    final meta = HadithLanguage.languageMetadata[languageCode];
    return meta?['flag'] ?? '🏳️';
  }

  factory HadithResource.fromJson(
    Map<String, dynamic> json, {
    String languageCode = '',
  }) {
    return HadithResource(
      book: json['book'] as String,
      name: json['name'] as String,
      nameNative: json['name_native'] as String? ?? '',
      hadithCount: (json['hadith_count'] as num?)?.toInt() ?? 0,
      sectionCount: (json['section_count'] as num?)?.toInt() ?? 0,
      checksum: json['checksum'] as String,
      zipPath: json['zip_path'] as String,
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      zipSize: (json['zip_size'] as num?)?.toInt() ?? 0,
      languageCode: languageCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book,
      'name': name,
      'name_native': nameNative,
      'hadith_count': hadithCount,
      'section_count': sectionCount,
      'checksum': checksum,
      'zip_path': zipPath,
      'file_size': fileSize,
      'zip_size': zipSize,
    };
  }

  // Helper properties
  String get formattedZipSize {
    if (zipSize < 1024) return '$zipSize B';
    if (zipSize < 1024 * 1024)
      return '${(zipSize / 1024).toStringAsFixed(1)} KB';
    return '${(zipSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  HadithResource copyWith({
    String? languageCode,
    bool? isDownloaded,
    bool? isExtracting,
    double? progress,
    String? error,
  }) {
    return HadithResource(
      book: book,
      name: name,
      nameNative: nameNative,
      hadithCount: hadithCount,
      sectionCount: sectionCount,
      checksum: checksum,
      zipPath: zipPath,
      fileSize: fileSize,
      zipSize: zipSize,
      languageCode: languageCode ?? this.languageCode,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isExtracting: isExtracting ?? this.isExtracting,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}

class HadithLanguage {
  final String code;
  final String displayName;
  final String nativeName;
  final String flagEmoji;
  final List<HadithResource> resources;

  HadithLanguage({
    required this.code,
    required this.displayName,
    required this.nativeName,
    required this.flagEmoji,
    required this.resources,
  });

  static const Map<String, Map<String, String>> languageMetadata = {
    'ara': {'display': 'Arabic', 'native': 'العربية', 'flag': '🇸🇦'},
    'ben': {'display': 'Bengali', 'native': 'বাংলা', 'flag': '🇧🇩'},
    'eng': {'display': 'English', 'native': 'English', 'flag': '🇬🇧'},
    'fra': {'display': 'French', 'native': 'Français', 'flag': '🇫🇷'},
    'ind': {
      'display': 'Indonesian',
      'native': 'Bahasa Indonesia',
      'flag': '🇮🇩',
    },
    'rus': {'display': 'Russian', 'native': 'Русский', 'flag': '🇷🇺'},
    'tam': {'display': 'Tamil', 'native': 'தமிழ்', 'flag': '🇮🇳'},
    'tur': {'display': 'Turkish', 'native': 'Türkçe', 'flag': '🇹🇷'},
    'urd': {'display': 'Urdu', 'native': 'اردو', 'flag': '🇵🇰'},
  };

  factory HadithLanguage.fromCode(String code, List<HadithResource> resources) {
    final meta =
        languageMetadata[code] ??
        {'display': 'Language ($code)', 'native': code, 'flag': '🏳️'};
    return HadithLanguage(
      code: code,
      displayName: meta['display']!,
      nativeName: meta['native']!,
      flagEmoji: meta['flag']!,
      resources: resources,
    );
  }
}

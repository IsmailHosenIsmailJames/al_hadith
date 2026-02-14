/// Data model for a single Hadith resource entry from `all_hadith_info.json`.
class HadithInfoModel {
  final String book;
  final String name;
  final int hadithCount;
  final int sectionCount;
  final String checksum;
  final String zipPath;
  final int fileSize;
  final int zipSize;

  const HadithInfoModel({
    required this.book,
    required this.name,
    required this.hadithCount,
    required this.sectionCount,
    required this.checksum,
    required this.zipPath,
    required this.fileSize,
    required this.zipSize,
  });

  factory HadithInfoModel.fromJson(Map<String, dynamic> json) {
    return HadithInfoModel(
      book: json['book'] as String,
      name: json['name'] as String,
      hadithCount: json['hadith_count'] as int,
      sectionCount: json['section_count'] as int,
      checksum: json['checksum'] as String,
      zipPath: json['zip_path'] as String,
      fileSize: json['file_size'] as int,
      zipSize: json['zip_size'] as int,
    );
  }

  /// Language code extracted from the book id (e.g. "eng" from "eng-bukhari").
  String get languageCode => book.split('-').first;
}

/// Maps 3-letter language codes to display names and metadata.
class LanguageInfo {
  final String code3; // e.g. "eng"
  final String localeCode; // e.g. "en"
  final String nativeName;
  final String englishName;
  final String flag;

  const LanguageInfo({
    required this.code3,
    required this.localeCode,
    required this.nativeName,
    required this.englishName,
    required this.flag,
  });

  static const List<LanguageInfo> all = [
    LanguageInfo(
      code3: 'ara',
      localeCode: 'ar',
      nativeName: 'العربية',
      englishName: 'Arabic',
      flag: '🇸🇦',
    ),
    LanguageInfo(
      code3: 'ben',
      localeCode: 'bn',
      nativeName: 'বাংলা',
      englishName: 'Bengali',
      flag: '🇧🇩',
    ),
    LanguageInfo(
      code3: 'eng',
      localeCode: 'en',
      nativeName: 'English',
      englishName: 'English',
      flag: '🇺🇸',
    ),
    LanguageInfo(
      code3: 'fra',
      localeCode: 'fr',
      nativeName: 'Français',
      englishName: 'French',
      flag: '🇫🇷',
    ),
    LanguageInfo(
      code3: 'ind',
      localeCode: 'id',
      nativeName: 'Bahasa Indonesia',
      englishName: 'Indonesian',
      flag: '🇮🇩',
    ),
    LanguageInfo(
      code3: 'rus',
      localeCode: 'ru',
      nativeName: 'Русский',
      englishName: 'Russian',
      flag: '🇷🇺',
    ),
    LanguageInfo(
      code3: 'tam',
      localeCode: 'ta',
      nativeName: 'தமிழ்',
      englishName: 'Tamil',
      flag: '🇮🇳',
    ),
    LanguageInfo(
      code3: 'tur',
      localeCode: 'tr',
      nativeName: 'Türkçe',
      englishName: 'Turkish',
      flag: '🇹🇷',
    ),
    LanguageInfo(
      code3: 'urd',
      localeCode: 'ur',
      nativeName: 'اردو',
      englishName: 'Urdu',
      flag: '🇵🇰',
    ),
  ];

  /// Find by 3-letter code.
  static LanguageInfo fromCode3(String code3) {
    return all.firstWhere(
      (l) => l.code3 == code3,
      orElse: () => all.firstWhere((l) => l.code3 == 'eng'),
    );
  }

  /// Find by 2-letter locale code.
  static LanguageInfo fromLocaleCode(String localeCode) {
    return all.firstWhere(
      (l) => l.localeCode == localeCode,
      orElse: () => all.firstWhere((l) => l.code3 == 'eng'),
    );
  }
}

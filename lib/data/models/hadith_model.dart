int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
  }
  return 0;
}

class HadithSection {
  final int id;
  final String sectionName;
  final String sectionNameNative;
  final int startHadithNumber;
  final int endHadithNumber;
  final int hadithCount;

  HadithSection({
    required this.id,
    required this.sectionName,
    required this.sectionNameNative,
    required this.startHadithNumber,
    required this.endHadithNumber,
    required this.hadithCount,
  });

  factory HadithSection.fromMap(Map<String, dynamic> map) {
    return HadithSection(
      id: parseInt(map['id']),
      sectionName: (map['section_name'] ?? '') as String,
      sectionNameNative: (map['section_name_native'] ?? '') as String,
      startHadithNumber: parseInt(map['start_hadith_number']),
      endHadithNumber: parseInt(map['end_hadith_number']),
      hadithCount: parseInt(map['hadith_count']),
    );
  }
}

class HadithGrade {
  final int id;
  final int hadithId;
  final String scholarName;
  final String grade;

  HadithGrade({
    required this.id,
    required this.hadithId,
    required this.scholarName,
    required this.grade,
  });

  factory HadithGrade.fromMap(Map<String, dynamic> map) {
    return HadithGrade(
      id: parseInt(map['id']),
      hadithId: parseInt(map['hadith_id']),
      scholarName: (map['scholar_name'] ?? '') as String,
      grade: (map['grade'] ?? '') as String,
    );
  }
}

class HadithItem {
  final int id;
  final int hadithNumber;
  final String text;
  final int sectionId;
  final int bookId;
  final List<HadithGrade> grades;

  HadithItem({
    required this.id,
    required this.hadithNumber,
    required this.text,
    required this.sectionId,
    required this.bookId,
    required this.grades,
  });

  factory HadithItem.fromMap(
    Map<String, dynamic> map, {
    List<HadithGrade> grades = const [],
  }) {
    return HadithItem(
      id: parseInt(map['id']),
      hadithNumber: parseInt(map['hadith_number']),
      text: (map['text'] ?? '') as String,
      sectionId: parseInt(map['section_id']),
      bookId: parseInt(map['book_id']),
      grades: grades,
    );
  }
}

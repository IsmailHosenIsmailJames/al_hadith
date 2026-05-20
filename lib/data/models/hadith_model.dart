class HadithSection {
  final int id;
  final String sectionName;
  final int startHadithNumber;
  final int endHadithNumber;
  final int hadithCount;

  HadithSection({
    required this.id,
    required this.sectionName,
    required this.startHadithNumber,
    required this.endHadithNumber,
    required this.hadithCount,
  });

  factory HadithSection.fromMap(Map<String, dynamic> map) {
    return HadithSection(
      id: map['id'] as int,
      sectionName: (map['section_name'] ?? '') as String,
      startHadithNumber: (map['start_hadith_number'] ?? 0) as int,
      endHadithNumber: (map['end_hadith_number'] ?? 0) as int,
      hadithCount: (map['hadith_count'] ?? 0) as int,
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
      id: map['id'] as int,
      hadithId: (map['hadith_id'] ?? 0) as int,
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

  factory HadithItem.fromMap(Map<String, dynamic> map, {List<HadithGrade> grades = const []}) {
    return HadithItem(
      id: map['id'] as int,
      hadithNumber: (map['hadith_number'] ?? 0) as int,
      text: (map['text'] ?? '') as String,
      sectionId: (map['section_id'] ?? 0) as int,
      bookId: (map['book_id'] ?? 0) as int,
      grades: grades,
    );
  }
}

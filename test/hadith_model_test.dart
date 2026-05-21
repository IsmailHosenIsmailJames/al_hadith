import 'package:flutter_test/flutter_test.dart';
import 'package:al_hadith/data/models/hadith_model.dart';

void main() {
  group('Hadith Models Safe Parsing Tests', () {
    test('HadithSection parses double/string values correctly', () {
      final map = {
        'id': 1.0, // double
        'section_name': 'Chapter 1',
        'start_hadith_number': '10', // string
        'end_hadith_number': 20.0, // double
        'hadith_count': 11, // int
      };

      final section = HadithSection.fromMap(map);

      expect(section.id, equals(1));
      expect(section.sectionName, equals('Chapter 1'));
      expect(section.startHadithNumber, equals(10));
      expect(section.endHadithNumber, equals(20));
      expect(section.hadithCount, equals(11));
    });

    test('HadithGrade parses double/string values correctly', () {
      final map = {
        'id': 5.0, // double
        'hadith_id': '100', // string
        'scholar_name': 'Scholar Name',
        'grade': 'Sahih',
      };

      final grade = HadithGrade.fromMap(map);

      expect(grade.id, equals(5));
      expect(grade.hadithId, equals(100));
      expect(grade.scholarName, equals('Scholar Name'));
      expect(grade.grade, equals('Sahih'));
    });

    test('HadithItem parses double/string values correctly', () {
      final map = {
        'id': 50.0, // double
        'hadith_number': '1002', // string
        'text': 'Hadith content text',
        'section_id': 20.0, // double
        'book_id': 1, // int
      };

      final item = HadithItem.fromMap(map);

      expect(item.id, equals(50));
      expect(item.hadithNumber, equals(1002));
      expect(item.text, equals('Hadith content text'));
      expect(item.sectionId, equals(20));
      expect(item.bookId, equals(1));
    });
  });
}

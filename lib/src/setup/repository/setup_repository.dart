import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hadith_info.dart';

class SetupRepository {
  Map<String, List<HadithInfo>>? _allHadithInfo;

  Future<Map<String, List<HadithInfo>>> getAllHadithInfo() async {
    if (_allHadithInfo != null) return _allHadithInfo!;

    final String response = await rootBundle.loadString(
      'assets/all_hadith_info.json',
    );
    final Map<String, dynamic> data = json.decode(response);

    _allHadithInfo = data.map((key, value) {
      return MapEntry(
        key,
        (value as List).map((i) => HadithInfo.fromMap(i)).toList(),
      );
    });

    return _allHadithInfo!;
  }

  List<String> getAvailableLanguages(Map<String, List<HadithInfo>> info) {
    return info.keys.toList();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'ara':
        return 'Arabic';
      case 'ben':
        return 'Bengali';
      case 'eng':
        return 'English';
      case 'fra':
        return 'French';
      case 'ind':
        return 'Indonesian';
      case 'rus':
        return 'Russian';
      case 'tam':
        return 'Tamil';
      case 'tur':
        return 'Turkish';
      case 'urd':
        return 'Urdu';
      default:
        return code.toUpperCase();
    }
  }
}

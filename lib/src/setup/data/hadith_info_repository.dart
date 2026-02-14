import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/hadith_info_model.dart';

/// Loads and parses Hadith resource info from the bundled JSON asset.
class HadithInfoRepository {
  Map<String, List<HadithInfoModel>>? _cache;

  /// Returns all resources grouped by 3-letter language code.
  Future<Map<String, List<HadithInfoModel>>> loadAll() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString(
      'assets/all_hadith_info.json',
    );
    final Map<String, dynamic> raw = json.decode(jsonString);

    _cache = raw.map((langCode, items) {
      final list = (items as List)
          .map((e) => HadithInfoModel.fromJson(e))
          .toList();
      return MapEntry(langCode, list);
    });

    return _cache!;
  }
}

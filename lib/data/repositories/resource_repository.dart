import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:al_hadith/core/constants/api_constants.dart';
import 'package:al_hadith/data/models/resource_model.dart';

class ResourceRepository {
  final Dio _dio;

  ResourceRepository({Dio? dio}) : _dio = dio ?? Dio();

  /// Loads the metadata either from local assets or remote server
  Future<List<HadithLanguage>> getLanguagesAndResources({bool forceRemote = false}) async {
    try {
      if (forceRemote) {
        return await _fetchFromRemote();
      }
    } catch (e) {
      // Fail silently and fallback to local assets
    }
    return await _fetchFromLocal();
  }

  /// Fetches metadata from bundled assets
  Future<List<HadithLanguage>> _fetchFromLocal() async {
    final String jsonString = await rootBundle.loadString('assets/data/all_info.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
    return _parseMetadata(jsonData);
  }

  /// Fetches metadata from remote repository
  Future<List<HadithLanguage>> _fetchFromRemote() async {
    final response = await _dio.get(ApiConstants.allInfoUrl);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = response.data is String 
          ? json.decode(response.data as String) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return _parseMetadata(jsonData);
    } else {
      throw Exception('Failed to load remote resources metadata');
    }
  }

  /// Parses JSON structure into models
  List<HadithLanguage> _parseMetadata(Map<String, dynamic> data) {
    final List<HadithLanguage> languages = [];
    
    data.forEach((langCode, resourcesJson) {
      if (resourcesJson is List) {
        final resources = resourcesJson
            .map((item) => HadithResource.fromJson(item as Map<String, dynamic>, languageCode: langCode))
            .toList();
        languages.add(HadithLanguage.fromCode(langCode, resources));
      }
    });

    // Sort languages to put English first, Bengali second, Arabic third, and others alphabetically
    languages.sort((a, b) {
      if (a.code == 'eng') return -1;
      if (b.code == 'eng') return 1;
      if (a.code == 'ben') return -1;
      if (b.code == 'ben') return 1;
      if (a.code == 'ara') return -1;
      if (b.code == 'ara') return 1;
      return a.displayName.compareTo(b.displayName);
    });

    return languages;
  }
}

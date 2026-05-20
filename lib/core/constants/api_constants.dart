class ApiConstants {
  static const String baseUrl = 'https://ismailhosenismailjames.github.io/compressed_hadith_sqlite';
  static const String allInfoUrl = '$baseUrl/all_info.json';

  /// Helper to generate download URL for a specific resource
  static String getDownloadUrl(String zipPath) {
    return '$baseUrl/$zipPath';
  }
}

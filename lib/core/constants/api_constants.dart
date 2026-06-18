class ApiConstants {
  static const String baseUrl = 'https://compressed-hadith-sqlite.vercel.app';
  static const String allInfoUrl = '$baseUrl/all_info.json';

  /// Helper to generate download URL for a specific resource
  static String getDownloadUrl(String zipPath) {
    return '$baseUrl/$zipPath';
  }
}

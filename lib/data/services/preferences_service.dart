import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static const String _keyLanguage = 'app_language_code';
  static const String _keySelectedResources = 'selected_resources_keys';
  static const String _keyDownloadedResources = 'downloaded_resources_keys';
  static const String _keyIsSetupCompleted = 'is_setup_completed';
  static const String _keyThemeMode = 'theme_mode'; // 'light', 'dark'
  static const String _keyArabicFontSize = 'arabic_font_size';
  static const String _keyTranslationFontSize = 'translation_font_size';
  static const String _keyArabicFontFamily = 'arabic_font_family';
  static const String _keyWakeLockEnabled = 'wake_lock_enabled';

  // Language setting
  String? getAppLanguage() {
    return _prefs.getString(_keyLanguage);
  }

  Future<bool> setAppLanguage(String languageCode) {
    return _prefs.setString(_keyLanguage, languageCode);
  }

  // Selected Resources keys (to be downloaded)
  List<String> getSelectedResources() {
    return _prefs.getStringList(_keySelectedResources) ?? [];
  }

  Future<bool> setSelectedResources(List<String> keys) {
    return _prefs.setStringList(_keySelectedResources, keys);
  }

  // Already downloaded resources keys (cached checklist)
  List<String> getDownloadedResources() {
    return _prefs.getStringList(_keyDownloadedResources) ?? [];
  }

  Future<bool> setDownloadedResources(List<String> keys) {
    return _prefs.setStringList(_keyDownloadedResources, keys);
  }

  Future<bool> addDownloadedResource(String bookKey) {
    final downloaded = getDownloadedResources();
    if (!downloaded.contains(bookKey)) {
      downloaded.add(bookKey);
      return setDownloadedResources(downloaded);
    }
    return Future.value(true);
  }

  Future<bool> removeDownloadedResource(String bookKey) {
    final downloaded = getDownloadedResources();
    if (downloaded.contains(bookKey)) {
      downloaded.remove(bookKey);
      return setDownloadedResources(downloaded);
    }
    return Future.value(true);
  }

  // Setup completion status
  bool isSetupCompleted() {
    return _prefs.getBool(_keyIsSetupCompleted) ?? false;
  }

  Future<bool> setSetupCompleted(bool completed) {
    return _prefs.setBool(_keyIsSetupCompleted, completed);
  }

  // Theme settings
  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'dark';
  }

  Future<bool> setThemeMode(String mode) {
    return _prefs.setString(_keyThemeMode, mode);
  }

  // Font Sizing settings
  double getArabicFontSize() {
    return _prefs.getDouble(_keyArabicFontSize) ?? 24.0;
  }

  Future<bool> setArabicFontSize(double size) {
    return _prefs.setDouble(_keyArabicFontSize, size);
  }

  double getTranslationFontSize() {
    return _prefs.getDouble(_keyTranslationFontSize) ?? 16.0;
  }

  Future<bool> setTranslationFontSize(double size) {
    return _prefs.setDouble(_keyTranslationFontSize, size);
  }

  // Arabic Font Family
  String getArabicFontFamily() {
    return _prefs.getString(_keyArabicFontFamily) ?? 'me_quran';
  }

  Future<bool> setArabicFontFamily(String family) {
    return _prefs.setString(_keyArabicFontFamily, family);
  }

  // Wake Lock toggles
  bool isWakeLockEnabled() {
    return _prefs.getBool(_keyWakeLockEnabled) ?? false;
  }

  Future<bool> setWakeLockEnabled(bool enabled) {
    return _prefs.setBool(_keyWakeLockEnabled, enabled);
  }

  // Clear preferences (useful for reset / testing)
  Future<bool> clearAll() {
    return _prefs.clear();
  }
}

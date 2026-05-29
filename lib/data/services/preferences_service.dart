import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static const String _keyLanguage = 'app_language_code';
  static const String _keyAppLocale = 'app_locale_code';
  static const String _keyAppLocaleExplicit = 'app_locale_explicit';
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

  // App Interface Localization settings
  String? getAppLocale() {
    return _prefs.getString(_keyAppLocale);
  }

  Future<bool> setAppLocale(String localeCode) {
    return _prefs.setString(_keyAppLocale, localeCode);
  }

  bool isAppLocaleExplicit() {
    return _prefs.getBool(_keyAppLocaleExplicit) ?? false;
  }

  Future<bool> setAppLocaleExplicit(bool explicit) {
    return _prefs.setBool(_keyAppLocaleExplicit, explicit);
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
    return _prefs.getString(_keyThemeMode) ?? 'system';
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
    return _prefs.getString(_keyArabicFontFamily) ?? 'Me Quran';
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

  // Auto Sync setting
  static const String _keyAutoSync = 'auto_sync_enabled';

  bool isAutoSyncEnabled() {
    return _prefs.getBool(_keyAutoSync) ?? true; // Default: ON
  }

  Future<bool> setAutoSyncEnabled(bool enabled) {
    return _prefs.setBool(_keyAutoSync, enabled);
  }

  // Clear preferences (useful for reset / testing)
  Future<bool> clearAll() {
    return _prefs.clear();
  }
}

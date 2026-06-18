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

  // Sorting Keys
  static const String _keyBookSortType = 'book_sort_type';
  static const String _keyBookSortAscending = 'book_sort_ascending';
  static const String _keyBookCustomOrder = 'book_custom_order';
  static const String _keyBookDownloadTimePrefix = 'book_download_time_';

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

  Future<bool> addDownloadedResource(String bookKey) async {
    final downloaded = getDownloadedResources();
    if (!downloaded.contains(bookKey)) {
      downloaded.add(bookKey);
      await _prefs.setInt('$_keyBookDownloadTimePrefix$bookKey', DateTime.now().millisecondsSinceEpoch);
      return setDownloadedResources(downloaded);
    }
    return true;
  }

  Future<bool> removeDownloadedResource(String bookKey) async {
    final downloaded = getDownloadedResources();
    if (downloaded.contains(bookKey)) {
      downloaded.remove(bookKey);
      await _prefs.remove('$_keyBookDownloadTimePrefix$bookKey');
      return setDownloadedResources(downloaded);
    }
    return true;
  }

  int getBookDownloadTime(String bookKey) {
    return _prefs.getInt('$_keyBookDownloadTimePrefix$bookKey') ?? 0;
  }

  // Sorting helper methods
  String getBookSortType() {
    return _prefs.getString(_keyBookSortType) ?? 'name';
  }

  Future<bool> setBookSortType(String type) {
    return _prefs.setString(_keyBookSortType, type);
  }

  bool isBookSortAscending() {
    return _prefs.getBool(_keyBookSortAscending) ?? true;
  }

  Future<bool> setBookSortAscending(bool ascending) {
    return _prefs.setBool(_keyBookSortAscending, ascending);
  }

  List<String> getBookCustomOrder() {
    return _prefs.getStringList(_keyBookCustomOrder) ?? [];
  }

  Future<bool> setBookCustomOrder(List<String> order) {
    return _prefs.setStringList(_keyBookCustomOrder, order);
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

  // Hadith View Mode preference
  static const String _keyHadithViewMode = 'hadith_view_mode';

  String getHadithViewMode() {
    return _prefs.getString(_keyHadithViewMode) ?? 'page';
  }

  Future<bool> setHadithViewMode(String mode) {
    return _prefs.setString(_keyHadithViewMode, mode);
  }

  // Clear preferences (useful for reset / testing)
  Future<bool> clearAll() {
    return _prefs.clear();
  }
}

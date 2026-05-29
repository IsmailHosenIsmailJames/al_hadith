import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:al_hadith/data/services/preferences_service.dart';
import 'package:al_hadith/logic/settings/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final PreferencesService _prefs;

  SettingsCubit(this._prefs) : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final explicit = _prefs.isAppLocaleExplicit();
    final appLocale = _prefs.getAppLocale() ?? 'eng';
    final resourceLang = _prefs.getAppLanguage() ?? 'eng';
    final activeLanguage = explicit ? appLocale : resourceLang;

    emit(SettingsState(
      themeMode: _prefs.getThemeMode(),
      arabicFontSize: _prefs.getArabicFontSize(),
      translationFontSize: _prefs.getTranslationFontSize(),
      arabicFontFamily: _prefs.getArabicFontFamily(),
      wakeLockEnabled: _prefs.isWakeLockEnabled(),
      autoSyncEnabled: _prefs.isAutoSyncEnabled(),
      appLanguage: activeLanguage,
      isAppLanguageExplicit: explicit,
    ));

    // Apply wake lock on startup if enabled
    if (_prefs.isWakeLockEnabled()) {
      WakelockPlus.enable();
    }
  }

  Future<void> setAppLanguage(String languageCode, {bool explicit = true}) async {
    await _prefs.setAppLocale(languageCode);
    await _prefs.setAppLocaleExplicit(explicit);
    emit(state.copyWith(
      appLanguage: languageCode,
      isAppLanguageExplicit: explicit,
    ));
  }

  Future<void> updateLanguageImplicitly(String languageCode) async {
    if (!state.isAppLanguageExplicit) {
      await _prefs.setAppLocale(languageCode);
      emit(state.copyWith(
        appLanguage: languageCode,
      ));
    }
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setArabicFontSize(double size) async {
    await _prefs.setArabicFontSize(size);
    emit(state.copyWith(arabicFontSize: size));
  }

  Future<void> setTranslationFontSize(double size) async {
    await _prefs.setTranslationFontSize(size);
    emit(state.copyWith(translationFontSize: size));
  }

  Future<void> setArabicFontFamily(String family) async {
    await _prefs.setArabicFontFamily(family);
    emit(state.copyWith(arabicFontFamily: family));
  }

  Future<void> setWakeLockEnabled(bool enabled) async {
    await _prefs.setWakeLockEnabled(enabled);
    if (enabled) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
    emit(state.copyWith(wakeLockEnabled: enabled));
  }

  Future<void> setAutoMarkRead(bool enabled) async {
    emit(state.copyWith(autoMarkRead: enabled));
  }

  Future<void> setDwellTimerSeconds(int seconds) async {
    emit(state.copyWith(dwellTimerSeconds: seconds));
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    await _prefs.setAutoSyncEnabled(enabled);
    emit(state.copyWith(autoSyncEnabled: enabled));
  }
}

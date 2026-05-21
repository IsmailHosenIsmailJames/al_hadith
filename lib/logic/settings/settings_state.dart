class SettingsState {
  final String themeMode; // 'dark' or 'light'
  final double arabicFontSize;
  final double translationFontSize;
  final String arabicFontFamily;
  final bool wakeLockEnabled;
  final bool autoMarkRead; // Auto mark hadith as read after dwell time
  final int dwellTimerSeconds; // Dwell time in seconds

  const SettingsState({
    this.themeMode = 'dark',
    this.arabicFontSize = 24.0,
    this.translationFontSize = 16.0,
    this.arabicFontFamily = 'Me Quran',
    this.wakeLockEnabled = false,
    this.autoMarkRead = true,
    this.dwellTimerSeconds = 5,
  });

  SettingsState copyWith({
    String? themeMode,
    double? arabicFontSize,
    double? translationFontSize,
    String? arabicFontFamily,
    bool? wakeLockEnabled,
    bool? autoMarkRead,
    int? dwellTimerSeconds,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      arabicFontFamily: arabicFontFamily ?? this.arabicFontFamily,
      wakeLockEnabled: wakeLockEnabled ?? this.wakeLockEnabled,
      autoMarkRead: autoMarkRead ?? this.autoMarkRead,
      dwellTimerSeconds: dwellTimerSeconds ?? this.dwellTimerSeconds,
    );
  }
}

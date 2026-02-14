import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// All locales supported by this application.
const supportedLocales = [
  Locale('ar'), // Arabic
  Locale('bn'), // Bengali
  Locale('en'), // English
  Locale('fr'), // French
  Locale('id'), // Indonesian
  Locale('ru'), // Russian
  Locale('ta'), // Tamil
  Locale('tr'), // Turkish
  Locale('ur'), // Urdu
];

/// Fallback locale when the system language is not supported.
const _fallbackLocale = Locale('en');

/// Cubit that manages the active [Locale].
///
/// On creation it resolves the system language: if it matches one of the
/// [supportedLocales] that locale is used; otherwise English is the default.
///
/// Call [changeLocale] to switch languages at runtime.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(_resolveInitialLocale());

  /// Resolve the best initial locale from the system language.
  static Locale _resolveInitialLocale() {
    final systemLocale = ui.PlatformDispatcher.instance.locale;

    // Exact match first (language + country), then language-only match.
    for (final supported in supportedLocales) {
      if (supported == systemLocale) return supported;
    }
    for (final supported in supportedLocales) {
      if (supported.languageCode == systemLocale.languageCode) {
        return supported;
      }
    }

    return _fallbackLocale;
  }

  /// Switch the active locale. If [locale] is not in [supportedLocales],
  /// the call is ignored.
  void changeLocale(Locale locale) {
    final isSupported = supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
    if (!isSupported || locale.languageCode == state.languageCode) return;

    emit(locale);
  }
}

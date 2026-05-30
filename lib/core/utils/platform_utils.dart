import 'package:flutter/foundation.dart';

/// Helper to determine if Firebase Auth and Firebase Realtime Database
/// are supported on the current platform.
bool get isFirebaseSupported {
  if (kIsWeb) return true;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows;
}

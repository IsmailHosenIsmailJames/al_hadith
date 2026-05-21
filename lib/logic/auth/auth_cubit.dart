import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:al_hadith/data/services/backup_service.dart';
import 'package:al_hadith/data/services/preferences_service.dart';
import 'package:al_hadith/logic/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final BackupService _backupService;
  final PreferencesService _prefs;
  StreamSubscription<User?>? _authSubscription;

  AuthCubit({
    required FirebaseAuth auth,
    required BackupService backupService,
    required PreferencesService prefs,
  })  : _auth = auth,
        _backupService = backupService,
        _prefs = prefs,
        super(const AuthState()) {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        ));
        // Auto-sync on login if enabled
        if (_prefs.isAutoSyncEnabled()) {
          syncNow();
        }
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearError: true,
        ));
      }
    });
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      // Auth state listener handles the rest
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message ?? 'Google sign-in failed',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google sign-in failed: ${e.toString()}',
      ));
    }
  }

  /// Sign in with Email & Password
  Future<void> signInWithEmail(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getAuthErrorMessage(e.code),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Sign-in failed: ${e.toString()}',
      ));
    }
  }

  /// Register with Email & Password
  Future<void> registerWithEmail(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _getAuthErrorMessage(e.code),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Registration failed: ${e.toString()}',
      ));
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (_) {
      // Silently fail — don't reveal whether email exists
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Upload one final backup before signing out
      if (state.user != null && _prefs.isAutoSyncEnabled()) {
        await _backupService.uploadBackup(state.user!.uid);
      }
    } catch (_) {
      // Best effort backup on sign-out
    }
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  /// Manual sync: merge local ↔ remote
  Future<void> syncNow() async {
    if (state.user == null) return;

    emit(state.copyWith(isSyncing: true, clearError: true));
    try {
      await _backupService.mergeBackup(state.user!.uid);
      emit(state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isSyncing: false,
        errorMessage: 'Sync failed: ${e.toString()}',
      ));
    }
  }

  /// Upload-only backup (used by auto-sync triggers)
  Future<void> autoUpload() async {
    if (state.user == null || !_prefs.isAutoSyncEnabled()) return;
    try {
      await _backupService.uploadBackup(state.user!.uid);
    } catch (_) {
      // Silent fail for auto-upload
    }
  }

  /// Delete both account and all cloud sync data permanently (Google Play compliance)
  Future<void> deleteAccountAndData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final uid = user.uid;

      // 1. Purge remote database records
      await _backupService.deleteBackup(uid);

      // 2. Delete the user account from Firebase Auth
      await user.delete();

      // 3. Clear Google sign-in local state
      await GoogleSignIn().signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'For security, please sign out and sign back in before deleting your account.',
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.message ?? 'Account deletion failed.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Account deletion failed: ${e.toString()}',
      ));
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return 'Authentication error: $code';
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

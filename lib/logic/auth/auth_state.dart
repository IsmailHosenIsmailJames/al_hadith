import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isSyncing;
  final DateTime? lastSyncTime;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isSyncing = false,
    this.lastSyncTime,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
    bool? isSyncing,
    DateTime? lastSyncTime,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  bool get isLoggedIn => status == AuthStatus.authenticated && user != null;
  String get displayName => user?.displayName ?? user?.email?.split('@').first ?? 'User';
  String get email => user?.email ?? '';
  String? get photoUrl => user?.photoURL;
}

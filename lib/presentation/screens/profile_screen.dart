import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/logic/auth/auth_cubit.dart';
import 'package:al_hadith/logic/auth/auth_state.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/logic/settings/settings_state.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState.isLoggedIn) {
          return _buildLoggedInView(context, authState);
        }
        return _buildLoginView(context, authState);
      },
    );
  }

  // ── Logged-in view ──
  Widget _buildLoggedInView(BuildContext context, AuthState authState) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Gap(20),
          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              border: Border.all(
                color: AppTheme.primaryMint.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: authState.photoUrl != null
                ? ClipOval(
                    child: Image.network(
                      authState.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Icon(
                        Icons.person,
                        size: 40,
                        color: AppTheme.darkCanvas,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.darkCanvas,
                  ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

          const Gap(16),
          Text(
            authState.displayName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const Gap(4),
          Text(
            authState.email,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),

          const Gap(28),

          // Sync Card
          _buildSyncCard(context, authState),

          const Gap(16),

          // Auto Sync Toggle
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.sync_rounded,
                        color: AppTheme.primaryMint,
                        size: 20,
                      ),
                    ),
                    const Gap(12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto Sync',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Gap(2),
                          Text(
                            'Automatically backup data on changes',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: settingsState.autoSyncEnabled,
                      onChanged: (val) {
                        context.read<SettingsCubit>().setAutoSyncEnabled(val);
                      },
                      activeThumbColor: AppTheme.primaryMint,
                      activeTrackColor: AppTheme.primaryMint.withValues(
                        alpha: 0.3,
                      ),
                      inactiveThumbColor: AppTheme.textSecondary,
                      inactiveTrackColor: const Color(0xFF1E293B),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
            },
          ),

          const Gap(24),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.darkSurface,
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      'Your data will be backed up before signing out.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await context.read<AuthCubit>().signOut();
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

          const Gap(32),
        ],
      ),
    );
  }

  Widget _buildSyncCard(BuildContext context, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: authState.isSyncing
              ? AppTheme.primaryMint.withValues(alpha: 0.4)
              : const Color(0xFF1E293B),
          width: authState.isSyncing ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: authState.isSyncing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryMint,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(
                        Icons.cloud_done_rounded,
                        color: AppTheme.primaryMint,
                        size: 22,
                      ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authState.isSyncing ? 'Syncing...' : 'Cloud Backup',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      authState.lastSyncTime != null
                          ? 'Last synced: ${_formatTime(authState.lastSyncTime!)}'
                          : 'Tap to sync your data now',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: authState.isSyncing
                  ? null
                  : () {
                      context.read<AuthCubit>().syncNow();
                      // Reload dashboard after sync to reflect restored data
                      Future.delayed(const Duration(seconds: 2), () {
                        if (context.mounted) {
                          context.read<HadithCubit>().loadDashboard();
                        }
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMint,
                foregroundColor: AppTheme.darkCanvas,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.sync_rounded, size: 18),
              label: Text(
                authState.isSyncing ? 'Syncing...' : 'Sync Now',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (authState.errorMessage != null) ...[
            const Gap(10),
            Text(
              authState.errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms).slideY(begin: 0.03, end: 0);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  // ── Login view ──
  Widget _buildLoginView(BuildContext context, AuthState authState) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Gap(32),
          // Hero Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryMint.withValues(alpha: 0.1),
              border: Border.all(
                color: AppTheme.primaryMint.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.cloud_outlined,
              size: 36,
              color: AppTheme.primaryMint,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

          const Gap(20),
          const Text(
            'Backup & Sync',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const Gap(8),
          const Text(
            'Sign in to backup your bookmarks, notes,\nread progress, and collections to the cloud.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const Gap(32),

          // Google Sign-In Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: authState.status == AuthStatus.loading
                  ? null
                  : () => context.read<AuthCubit>().signInWithGoogle(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1E293B)),
                backgroundColor: AppTheme.darkSurface,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: SvgPicture.asset(
                'assets/img/google-color-svgrepo-com.svg',
                height: 20,
                width: 20,
              ),
              label: const Text(
                'Continue with Google',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          const Gap(20),

          // Divider
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFF1E293B))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFF1E293B))),
            ],
          ),

          const Gap(20),

          // Email field
          _buildTextField(
            controller: _emailController,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const Gap(12),

          // Password field
          _buildTextField(
            controller: _passwordController,
            hint: 'Password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textSecondary,
                size: 18,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),

          const Gap(20),

          // Email Sign-In / Register Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authState.status == AuthStatus.loading
                  ? null
                  : () {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text;
                      if (email.isEmpty || password.isEmpty) return;
                      if (_isRegisterMode) {
                        context.read<AuthCubit>().registerWithEmail(
                          email,
                          password,
                        );
                      } else {
                        context.read<AuthCubit>().signInWithEmail(
                          email,
                          password,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMint,
                foregroundColor: AppTheme.darkCanvas,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: authState.status == AuthStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.darkCanvas,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      _isRegisterMode ? 'Create Account' : 'Sign In',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),

          const Gap(12),

          // Toggle Register / Login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isRegisterMode
                    ? 'Already have an account?'
                    : "Don't have an account?",
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _isRegisterMode = !_isRegisterMode),
                child: Text(
                  _isRegisterMode ? 'Sign In' : 'Register',
                  style: const TextStyle(
                    color: AppTheme.primaryMint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Forgot Password
          if (!_isRegisterMode)
            TextButton(
              onPressed: () {
                final email = _emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter your email above to reset password'),
                    ),
                  );
                  return;
                }
                context.read<AuthCubit>().resetPassword(email);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.primaryMint,
                    content: Text(
                      'Password reset link sent! Check your email.',
                      style: TextStyle(color: AppTheme.darkCanvas),
                    ),
                  ),
                );
              },
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),

          // Error message
          if (authState.errorMessage != null) ...[
            const Gap(12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const Gap(10),
                  Expanded(
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Gap(32),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 18),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

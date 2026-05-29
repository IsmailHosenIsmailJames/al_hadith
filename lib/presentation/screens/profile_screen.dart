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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final tickColor = isDark ? AppTheme.darkCanvas : Colors.white;

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
                      errorBuilder: (ctx, err, stack) => Icon(
                        Icons.person,
                        size: 40,
                        color: tickColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 40,
                    color: tickColor,
                  ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

          const Gap(16),
          Text(
            authState.displayName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const Gap(4),
          Text(
            authState.email,
            style: TextStyle(fontSize: 13, color: textSecondary),
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
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderDividerColor),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto Sync',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            'Automatically backup data on changes',
                            style: TextStyle(
                              color: textSecondary,
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
                      inactiveThumbColor: textSecondary,
                      inactiveTrackColor: borderDividerColor,
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
                    backgroundColor: cardBgColor,
                    title: Text(
                      'Sign Out',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      'Your data will be backed up before signing out.',
                      style: TextStyle(color: textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: textSecondary),
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

          // Delete Account Button (Google Play Compliance)
          const Gap(12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: cardBgColor,
                    title: const Text(
                      'Delete Account & Data',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      'Are you absolutely sure? This will permanently delete your user account and purge all your synced bookmarks, notes, and progress from the cloud. This action cannot be undone.',
                      style: TextStyle(color: textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Delete Forever',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await context.read<AuthCubit>().deleteAccountAndData();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent.withValues(alpha: 0.8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2)),
                ),
              ),
              icon: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
              label: const Text(
                'Delete Account & Sync Data',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

          const Gap(32),
        ],
      ),
    );
  }

  Widget _buildSyncCard(BuildContext context, AuthState authState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final tickColor = isDark ? AppTheme.darkCanvas : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: authState.isSyncing
              ? AppTheme.primaryMint.withValues(alpha: 0.4)
              : borderDividerColor,
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
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      authState.lastSyncTime != null
                          ? 'Last synced: ${_formatTime(authState.lastSyncTime!)}'
                          : 'Tap to sync your data now',
                      style: TextStyle(
                        color: textSecondary,
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
                foregroundColor: tickColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final tickColor = isDark ? AppTheme.darkCanvas : Colors.white;

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
          Text(
            'Backup & Sync',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const Gap(8),
          Text(
            'Sign in to backup your bookmarks, notes,\nread progress, and collections to the cloud.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondary,
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
                side: BorderSide(color: borderDividerColor),
                backgroundColor: cardBgColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: SvgPicture.asset(
                'assets/img/google-color-svgrepo-com.svg',
                height: 20,
                width: 20,
                placeholderBuilder: (context) => const Icon(
                  Icons.login_rounded,
                  color: AppTheme.primaryMint,
                  size: 20,
                ),
              ),
              label: Text(
                'Continue with Google',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          const Gap(20),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: borderDividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: borderDividerColor)),
            ],
          ),

          const Gap(20),

          // Email field
          _buildTextField(
            context,
            controller: _emailController,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const Gap(12),

          // Password field
          _buildTextField(
            context,
            controller: _passwordController,
            hint: 'Password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: textSecondary,
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
                foregroundColor: tickColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: authState.status == AuthStatus.loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: tickColor,
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
                style: TextStyle(
                  color: textSecondary,
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
                  SnackBar(
                    backgroundColor: AppTheme.primaryMint,
                    content: Text(
                      'Password reset link sent! Check your email.',
                      style: TextStyle(color: tickColor),
                    ),
                  ),
                );
              },
              child: Text(
                'Forgot password?',
                style: TextStyle(color: textSecondary, fontSize: 12),
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

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderDividerColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: textSecondary,
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: textSecondary, size: 18),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

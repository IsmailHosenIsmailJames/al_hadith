import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/logic/auth/auth_cubit.dart';
import 'package:al_hadith/logic/auth/auth_state.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';
import 'package:al_hadith/core/localization/app_localization.dart';

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
  bool _isEmailFormExpanded = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  int _getHadithsReadTodayCount(HadithState state) {
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    int count = 0;
    for (final r in state.readHistory) {
      final date = DateTime.fromMillisecondsSinceEpoch(r.timestamp);
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      if (dateStr == todayStr) {
        count++;
      }
    }
    return count;
  }

  int _getTotalReadingMinutes(HadithState state) {
    int totalSecs = 0;
    for (final s in state.readingSessions) {
      totalSecs += s.durationSeconds;
    }
    return (totalSecs / 60).round();
  }

  String _formatTime(DateTime? time, String appLanguage) {
    if (time == null) return AppLocalization.get('just_now', appLanguage);
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) {
      return AppLocalization.get('just_now', appLanguage);
    }
    if (diff.inMinutes < 60) {
      return AppLocalization.get(
        'minutes_ago',
        appLanguage,
        args: {'minutes': diff.inMinutes.toString()},
      );
    }
    if (diff.inHours < 24) {
      return AppLocalization.get(
        'hours_ago',
        appLanguage,
        args: {'hours': diff.inHours.toString()},
      );
    }
    return '${time.day}/${time.month}/${time.year}';
  }

  void _showLanguageDialog(BuildContext context, String currentLang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;

    final languages = [
      {'code': 'bng', 'name': 'বাংলা (Bengali)', 'flag': '🇧🇩'},
      {'code': 'eng', 'name': 'English', 'flag': '🇬🇧'},
      {'code': 'ara', 'name': 'العربية (Arabic)', 'flag': '🇸🇦'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(14),
            Text(
              'অ্যাপের ভাষা নির্বাচন করুন',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const Gap(12),
            ...languages.map((l) {
              final isSelected = l['code'] == currentLang;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Text(l['flag']!, style: const TextStyle(fontSize: 20)),
                title: Text(
                  l['name']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryMint : textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryMint)
                    : null,
                onTap: () {
                  context.read<SettingsCubit>().setAppLanguage(l['code']!);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final settingsState = context.watch<SettingsCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final cardBgColor = isDark
        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.25)
        : const Color(0xFFF8FAFC);
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<HadithCubit, HadithState>(
          builder: (context, hadithState) {
            final readToday = _getHadithsReadTodayCount(hadithState);
            final readingMins = _getTotalReadingMinutes(hadithState);
            final dailyGoal = hadithState.dailyGoal;
            final isBn = appLanguage == 'bng';

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Compact User Profile / Guest Card ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderDividerColor),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                            border: Border.all(
                              color: AppTheme.primaryMint.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: authState.isLoggedIn && authState.photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    authState.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Icon(
                                      Icons.person_rounded,
                                      size: 26,
                                      color: isDark ? AppTheme.darkCanvas : Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  authState.isLoggedIn
                                      ? Icons.person_rounded
                                      : Icons.account_circle_rounded,
                                  size: 28,
                                  color: isDark ? AppTheme.darkCanvas : Colors.white,
                                ),
                        ),
                        const Gap(12),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      authState.isLoggedIn
                                          ? authState.displayName
                                          : (isBn ? 'অতিথি পাঠক' : 'Guest Reader'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Gap(6),
                                  // Status Indicator
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: authState.isLoggedIn
                                          ? const Color(0xFF10B981)
                                          : Colors.amber.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(2),
                              Text(
                                authState.isLoggedIn
                                    ? authState.email
                                    : (isBn
                                        ? 'অফলাইন মোড • লোকাল স্টোরেজ'
                                        : 'Offline Mode • Local Storage'),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Cloud Sync Badge / Log in Action
                        if (authState.isLoggedIn) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryMint.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.cloud_done_rounded,
                                  color: AppTheme.primaryMint,
                                  size: 13,
                                ),
                                const Gap(4),
                                Text(
                                  isBn ? 'সিঙ্কড' : 'Synced',
                                  style: const TextStyle(
                                    color: AppTheme.primaryMint,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Gap(12),

                  // ── 2. Personal Spiritual Progress Grid (4 metrics) ──
                  Row(
                    children: [
                      // Streak Metric
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: const Color(0xFFFF9800),
                          title: isBn ? 'ধারাবাহিকতা' : 'Streak',
                          value: isBn
                              ? '${hadithState.currentStreak} দিন'
                              : '${hadithState.currentStreak} Days',
                          subvalue: isBn
                              ? 'সেরা: ${hadithState.longestStreak} দিন'
                              : 'Best: ${hadithState.longestStreak}d',
                          cardBgColor: cardBgColor,
                          borderDividerColor: borderDividerColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                      const Gap(8),
                      // Daily Goal Metric
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.adjust_rounded,
                          iconColor: AppTheme.primaryMint,
                          title: isBn ? 'দৈনিক লক্ষ্য' : 'Daily Goal',
                          value: '$readToday / $dailyGoal',
                          subvalue: readToday >= dailyGoal
                              ? (isBn ? '✓ সম্পন্ন' : '✓ Completed')
                              : (isBn ? '${dailyGoal - readToday}টি বাকি' : '${dailyGoal - readToday} left'),
                          cardBgColor: cardBgColor,
                          borderDividerColor: borderDividerColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      // Reading Time Metric
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.timer_outlined,
                          iconColor: const Color(0xFF6366F1),
                          title: isBn ? 'পড়ার সময়' : 'Reading Time',
                          value: isBn ? '$readingMins মিনিট' : '$readingMins min',
                          subvalue: isBn
                              ? '${hadithState.readingSessions.length}টি সেশন'
                              : '${hadithState.readingSessions.length} sessions',
                          cardBgColor: cardBgColor,
                          borderDividerColor: borderDividerColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                      const Gap(8),
                      // Hadiths Read Metric
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.menu_book_rounded,
                          iconColor: const Color(0xFF0EA5E9),
                          title: isBn ? 'পঠিত হাদিস' : 'Hadiths Read',
                          value: isBn
                              ? '${hadithState.readHistory.length}টি'
                              : '${hadithState.readHistory.length}',
                          subvalue: isBn
                              ? '${hadithState.bookmarkedRefs.length} বুকমার্ক'
                              : '${hadithState.bookmarkedRefs.length} saved',
                          cardBgColor: cardBgColor,
                          borderDividerColor: borderDividerColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const Gap(14),

                  // ── 3. Cloud Backup & Authentication Section ──
                  if (authState.isLoggedIn) ...[
                    // Logged In Cloud Sync Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderDividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryMint.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: authState.isSyncing
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: AppTheme.primaryMint,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.cloud_sync_rounded,
                                        color: AppTheme.primaryMint,
                                        size: 18,
                                      ),
                              ),
                              const Gap(10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authState.isSyncing
                                          ? (isBn ? 'ক্লাউড সিঙ্ক হচ্ছে...' : 'Syncing...')
                                          : (isBn ? 'ক্লাউড ব্যাকআপ ও সিঙ্ক' : 'Cloud Backup & Sync'),
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text(
                                      isBn
                                          ? 'সর্বশেষ সিঙ্ক: ${_formatTime(authState.lastSyncTime, appLanguage)}'
                                          : 'Last synced: ${_formatTime(authState.lastSyncTime, appLanguage)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: authState.isSyncing
                                    ? null
                                    : () => context.read<AuthCubit>().syncNow(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  isBn ? 'সিঙ্ক করুন' : 'Sync Now',
                                  style: const TextStyle(
                                    color: AppTheme.primaryMint,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(10),
                          Divider(color: borderDividerColor, height: 1),
                          const Gap(8),
                          // Auto Sync Switch Row
                          Row(
                            children: [
                              Text(
                                isBn ? 'স্বয়ংক্রিয় সিঙ্ক' : 'Auto-Sync',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: settingsState.autoSyncEnabled,
                                onChanged: (val) {
                                  context.read<SettingsCubit>().setAutoSyncEnabled(val);
                                },
                                activeThumbColor: AppTheme.primaryMint,
                                activeTrackColor: AppTheme.primaryMint.withValues(alpha: 0.3),
                                inactiveThumbColor: textSecondary,
                                inactiveTrackColor: borderDividerColor,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Offline / Guest Cloud Backup Promo & Sign-In Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderDividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryMint.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: AppTheme.primaryMint,
                                  size: 18,
                                ),
                              ),
                              const Gap(10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isBn ? 'ক্লাউড ব্যাকআপ সক্রিয় করুন' : 'Enable Cloud Backup',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text(
                                      isBn
                                          ? 'বুকমার্ক ও পড়ার অগ্রগতি অনলাইনে সুরক্ষিত রাখুন'
                                          : 'Secure your bookmarks & history across devices',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(12),
                          // 1-Tap Google Sign-In
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: authState.status == AuthStatus.loading
                                  ? null
                                  : () => context.read<AuthCubit>().signInWithGoogle(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: borderDividerColor),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: SvgPicture.asset(
                                'assets/img/google-color-svgrepo-com.svg',
                                height: 16,
                                width: 16,
                                placeholderBuilder: (context) => const Icon(
                                  Icons.login_rounded,
                                  color: AppTheme.primaryMint,
                                  size: 16,
                                ),
                              ),
                              label: Text(
                                AppLocalization.get('continue_with_google', appLanguage),
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const Gap(8),
                          // Toggle Email Sign-in expander
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isEmailFormExpanded = !_isEmailFormExpanded;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: Icon(
                                _isEmailFormExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.mail_outline_rounded,
                                size: 14,
                                color: textSecondary,
                              ),
                              label: Text(
                                _isEmailFormExpanded
                                    ? (isBn ? 'ইমেইল ফরম লুকান' : 'Hide Email Form')
                                    : (isBn ? 'বা ইমেইল দিয়ে সাইন ইন করুন' : 'Or Sign in with Email'),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          ),
                          // Collapsible Email Form
                          if (_isEmailFormExpanded) ...[
                            const Gap(10),
                            _buildCompactTextField(
                              controller: _emailController,
                              hint: AppLocalization.get('email_address', appLanguage),
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              isDark: isDark,
                              borderDividerColor: borderDividerColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                            const Gap(8),
                            _buildCompactTextField(
                              controller: _passwordController,
                              hint: AppLocalization.get('password_field', appLanguage),
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              isDark: isDark,
                              borderDividerColor: borderDividerColor,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: textSecondary,
                                  size: 16,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            const Gap(10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryMint,
                                  foregroundColor: isDark ? AppTheme.darkCanvas : Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
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
                                child: Text(
                                  _isRegisterMode
                                      ? AppLocalization.get('create_account', appLanguage)
                                      : AppLocalization.get('sign_in', appLanguage),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ),
                            const Gap(6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isRegisterMode
                                      ? AppLocalization.get('toggle_already_have_account', appLanguage)
                                      : AppLocalization.get('toggle_no_account', appLanguage),
                                  style: TextStyle(color: textSecondary, fontSize: 11.5),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _isRegisterMode = !_isRegisterMode),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    _isRegisterMode
                                        ? AppLocalization.get('sign_in', appLanguage)
                                        : AppLocalization.get('register', appLanguage),
                                    style: const TextStyle(
                                      color: AppTheme.primaryMint,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const Gap(14),

                  // ── 4. Quick Customization & Preferences ──
                  Container(
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderDividerColor),
                    ),
                    child: Column(
                      children: [
                        // App Language Setting
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                          dense: true,
                          leading: const Icon(Icons.language_rounded, color: AppTheme.primaryMint, size: 18),
                          title: Text(
                            isBn ? 'অ্যাপের ভাষা' : 'App Language',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                appLanguage == 'bng'
                                    ? 'বাংলা'
                                    : appLanguage == 'ara'
                                        ? 'العربية'
                                        : 'English',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryMint,
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
                            ],
                          ),
                          onTap: () => _showLanguageDialog(context, appLanguage),
                        ),
                        Divider(color: borderDividerColor, height: 1),

                        // Theme Mode Setting
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                          dense: true,
                          leading: Icon(
                            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            color: AppTheme.primaryMint,
                            size: 18,
                          ),
                          title: Text(
                            isBn ? 'থিম মুড' : 'Theme Mode',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                settingsState.themeMode == 'dark'
                                    ? (isBn ? 'ডার্ক' : 'Dark')
                                    : settingsState.themeMode == 'light'
                                        ? (isBn ? 'লাইট' : 'Light')
                                        : (isBn ? 'সিস্টেম' : 'System'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryMint,
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
                            ],
                          ),
                          onTap: () {
                            // Cycle theme
                            final next = settingsState.themeMode == 'dark'
                                ? 'light'
                                : settingsState.themeMode == 'light'
                                    ? 'system'
                                    : 'dark';
                            context.read<SettingsCubit>().setThemeMode(next);
                          },
                        ),
                        Divider(color: borderDividerColor, height: 1),

                        // Daily Goal Setting
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                          dense: true,
                          leading: const Icon(Icons.flag_outlined, color: AppTheme.primaryMint, size: 18),
                          title: Text(
                            isBn ? 'দৈনিক পড়ার লক্ষ্য' : 'Daily Reading Goal',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [1, 3, 5, 10].map((goalOption) {
                              final isSelected = goalOption == hadithState.dailyGoal;
                              return GestureDetector(
                                onTap: () => context.read<HadithCubit>().updateDailyGoal(goalOption),
                                child: Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryMint
                                        : borderDividerColor.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$goalOption',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? (isDark ? AppTheme.darkCanvas : Colors.white)
                                          : textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Divider(color: borderDividerColor, height: 1),

                        // Full Settings Link
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                          dense: true,
                          leading: const Icon(Icons.settings_outlined, color: AppTheme.primaryMint, size: 18),
                          title: Text(
                            isBn ? 'সমস্ত সেটিংস' : 'All Settings',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
                          onTap: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),

                  // ── 5. Account Actions (Sign Out / Delete) ──
                  if (authState.isLoggedIn) ...[
                    const Gap(14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent, width: 0.8),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 15),
                            label: Text(
                              AppLocalization.get('sign_out', appLanguage),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: cardBgColor,
                                  title: Text(
                                    AppLocalization.get('sign_out', appLanguage),
                                    style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
                                  ),
                                  content: Text(
                                    AppLocalization.get('sign_out_desc', appLanguage),
                                    style: TextStyle(color: textSecondary),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text(AppLocalization.get('cancel', appLanguage)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(AppLocalization.get('sign_out', appLanguage)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true && context.mounted) {
                                await context.read<AuthCubit>().signOut();
                              }
                            },
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                              ),
                            ),
                            icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 15),
                            label: Text(
                              AppLocalization.get('delete_account_title', appLanguage),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: cardBgColor,
                                  title: Text(
                                    AppLocalization.get('delete_account_title', appLanguage),
                                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                  ),
                                  content: Text(
                                    AppLocalization.get('delete_account_desc', appLanguage),
                                    style: TextStyle(color: textSecondary),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text(AppLocalization.get('cancel', appLanguage)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(AppLocalization.get('delete_forever', appLanguage)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true && context.mounted) {
                                await context.read<AuthCubit>().deleteAccountAndData();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Gap(16),

                  // ── 6. App Version & Credits Footer ──
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Al Hadith • v1.0.0 (Build 1)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                        const Gap(2),
                        Text(
                          isBn
                              ? 'সম্পূর্ণ অফলাইন হাদিস অ্যাপ • ফিসাবিলিল্লাহ'
                              : 'Offline Hadith Study App • Open Source',
                          style: TextStyle(
                            fontSize: 10,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subvalue,
    required Color cardBgColor,
    required Color borderDividerColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderDividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(1),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    required bool isDark,
    required Color borderDividerColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderDividerColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: textSecondary.withValues(alpha: 0.7),
            fontSize: 12,
          ),
          prefixIcon: Icon(icon, color: textSecondary, size: 16),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}

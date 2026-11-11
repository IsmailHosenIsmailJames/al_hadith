import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';
import 'package:al_hadith/presentation/widgets/hadiths_dashboard_view.dart';
import 'package:al_hadith/presentation/widgets/hadith_sections_view.dart';
import 'package:al_hadith/presentation/widgets/hadith_collections_view.dart';
import 'package:al_hadith/presentation/screens/profile_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final List<Widget> views = [
      const HadithsDashboardView(),
      const HadithSectionsView(),
      const HadithCollectionsView(),
      const ProfileScreen(),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final navIndicatorColor = isDark
        ? AppTheme.darkSurfaceCard
        : const Color(0xFFF3F4F6);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth >= AppTheme.wideWidth;

    return Scaffold(
      appBar: isWideScreen
          ? null
          : AppBar(
              toolbarHeight: 52,
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: AppTheme.primaryMint, size: 22),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
              title: Text(
                'Al Hadith',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.5,
                  letterSpacing: -0.3,
                ),
              ).animate().fadeIn(duration: 500.ms),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.primaryMint, size: 22),
                  onPressed: () {
                    context.push('/search');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings_outlined, color: textSecondary, size: 22),
                  onPressed: () {
                    context.push('/settings');
                  },
                ),
                const Gap(4),
              ],
            ),
      drawer: _buildDrawer(context, isWideScreen),
      body: Row(
        children: [
          if (isWideScreen)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: borderDividerColor, width: 1.5),
                ),
              ),
              child: NavigationRail(
                indicatorColor: navIndicatorColor,
                selectedIndex: _currentIndex,
                scrollable: true,
                minWidth: 120,
                onDestinationSelected: (index) =>
                    setState(() => _currentIndex = index),
                backgroundColor: surfaceColor,
                extended: screenWidth >= 1100,
                minExtendedWidth: 300,
                selectedIconTheme: const IconThemeData(
                  color: AppTheme.primaryMint,
                  size: 28,
                ),
                unselectedIconTheme: IconThemeData(
                  color: textSecondary,
                  size: 24,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: AppTheme.primaryMint,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
                labelType: screenWidth >= 1100
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                leading: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth >= 1100 ? 260 : 72,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Builder(
                              builder: (context) {
                                return IconButton(
                                  onPressed: () =>
                                      Scaffold.of(context).openDrawer(),
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryMint.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.menu_open_rounded,
                                      color: AppTheme.primaryMint,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (screenWidth >= 1100)
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      color: AppTheme.primaryMint,
                                    ),
                                    onPressed: () {
                                      context.push('/search');
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.settings_outlined,
                                      color: textSecondary,
                                    ),
                                    onPressed: () {
                                      context.push('/settings');
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (screenWidth >= 1100) ...[
                        const Gap(24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child:
                              Text(
                                    'Al Hadith',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .scale(delay: 100.ms),
                        ),
                        const Gap(32),
                      ] else
                        const Gap(24),
                    ],
                  ),
                ),
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.book_outlined),
                    selectedIcon: const Icon(Icons.book),
                    label: Text(
                      AppLocalization.getTabName('hadiths', appLanguage),
                    ),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.grid_view_outlined),
                    selectedIcon: const Icon(Icons.grid_view),
                    label: Text(
                      AppLocalization.getTabName('chapters', appLanguage),
                    ),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.bookmark_outline),
                    selectedIcon: const Icon(Icons.bookmark),
                    label: Text(
                      AppLocalization.getTabName('collections', appLanguage),
                    ),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person),
                    label: Text(
                      AppLocalization.getTabName('profile', appLanguage),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: 300.ms,
              child: views[_currentIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: borderDividerColor.withValues(alpha: 0.8),
                    width: 0.8,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                backgroundColor: surfaceColor,
                selectedItemColor: AppTheme.primaryMint,
                unselectedItemColor: textSecondary,
                type: BottomNavigationBarType.fixed,
                iconSize: 22,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                elevation: 0,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.menu_book_outlined),
                    activeIcon: const Icon(
                      Icons.menu_book_rounded,
                      color: AppTheme.primaryMint,
                    ),
                    label: AppLocalization.getTabName('hadiths', appLanguage),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.grid_view_outlined),
                    activeIcon: const Icon(
                      Icons.grid_view_rounded,
                      color: AppTheme.primaryMint,
                    ),
                    label: AppLocalization.getTabName('chapters', appLanguage),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.bookmark_outline_rounded),
                    activeIcon: const Icon(
                      Icons.bookmark_rounded,
                      color: AppTheme.primaryMint,
                    ),
                    label: AppLocalization.getTabName(
                      'collections',
                      appLanguage,
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline_rounded),
                    activeIcon: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.primaryMint,
                    ),
                    label: AppLocalization.getTabName('profile', appLanguage),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalization.get('error', context.read<SettingsCubit>().state.appLanguage)}: ${e.toString()}',
            ),
          ),
        );
      }
    }
  }

  void _showAboutDialog(String appLanguage) {
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final surfaceColor = Theme.of(context).colorScheme.surface;

    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppTheme.wideWidth),
          child: AlertDialog(
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: borderDividerColor, width: 1.5),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.primaryMint,
                    size: 24,
                  ),
                ),
                const Gap(12),
                Text(
                  AppLocalization.get('about_app', appLanguage),
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalization.get('about_app_desc', appLanguage),
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  AppLocalization.getTabName('close', appLanguage),
                  style: const TextStyle(
                    color: AppTheme.primaryMint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildDrawer(BuildContext context, bool isWideScreen) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final themeMode = context.watch<SettingsCubit>().state.themeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    final hadithState = context.watch<HadithCubit>().state;
    final booksCount = hadithState.downloadedBooks.length;
    final readToday = _getHadithsReadTodayCount(hadithState);
    final dailyGoal = hadithState.dailyGoal;
    final streak = hadithState.currentStreak;

    return Drawer(
      backgroundColor: canvasColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: borderDividerColor, width: 1.2),
          ),
        ),
        child: Column(
          children: [
            // Brand Hero Header
            Container(
              padding: EdgeInsets.fromLTRB(
                18,
                MediaQuery.of(context).padding.top + 16,
                18,
                16,
              ),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  bottom: BorderSide(color: borderDividerColor, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryMint.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              'assets/img/logo.png',
                              height: 44,
                              width: 44,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.auto_stories_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Al Hadith',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const Spacer(),
                                FutureBuilder<PackageInfo>(
                                  future: PackageInfo.fromPlatform(),
                                  builder: (context, snapshot) {
                                    final version =
                                        snapshot.data?.version ?? '1.0.0';
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: borderDividerColor,
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        'v$version',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: textSecondary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Gap(2),
                            const Text(
                              'الحديث النبوي الشريف • Offline Study',
                              style: TextStyle(
                                color: AppTheme.primaryMint,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(14),
                  // Spiritual Streak & Goal Capsule Pill
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/stats');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: streak > 0
                                ? Colors.orangeAccent
                                : textSecondary,
                            size: 16,
                          ),
                          const Gap(5),
                          Text(
                            '${streak}d Streak',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppTheme.primaryMint,
                            size: 15,
                          ),
                          const Gap(5),
                          Text(
                            '$readToday/$dailyGoal Daily Goal',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: textSecondary.withValues(alpha: 0.5),
                            size: 11,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Menu Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerSectionHeader('LIBRARY & STUDY'),
                  _buildDrawerItem(
                    context,
                    icon: Icons.auto_stories_rounded,
                    title: AppLocalization.getTabName(
                      'manage_resources',
                      appLanguage,
                    ),
                    subtitle: 'Download, update & offline files',
                    badge: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$booksCount Books',
                        style: const TextStyle(
                          color: AppTheme.primaryMint,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/resources');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.insights_rounded,
                    title: 'Reading Analytics',
                    subtitle: 'Streaks, insights & progress',
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: textSecondary.withValues(alpha: 0.5),
                      size: 12,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/stats');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_suggest_rounded,
                    title: 'Settings & Studio',
                    subtitle: 'Fonts, reading modes & storage',
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: textSecondary.withValues(alpha: 0.5),
                      size: 12,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  const Gap(8),
                  _buildDrawerSectionHeader('QUICK APPEARANCE'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderDividerColor),
                      ),
                      child: Row(
                        children: [
                          _buildThemeModePill(
                            context: context,
                            title: 'Light',
                            icon: Icons.light_mode_rounded,
                            isActive: themeMode == 'light',
                            onTap: () => context
                                .read<SettingsCubit>()
                                .setThemeMode('light'),
                          ),
                          _buildThemeModePill(
                            context: context,
                            title: 'Dark',
                            icon: Icons.dark_mode_rounded,
                            isActive: themeMode == 'dark',
                            onTap: () => context
                                .read<SettingsCubit>()
                                .setThemeMode('dark'),
                          ),
                          _buildThemeModePill(
                            context: context,
                            title: 'System',
                            icon: Icons.brightness_auto_rounded,
                            isActive: themeMode == 'system',
                            onTap: () => context
                                .read<SettingsCubit>()
                                .setThemeMode('system'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(8),
                  _buildDrawerSectionHeader('COMMUNITY & SUPPORT'),
                  _buildDrawerItem(
                    context,
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber,
                    title: AppLocalization.get('star_on_github', appLanguage),
                    subtitle: 'Star and contribute on GitHub',
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      color: textSecondary.withValues(alpha: 0.5),
                      size: 14,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(
                        'https://github.com/IsmailHosenIsmailJames/al_hadith',
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.bug_report_outlined,
                    title: AppLocalization.getTabName(
                      'send_bug_report',
                      appLanguage,
                    ),
                    subtitle: 'Report issues or suggest features',
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      color: textSecondary.withValues(alpha: 0.5),
                      size: 14,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(
                        'https://github.com/IsmailHosenIsmailJames/al_hadith/issues',
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.dataset_outlined,
                    title: AppLocalization.getTabName(
                      'dataset_feedback',
                      appLanguage,
                    ),
                    subtitle: 'Hadith API dataset sources',
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      color: textSecondary.withValues(alpha: 0.5),
                      size: 14,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl('https://github.com/fawazahmed0/hadith-api');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.thumb_up_alt_outlined,
                    title: AppLocalization.getTabName('rate_app', appLanguage),
                    subtitle: 'Share your feedback on Google Play',
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      color: textSecondary.withValues(alpha: 0.5),
                      size: 14,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(
                        'https://play.google.com/store/apps/details?id=com.ismail.al_hadith',
                      );
                    },
                  ),
                  const Gap(8),
                  _buildDrawerSectionHeader('ABOUT & LEGAL'),
                  _buildDrawerItem(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: AppLocalization.getTabName(
                      'about_app_drawer',
                      appLanguage,
                    ),
                    subtitle: 'App details, license & mission',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(appLanguage);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.shield_outlined,
                    title: AppLocalization.getTabName(
                      'privacy_policy',
                      appLanguage,
                    ),
                    subtitle: 'Data protection and usage terms',
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      color: textSecondary.withValues(alpha: 0.5),
                      size: 14,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(
                        'https://ismailhosenismailjames.github.io/compressed_hadith_sqlite/privacy.html',
                      );
                    },
                  ),
                ],
              ),
            ),
            // Sleek Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  top: BorderSide(color: borderDividerColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.primaryMint,
                    size: 14,
                  ),
                  const Gap(8),
                  Text(
                    'Built for the Ummah • Free & Open Source',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: AppTheme.primaryMint.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    Widget? badge,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final iconBgColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor ?? AppTheme.primaryMint,
                  size: 18,
                ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: textPrimary,
                    ),
                  ),
                  const Gap(1.5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (badge != null) ...[
              const Gap(8),
              badge,
            ] else if (trailing != null) ...[
              const Gap(8),
              trailing,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModePill({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryMint : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? AppTheme.darkCanvas : textSecondary,
              ),
              const Gap(4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? AppTheme.darkCanvas : textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

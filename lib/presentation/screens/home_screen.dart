import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
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
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: AppTheme.primaryMint),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
              title: Text(
                'Al Hadith',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 600.ms).scale(delay: 100.ms),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.primaryMint),
                  onPressed: () {
                    context.push('/search');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings_outlined, color: textSecondary),
                  onPressed: () {
                    context.push('/settings');
                  },
                ),
                const Gap(8),
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
                  top: BorderSide(color: borderDividerColor, width: 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
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
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                elevation: 0,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.book_outlined),
                    activeIcon: const Icon(
                      Icons.book,
                      color: AppTheme.primaryMint,
                    ),
                    label: AppLocalization.getTabName('hadiths', appLanguage),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.grid_view_outlined),
                    activeIcon: const Icon(
                      Icons.grid_view,
                      color: AppTheme.primaryMint,
                    ),
                    label: AppLocalization.getTabName('chapters', appLanguage),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.bookmark_outline),
                    activeIcon: const Icon(
                      Icons.bookmark,
                      color: AppTheme.primaryMint,
                    ),
                    label: AppLocalization.getTabName(
                      'collections',
                      appLanguage,
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_outline),
                    activeIcon: const Icon(
                      Icons.person,
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

  Widget _buildDrawer(BuildContext context, bool isWideScreen) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
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

    return Drawer(
      backgroundColor: canvasColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: borderDividerColor, width: 1.5),
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border(
                      bottom: BorderSide(color: borderDividerColor, width: 1.5),
                    ),
                  ),
                  currentAccountPicture: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          'assets/img/logo.png',
                          height: 100,
                          width: 100,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.book,
                                color: Colors.white,
                                size: 40,
                              ),
                        ),
                      ),
                    ),
                  ),
                  accountName: Text(
                    'Al Hadith',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: textPrimary,
                    ),
                  ),
                  accountEmail: Text(
                    AppLocalization.get('drawer_tagline', appLanguage),
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ),
                Container(
                  alignment: const Alignment(1, -0.6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              'Version ${snapshot.data!.version}',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      if (isWideScreen) const Gap(16),
                      if (isWideScreen)
                        IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: AppTheme.primaryMint,
                          ),
                          onPressed: () {
                            context.push('/search');
                          },
                        ),
                      if (isWideScreen)
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
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.library_books,
                    title: AppLocalization.getTabName(
                      'manage_resources',
                      appLanguage,
                    ),
                    subtitle: AppLocalization.getTabName(
                      'manage_resources_desc',
                      appLanguage,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/resources');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.bug_report_outlined,
                    title: AppLocalization.getTabName(
                      'send_bug_report',
                      appLanguage,
                    ),
                    subtitle: AppLocalization.getTabName(
                      'send_bug_report_desc',
                      appLanguage,
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
                    icon: Icons.feedback_outlined,
                    title: AppLocalization.getTabName(
                      'dataset_feedback',
                      appLanguage,
                    ),
                    subtitle: AppLocalization.getTabName(
                      'dataset_feedback_desc',
                      appLanguage,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl('https://github.com/fawazahmed0/hadith-api');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.star_rate_outlined,
                    title: AppLocalization.getTabName('rate_app', appLanguage),
                    subtitle: AppLocalization.getTabName(
                      'rate_app_desc',
                      appLanguage,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(
                        'https://play.google.com/store/apps/details?id=com.ismail.al_hadith',
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.star_border,
                    title: AppLocalization.get('star_on_github', appLanguage),
                    subtitle: AppLocalization.get(
                      'show_support_github',
                      appLanguage,
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
                    icon: Icons.privacy_tip_outlined,
                    title: AppLocalization.getTabName(
                      'privacy_policy',
                      appLanguage,
                    ),
                    subtitle: AppLocalization.getTabName(
                      'privacy_policy_desc',
                      appLanguage,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(
                        'https://ismailhosenismailjames.github.io/compressed_hadith_sqlite/privacy.html',
                      );
                    },
                  ),
                  Divider(color: borderDividerColor, thickness: 1),
                  _buildDrawerItem(
                    context,
                    icon: Icons.info_outline,
                    title: AppLocalization.getTabName(
                      'about_app_drawer',
                      appLanguage,
                    ),
                    subtitle: AppLocalization.getTabName(
                      'about_app_drawer_desc',
                      appLanguage,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(appLanguage);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;

    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryMint, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: textSecondary, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}

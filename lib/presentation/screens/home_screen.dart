import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
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
    final List<Widget> views = [
      const HadithsDashboardView(),
      const HadithSectionsView(),
      const HadithCollectionsView(),
      const ProfileScreen(),
    ];

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
              title: const Text(
                'Al Hadith',
              ).animate().fadeIn(duration: 600.ms).scale(delay: 100.ms),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.primaryMint),
                  onPressed: () {
                    context.push('/search');
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppTheme.textSecondary,
                  ),
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
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: Color(0xFF1E293B), width: 1.5),
                ),
              ),
              child: NavigationRail(
                indicatorColor: AppTheme.darkSurfaceCard,
                selectedIndex: _currentIndex,
                scrollable: true,

                minWidth: 120,
                onDestinationSelected: (index) =>
                    setState(() => _currentIndex = index),
                backgroundColor: AppTheme.darkSurface,
                extended: screenWidth >= 1100,
                minExtendedWidth: 300,
                selectedIconTheme: const IconThemeData(
                  color: AppTheme.primaryMint,
                  size: 28,
                ),
                unselectedIconTheme: const IconThemeData(
                  color: AppTheme.textSecondary,
                  size: 24,
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: AppTheme.primaryMint,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: AppTheme.textSecondary,
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
                                    icon: const Icon(
                                      Icons.settings_outlined,
                                      color: AppTheme.textSecondary,
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
                              const Text(
                                    'Al Hadith',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
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
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.book_outlined),
                    selectedIcon: Icon(Icons.book),
                    label: Text('Hadiths'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.grid_view_outlined),
                    selectedIcon: Icon(Icons.grid_view),
                    label: Text('Chapters'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bookmark_outline),
                    selectedIcon: Icon(Icons.bookmark),
                    label: Text('Collections'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Profile'),
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
                border: const Border(
                  top: BorderSide(color: Color(0xFF1E293B), width: 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                backgroundColor: AppTheme.darkSurface,
                selectedItemColor: AppTheme.primaryMint,
                unselectedItemColor: AppTheme.textSecondary,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.book_outlined),
                    activeIcon: Icon(Icons.book, color: AppTheme.primaryMint),
                    label: 'Hadiths',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view_outlined),
                    activeIcon: Icon(
                      Icons.grid_view,
                      color: AppTheme.primaryMint,
                    ),
                    label: 'Chapters',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark_outline),
                    activeIcon: Icon(
                      Icons.bookmark,
                      color: AppTheme.primaryMint,
                    ),
                    label: 'Collections',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person, color: AppTheme.primaryMint),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
    );
  }

  // Bottom Navigation view builders

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E293B), width: 1.5),
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
            const Text(
              'About Al Hadith',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Al Hadith is a premium, fully offline reader powered by optimized local SQLite databases. It features state-of-the-art Custom Arabic Fonts, customizable sizes, real-time query filtering, and automated bookmarking/progress tracking.',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            Gap(12),
            Text(
              'Hadith Resources:',
              style: TextStyle(
                color: AppTheme.primaryMint,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(4),
            Text(
              'Fetched remotely and cached locally from fawazahmed0\'s open-source database repository. Under MIT License.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            Gap(12),
            Text(
              'Built With:',
              style: TextStyle(
                color: AppTheme.primaryMint,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(4),
            Text(
              'Flutter, Bloc Pattern, sqflite, path_provider, and Google Outfit fonts.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(
                color: AppTheme.primaryMint,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Drawer builder
  Widget _buildDrawer(BuildContext context, bool isWideScreen) {
    return Drawer(
      backgroundColor: AppTheme.darkCanvas,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: Color(0xFF1E293B), width: 1.5),
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppTheme.darkSurface,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5),
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
                        ),
                      ),
                    ),
                  ),
                  accountName: Text(
                    'Al Hadith',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  accountEmail: const Text(
                    'Read, search & study authentic Hadith offline with multilingual support & sync',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment(1, 1),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FutureBuilder(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              'Version ${snapshot.data!.version}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      if (isWideScreen) Gap(16),
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
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: AppTheme.textSecondary,
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
                    icon: Icons.library_books,
                    title: 'Manage Resources',
                    subtitle: 'Download, delete & update books',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/resources');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.bug_report_outlined,
                    title: 'Send Bug Report',
                    subtitle: 'Report app issues on GitHub',
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(
                        'https://github.com/IsmailHosenIsmailJames/al_hadith/issues',
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.feedback_outlined,
                    title: 'Hadith Dataset Feedback',
                    subtitle: 'Submit database edits to API owner',
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl('https://github.com/fawazahmed0/hadith-api');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.star_rate_outlined,
                    title: 'Rate App',
                    subtitle: 'Give us 5 stars on Play Store',
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(
                        'https://play.google.com/store/apps/details?id=com.ismail.al_hadith',
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.star_border,
                    title: 'Star on GitHub',
                    subtitle: 'Show support to open-source repository',
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(
                        'https://github.com/IsmailHosenIsmailJames/al_hadith',
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our Google Play data policies',
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(
                        'https://ismailhosenismailjames.github.io/compressed_hadith_sqlite/privacy.html',
                      );
                    },
                  ),
                  const Divider(color: Color(0xFF1E293B), thickness: 1),
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: 'About App',
                    subtitle: 'Details about API and compilers',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog();
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryMint, size: 24),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}

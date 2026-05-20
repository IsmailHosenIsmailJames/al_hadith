import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/presentation/widgets/hadiths_dashboard_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const HadithsDashboardView(),
    _buildSectionsView(),
    _buildCollectionsView(),
    _buildProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Al Hadith')
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(delay: 100.ms),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primaryMint),
            onPressed: () {
              // Search action placeholder
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
            onPressed: () {
              // Settings action placeholder
            },
          ),
          const Gap(8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: AnimatedSwitcher(
        duration: 300.ms,
        child: _views[_currentIndex],
      ),
      bottomNavigationBar: Container(
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
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book, color: AppTheme.primaryMint),
              label: 'Hadiths',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view, color: AppTheme.primaryMint),
              label: 'Sections',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark, color: AppTheme.primaryMint),
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

  static Widget _buildSectionsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.grid_view, size: 64, color: AppTheme.primaryMint),
          const Gap(16),
          const Text('Hadiths Sections', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Gap(8),
          const Text('Grouped sections from all books.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0.0),
    );
  }

  static Widget _buildCollectionsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark, size: 64, color: AppTheme.primaryMint),
          const Gap(16),
          const Text('Collections', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Gap(8),
          const Text('Bookmarks, Pin, & Notes tabs.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0.0),
    );
  }

  static Widget _buildProfileView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 64, color: AppTheme.primaryMint),
          const Gap(16),
          const Text('User Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Gap(8),
          const Text('Sync your progress & backup collections.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0.0),
    );
  }

  // Drawer builder
  Widget _buildDrawer(BuildContext context) {
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
                child: const Center(
                  child: Icon(Icons.menu_book, size: 36, color: AppTheme.darkCanvas),
                ),
              ),
              accountName: const Text(
                'Al Hadith App',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: const Text(
                'Offline SQLite-based Hadith Reader',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.library_books,
                    title: 'Manage Resources',
                    subtitle: 'Download, delete & update books',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.bug_report_outlined,
                    title: 'Send Bug Report',
                    subtitle: 'Report app issues on GitHub',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.feedback_outlined,
                    title: 'Hadith Dataset Feedback',
                    subtitle: 'Submit database edits to API owner',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.star_rate_outlined,
                    title: 'Rate App',
                    subtitle: 'Give us 5 stars on Play Store',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    icon: Icons.star_border,
                    title: 'Star on GitHub',
                    subtitle: 'Show support to open-source repository',
                    onTap: () {},
                  ),
                  const Divider(color: Color(0xFF1E293B), thickness: 1),
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: 'About App',
                    subtitle: 'Details about API and compilers',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Version 1.0.0 (Beta)',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      onTap: onTap,
    );
  }
}

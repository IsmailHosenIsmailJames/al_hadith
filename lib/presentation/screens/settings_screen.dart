import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/logic/settings/settings_state.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import 'package:al_hadith/data/models/resource_model.dart';
import 'package:al_hadith/data/services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, String>> arabicFonts = [
    {'key': 'Me Quran', 'display': 'Me Quran'},
    {'key': 'QPC Hafs', 'display': 'QPC Hafs'},
    {'key': 'Indopak Nastaleeq', 'display': 'Indopak Nastaleeq'},
    {'key': 'Amiri', 'display': 'Amiri'},
    {'key': 'Noto Naskh Arabic', 'display': 'Noto Naskh'},
  ];

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _viewMode;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<PreferencesService>();
    _viewMode = prefs.getHadithViewMode();
  }

  void _showLanguageDialog(BuildContext context, String currentLang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;

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
              'Select App Language',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const Gap(12),
            ...HadithLanguage.languageMetadata.entries.map((entry) {
              final code = entry.key;
              final meta = entry.value;
              final isSelected = code == currentLang;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Text(meta['flag'] ?? '🌐', style: const TextStyle(fontSize: 20)),
                title: Text(
                  meta['native'] ?? code,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryMint : textPrimary,
                  ),
                ),
                subtitle: meta['native'] != meta['display']
                    ? Text(meta['display'] ?? '', style: const TextStyle(fontSize: 11.5))
                    : null,
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryMint)
                    : null,
                onTap: () {
                  context.read<SettingsCubit>().setAppLanguage(code, explicit: true);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _exportCollections(BuildContext context, HadithState hadithState, String appLanguage) {
    final isBn = appLanguage == 'bng';
    final sb = StringBuffer();
    sb.writeln('=== Al Hadith Study Export ===\n');

    sb.writeln('--- Bookmarks (${hadithState.bookmarkedRefs.length}) ---');
    for (final ref in hadithState.bookmarkedRefs) {
      final h = hadithState.collectionsHadiths[ref];
      sb.writeln('[$ref] ${h?.text ?? ''}\n');
    }

    sb.writeln('\n--- Pinned Hadiths (${hadithState.pinnedRefs.length}) ---');
    for (final ref in hadithState.pinnedRefs) {
      final h = hadithState.collectionsHadiths[ref];
      sb.writeln('[$ref] ${h?.text ?? ''}\n');
    }

    sb.writeln('\n--- Study Notes (${hadithState.hadithNotes.length}) ---');
    hadithState.hadithNotes.forEach((ref, note) {
      sb.writeln('[$ref Note]: $note');
    });

    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBn
              ? 'সমস্ত বুকমার্ক ও নোট ক্লিপবোর্ডে কপি করা হয়েছে!'
              : 'All bookmarks and notes copied to clipboard!',
        ),
        backgroundColor: AppTheme.primaryMint,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context, String appLanguage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final isBn = appLanguage == 'bng';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isBn ? 'সেটিংস রিসেট করবেন?' : 'Reset All Settings?',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          isBn
              ? 'ফন্ট সাইজ, স্ক্রিপ্ট, রিডিং মোড এবং টাইমার ডিফল্ট মানে ফিরে যাবে। আপনার ডাউনলোড করা বই বা বুকমার্ক মোছা হবে না।'
              : 'Font sizes, script, reading view, and timers will be restored to defaults. Your downloaded books and bookmarks will remain safe.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SettingsCubit>().resetToDefaults();
              setState(() {
                _viewMode = 'page';
              });
              context.read<PreferencesService>().setHadithViewMode('page');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBn ? 'সেটিংস সফলভাবে রিসেট হয়েছে' : 'Settings restored to defaults',
                  ),
                  backgroundColor: AppTheme.primaryMint,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              isBn ? 'রিসেট' : 'Reset',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primaryMint,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildCardGroup({
    required List<Widget> children,
    required bool isDark,
    required Color cardBgColor,
    required Color borderDividerColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderDividerColor),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return BlocBuilder<HadithCubit, HadithState>(
          builder: (context, hadithState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final canvasColor = Theme.of(context).scaffoldBackgroundColor;
            final surfaceColor = Theme.of(context).colorScheme.surface;
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
            final appLanguage = state.appLanguage;
            final isBn = appLanguage == 'bng';

            // Calculate offline books total storage size
            int totalBytes = 0;
            for (final b in hadithState.downloadedBooks) {
              totalBytes += b.fileSize;
            }
            final totalMb = (totalBytes / (1024 * 1024)).toStringAsFixed(1);

            return Scaffold(
              backgroundColor: canvasColor,
              appBar: AppBar(
                backgroundColor: surfaceColor,
                elevation: 0,
                toolbarHeight: 52,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 22),
                  color: textPrimary,
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  AppLocalization.get('settings', appLanguage),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                    color: textPrimary,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.restart_alt_rounded, size: 20),
                    tooltip: isBn ? 'ডিফল্ট সেটিংস' : 'Reset to Defaults',
                    color: textSecondary,
                    onPressed: () => _showResetConfirmDialog(context, appLanguage),
                  ),
                  const Gap(6),
                ],
              ),
              body: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 6, bottom: 28),
                children: [
                  // ── 1. General & Appearance ──
                  _buildSectionTitle(isBn ? 'সাধারণ ও রূপরেখা' : 'General & Appearance'),
                  _buildCardGroup(
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderDividerColor: borderDividerColor,
                    children: [
                      // App Language
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMint.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.language_rounded, color: AppTheme.primaryMint, size: 17),
                        ),
                        title: Text(
                          isBn ? 'অ্যাপের ভাষা' : 'App Language',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              HadithLanguage.languageMetadata[state.appLanguage]?['native'] ?? state.appLanguage,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryMint,
                              ),
                            ),
                            const Gap(4),
                            const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
                          ],
                        ),
                        onTap: () => _showLanguageDialog(context, state.appLanguage),
                      ),
                      Divider(color: borderDividerColor, height: 1),

                      // Theme Selector Pills Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryMint.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.palette_outlined, color: AppTheme.primaryMint, size: 17),
                            ),
                            const Gap(10),
                            Text(
                              isBn ? 'থিম মুড' : 'Theme',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                            ),
                            const Spacer(),
                            // Segmented Theme Pills
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildCompactThemePill(
                                  icon: Icons.dark_mode_rounded,
                                  label: isBn ? 'ডার্ক' : 'Dark',
                                  isSelected: state.themeMode == 'dark',
                                  isDark: isDark,
                                  onTap: () => context.read<SettingsCubit>().setThemeMode('dark'),
                                ),
                                const Gap(4),
                                _buildCompactThemePill(
                                  icon: Icons.light_mode_rounded,
                                  label: isBn ? 'লাইট' : 'Light',
                                  isSelected: state.themeMode == 'light',
                                  isDark: isDark,
                                  onTap: () => context.read<SettingsCubit>().setThemeMode('light'),
                                ),
                                const Gap(4),
                                _buildCompactThemePill(
                                  icon: Icons.brightness_auto_rounded,
                                  label: isBn ? 'অটো' : 'Auto',
                                  isSelected: state.themeMode == 'system',
                                  isDark: isDark,
                                  onTap: () => context.read<SettingsCubit>().setThemeMode('system'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(color: borderDividerColor, height: 1),

                      // Manage Offline Books shortcut
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.menu_book_rounded, color: Color(0xFF6366F1), size: 17),
                        ),
                        title: Text(
                          isBn ? 'অফলাইন হাদিস বইসমূহ' : 'Offline Hadith Books',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: borderDividerColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${hadithState.downloadedBooks.length} Books • $totalMb MB',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                            const Gap(4),
                            const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
                          ],
                        ),
                        onTap: () => context.push('/resources'),
                      ),
                    ],
                  ),

                  const Gap(10),

                  // ── 2. Typography & Live Studio Preview ──
                  _buildSectionTitle(isBn ? 'টাইপোগ্রাফি ও ফন্ট স্টুডিও' : 'Typography & Font Studio'),
                  _buildCardGroup(
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderDividerColor: borderDividerColor,
                    children: [
                      // Arabic Font Family Horizontal Chips
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryMint.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.font_download_rounded, color: AppTheme.primaryMint, size: 17),
                                ),
                                const Gap(10),
                                Text(
                                  isBn ? 'আরবি ফন্ট স্ক্রিপ্ট' : 'Arabic Script',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                                ),
                                const Spacer(),
                                Text(
                                  state.arabicFontFamily,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryMint,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: SettingsScreen.arabicFonts.map((font) {
                                  final isSelected = state.arabicFontFamily == font['key'];
                                  return GestureDetector(
                                    onTap: () => context.read<SettingsCubit>().setArabicFontFamily(font['key']!),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryMint
                                            : isDark
                                                ? AppTheme.darkSurface
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected ? AppTheme.primaryMint : borderDividerColor,
                                        ),
                                      ),
                                      child: Text(
                                        font['display']!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected
                                              ? (isDark ? AppTheme.darkCanvas : Colors.white)
                                              : textPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: borderDividerColor, height: 1),

                      // Arabic Font Size Stepper & Slider
                      _buildSizeControlRow(
                        title: isBn ? 'আরবি ফন্ট সাইজ' : 'Arabic Size',
                        currentSize: state.arabicFontSize,
                        min: 16,
                        max: 40,
                        unit: 'pt',
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        borderDividerColor: borderDividerColor,
                        onChanged: (val) => context.read<SettingsCubit>().setArabicFontSize(val.roundToDouble()),
                      ),
                      Divider(color: borderDividerColor, height: 1),

                      // Translation Font Size Stepper & Slider
                      _buildSizeControlRow(
                        title: isBn ? 'অনুবাদ ফন্ট সাইজ' : 'Translation Size',
                        currentSize: state.translationFontSize,
                        min: 12,
                        max: 28,
                        unit: 'pt',
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        borderDividerColor: borderDividerColor,
                        onChanged: (val) => context.read<SettingsCubit>().setTranslationFontSize(val.roundToDouble()),
                      ),
                      Divider(color: borderDividerColor, height: 1),

                      // Unified Live Reader Studio Preview Card
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.preview_rounded, size: 14, color: AppTheme.primaryMint),
                                const Gap(5),
                                Text(
                                  isBn ? 'লাইভ রিডার প্রিভিউ' : 'Live Reader Preview',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: textSecondary.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkSurface : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderDividerColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Arabic Preview
                                  Text(
                                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: _getArabicTextStyle(state, textPrimary),
                                  ),
                                  const Gap(6),
                                  // Translation Preview
                                  Text(
                                    isBn
                                        ? 'শুরু করছি পরম করুণাময় ও অসীম দয়ালু আল্লাহর নামে।'
                                        : 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: state.translationFontSize,
                                      color: textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Gap(10),

                  // ── 3. Reading Behavior & View Mode ──
                  _buildSectionTitle(isBn ? 'পড়ার অভ্যাস ও আচরণ' : 'Reading Behavior'),
                  _buildCardGroup(
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderDividerColor: borderDividerColor,
                    children: [
                      // Reading View Mode
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.auto_stories_rounded, color: Color(0xFF0EA5E9), size: 17),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Text(
                                isBn ? 'রিডিং মোড' : 'Reading Mode',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                              ),
                            ),
                            // Segmented Switcher
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildCompactPill(
                                  label: isBn ? 'পৃষ্ঠা' : 'Page',
                                  icon: Icons.view_carousel_rounded,
                                  isSelected: _viewMode == 'page',
                                  isDark: isDark,
                                  onTap: () {
                                    setState(() => _viewMode = 'page');
                                    context.read<PreferencesService>().setHadithViewMode('page');
                                  },
                                ),
                                const Gap(4),
                                _buildCompactPill(
                                  label: isBn ? 'স্ক্রোল' : 'Scroll',
                                  icon: Icons.view_stream_rounded,
                                  isSelected: _viewMode == 'scroll',
                                  isDark: isDark,
                                  onTap: () {
                                    setState(() => _viewMode = 'scroll');
                                    context.read<PreferencesService>().setHadithViewMode('scroll');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(color: borderDividerColor, height: 1),

                      // Keep Screen Awake
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        dense: true,
                        secondary: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.screen_lock_portrait_rounded, color: Color(0xFF10B981), size: 17),
                        ),
                        title: Text(
                          isBn ? 'পড়ার সময় স্ক্রিন চালু রাখুন' : 'Keep Screen Awake',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                        ),
                        subtitle: Text(
                          isBn ? 'পড়ার সময় স্ক্রিন স্লিপ হওয়া রোধ করে' : 'Prevent screen sleep while reading',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        value: state.wakeLockEnabled,
                        activeThumbColor: AppTheme.primaryMint,
                        onChanged: (val) => context.read<SettingsCubit>().setWakeLockEnabled(val),
                      ),
                      Divider(color: borderDividerColor, height: 1),

                      // Auto Mark as Read
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        dense: true,
                        secondary: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.done_all_rounded, color: Color(0xFFF59E0B), size: 17),
                        ),
                        title: Text(
                          isBn ? 'স্বয়ংক্রিয় পঠিত চিহ্নিত' : 'Auto Mark as Read',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                        ),
                        subtitle: Text(
                          isBn
                              ? 'নির্দিষ্ট সময় থাকার পর হাদিস পঠিত গণ্য হয়'
                              : 'Mark hadith read after staying on it',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        value: state.autoMarkRead,
                        activeThumbColor: AppTheme.primaryMint,
                        onChanged: (val) => context.read<SettingsCubit>().setAutoMarkRead(val),
                      ),

                      // Dwell Timer Selector (if Auto Mark Read is true)
                      if (state.autoMarkRead) ...[
                        Divider(color: borderDividerColor, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.timer_outlined, color: Colors.grey, size: 17),
                              ),
                              const Gap(10),
                              Text(
                                isBn ? 'পড়ার সময়কাল' : 'Dwell Time',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [3, 5, 10, 15].map((sec) {
                                  final isSelected = sec == state.dwellTimerSeconds;
                                  return GestureDetector(
                                    onTap: () => context.read<SettingsCubit>().setDwellTimerSeconds(sec),
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryMint
                                            : isDark
                                                ? AppTheme.darkSurface
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected ? AppTheme.primaryMint : borderDividerColor,
                                        ),
                                      ),
                                      child: Text(
                                        '${sec}s',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected
                                              ? (isDark ? AppTheme.darkCanvas : Colors.white)
                                              : textPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const Gap(10),

                  // ── 4. Data, Storage & Maintenance ──
                  _buildSectionTitle(isBn ? 'ডাটা ও ব্যাকআপ' : 'Data & Maintenance'),
                  _buildCardGroup(
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderDividerColor: borderDividerColor,
                    children: [
                      // Export Bookmarks & Notes
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMint.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.file_upload_outlined, color: AppTheme.primaryMint, size: 17),
                        ),
                        title: Text(
                          isBn ? 'সংগ্রহ ও নোট এক্সপোর্ট করুন' : 'Export Collections',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                        ),
                        subtitle: Text(
                          isBn
                              ? 'বুকমার্ক ও নোট টেক্সট আকারে কপি করুন'
                              : 'Copy all bookmarks and reflections',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        trailing: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.primaryMint),
                        onTap: () => _exportCollections(context, hadithState, appLanguage),
                      ),
                      Divider(color: borderDividerColor, height: 1),

                      // Clear Cache
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.cleaning_services_rounded, color: Colors.amber.shade700, size: 17),
                        ),
                        title: Text(
                          isBn ? 'অ্যাপ ক্যাশ ক্লিয়ার করুন' : 'Clear Temporary Cache',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                        ),
                        subtitle: Text(
                          isBn ? 'মেমরি ও প্রিভিউ ক্যাশ মুক্ত করে' : 'Frees in-memory image & font cache',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: borderDividerColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isBn ? 'ক্লিয়ার' : 'Clear',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        onTap: () {
                          PaintingBinding.instance.imageCache.clear();
                          PaintingBinding.instance.imageCache.clearLiveImages();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isBn ? 'মেমরি ক্যাশ সফলভাবে ক্লিয়ার হয়েছে!' : 'Temporary cache cleared!',
                              ),
                              backgroundColor: AppTheme.primaryMint,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      Divider(color: borderDividerColor, height: 1),

                      // Re-run Setup Wizard
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMint.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.auto_stories_rounded, color: AppTheme.primaryMint, size: 17),
                        ),
                        title: Text(
                          isBn ? 'সেটআপ ও লাইব্রেরি উইজার্ড' : 'Setup & Library Wizard',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                        ),
                        subtitle: Text(
                          isBn
                              ? 'নতুন বই ডাউনলোড বা প্রাথমিক ভাষা বদলান'
                              : 'Re-run onboarding to download books or switch language',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppTheme.primaryMint),
                        onTap: () => context.push('/setup'),
                      ),
                    ],
                  ),

                  const Gap(10),

                  // ── 5. About & Community ──
                  _buildSectionTitle(isBn ? 'সম্পর্কে' : 'About & Credits'),
                  _buildCardGroup(
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    borderDividerColor: borderDividerColor,
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.info_outline_rounded, color: Colors.grey, size: 17),
                        ),
                        title: Text(
                          isBn ? 'অ্যাপ ভার্সন' : 'App Version',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                        ),
                        trailing: Text(
                          'v1.0.0 (Build 1)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textSecondary),
                        ),
                      ),
                      Divider(color: borderDividerColor, height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.code_rounded, color: Colors.grey, size: 17),
                        ),
                        title: Text(
                          isBn ? 'নির্মাতা' : 'Developed by',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                        ),
                        trailing: Text(
                          'Ismail Hosen',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  TextStyle _getArabicTextStyle(SettingsState state, Color textPrimary) {
    final isLocalFont =
        state.arabicFontFamily == 'Me Quran' ||
        state.arabicFontFamily == 'QPC Hafs' ||
        state.arabicFontFamily == 'Indopak Nastaleeq';

    if (isLocalFont) {
      return TextStyle(
        fontFamily: state.arabicFontFamily,
        fontSize: state.arabicFontSize,
        color: textPrimary,
        height: 1.7,
      );
    }
    return GoogleFonts.getFont(
      state.arabicFontFamily,
      fontSize: state.arabicFontSize,
      color: textPrimary,
      height: 1.7,
    );
  }

  Widget _buildSizeControlRow({
    required String title,
    required double currentSize,
    required double min,
    required double max,
    required String unit,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderDividerColor,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textPrimary),
              ),
              const Spacer(),
              // Minus Stepper
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: currentSize > min ? () => onChanged(currentSize - 1) : null,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderDividerColor),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 14,
                    color: currentSize > min ? textPrimary : Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const Gap(6),
              // Size Value Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${currentSize.toInt()} $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryMint,
                  ),
                ),
              ),
              const Gap(6),
              // Plus Stepper
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: currentSize < max ? () => onChanged(currentSize + 1) : null,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderDividerColor),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 14,
                    color: currentSize < max ? textPrimary : Colors.grey.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryMint,
              inactiveTrackColor: borderDividerColor,
              thumbColor: AppTheme.primaryMint,
              overlayColor: AppTheme.primaryMint.withValues(alpha: 0.15),
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: currentSize.clamp(min, max),
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactThemePill({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryMint
              : isDark
                  ? AppTheme.darkSurface
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryMint : const Color(0xFFCBD5E1).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? (isDark ? AppTheme.darkCanvas : Colors.white) : Colors.grey,
            ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppTheme.darkCanvas : Colors.white)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryMint
              : isDark
                  ? AppTheme.darkSurface
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryMint : const Color(0xFFCBD5E1).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? (isDark ? AppTheme.darkCanvas : Colors.white) : Colors.grey,
            ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppTheme.darkCanvas : Colors.white)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

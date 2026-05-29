import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/logic/settings/settings_state.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import 'package:al_hadith/data/models/resource_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, String>> arabicFonts = [
    {'key': 'Me Quran', 'display': 'Me Quran'},
    {'key': 'QPC Hafs', 'display': 'QPC Hafs'},
    {'key': 'Indopak Nastaleeq', 'display': 'Indopak Nastaleeq'},
    {'key': 'Amiri', 'display': 'Amiri'},
    {'key': 'Noto Naskh Arabic', 'display': 'Noto Naskh Arabic'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final canvasColor = Theme.of(context).scaffoldBackgroundColor;
        final surfaceColor = Theme.of(context).colorScheme.surface;
        final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
        final appLanguage = state.appLanguage;

        return Scaffold(
          backgroundColor: canvasColor,
          appBar: AppBar(
            backgroundColor: surfaceColor,
            elevation: 0,
            iconTheme: IconThemeData(color: textPrimary),
            title: Text(
              AppLocalization.get('settings', appLanguage),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: textPrimary,
              ),
            ),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // ── Language ──
              _buildSectionHeader(context, AppLocalization.get('language', appLanguage)),
              _buildLanguageSelector(context, state),
              const Gap(8),

              // ── Appearance ──
              _buildSectionHeader(context, AppLocalization.get('appearance', appLanguage)),
              _buildThemeSelector(context, state),
              const Gap(8),

              // ── Font Settings ──
              _buildSectionHeader(context, AppLocalization.get('font_settings', appLanguage)),
              _buildArabicFontPicker(context, state),
              const Gap(8),
              _buildSliderTile(
                context,
                icon: Icons.format_size_rounded,
                title: AppLocalization.get('arabic_font_size', appLanguage),
                subtitle: '${state.arabicFontSize.toInt()} pt',
                value: state.arabicFontSize,
                min: 16,
                max: 42,
                preview: _buildArabicPreview(context, state),
                onChanged: (v) =>
                    context.read<SettingsCubit>().setArabicFontSize(v.roundToDouble()),
              ),
              const Gap(8),
              _buildSliderTile(
                context,
                icon: Icons.text_fields_rounded,
                title: AppLocalization.get('translation_font_size', appLanguage),
                subtitle: '${state.translationFontSize.toInt()} pt',
                value: state.translationFontSize,
                min: 12,
                max: 30,
                preview: _buildTranslationPreview(context, state),
                onChanged: (v) =>
                    context.read<SettingsCubit>().setTranslationFontSize(v.roundToDouble()),
              ),
              const Gap(8),

              // ── Reading Behavior ──
              _buildSectionHeader(context, AppLocalization.get('reading_behavior', appLanguage)),
              _buildToggleTile(
                context,
                icon: Icons.screen_lock_portrait_rounded,
                title: AppLocalization.get('keep_screen_awake', appLanguage),
                subtitle: AppLocalization.get('keep_screen_awake_desc', appLanguage),
                value: state.wakeLockEnabled,
                onChanged: (v) => context.read<SettingsCubit>().setWakeLockEnabled(v),
              ),
              _buildToggleTile(
                context,
                icon: Icons.auto_stories_rounded,
                title: AppLocalization.get('auto_mark_read', appLanguage),
                subtitle: AppLocalization.get('auto_mark_read_desc', appLanguage),
                value: state.autoMarkRead,
                onChanged: (v) => context.read<SettingsCubit>().setAutoMarkRead(v),
              ),
              if (state.autoMarkRead)
                _buildSliderTile(
                  context,
                  icon: Icons.timer_outlined,
                  title: AppLocalization.get('dwell_timer', appLanguage),
                  subtitle: AppLocalization.get('dwell_timer_seconds', appLanguage, args: {
                    'seconds': state.dwellTimerSeconds.toString()
                  }),
                  value: state.dwellTimerSeconds.toDouble(),
                  min: 2,
                  max: 15,
                  onChanged: (v) =>
                      context.read<SettingsCubit>().setDwellTimerSeconds(v.toInt()),
                ),
              const Gap(8),

              // ── About ──
              _buildSectionHeader(context, AppLocalization.get('about_section', appLanguage)),
              _buildInfoTile(
                context,
                icon: Icons.info_outline_rounded,
                title: AppLocalization.get('version', appLanguage),
                trailing: '1.0.0',
              ),
              _buildInfoTile(
                context,
                icon: Icons.code_rounded,
                title: AppLocalization.get('developed_by', appLanguage),
                trailing: 'Ismail Hosen',
              ),
              const Gap(32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primaryMint,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildThemeSelector(BuildContext context, SettingsState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3) : const Color(0xFFF3F4F6);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_rounded, color: AppTheme.primaryMint, size: 18),
              const Gap(10),
              Text(
                AppLocalization.get('theme', state.appLanguage),
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(14),
          Row(
            children: [
              _buildThemeOption(
                context,
                icon: Icons.dark_mode_rounded,
                label: AppLocalization.get('theme_dark', state.appLanguage),
                isSelected: state.themeMode == 'dark',
                onTap: () => context.read<SettingsCubit>().setThemeMode('dark'),
              ),
              const Gap(12),
              _buildThemeOption(
                context,
                icon: Icons.light_mode_rounded,
                label: AppLocalization.get('theme_light', state.appLanguage),
                isSelected: state.themeMode == 'light',
                onTap: () => context.read<SettingsCubit>().setThemeMode('light'),
              ),
              const Gap(12),
              _buildThemeOption(
                context,
                icon: Icons.brightness_auto_rounded,
                label: AppLocalization.get('theme_system', state.appLanguage),
                isSelected: state.themeMode == 'system',
                onTap: () => context.read<SettingsCubit>().setThemeMode('system'),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final unselectedBorderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final optionBgColor = isSelected
        ? AppTheme.primaryMint.withValues(alpha: 0.12)
        : (isDark ? AppTheme.darkSurface : Colors.white);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: optionBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryMint : unselectedBorderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryMint : textSecondary,
                size: 22,
              ),
              const Gap(6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryMint : textSecondary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArabicFontPicker(BuildContext context, SettingsState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3) : const Color(0xFFF3F4F6);
    final chipBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.font_download_rounded, color: AppTheme.primaryMint, size: 18),
              const Gap(10),
              Text(
                AppLocalization.get('arabic_font_family', state.appLanguage),
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: arabicFonts.map((font) {
              final isSelected = state.arabicFontFamily == font['key'];
              return ChoiceChip(
                label: Text(
                  font['display']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                backgroundColor: chipBgColor,
                selectedColor: AppTheme.primaryMint,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryMint : borderColor,
                  ),
                ),
                onSelected: (_) {
                  context.read<SettingsCubit>().setArabicFontFamily(font['key']!);
                },
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildArabicPreview(BuildContext context, SettingsState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;

    final isLocalFont = state.arabicFontFamily == 'Me Quran' ||
        state.arabicFontFamily == 'QPC Hafs' ||
        state.arabicFontFamily == 'Indopak Nastaleeq';

    final textStyle = isLocalFont
        ? TextStyle(
            fontFamily: state.arabicFontFamily,
            fontSize: state.arabicFontSize,
            color: textPrimary,
            height: 1.8,
          )
        : GoogleFonts.getFont(
            state.arabicFontFamily,
            fontSize: state.arabicFontSize,
            color: textPrimary,
            height: 1.8,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: previewBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: textStyle,
      ),
    );
  }

  Widget _buildTranslationPreview(BuildContext context, SettingsState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: previewBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        AppLocalization.get('translation_preview', state.appLanguage),
        style: TextStyle(
          fontSize: state.translationFontSize,
          color: textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    Widget? preview,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3) : const Color(0xFFF3F4F6);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryMint, size: 18),
              const Gap(10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.primaryMint,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryMint,
              inactiveTrackColor: borderColor,
              thumbColor: AppTheme.primaryMint,
              overlayColor: AppTheme.primaryMint.withValues(alpha: 0.15),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: onChanged,
            ),
          ),
          if (preview != null) ...[
            const Gap(4),
            preview,
          ],
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildToggleTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3) : const Color(0xFFF3F4F6);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryMint, size: 18),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.primaryMint,
            activeTrackColor: AppTheme.primaryMint.withValues(alpha: 0.3),
            inactiveThumbColor: textSecondary,
            inactiveTrackColor: borderColor,
            onChanged: onChanged,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3) : const Color(0xFFF3F4F6);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryMint, size: 18),
          const Gap(14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildLanguageSelector(BuildContext context, SettingsState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3) : const Color(0xFFF3F4F6);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.translate_rounded, color: AppTheme.primaryMint, size: 18),
          const Gap(14),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.appLanguage,
                isExpanded: true,
                dropdownColor: isDark ? AppTheme.darkSurfaceCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                icon: Icon(Icons.arrow_drop_down_rounded, color: textSecondary),
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
                items: HadithLanguage.languageMetadata.entries.map((entry) {
                  final code = entry.key;
                  final meta = entry.value;
                  return DropdownMenuItem<String>(
                    value: code,
                    child: Row(
                      children: [
                        Text(meta['flag'] ?? '', style: const TextStyle(fontSize: 16)),
                        const Gap(10),
                        Text(
                          meta['native'] ?? '',
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                        if (meta['native'] != meta['display']) ...[
                          const Gap(6),
                          Text(
                            '(${meta['display']})',
                            style: TextStyle(color: textSecondary, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newLangCode) {
                  if (newLangCode != null) {
                    context.read<SettingsCubit>().setAppLanguage(newLangCode, explicit: true);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }
}

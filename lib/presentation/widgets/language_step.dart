import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import 'package:al_hadith/data/models/resource_model.dart';
import 'package:al_hadith/logic/setup/setup_state.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';

class LanguageStep extends StatelessWidget {
  final SetupState state;
  final Function(HadithLanguage) onSelected;

  const LanguageStep({
    super.key,
    required this.state,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.languages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryMint),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final inactiveBorderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final tickColor = isDark ? AppTheme.darkCanvas : Colors.white;

    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final isWideWindow = MediaQuery.of(context).size.width > AppTheme.wideWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Sacred Spiritual Bismillah Greeting Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppTheme.primaryMint.withValues(alpha: 0.12),
                      AppTheme.darkSurfaceCard,
                    ]
                  : [
                      const Color(0xFFE6F9F5),
                      Colors.white,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.primaryMint.withValues(alpha: 0.22),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryMint,
                  letterSpacing: 0.5,
                ),
              ),
              const Gap(4),
              Text(
                AppLocalization.get('lang_step_desc', appLanguage),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.05, end: 0),

        const Gap(14),

        // 2. Compact App Interface Language Selector Pill Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: inactiveBorderColor, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMint.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: AppTheme.primaryMint,
                  size: 16,
                ),
              ),
              const Gap(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalization.get('app_interface_lang', appLanguage),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: appLanguage,
                  isDense: true,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary, size: 20),
                  items: HadithLanguage.languageMetadata.entries.map((entry) {
                    final code = entry.key;
                    final meta = entry.value;
                    return DropdownMenuItem<String>(
                      value: code,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(meta['flag'] ?? '', style: const TextStyle(fontSize: 15)),
                          const Gap(6),
                          Text(
                            meta['native'] ?? '',
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
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
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

        const Gap(16),

        // 3. Section Title with Information Chip
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalization.get('select_language', appLanguage),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: 0.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryMint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${state.languages.length} Available',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryMint,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

        const Gap(10),

        // 4. Primary Translation Language High-Density Cards
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWideWindow ? 4 : 2,
              childAspectRatio: isWideWindow ? 1.6 : 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.languages.length,
            itemBuilder: (context, index) {
              final lang = state.languages[index];
              final isSelected = state.selectedLanguage?.code == lang.code;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelected(lang),
                child: AnimatedContainer(
                  duration: 220.ms,
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AppTheme.primaryMint.withValues(alpha: 0.14)
                            : const Color(0xFFE8FAF5))
                        : cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryMint
                          : inactiveBorderColor,
                      width: isSelected ? 1.8 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryMint.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    lang.flagEmoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: 200.ms,
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppTheme.primaryMint
                                      : (isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFE2E8F0)),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryMint
                                        : inactiveBorderColor,
                                    width: 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: tickColor,
                                          size: 14,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                  color: textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(2),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      lang.code == "eng" ? "English" : lang.nativeName,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? AppTheme.primaryMint
                                            : textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${lang.resources.length} books',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: textSecondary.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 250.ms, delay: (index * 30).ms);
            },
          ),
        ),
      ],
    );
  }
}

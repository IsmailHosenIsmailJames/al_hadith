import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import 'package:al_hadith/data/models/resource_model.dart';
import 'package:al_hadith/logic/setup/setup_state.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';

/// Helper hierarchy for unified flat-list rendering
abstract class ResourceListItem {}

class HeaderItem extends ResourceListItem {
  final HadithLanguage language;
  HeaderItem(this.language);
}

class BookItem extends ResourceListItem {
  final HadithLanguage language;
  final HadithResource resource;
  BookItem(this.language, this.resource);
}

class ResourceStep extends StatelessWidget {
  final SetupState state;
  final Function(String) onToggle;
  final VoidCallback? onSelectRecommended;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClearAll;

  const ResourceStep({
    super.key,
    required this.state,
    required this.onToggle,
    this.onSelectRecommended,
    this.onSelectAll,
    this.onClearAll,
  });

  String _getBookInitials(String bookKey) {
    if (bookKey.contains('bukhari')) return 'SB';
    if (bookKey.contains('muslim')) return 'SM';
    if (bookKey.contains('abudawud')) return 'AD';
    if (bookKey.contains('tirmidhi')) return 'TI';
    if (bookKey.contains('nasai')) return 'NA';
    if (bookKey.contains('ibnmajah')) return 'IM';
    if (bookKey.contains('malik')) return 'MA';
    if (bookKey.contains('nawawi')) return 'NW';
    if (bookKey.contains('qudsi')) return 'QD';
    if (bookKey.contains('dehlawi')) return 'DH';
    return bookKey.length >= 2 ? bookKey.substring(0, 2).toUpperCase() : 'BK';
  }

  @override
  Widget build(BuildContext context) {
    if (state.selectedLanguage == null) return const SizedBox.shrink();
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final isWideWindow = MediaQuery.of(context).size.width > AppTheme.wideWidth;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderUncheckedColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final tickColor = isDark ? AppTheme.darkCanvas : Colors.white;

    // 1. Flatten languages list for grouped display, prioritizing chosen language at the top
    final List<ResourceListItem> items = [];
    final selectedLang = state.selectedLanguage!;

    // Selected language section goes first, sorted by canonical popularity
    items.add(HeaderItem(selectedLang));
    final sortedSelected = List<HadithResource>.from(selectedLang.resources)
      ..sort((a, b) => HadithCubit.getBookPopularityRank(a.book).compareTo(HadithCubit.getBookPopularityRank(b.book)));
    for (final res in sortedSelected) {
      items.add(BookItem(selectedLang, res));
    }

    // Other language sections follow, sorted by canonical popularity
    for (final lang in state.languages) {
      if (lang.code == selectedLang.code) continue;
      items.add(HeaderItem(lang));
      final sortedOther = List<HadithResource>.from(lang.resources)
        ..sort((a, b) => HadithCubit.getBookPopularityRank(a.book).compareTo(HadithCubit.getBookPopularityRank(b.book)));
      for (final res in sortedOther) {
        items.add(BookItem(lang, res));
      }
    }

    // Calculate offline ready books count among selected
    int offlineReadyCount = 0;
    for (final bookKey in state.selectedResources) {
      if (state.downloadProgress[bookKey] == 1.0 ||
          state.downloadStatus[bookKey] == 'Completed' ||
          state.downloadStatus[bookKey] == 'Completed (Skipped)') {
        offlineReadyCount++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Title & Description
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalization.get('select_resources', appLanguage),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    AppLocalization.get('resource_step_desc', appLanguage),
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 350.ms),

        const Gap(12),

        // 2. Bundle Presets Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip(
                label: '⭐ Recommended',
                onTap: onSelectRecommended,
                isSelected: false,
                isDark: isDark,
              ),
              const Gap(8),
              _buildPresetChip(
                label: '⚡ All Collections',
                onTap: onSelectAll,
                isSelected: false,
                isDark: isDark,
              ),
              const Gap(8),
              _buildPresetChip(
                label: '🧹 Clear',
                onTap: onClearAll,
                isSelected: false,
                isDark: isDark,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 80.ms),

        const Gap(10),

        // 3. Storage & Bandwidth Telemetry Strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceCard : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.folder_zip_outlined,
                color: AppTheme.primaryMint,
                size: 16,
              ),
              const Gap(8),
              Text(
                '${state.selectedResources.length} Selected',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const Gap(8),
              Text('•', style: TextStyle(color: textSecondary)),
              const Gap(8),
              Text(
                state.formattedTotalSize,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryMint,
                ),
              ),
              const Spacer(),
              if (offlineReadyCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.primaryMint, size: 12),
                      const Gap(4),
                      Text(
                        '$offlineReadyCount Ready',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryMint,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 120.ms),

        const Gap(12),

        // 4. Books Grouped List
        Expanded(
          child: ListView.builder(
            itemCount: items.count((element) => element is HeaderItem),
            itemBuilder: (context, index) {
              final header = items.whereType<HeaderItem>().toList()[index];
              final itemsOfLang = items
                  .whereType<BookItem>()
                  .toList()
                  .where((element) => element.language.code == header.language.code)
                  .toList();
              final lang = header.language;
              final isDefault = lang.code == selectedLang.code;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language group header
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 8, left: 2),
                    child: Row(
                      children: [
                        Text(
                          lang.flagEmoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const Gap(8),
                        Text(
                          AppLocalization.getResourceHeader(appLanguage, lang.code),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const Gap(8),
                        if (isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryMint.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.primaryMint.withValues(alpha: 0.3),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              AppLocalization.get('default', appLanguage),
                              style: const TextStyle(
                                color: AppTheme.primaryMint,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Text(
                          '${itemsOfLang.length} books',
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // High-density cards in grid / list
                  if (isWideWindow)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: itemsOfLang.length,
                      itemBuilder: (context, i) => _buildBookCard(
                        itemsOfLang[i],
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        cardBgColor: cardBgColor,
                        borderUncheckedColor: borderUncheckedColor,
                        tickColor: tickColor,
                        appLanguage: appLanguage,
                      ),
                    )
                  else
                    ...itemsOfLang.map((bookItem) => _buildBookCard(
                          bookItem,
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          cardBgColor: cardBgColor,
                          borderUncheckedColor: borderUncheckedColor,
                          tickColor: tickColor,
                          appLanguage: appLanguage,
                        )),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(
    BookItem bookItem, {
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color cardBgColor,
    required Color borderUncheckedColor,
    required Color tickColor,
    required String appLanguage,
  }) {
    final res = bookItem.resource;
    final isChecked = state.selectedResources.contains(res.book);
    final isAlreadyDownloaded = state.downloadProgress[res.book] == 1.0 ||
        state.downloadStatus[res.book] == 'Completed' ||
        state.downloadStatus[res.book] == 'Completed (Skipped)';

    final initials = _getBookInitials(res.book);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onToggle(res.book),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isChecked
                ? (isDark
                    ? AppTheme.primaryMint.withValues(alpha: 0.1)
                    : const Color(0xFFE8FAF5))
                : cardBgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isChecked ? AppTheme.primaryMint : borderUncheckedColor,
              width: isChecked ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Monogram Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isChecked
                      ? AppTheme.primaryMint
                      : (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isChecked
                          ? tickColor
                          : (isDark ? Colors.white70 : AppTheme.textDark),
                    ),
                  ),
                ),
              ),

              const Gap(12),

              // Book titles and metrics
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            res.nameNative,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAlreadyDownloaded)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryMint.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.offline_pin_rounded,
                                  color: AppTheme.primaryMint,
                                  size: 11,
                                ),
                                const Gap(3),
                                Text(
                                  AppLocalization.get('offline_ready', appLanguage),
                                  style: const TextStyle(
                                    color: AppTheme.primaryMint,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const Gap(2),
                    if (res.languageCode != "eng" && res.name.isNotEmpty)
                      Text(
                        res.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Gap(4),
                    Row(
                      children: [
                        Text(
                          '${res.hadithCount} Hadiths',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isChecked
                                ? AppTheme.primaryMint
                                : textSecondary,
                          ),
                        ),
                        const Gap(6),
                        Text('•', style: TextStyle(fontSize: 10, color: textSecondary)),
                        const Gap(6),
                        Text(
                          '${res.sectionCount} Ch',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        const Gap(6),
                        Text('•', style: TextStyle(fontSize: 10, color: textSecondary)),
                        const Gap(6),
                        Text(
                          res.formattedZipSize,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isChecked ? textPrimary : textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Gap(10),

              // Interactive Checkbox Indicator
              AnimatedContainer(
                duration: 200.ms,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked ? AppTheme.primaryMint : Colors.transparent,
                  border: Border.all(
                    color: isChecked
                        ? AppTheme.primaryMint
                        : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1)),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isChecked
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
        ),
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required VoidCallback? onTap,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}

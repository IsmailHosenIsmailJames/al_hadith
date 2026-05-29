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

  const ResourceStep({super.key, required this.state, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    if (state.selectedLanguage == null) return const SizedBox.shrink();
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    bool isWideWindow = MediaQuery.of(context).size.width > AppTheme.wideWidth;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderUncheckedColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final offlineReadyTagBg = isDark ? AppTheme.darkSurfaceCard : const Color(0xFFF3F4F6);

    // 1. Flatten languages list for grouped display, prioritizing chosen language at the top
    final List<ResourceListItem> items = [];
    final selectedLang = state.selectedLanguage!;

    // Selected language section goes first
    items.add(HeaderItem(selectedLang));
    for (final res in selectedLang.resources) {
      items.add(BookItem(selectedLang, res));
    }

    // Other language sections follow
    for (final lang in state.languages) {
      if (lang.code == selectedLang.code) continue;
      items.add(HeaderItem(lang));
      for (final res in lang.resources) {
        items.add(BookItem(lang, res));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.get('select_resources', appLanguage),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        const Gap(6),
        Text(
              AppLocalization.get('resource_step_desc', appLanguage),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textSecondary,
                height: 1.4,
              ),
            )
            .animate()
            .fadeIn(duration: 450.ms, delay: 100.ms)
            .slideY(begin: 0.1, end: 0),
        const Gap(16),
        Expanded(
          child: ListView.builder(
            itemCount: items.count((element) => element is HeaderItem),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final header = items.whereType<HeaderItem>().toList()[index];
              final itemsOfLang = items
                  .whereType<BookItem>()
                  .toList()
                  .where(
                    (element) => element.language.code == header.language.code,
                  )
                  .toList();
              final lang = header.language;
              final isDefault = lang.code == selectedLang.code;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 8.0,
                      left: 4.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          lang.flagEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const Gap(8),
                        Text(
                          AppLocalization.getResourceHeader(appLanguage, lang.code),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Gap(8),
                        if (isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryMint.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.primaryMint.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              AppLocalization.get('default', appLanguage),
                              style: const TextStyle(
                                color: AppTheme.primaryMint,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  const Gap(20),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWideWindow ? 2 : 1,
                      childAspectRatio: isWideWindow ? 3 : 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemsOfLang.length,
                    itemBuilder: (context, index) {
                      // Else it is a BookItem
                      final bookItem = itemsOfLang[index];
                      final res = bookItem.resource;
                      final isChecked = state.selectedResources.contains(
                        res.book,
                      );

                      // Read pre-cached download statuses
                      final isAlreadyDownloaded =
                          state.downloadProgress[res.book] == 1.0 ||
                          state.downloadStatus[res.book] == 'Completed' ||
                          state.downloadStatus[res.book] ==
                              'Completed (Skipped)';

                      final containerBg = isChecked
                          ? (isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.4) : const Color(0xFFE6F9F5))
                          : (isDark ? AppTheme.darkSurface.withValues(alpha: 0.5) : Colors.white);

                      return GestureDetector(
                            onTap: () => onToggle(res.book),
                            child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: containerBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isChecked
                                          ? AppTheme.primaryMint.withValues(
                                              alpha: 0.3,
                                            )
                                          : borderUncheckedColor,
                                      width: isChecked ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isChecked,
                                        onChanged: (_) => onToggle(res.book),
                                      ),
                                      const Gap(12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              res.nameNative,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Gap(2),
                                            if (res.languageCode != "eng")
                                              Text(
                                                res.name,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: textSecondary,
                                                ),
                                              ),
                                            const Gap(6),
                                            Row(
                                              children: [
                                                // Sleek language tag
                                                Text(
                                                  bookItem.language.flagEmoji,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const Gap(4),
                                                Text(
                                                  bookItem.language.code ==
                                                          "eng"
                                                      ? bookItem
                                                            .language
                                                            .displayName
                                                      : "${bookItem.language.nativeName} (${bookItem.language.displayName})",
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryMint,
                                                  ),
                                                ),
                                                const Gap(8),
                                                Text(
                                                  '•',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                                const Gap(8),
                                                Text(
                                                  AppLocalization.get('hadiths', appLanguage, args: {'count': res.hadithCount.toString()}),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                                const Gap(6),
                                                Text(
                                                  '•',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                                const Gap(6),
                                                Text(
                                                  AppLocalization.get('chapters', appLanguage, args: {'count': res.sectionCount.toString()}),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Gap(4),
                                            Text(
                                              AppLocalization.get('download_size', appLanguage, args: {'size': res.formattedZipSize}),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isChecked
                                                    ? AppTheme.primaryMint
                                                    : textSecondary,
                                                fontWeight: isChecked
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isAlreadyDownloaded)
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: offlineReadyTagBg,
                                        borderRadius: BorderRadius.circular(20),
                                        border: isDark
                                            ? null
                                            : Border.all(color: borderUncheckedColor),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.offline_pin,
                                            color: AppTheme.primaryMint,
                                            size: 14,
                                          ),
                                          const Gap(4),
                                          Text(
                                            AppLocalization.get('offline_ready', appLanguage),
                                            style: const TextStyle(
                                              color: AppTheme.primaryMint,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).animate().fadeIn(duration: 300.ms),
                                  ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (index * 25).ms)
                          .slideX(begin: 0.05, end: 0);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/data/models/resource_model.dart';
import 'package:al_hadith/logic/setup/setup_state.dart';

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
    bool isWideWindow = MediaQuery.of(context).size.width > AppTheme.wideWidth;

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
          'Select Resources',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        const Gap(6),
        Text(
              'Select books to download. Your preferred language is pre-selected by default. You can choose other languages too.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
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
                          '${lang.displayName} Resources',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
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
                            child: const Text(
                              'Default',
                              style: TextStyle(
                                color: AppTheme.primaryMint,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  Gap(20),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWideWindow ? 2 : 1,
                      childAspectRatio: isWideWindow ? 3 : 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
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

                      return GestureDetector(
                            onTap: () => onToggle(res.book),
                            child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isChecked
                                        ? AppTheme.darkSurfaceCard.withValues(
                                            alpha: 0.4,
                                          )
                                        : AppTheme.darkSurface.withValues(
                                            alpha: 0.5,
                                          ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isChecked
                                          ? AppTheme.primaryMint.withValues(
                                              alpha: 0.3,
                                            )
                                          : const Color(0xFF1E293B),
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
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: AppTheme.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Gap(2),
                                            if (res.languageCode != "eng")
                                              Text(
                                                res.name,

                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppTheme.textSecondary,
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
                                                const Text(
                                                  '•',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                ),
                                                const Gap(8),
                                                Text(
                                                  '${res.hadithCount} Hadiths',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                ),
                                                const Gap(6),
                                                const Text(
                                                  '•',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                ),
                                                const Gap(6),
                                                Text(
                                                  '${res.sectionCount} Ch',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Gap(4),
                                            Text(
                                              'Download Size: ${res.formattedZipSize}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isChecked
                                                    ? AppTheme.primaryMint
                                                    : AppTheme.textSecondary,
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
                                        color: AppTheme.darkSurfaceCard,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.offline_pin,
                                            color: AppTheme.primaryMint,
                                            size: 14,
                                          ),
                                          Gap(4),
                                          Text(
                                            'Offline Ready',
                                            style: TextStyle(
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

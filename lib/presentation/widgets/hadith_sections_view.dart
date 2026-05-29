import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';

class HadithSectionsView extends StatefulWidget {
  const HadithSectionsView({super.key});

  @override
  State<HadithSectionsView> createState() => _HadithSectionsViewState();
}

class _HadithSectionsViewState extends State<HadithSectionsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Intelligently auto-load first book sections if no book is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<HadithCubit>();
      final state = cubit.state;
      if (state.downloadedBooks.isNotEmpty && state.selectedBookKey == null) {
        cubit.loadBookSections(state.downloadedBooks.first.book);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final searchBgColor = Theme.of(context).colorScheme.surface;

    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryMint),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const Gap(16),
                  Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textSecondary),
                  ),
                  const Gap(16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryMint,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () =>
                        context.read<HadithCubit>().loadDashboard(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.downloadedBooks.isEmpty) {
          return _buildEmptyState();
        }

        final selectedKey =
            state.selectedBookKey ?? state.downloadedBooks.first.book;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Horizontal Book Selector Carousel
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Select Resource',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: state.downloadedBooks.length,
                itemBuilder: (context, index) {
                  final book = state.downloadedBooks[index];
                  final isSelected = book.book == selectedKey;
                  final readCount = state.readCounts[book.book] ?? 0;
                  final totalHadiths = book.hadithCount;
                  final ratio = totalHadiths > 0
                      ? readCount / totalHadiths
                      : 0.0;

                  final inactiveBookBgColor = isDark
                      ? AppTheme.darkSurfaceCard.withValues(alpha: 0.2)
                      : const Color(0xFFF3F4F6);

                  return GestureDetector(
                    onTap: () {
                      if (book.book != state.selectedBookKey) {
                        _searchController.clear();
                        context.read<HadithCubit>().loadBookSections(book.book);
                      }
                    },
                    child:
                        AnimatedContainer(
                              duration: 250.ms,
                              curve: Curves.easeInOut,
                              width: 175,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                                vertical: 8.0,
                              ),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          AppTheme.primaryMint.withValues(
                                            alpha: 0.15,
                                          ),
                                          AppTheme.secondaryIndigo.withValues(
                                            alpha: 0.06,
                                          ),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : inactiveBookBgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryMint
                                      : borderDividerColor,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryMint
                                              .withValues(alpha: 0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        book.langFlag,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const Gap(6),
                                      Expanded(
                                        child: Text(
                                          book.languageCode == "eng"
                                              ? book.langDisplayName
                                              : "${book.langNativeName} (${book.langDisplayName})",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: textSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(4),
                                  Text(
                                    book.nameNative.isNotEmpty
                                        ? book.nameNative
                                        : book.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (book.nameNative.isNotEmpty &&
                                      book.languageCode != "eng")
                                    Text(
                                      book.name,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const Gap(6),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${book.sectionCount} Ch.',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: textSecondary,
                                            ),
                                          ),
                                          Text(
                                            '${(ratio * 100).toStringAsFixed(0)}% Read',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? AppTheme.primaryMint
                                                  : textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Gap(4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: LinearProgressIndicator(
                                          value: ratio,
                                          minHeight: 3,
                                          backgroundColor: borderDividerColor,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                isSelected
                                                    ? AppTheme.primaryMint
                                                    : textSecondary.withValues(
                                                        alpha: 0.6,
                                                      ),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                            .animate(target: isSelected ? 1.0 : 0.0)
                            .scale(
                              begin: const Offset(0.98, 0.98),
                              end: const Offset(1.02, 1.02),
                              duration: 200.ms,
                            ),
                  );
                },
              ),
            ),

            // 2. Glassmorphic Chapter Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: searchBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderDividerColor),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) =>
                      context.read<HadithCubit>().updateSectionsSearch(val),
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search chapters by name...',
                    hintStyle: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: textSecondary,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: textSecondary,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              context.read<HadithCubit>().updateSectionsSearch(
                                '',
                              );
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                ),
              ),
            ),

            // 3. Chapters List Header Counter
            if (state.isLoadingSections) ...[
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryMint),
                ),
              ),
            ] else if (state.sectionsErrorMessage != null) ...[
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 40,
                        ),
                        const Gap(12),
                        Text(
                          state.sectionsErrorMessage!,
                          style: TextStyle(color: textSecondary),
                        ),
                        const Gap(12),
                        ElevatedButton(
                          onPressed: () => context
                              .read<HadithCubit>()
                              .loadBookSections(selectedKey),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 6.0,
                ),
                child: Text(
                  '${state.filteredSections.length} Chapters Available',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 4. Vertical Chapters Scroll List
              Expanded(
                child: state.filteredSections.isEmpty
                    ? _buildNoResultsState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: state.filteredSections.length,
                        itemBuilder: (context, index) {
                          final section = state.filteredSections[index];
                          final cardBgColor = isDark
                              ? AppTheme.darkSurfaceCard.withValues(alpha: 0.2)
                              : const Color(0xFFF3F4F6);

                          return GestureDetector(
                                onTap: () {
                                  final displayName =
                                      section.sectionNameNative.isNotEmpty
                                      ? section.sectionNameNative
                                      : section.sectionName;
                                  final encodedName = Uri.encodeComponent(
                                    displayName,
                                  );
                                  context.push(
                                    '/book/$selectedKey/hadith/${section.startHadithNumber}?sectionId=${section.id}&sectionName=$encodedName',
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cardBgColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: borderDividerColor,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Unique visual tag index
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.primaryMint
                                              .withValues(alpha: 0.1),
                                          border: Border.all(
                                            color: AppTheme.primaryMint
                                                .withValues(alpha: 0.35),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${section.id}',
                                            style: const TextStyle(
                                              color: AppTheme.primaryMint,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              section
                                                      .sectionNameNative
                                                      .isNotEmpty
                                                  ? section.sectionNameNative
                                                  : section.sectionName,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.bold,
                                                color: textPrimary,
                                                height: 1.3,
                                              ),
                                            ),
                                            if (section
                                                .sectionNameNative
                                                .isNotEmpty)
                                              Text(
                                                section.sectionName,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: textSecondary,
                                                  height: 1.2,
                                                ),
                                              ),
                                            const Gap(6),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.bookmark_outline,
                                                  color: textSecondary,
                                                  size: 12,
                                                ),
                                                const Gap(4),
                                                Text(
                                                  'Hadith: ${section.startHadithNumber} - ${section.endHadithNumber}',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                                const Gap(8),
                                                Text(
                                                  '•',
                                                  style: TextStyle(
                                                    color: textSecondary,
                                                    fontSize: 11.5,
                                                  ),
                                                ),
                                                const Gap(8),
                                                Text(
                                                  '${section.hadithCount} items',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: textSecondary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Gap(8),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: textSecondary,
                                        size: 13,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 250.ms, delay: (index * 15).ms)
                              .slideX(begin: 0.03, end: 0);
                        },
                      ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryMint.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                size: 48,
                color: AppTheme.primaryMint,
              ),
            ),
            const Gap(24),
            Text(
              'No Offline Books',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const Gap(8),
            Text(
              'Chapters will appear here once you download resources from the setup wizard or download center.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, height: 1.4),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }

  Widget _buildNoResultsState() {
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: textSecondary.withValues(alpha: 0.2),
              size: 48,
            ),
            const Gap(16),
            Text(
              'No chapters match your query.',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

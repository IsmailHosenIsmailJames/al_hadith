import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';

class BookSectionsScreen extends StatefulWidget {
  final String bookKey;

  const BookSectionsScreen({super.key, required this.bookKey});

  @override
  State<BookSectionsScreen> createState() => _BookSectionsScreenState();
}

class _BookSectionsScreenState extends State<BookSectionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dispatch section loading
    context.read<HadithCubit>().loadBookSections(widget.bookKey);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasColor = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final cardBgColor = isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.2) : Colors.white;
    final searchBgColor = isDark ? AppTheme.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: BlocBuilder<HadithCubit, HadithState>(
          buildWhen: (p, c) =>
              p.selectedBookKey != c.selectedBookKey ||
              p.downloadedBooks != c.downloadedBooks,
          builder: (context, state) {
            // Find book name in metadata
            if (!state.downloadedBooks.any((b) => b.book == widget.bookKey)) {
              return Text(
                'Hadith Book',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              );
            }

            final book = state.downloadedBooks.firstWhere(
              (b) => b.book == widget.bookKey,
            );
            final displayName = book.nameNative.isNotEmpty
                ? book.nameNative
                : book.name;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                if (book.nameNative.isNotEmpty)
                  Text(
                    book.name,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
              ],
            );
          },
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<HadithCubit, HadithState>(
        builder: (context, state) {
          if (state.isLoadingSections) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryMint),
            );
          }

          if (state.sectionsErrorMessage != null) {
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
                      state.sectionsErrorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textSecondary),
                    ),
                    const Gap(16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryMint,
                        foregroundColor: AppTheme.darkCanvas,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context
                          .read<HadithCubit>()
                          .loadBookSections(widget.bookKey),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final sections = state.filteredSections;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Search Bar Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
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
                                context
                                    .read<HadithCubit>()
                                    .updateSectionsSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                      ),
                    ),
                  ),
                ),
              ),

              // Metadata counter
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  bottom: 8.0,
                ),
                child: Text(
                  '${sections.length} Chapters Available',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Sections List
              Expanded(
                child: sections.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              color: textSecondary.withValues(
                                alpha: 0.3,
                              ),
                              size: 48,
                            ),
                            const Gap(16),
                            Text(
                              'No chapters found matching your query.',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: sections.length,
                        itemBuilder: (context, index) {
                          final section = sections[index];

                          return GestureDetector(
                                onTap: () {
                                  // Route to reading screen, starting at the start_hadith_number
                                  final displayName =
                                      section.sectionNameNative.isNotEmpty
                                      ? section.sectionNameNative
                                      : section.sectionName;
                                  final encodedName = Uri.encodeComponent(
                                    displayName,
                                  );
                                  context.push(
                                    '/book/${widget.bookKey}/hadith/${section.startHadithNumber}?sectionId=${section.id}&sectionName=$encodedName',
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
                                      // Chapter Index Circle
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.primaryMint
                                              .withValues(alpha: 0.12),
                                          border: Border.all(
                                            color: AppTheme.primaryMint
                                                .withValues(alpha: 0.4),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: AppTheme.primaryMint,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
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
                                                fontSize: 15,
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
                                                  Icons.menu_book,
                                                  color: textSecondary,
                                                  size: 12,
                                                ),
                                                const Gap(4),
                                                Text(
                                                  'Hadith: ${section.startHadithNumber} - ${section.endHadithNumber}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                                const Gap(8),
                                                Text(
                                                  '•',
                                                  style: TextStyle(
                                                    color: textSecondary,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const Gap(8),
                                                Text(
                                                  '${section.hadithCount} items',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                    fontWeight: FontWeight.w600,
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
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: (index * 20).ms)
                              .slideX(begin: 0.04, end: 0);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

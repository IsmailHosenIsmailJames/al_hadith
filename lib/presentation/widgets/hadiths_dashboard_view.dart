import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';

class HadithsDashboardView extends StatefulWidget {
  const HadithsDashboardView({super.key});

  @override
  State<HadithsDashboardView> createState() => _HadithsDashboardViewState();
}

class _HadithsDashboardViewState extends State<HadithsDashboardView> {
  @override
  void initState() {
    super.initState();
    // Dispatch dashboard load to sync files and history metrics on tab entry
    context.read<HadithCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);

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
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          color: AppTheme.primaryMint,
          backgroundColor: surfaceColor,
          onRefresh: () => context.read<HadithCubit>().loadDashboard(),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. History or Daily Inspiration Panel
              _buildHistoryHeader(context, state),

              const Gap(28),

              // 2. Downloaded Book Categories
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                child: Text(
                  'Your Offline Library',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.downloadedBooks.length,
                itemBuilder: (context, index) {
                  final book = state.downloadedBooks[index];
                  final readCount = state.readCounts[book.book] ?? 0;
                  final totalHadiths = book.hadithCount;

                  // Calculate dynamic reading ratio
                  final double ratio = totalHadiths > 0
                      ? readCount / totalHadiths
                      : 0.0;
                  final percentageText = (ratio * 100).toStringAsFixed(2);
                  final cardBgColor = isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.2) : const Color(0xFFF3F4F6);

                  return GestureDetector(
                        onTap: () {
                          context.push('/book/${book.book}');
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderDividerColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Unique book visual card logo
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryMint.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.primaryMint.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.menu_book_rounded,
                                      color: AppTheme.primaryMint,
                                      size: 20,
                                    ),
                                  ),
                                  const Gap(14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.nameNative.isNotEmpty
                                              ? book.nameNative
                                              : book.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                        ),
                                        if (book.nameNative.isNotEmpty &&
                                            book.languageCode != "eng")
                                          Text(
                                            book.name,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: textSecondary,
                                            ),
                                          ),
                                        const Gap(4),
                                        Text(
                                          '${book.hadithCount} Hadiths • ${book.sectionCount} Chapters',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textSecondary,
                                          ),
                                        ),
                                        if (book.languageCode.isNotEmpty) ...[
                                          const Gap(6),
                                          // Language pill badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.secondaryIndigo
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: AppTheme.secondaryIndigo
                                                    .withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  book.langFlag,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const Gap(4),
                                                Text(
                                                  book.languageCode == "eng"
                                                      ? book.langDisplayName
                                                      : "${book.langNativeName} (${book.langDisplayName})",
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme
                                                        .secondaryIndigo,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: textSecondary,
                                    size: 24,
                                  ),
                                ],
                              ),
                              const Gap(16),

                              // Custom Linear Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 5,
                                  backgroundColor: borderDividerColor,
                                  color: AppTheme.primaryMint,
                                ),
                              ),
                              const Gap(8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$readCount / $totalHadiths read',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$percentageText%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.primaryMint,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 350.ms, delay: (index * 40).ms)
                      .slideY(begin: 0.05, end: 0);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryHeader(BuildContext context, HadithState state) {
    final history = state.history;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final tickColor = isDark ? AppTheme.darkCanvas : Colors.white;

    if (history != null) {
      // Premium interactive resume card
      return Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryMint.withValues(alpha: 0.15),
              AppTheme.secondaryIndigo.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryMint.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryMint.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Pulsing read dot
                Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryMint,
                        shape: BoxShape.circle,
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(end: const Offset(1.5, 1.5), duration: 1000.ms),
                const Gap(8),
                const Text(
                  'RESUME READING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryMint,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const Gap(14),
            Text(
              history.bookName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const Gap(4),
            Text(
              'Hadith Reference: #${history.hadithNumber}',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (history.sectionTitle.isNotEmpty) ...[
              const Gap(4),
              Row(
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    color: textSecondary,
                    size: 13,
                  ),
                  const Gap(5),
                  Expanded(
                    child: Text(
                      history.sectionTitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const Gap(20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMint,
                foregroundColor: tickColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              onPressed: () {
                final encodedSection = Uri.encodeComponent(
                  history.sectionTitle,
                );
                context.push(
                  '/book/${history.bookKey}/hadith/${history.hadithNumber}?sectionName=$encodedSection',
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 18),
                  Gap(6),
                  Text(
                    'Continue Reading',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.98, 0.98));
    }

    final quoteBgColor = isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.12) : const Color(0xFFF3F4F6);

    // Curated Empty Quote Panel
    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: quoteBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderDividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: AppTheme.primaryMint,
            size: 32,
          ),
          const Gap(12),
          Text(
            '"Verily, actions are judged by intentions, and every person will have only what they intended."',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: textPrimary,
              height: 1.5,
            ),
          ),
          const Gap(12),
          Text(
            '— Sahih al-Bukhari, Hadith 1',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildEmptyState(BuildContext context) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickColor = isDark ? AppTheme.darkCanvas : Colors.white;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryMint.withValues(alpha: 0.08),
              ),
              child: const Icon(
                Icons.library_books_rounded,
                color: AppTheme.primaryMint,
                size: 36,
              ),
            ),
            const Gap(24),
            Text(
              'Your Library is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const Gap(8),
            Text(
              'No downloaded hadith books detected on this device. Click the button below to download static resources.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const Gap(24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMint,
                foregroundColor: tickColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              onPressed: () {
                // Navigate to the Setup wizard screen to choose and download databases!
                context.push('/setup');
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text(
                'Configure Resources',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

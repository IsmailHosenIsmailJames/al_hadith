import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/core/localization/app_localization.dart';

class HadithsDashboardView extends StatefulWidget {
  const HadithsDashboardView({super.key});

  @override
  State<HadithsDashboardView> createState() => _HadithsDashboardViewState();
}

class _HadithsDashboardViewState extends State<HadithsDashboardView> {
  bool _animateList = true;

  @override
  void initState() {
    super.initState();
    // Dispatch dashboard load to sync files and history metrics on tab entry
    context.read<HadithCubit>().loadDashboard();

    // Disable initial animations after 800ms to avoid re-triggering during drag & drop reordering or sort preference change
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _animateList = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);

    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;

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
                    child: Text(
                      AppLocalization.get('retry_setup_download', appLanguage),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.downloadedBooks.isEmpty) {
          return _buildEmptyState(context, appLanguage);
        }

        return RefreshIndicator(
          color: AppTheme.primaryMint,
          backgroundColor: surfaceColor,
          onRefresh: () => context.read<HadithCubit>().loadDashboard(),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            children: [
              // 0. Study Stats Panel
              _buildStudyStatsHeader(context, state, appLanguage),

              const Gap(10),

              // 1. History or Daily Inspiration Panel
              _buildHistoryHeader(context, state, appLanguage),

              const Gap(16),

              // 2. Downloaded Book Categories Header with Sort Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppLocalization.get('your_offline_library', appLanguage),
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMint.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.primaryMint.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            '${state.downloadedBooks.length}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryMint,
                            ),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => _showSortSelectorBottomSheet(
                        context,
                        state,
                        appLanguage,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.sort_rounded,
                              color: AppTheme.primaryMint,
                              size: 16,
                            ),
                            const Gap(4),
                            Text(
                              AppLocalization.get('sort_books', appLanguage),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryMint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.downloadedBooks.length,
                onReorderItem: (oldIndex, newIndex) {
                  context.read<HadithCubit>().reorderBooks(oldIndex, newIndex);
                },
                buildDefaultDragHandles: false,
                itemBuilder: (context, index) {
                  final book = state.downloadedBooks[index];
                  final readCount = state.readCounts[book.book] ?? 0;
                  final totalHadiths = book.hadithCount;

                  // Calculate dynamic reading ratio
                  final double ratio = totalHadiths > 0
                      ? readCount / totalHadiths
                      : 0.0;
                  final percentageText = (ratio * 100).toStringAsFixed(2);
                  final cardBgColor = isDark
                      ? AppTheme.darkSurfaceCard.withValues(alpha: 0.25)
                      : const Color(0xFFF3F4F6);

                  final Widget card = GestureDetector(
                        onTap: () {
                          context.push('/book/${book.book}');
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderDividerColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.08 : 0.02,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
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
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryMint.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppTheme.primaryMint.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.menu_book_rounded,
                                      color: AppTheme.primaryMint,
                                      size: 18,
                                    ),
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                book.nameNative.isNotEmpty
                                                    ? book.nameNative
                                                    : book.name,
                                                style: TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: textPrimary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (book.languageCode.isNotEmpty) ...[
                                              const Gap(6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 1.5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.secondaryIndigo
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: AppTheme.secondaryIndigo
                                                        .withValues(alpha: 0.25),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      book.langFlag,
                                                      style: const TextStyle(
                                                        fontSize: 9.5,
                                                      ),
                                                    ),
                                                    const Gap(3),
                                                    Text(
                                                      book.languageCode == "eng"
                                                          ? book.langDisplayName
                                                          : book.langNativeName,
                                                      style: const TextStyle(
                                                        fontSize: 9,
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
                                        if (book.nameNative.isNotEmpty &&
                                            book.languageCode != "eng")
                                          Text(
                                            book.name,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const Gap(2),
                                        Row(
                                          children: [
                                            Text(
                                              AppLocalization.get(
                                                'hadiths_chapters_summary',
                                                appLanguage,
                                                args: {
                                                  'hadiths': '${book.hadithCount}',
                                                  'chapters':
                                                      '${book.sectionCount}',
                                                },
                                              ),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: textSecondary,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (totalHadiths > 0)
                                              Text(
                                                '$percentageText%',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppTheme.primaryMint,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(8),
                                  state.bookSortType == 'custom'
                                      ? ReorderableDragStartListener(
                                          index: index,
                                          child: Icon(
                                            Icons.drag_handle_rounded,
                                            color: textSecondary,
                                            size: 20,
                                          ),
                                        )
                                      : Icon(
                                          Icons.chevron_right_rounded,
                                          color: textSecondary.withValues(
                                            alpha: 0.6,
                                          ),
                                          size: 20,
                                        ),
                                ],
                              ),
                              if (totalHadiths > 0) ...[
                                const Gap(8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 3.5,
                                    backgroundColor: borderDividerColor,
                                    color: AppTheme.primaryMint,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );

                  final Widget animatedCard = _animateList
                      ? card
                          .animate()
                          .fadeIn(duration: 350.ms, delay: (index * 40).ms)
                          .slideY(begin: 0.05, end: 0)
                      : card;

                  return KeyedSubtree(
                    key: ValueKey(book.book),
                    child: animatedCard,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryHeader(
    BuildContext context,
    HadithState state,
    String appLanguage,
  ) {
    final history = state.history;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final tickColor = isDark ? AppTheme.darkCanvas : Colors.white;

    if (history != null) {
      // Sleek compact resume card
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final encodedSection = Uri.encodeComponent(
              history.sectionTitle,
            );
            context.push(
              '/book/${history.bookKey}/hadith/${history.hadithNumber}?sectionName=$encodedSection',
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryMint.withValues(alpha: 0.12),
                  AppTheme.secondaryIndigo.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryMint.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryMint.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon Avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMint.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.primaryMint.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppTheme.primaryMint,
                    size: 19,
                  ),
                ),
                const Gap(12),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryMint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Gap(5),
                          Text(
                            AppLocalization.get('resume_reading', appLanguage),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryMint,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const Gap(2),
                      Text(
                        history.bookName,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(1),
                      Row(
                        children: [
                          Text(
                            AppLocalization.get(
                              'hadith_reference',
                              appLanguage,
                              args: {'number': '${history.hadithNumber}'},
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (history.sectionTitle.isNotEmpty) ...[
                            Text(
                              ' • ',
                              style: TextStyle(fontSize: 11, color: textSecondary),
                            ),
                            Expanded(
                              child: Text(
                                history.sectionTitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                // Compact Action Pill Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMint,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryMint.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 16,
                        color: tickColor,
                      ),
                      const Gap(3),
                      Text(
                        AppLocalization.get('continue_reading', appLanguage),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: tickColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.98, 0.98));
    }

    final quoteBgColor = isDark
        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.12)
        : const Color(0xFFF3F4F6);

    // Compact Curated Empty Quote Panel
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: quoteBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryMint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              color: AppTheme.primaryMint,
              size: 18,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalization.get('daily_inspiration_quote', appLanguage),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: textPrimary,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(
                  AppLocalization.get('daily_inspiration_source', appLanguage),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildEmptyState(BuildContext context, String appLanguage) {
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
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
              AppLocalization.get('library_empty_title', appLanguage),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const Gap(8),
            Text(
              AppLocalization.get('library_empty_desc', appLanguage),
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
              label: Text(
                AppLocalization.get('setup_books_cta', appLanguage),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getHadithsReadTodayCount(HadithState state) {
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    int count = 0;
    for (final r in state.readHistory) {
      final date = DateTime.fromMillisecondsSinceEpoch(r.timestamp);
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      if (dateStr == todayStr) {
        count++;
      }
    }
    return count;
  }

  int _getTotalReadingMinutes(HadithState state) {
    int totalSecs = 0;
    for (final s in state.readingSessions) {
      totalSecs += s.durationSeconds;
    }
    return (totalSecs / 60).round();
  }

  Widget _buildStudyStatsHeader(
    BuildContext context,
    HadithState state,
    String appLanguage,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final cardBgColor = isDark
        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.25)
        : const Color(0xFFF3F4F6);

    final readToday = _getHadithsReadTodayCount(state);
    final dailyGoal = state.dailyGoal;
    final readingMins = _getTotalReadingMinutes(state);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row with "DAILY ACTIVITY" and "Analytics ›"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryMint,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    'DAILY ACTIVITY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.push('/stats'),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalization.get('view_analytics', appLanguage),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryMint,
                        ),
                      ),
                      const Gap(2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.primaryMint,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Gap(7),
          // 3 Metrics in a Compact Row
          Row(
            children: [
              // 1. Streak
              Expanded(
                child: InkWell(
                  onTap: () => context.push('/stats'),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5.5),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.orangeAccent,
                            size: 16,
                          ),
                        ),
                        const Gap(6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${state.currentStreak}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' d',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                AppLocalization.get('current_streak', appLanguage),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(height: 26, width: 1, color: borderDividerColor),
              // 2. Goal
              Expanded(
                child: InkWell(
                  onTap: () => _showGoalSelectorBottomSheet(
                    context,
                    state,
                    appLanguage,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5.5),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMint.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppTheme.primaryMint,
                            size: 16,
                          ),
                        ),
                        const Gap(6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$readToday / $dailyGoal',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                AppLocalization.get('daily_goal', appLanguage),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(height: 26, width: 1, color: borderDividerColor),
              // 3. Time
              Expanded(
                child: InkWell(
                  onTap: () => context.push('/stats'),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5.5),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryIndigo.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.timer_outlined,
                            color: AppTheme.secondaryIndigo,
                            size: 16,
                          ),
                        ),
                        const Gap(6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$readingMins',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' m',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                AppLocalization.get('reading_time', appLanguage),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGoalSelectorBottomSheet(
    BuildContext context,
    HadithState state,
    String appLanguage,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final navBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);

    final goals = [1, 3, 5, 10, 15, 20, 25, 30];

    showModalBottomSheet(
      context: context,
      backgroundColor: navBgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textSecondary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(20),
                Text(
                  AppLocalization.get('daily_goal_selector_title', appLanguage),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const Gap(6),
                Text(
                  AppLocalization.get('daily_goal_selector_desc', appLanguage),
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const Gap(20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goalOption = goals[index];
                    final isSelected = goalOption == state.dailyGoal;
                    final cardColor = isSelected
                        ? AppTheme.primaryMint.withValues(alpha: 0.1)
                        : Colors.transparent;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryMint
                              : borderDividerColor,
                        ),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          context.read<HadithCubit>().updateDailyGoal(goalOption);
                        },
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected ? AppTheme.primaryMint : textSecondary,
                        ),
                        title: Text(
                          goalOption == 1
                              ? '1 Hadith'
                              : goalOption == 3
                              ? '3 Hadiths (Recommended)'
                              : '$goalOption Hadiths',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSortSelectorBottomSheet(
    BuildContext context,
    HadithState state,
    String appLanguage,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final navBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);

    final sortTypes = ['popularity', 'name', 'date', 'hadithCount', 'custom'];
    final sortIcons = {
      'popularity': Icons.star_rounded,
      'name': Icons.abc_rounded,
      'date': Icons.calendar_today_rounded,
      'hadithCount': Icons.format_list_numbered_rounded,
      'custom': Icons.drag_indicator_rounded,
    };

    final sortDisplayNames = {
      'popularity': AppLocalization.get('sort_popularity', appLanguage),
      'name': AppLocalization.get('sort_name', appLanguage),
      'date': AppLocalization.get('sort_date', appLanguage),
      'hadithCount': AppLocalization.get('sort_hadith_count', appLanguage),
      'custom': AppLocalization.get('sort_custom', appLanguage),
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: navBgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.64,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setSheetState) {
            final activeSortType = state.bookSortType;
            final isAscending = state.bookSortAscending;
            final isCustom = activeSortType == 'custom';

            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: textSecondary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        const Icon(Icons.sort_rounded, color: AppTheme.primaryMint),
                        const Gap(8),
                        Text(
                          AppLocalization.get('sort_books', appLanguage),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    Text(
                      AppLocalization.get('sort_by', appLanguage),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                      ),
                    ),
                    const Gap(8),
                    ...sortTypes.map((type) {
                      final isSelected = type == activeSortType;
                      final cardColor = isSelected
                          ? AppTheme.primaryMint.withValues(alpha: 0.08)
                          : Colors.transparent;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryMint
                                : borderDividerColor,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          onTap: () {
                            // Close and apply sort type
                            Navigator.pop(ctx);
                            context.read<HadithCubit>().updateBookSort(sortType: type);
                          },
                          leading: Icon(
                            sortIcons[type] ?? Icons.sort,
                            color: isSelected ? AppTheme.primaryMint : textSecondary,
                          ),
                          title: Text(
                            sortDisplayNames[type] ?? type,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: textPrimary,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppTheme.primaryMint,
                                )
                              : null,
                        ),
                      );
                    }),
                    if (!isCustom) ...[
                      const Gap(16),
                      Text(
                        AppLocalization.get('sort_order', appLanguage),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textSecondary,
                        ),
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOrderButton(
                              context: context,
                              isSelected: isAscending,
                              label: activeSortType == 'popularity'
                                  ? (appLanguage == 'ben' ? 'জনপ্রিয়তা (বেশি)' : 'Most Popular')
                                  : (activeSortType == 'name'
                                      ? 'A → Z'
                                      : (activeSortType == 'hadithCount'
                                          ? (appLanguage == 'ben' ? 'বেশি হাদিস' : 'Most Hadiths')
                                          : AppLocalization.get('sort_ascending', appLanguage))),
                              icon: activeSortType == 'popularity'
                                  ? Icons.star_rounded
                                  : Icons.arrow_upward_rounded,
                              onTap: () {
                                Navigator.pop(ctx);
                                context.read<HadithCubit>().updateBookSort(isAscending: true);
                              },
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: _buildOrderButton(
                              context: context,
                              isSelected: !isAscending,
                              label: activeSortType == 'popularity'
                                  ? (appLanguage == 'ben' ? 'জনপ্রিয়তা (কম)' : 'Least Popular')
                                  : (activeSortType == 'name'
                                      ? 'Z → A'
                                      : (activeSortType == 'hadithCount'
                                          ? (appLanguage == 'ben' ? 'কম হাদিস' : 'Fewest Hadiths')
                                          : AppLocalization.get('sort_descending', appLanguage))),
                              icon: activeSortType == 'popularity'
                                  ? Icons.star_border_rounded
                                  : Icons.arrow_downward_rounded,
                              onTap: () {
                                Navigator.pop(ctx);
                                context.read<HadithCubit>().updateBookSort(isAscending: false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (isCustom) ...[
                      const Gap(16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryIndigo.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.secondaryIndigo.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.secondaryIndigo,
                              size: 20,
                            ),
                            const Gap(10),
                            Expanded(
                              child: Text(
                                AppLocalization.get('sort_custom_tip', appLanguage),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.secondaryIndigo,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderButton({
    required BuildContext context,
    required bool isSelected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryMint.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryMint : borderDividerColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.primaryMint : textSecondary,
            ),
            const Gap(6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryMint : textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

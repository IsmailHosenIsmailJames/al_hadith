import 'dart:math';
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
import 'package:al_hadith/data/models/hadith_model.dart';

enum ChapterFilterType { all, inProgress, completed, unread, bookmarked }

class HadithSectionsView extends StatefulWidget {
  const HadithSectionsView({super.key});

  @override
  State<HadithSectionsView> createState() => _HadithSectionsViewState();
}

class _SectionStats {
  final int readCount;
  final bool isCompleted;
  final bool isInProgress;
  final bool isUnread;
  final int bookmarkCount;

  _SectionStats({
    required this.readCount,
    required this.isCompleted,
    required this.isInProgress,
    required this.isUnread,
    required this.bookmarkCount,
  });
}

class _HadithSectionsViewState extends State<HadithSectionsView> {
  final TextEditingController _searchController = TextEditingController();
  ChapterFilterType _selectedFilter = ChapterFilterType.all;

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

  _SectionStats _calculateSectionStats(
    HadithSection section,
    Set<int> readHadiths,
    Set<String> bookmarks,
    String bookKey,
  ) {
    int readCount = 0;
    int bookmarkCount = 0;
    for (int num = section.startHadithNumber; num <= section.endHadithNumber; num++) {
      if (readHadiths.contains(num)) {
        readCount++;
      }
      if (bookmarks.contains('${bookKey}_$num')) {
        bookmarkCount++;
      }
    }
    final isCompleted = section.hadithCount > 0 && readCount >= section.hadithCount;
    final isInProgress = readCount > 0 && !isCompleted;
    final isUnread = readCount == 0;
    return _SectionStats(
      readCount: readCount,
      isCompleted: isCompleted,
      isInProgress: isInProgress,
      isUnread: isUnread,
      bookmarkCount: bookmarkCount,
    );
  }

  String _getFilterLabel(ChapterFilterType type, String lang, int count) {
    final isBn = lang == 'bng';
    final isAr = lang == 'ara';
    switch (type) {
      case ChapterFilterType.all:
        return isBn ? 'সকল ($count)' : isAr ? 'الكل ($count)' : 'All ($count)';
      case ChapterFilterType.inProgress:
        return isBn ? 'চলমান ($count)' : isAr ? 'قيد القراءة ($count)' : 'In Progress ($count)';
      case ChapterFilterType.completed:
        return isBn ? 'সম্পন্ন ($count)' : isAr ? 'সম্পূর্ণ ($count)' : 'Completed ($count)';
      case ChapterFilterType.unread:
        return isBn ? 'অপঠিত ($count)' : isAr ? 'غير مقروء ($count)' : 'Unread ($count)';
      case ChapterFilterType.bookmarked:
        return isBn ? 'বুকমার্ক ($count)' : isAr ? 'محفوظ ($count)' : 'Saved ($count)';
    }
  }

  void _showJumpDialog(
    BuildContext context,
    HadithState state,
    String selectedKey,
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

    final currentBook = state.downloadedBooks.firstWhere(
      (b) => b.book == selectedKey,
      orElse: () => state.downloadedBooks.first,
    );
    final totalChapters = state.activeSections.length;
    final totalHadiths = currentBook.hadithCount;

    final controller = TextEditingController();
    int jumpMode = 0; // 0 = Chapter, 1 = Hadith

    showModalBottomSheet(
      context: context,
      backgroundColor: navBgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isBn = appLanguage == 'bng';
          final title = jumpMode == 0
              ? (isBn ? 'অধ্যায় নম্বরে যান' : 'Jump to Chapter')
              : (isBn ? 'হাদিস নম্বরে যান' : 'Jump to Hadith');
          final maxLimit = jumpMode == 0 ? totalChapters : totalHadiths;
          final hint = jumpMode == 0
              ? (isBn ? 'অধ্যায় নম্বর লিখুন (১ - $totalChapters)' : 'Enter chapter number (1 - $totalChapters)')
              : (isBn ? 'হাদিস নম্বর লিখুন (১ - $totalHadiths)' : 'Enter hadith number (1 - $totalHadiths)');

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textSecondary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? 'সরাসরি যান' : 'Direct Jump',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    // Toggle Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurfaceCard
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setModalState(() => jumpMode = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: jumpMode == 0
                                    ? AppTheme.primaryMint
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isBn ? 'অধ্যায়' : 'Chapter',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: jumpMode == 0
                                      ? (isDark ? AppTheme.darkCanvas : Colors.white)
                                      : textSecondary,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setModalState(() => jumpMode = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: jumpMode == 1
                                    ? AppTheme.primaryMint
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isBn ? 'হাদিস' : 'Hadith',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: jumpMode == 1
                                      ? (isDark ? AppTheme.darkCanvas : Colors.white)
                                      : textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderDividerColor),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: textSecondary.withValues(alpha: 0.7),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.pin_rounded,
                        color: AppTheme.primaryMint,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const Gap(16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryMint,
                      foregroundColor: isDark ? AppTheme.darkCanvas : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final input = int.tryParse(controller.text.trim());
                      if (input == null || input < 1 || input > maxLimit) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBn
                                  ? 'অনুগ্রহ করে ১ থেকে $maxLimit এর মধ্যে একটি নম্বর লিখুন'
                                  : 'Please enter a number between 1 and $maxLimit',
                            ),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(ctx);

                      if (jumpMode == 0) {
                        // Jump to chapter
                        final target = state.activeSections.firstWhere(
                          (s) => s.id == input,
                          orElse: () => state.activeSections[(input - 1).clamp(0, state.activeSections.length - 1)],
                        );
                        final displayName = target.sectionNameNative.isNotEmpty
                            ? target.sectionNameNative
                            : target.sectionName;
                        context.push(
                          '/book/$selectedKey/hadith/${target.startHadithNumber}?sectionId=${target.id}&sectionName=${Uri.encodeComponent(displayName)}',
                        );
                      } else {
                        // Jump to hadith
                        final target = state.activeSections.firstWhere(
                          (s) => input >= s.startHadithNumber && input <= s.endHadithNumber,
                          orElse: () => state.activeSections.first,
                        );
                        final displayName = target.sectionNameNative.isNotEmpty
                            ? target.sectionNameNative
                            : target.sectionName;
                        context.push(
                          '/book/$selectedKey/hadith/$input?sectionId=${target.id}&sectionName=${Uri.encodeComponent(displayName)}',
                        );
                      }
                    },
                    child: Text(
                      isBn ? 'সরাসরি যান' : 'Jump Now',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _pickRandomChapter(
    BuildContext context,
    List<HadithSection> sections,
    String selectedKey,
    String appLanguage,
  ) {
    if (sections.isEmpty) return;
    final random = Random();
    final randomSection = sections[random.nextInt(sections.length)];
    final displayName = randomSection.sectionNameNative.isNotEmpty
        ? randomSection.sectionNameNative
        : randomSection.sectionName;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appLanguage == 'bng'
              ? 'দৈনিক অনুশীলন: "$displayName" খোলা হচ্ছে...'
              : 'Study Insight: Opening "$displayName"...',
        ),
        backgroundColor: AppTheme.primaryMint,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    context.push(
      '/book/$selectedKey/hadith/${randomSection.startHadithNumber}?sectionId=${randomSection.id}&sectionName=${Uri.encodeComponent(displayName)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final searchBgColor = isDark ? AppTheme.darkSurface : Colors.white;

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
                    onPressed: () => context.read<HadithCubit>().loadDashboard(),
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
          return _buildEmptyState(appLanguage);
        }

        final selectedKey =
            state.selectedBookKey ?? state.downloadedBooks.first.book;

        // Precompute hadith reading stats & bookmarks for fast linear filtering
        final readHadithsSet = state.readHistory
            .where((r) => r.bookKey == selectedKey)
            .map((r) => r.hadithNumber)
            .toSet();
        final bookmarksSet = {
          ...state.bookmarkedRefs,
          ...state.pinnedRefs,
        };

        // Calculate filter counts
        int inProgressCount = 0;
        int completedCount = 0;
        int unreadCount = 0;
        int bookmarkedCount = 0;

        final Map<int, _SectionStats> statsMap = {};
        for (final s in state.activeSections) {
          final stats = _calculateSectionStats(s, readHadithsSet, bookmarksSet, selectedKey);
          statsMap[s.id] = stats;
          if (stats.isCompleted) completedCount++;
          if (stats.isInProgress) inProgressCount++;
          if (stats.isUnread) unreadCount++;
          if (stats.bookmarkCount > 0) bookmarkedCount++;
        }

        // Apply search query + active filter
        List<HadithSection> displaySections = state.filteredSections.where((s) {
          final stats = statsMap[s.id];
          if (stats == null) return true;
          switch (_selectedFilter) {
            case ChapterFilterType.all:
              return true;
            case ChapterFilterType.inProgress:
              return stats.isInProgress;
            case ChapterFilterType.completed:
              return stats.isCompleted;
            case ChapterFilterType.unread:
              return stats.isUnread;
            case ChapterFilterType.bookmarked:
              return stats.bookmarkCount > 0;
          }
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(8),
            // 1. Sleek Compact Horizontal Book Capsule Pills (~40px)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: state.downloadedBooks.length,
                itemBuilder: (context, index) {
                  final book = state.downloadedBooks[index];
                  final isSelected = book.book == selectedKey;
                  final inactiveBgColor = isDark
                      ? AppTheme.darkSurfaceCard.withValues(alpha: 0.25)
                      : const Color(0xFFF3F4F6);

                  return GestureDetector(
                    onTap: () {
                      if (book.book != state.selectedBookKey) {
                        _searchController.clear();
                        setState(() {
                          _selectedFilter = ChapterFilterType.all;
                        });
                        context.read<HadithCubit>().loadBookSections(book.book);
                      }
                    },
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                      padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryMint.withValues(alpha: 0.16)
                            : inactiveBgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryMint : borderDividerColor,
                          width: isSelected ? 1.2 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(book.langFlag, style: const TextStyle(fontSize: 12)),
                          const Gap(6),
                          Text(
                            book.nameNative.isNotEmpty ? book.nameNative : book.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppTheme.primaryMint : textPrimary,
                            ),
                          ),
                          const Gap(6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryMint.withValues(alpha: 0.22)
                                  : borderDividerColor.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${book.sectionCount}',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppTheme.primaryMint : textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Gap(8),

            // 2. Compact Search & Quick Action Row (~40px)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                children: [
                  // Search Input
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: searchBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderDividerColor),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) =>
                            context.read<HadithCubit>().updateSectionsSearch(val),
                        style: TextStyle(color: textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: AppLocalization.get(
                            'search_chapters_hint',
                            appLanguage,
                          ),
                          hintStyle: TextStyle(color: textSecondary, fontSize: 12.5),
                          prefixIcon: Icon(
                            Icons.search,
                            color: textSecondary,
                            size: 18,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: textSecondary, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<HadithCubit>().updateSectionsSearch('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                      ),
                    ),
                  ),

                  const Gap(8),

                  // Direct Jump Dial Button (#)
                  InkWell(
                    onTap: () => _showJumpDialog(context, state, selectedKey, appLanguage),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryMint.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.tag_rounded,
                          color: AppTheme.primaryMint,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const Gap(6),

                  // Random Chapter Inspiration Button (Shuffle)
                  InkWell(
                    onTap: () => _pickRandomChapter(
                      context,
                      state.activeSections,
                      selectedKey,
                      appLanguage,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryIndigo.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.secondaryIndigo.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shuffle_rounded,
                          color: AppTheme.secondaryIndigo,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Gap(8),

            // 3. Compact Filter Chips Bar (~32px)
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                children: [
                  _buildFilterChip(
                    type: ChapterFilterType.all,
                    label: _getFilterLabel(ChapterFilterType.all, appLanguage, state.activeSections.length),
                    isSelected: _selectedFilter == ChapterFilterType.all,
                    isDark: isDark,
                    borderDividerColor: borderDividerColor,
                    textSecondary: textSecondary,
                  ),
                  if (inProgressCount > 0)
                    _buildFilterChip(
                      type: ChapterFilterType.inProgress,
                      label: _getFilterLabel(ChapterFilterType.inProgress, appLanguage, inProgressCount),
                      isSelected: _selectedFilter == ChapterFilterType.inProgress,
                      isDark: isDark,
                      borderDividerColor: borderDividerColor,
                      textSecondary: textSecondary,
                    ),
                  if (completedCount > 0)
                    _buildFilterChip(
                      type: ChapterFilterType.completed,
                      label: _getFilterLabel(ChapterFilterType.completed, appLanguage, completedCount),
                      isSelected: _selectedFilter == ChapterFilterType.completed,
                      isDark: isDark,
                      borderDividerColor: borderDividerColor,
                      textSecondary: textSecondary,
                    ),
                  _buildFilterChip(
                    type: ChapterFilterType.unread,
                    label: _getFilterLabel(ChapterFilterType.unread, appLanguage, unreadCount),
                    isSelected: _selectedFilter == ChapterFilterType.unread,
                    isDark: isDark,
                    borderDividerColor: borderDividerColor,
                    textSecondary: textSecondary,
                  ),
                  if (bookmarkedCount > 0)
                    _buildFilterChip(
                      type: ChapterFilterType.bookmarked,
                      label: _getFilterLabel(ChapterFilterType.bookmarked, appLanguage, bookmarkedCount),
                      isSelected: _selectedFilter == ChapterFilterType.bookmarked,
                      isDark: isDark,
                      borderDividerColor: borderDividerColor,
                      textSecondary: textSecondary,
                    ),
                ],
              ),
            ),

            const Gap(6),

            // 4. Chapter Counter & Summary Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalization.get(
                      'chapters_available',
                      appLanguage,
                      args: {'count': '${displaySections.length}'},
                    ),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (completedCount > 0)
                    Text(
                      appLanguage == 'bng'
                          ? '$completedCountটি সম্পন্ন'
                          : '$completedCount Completed',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryMint,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            const Gap(4),

            // 5. Vertical Chapters Scroll List
            Expanded(
              child: state.isLoadingSections
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryMint),
                    )
                  : displaySections.isEmpty
                      ? _buildNoResultsState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          itemCount: displaySections.length,
                          itemBuilder: (context, index) {
                            final section = displaySections[index];
                            final stats = statsMap[section.id] ?? _SectionStats(
                              readCount: 0,
                              isCompleted: false,
                              isInProgress: false,
                              isUnread: true,
                              bookmarkCount: 0,
                            );

                            final cardBgColor = isDark
                                ? AppTheme.darkSurfaceCard.withValues(alpha: 0.25)
                                : const Color(0xFFF3F4F6);

                            return GestureDetector(
                              onTap: () {
                                final displayName = section.sectionNameNative.isNotEmpty
                                    ? section.sectionNameNative
                                    : section.sectionName;
                                final encodedName = Uri.encodeComponent(displayName);
                                context.push(
                                  '/book/$selectedKey/hadith/${section.startHadithNumber}?sectionId=${section.id}&sectionName=$encodedName',
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: stats.isCompleted
                                        ? AppTheme.primaryMint.withValues(alpha: 0.35)
                                        : borderDividerColor,
                                    width: stats.isCompleted ? 1.2 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.08 : 0.02,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Index Badge
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: stats.isCompleted
                                                ? AppTheme.primaryMint
                                                : AppTheme.primaryMint.withValues(
                                                    alpha: 0.1,
                                                  ),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: stats.isCompleted
                                                  ? AppTheme.primaryMint
                                                  : AppTheme.primaryMint.withValues(
                                                      alpha: 0.3,
                                                    ),
                                            ),
                                          ),
                                          child: Center(
                                            child: stats.isCompleted
                                                ? const Icon(
                                                    Icons.check_rounded,
                                                    size: 18,
                                                    color: Colors.white,
                                                  )
                                                : Text(
                                                    '${section.id}',
                                                    style: const TextStyle(
                                                      color: AppTheme.primaryMint,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
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
                                                      section.sectionNameNative.isNotEmpty
                                                          ? section.sectionNameNative
                                                          : section.sectionName,
                                                      style: TextStyle(
                                                        fontSize: 13.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: textPrimary,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (stats.isCompleted) ...[
                                                    const Gap(6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 1.5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.primaryMint
                                                            .withValues(alpha: 0.15),
                                                        borderRadius:
                                                            BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        appLanguage == 'bng'
                                                            ? 'সম্পন্ন'
                                                            : 'Done',
                                                        style: const TextStyle(
                                                          fontSize: 9.5,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppTheme.primaryMint,
                                                        ),
                                                      ),
                                                    ),
                                                  ] else if (stats.isInProgress) ...[
                                                    const Gap(6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 1.5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.secondaryIndigo
                                                            .withValues(alpha: 0.15),
                                                        borderRadius:
                                                            BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        '${stats.readCount}/${section.hadithCount}',
                                                        style: const TextStyle(
                                                          fontSize: 9.5,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppTheme.secondaryIndigo,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  if (stats.bookmarkCount > 0) ...[
                                                    const Gap(4),
                                                    const Icon(
                                                      Icons.bookmark_rounded,
                                                      size: 13,
                                                      color: Colors.amberAccent,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              if (section.sectionNameNative.isNotEmpty &&
                                                  section.sectionName.isNotEmpty)
                                                Text(
                                                  section.sectionName,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: textSecondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              const Gap(2),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.bookmark_outline_rounded,
                                                    size: 11,
                                                    color: textSecondary,
                                                  ),
                                                  const Gap(4),
                                                  Text(
                                                    AppLocalization.get(
                                                      'hadith_range',
                                                      appLanguage,
                                                      args: {
                                                        'start': '${section.startHadithNumber}',
                                                        'end': '${section.endHadithNumber}',
                                                      },
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: textSecondary,
                                                    ),
                                                  ),
                                                  const Gap(6),
                                                  Text('•', style: TextStyle(color: textSecondary, fontSize: 11)),
                                                  const Gap(6),
                                                  Text(
                                                    AppLocalization.get(
                                                      'items_count',
                                                      appLanguage,
                                                      args: {'count': '${section.hadithCount}'},
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 11,
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
                                          Icons.chevron_right_rounded,
                                          color: textSecondary.withValues(alpha: 0.6),
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                    if (stats.isInProgress) ...[
                                      const Gap(6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: LinearProgressIndicator(
                                          value: (stats.readCount / section.hadithCount)
                                              .clamp(0.0, 1.0),
                                          minHeight: 2.5,
                                          backgroundColor: borderDividerColor,
                                          color: AppTheme.secondaryIndigo,
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
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({
    required ChapterFilterType type,
    required String label,
    required bool isSelected,
    required bool isDark,
    required Color borderDividerColor,
    required Color textSecondary,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = type;
        });
      },
      child: AnimatedContainer(
        duration: 150.ms,
        margin: const EdgeInsets.only(right: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryMint
              : (isDark
                  ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3)
                  : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryMint : borderDividerColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppTheme.darkCanvas : Colors.white)
                  : textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String appLanguage) {
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

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
              AppLocalization.get('no_offline_books_title', appLanguage),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const Gap(8),
            Text(
              AppLocalization.get('no_offline_books_desc', appLanguage),
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary, height: 1.4),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }

  Widget _buildNoResultsState() {
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

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
              AppLocalization.get(
                'no_chapters_match',
                context.read<SettingsCubit>().state.appLanguage,
              ),
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/data/models/hadith_model.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';

class HadithSearchScreen extends StatefulWidget {
  const HadithSearchScreen({super.key});

  @override
  State<HadithSearchScreen> createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends State<HadithSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default: select all downloaded books on mount for search scope
    final cubit = context.read<HadithCubit>();
    if (cubit.state.selectedSearchBooks.isEmpty) {
      final allKeys = cubit.state.downloadedBooks.map((b) => b.book).toList();
      cubit.selectAllSearchBooks(allKeys);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch(String val) {
    if (val.trim().isNotEmpty) {
      context.read<HadithCubit>().searchHadiths(val);
    }
  }

  String _getBookName(HadithState state, String bookKey) {
    final books = state.downloadedBooks;
    if (books.any((b) => b.book == bookKey)) {
      final book = books.firstWhere((b) => b.book == bookKey);
      return book.nameNative.isNotEmpty ? book.nameNative : book.name;
    }
    return bookKey.toUpperCase();
  }

  String _getFlag(HadithState state, String bookKey) {
    final books = state.downloadedBooks;
    if (books.any((b) => b.book == bookKey)) {
      return books.firstWhere((b) => b.book == bookKey).langFlag;
    }
    return '📖';
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Center(
      child:
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryMint.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: AppTheme.primaryMint.withValues(alpha: 0.6),
                        size: 40,
                      ),
                    ),
                    const Gap(20),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _buildScopeSelectionBar(HadithState state) {
    if (state.downloadedBooks.isEmpty) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final chipBgColor = isDark
        ? AppTheme.darkSurfaceCard
        : const Color(0xFFF3F4F6);
    final tickColor = AppTheme.darkCanvas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalization.get(
                  'search_scope',
                  context.read<SettingsCubit>().state.appLanguage,
                ),
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final cubit = context.read<HadithCubit>();
                  final allSelected =
                      state.selectedSearchBooks.length ==
                      state.downloadedBooks.length;
                  if (allSelected) {
                    cubit.deselectAllSearchBooks();
                  } else {
                    final allKeys = state.downloadedBooks
                        .map((b) => b.book)
                        .toList();
                    cubit.selectAllSearchBooks(allKeys);
                  }
                },
                child: Text(
                  state.selectedSearchBooks.length ==
                          state.downloadedBooks.length
                      ? AppLocalization.get(
                          'deselect_all',
                          context.read<SettingsCubit>().state.appLanguage,
                        )
                      : AppLocalization.get(
                          'select_all',
                          context.read<SettingsCubit>().state.appLanguage,
                        ),
                  style: const TextStyle(
                    color: AppTheme.primaryMint,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: state.downloadedBooks.length,
            itemBuilder: (context, index) {
              final book = state.downloadedBooks[index];
              final isSelected = state.selectedSearchBooks.contains(book.book);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(book.langFlag, style: const TextStyle(fontSize: 11)),
                      const Gap(6),
                      Text(
                        book.nameNative.isNotEmpty
                            ? book.nameNative
                            : book.name,
                        style: TextStyle(
                          color: isSelected ? tickColor : textPrimary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  backgroundColor: chipBgColor,
                  selectedColor: AppTheme.primaryMint,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryMint
                          : borderDividerColor,
                    ),
                  ),
                  onSelected: (_) {
                    context.read<HadithCubit>().toggleSearchBookSelection(
                      book.book,
                    );
                  },
                ),
              );
            },
          ),
        ),
        const Gap(8),
      ],
    );
  }

  Widget _buildSuggestionsView(String appLanguage) {
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBgColor = isDark
        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.4)
        : const Color(0xFFF3F4F6);
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);

    final trending = [
      {'key': 'topic_intention', 'default': 'Intention'},
      {'key': 'topic_charity', 'default': 'Charity'},
      {'key': 'topic_prayer', 'default': 'Prayer'},
      {'key': 'topic_fasting', 'default': 'Fasting'},
      {'key': 'topic_parents', 'default': 'Parents'},
      {'key': 'topic_greetings', 'default': 'Greetings'},
      {'key': 'topic_patience', 'default': 'Patience'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            AppLocalization.get('trending_suggestions', appLanguage),
            style: TextStyle(
              color: textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trending.map((topic) {
              final localizedTopic = AppLocalization.get(
                topic['key']!,
                appLanguage,
              );
              return ActionChip(
                backgroundColor: chipBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: borderDividerColor),
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: AppTheme.primaryMint,
                      size: 12,
                    ),
                    const Gap(6),
                    Text(
                      localizedTopic,
                      style: TextStyle(color: textPrimary, fontSize: 12),
                    ),
                  ],
                ),
                onPressed: () {
                  _searchController.text = localizedTopic;
                  _triggerSearch(localizedTopic);
                },
              );
            }).toList(),
          ),
        ),
        const Spacer(),
        _buildEmptyState(
          icon: Icons.search_rounded,
          title: AppLocalization.get('search_offline_title', appLanguage),
          subtitle: AppLocalization.get('search_offline_desc', appLanguage),
        ),
        const Spacer(),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildResultCard({
    required HadithItem hadith,
    required String bookKey,
    required HadithState state,
    required String appLanguage,
  }) {
    final flag = _getFlag(state, bookKey);
    final bookName = _getBookName(state, bookKey);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark
        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3)
        : const Color(0xFFF3F4F6);
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/book/$bookKey/hadith/${hadith.hadithNumber}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryMint.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(flag, style: const TextStyle(fontSize: 11)),
                          const Gap(6),
                          Text(
                            bookName,
                            style: const TextStyle(
                              color: AppTheme.primaryMint,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Text(
                      AppLocalization.get(
                        'hadith_no',
                        appLanguage,
                        args: {'number': hadith.hadithNumber.toString()},
                      ),
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: textSecondary,
                      size: 18,
                    ),
                  ],
                ),
                const Gap(12),
                Text(
                  hadith.text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                if (hadith.grades.isNotEmpty) ...[
                  const Gap(12),
                  Divider(color: borderDividerColor, height: 1),
                  const Gap(8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: hadith.grades.take(2).map((g) {
                      final gl = g.grade.toLowerCase();
                      Color c = Colors.grey;
                      if (gl.contains('sahih')) {
                        c = Colors.green;
                      } else if (gl.contains('hasan')) {
                        c = Colors.orangeAccent;
                      } else if (gl.contains('da') || gl.contains('weak')) {
                        c = Colors.redAccent;
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: c.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          '${g.scholarName}: ${g.grade}',
                          style: TextStyle(
                            color: c,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvasColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;

    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        final results = state.searchResultsGrouped;
        final resultsKeys = results.keys.toList();

        return Scaffold(
          backgroundColor: canvasColor,
          appBar: AppBar(
            backgroundColor: surfaceColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textPrimary),
              onPressed: () {
                context.read<HadithCubit>().clearSearch();
                Navigator.pop(context);
              },
            ),
            title: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: textPrimary, fontSize: 14),
              textInputAction: TextInputAction.search,
              onSubmitted: _triggerSearch,
              decoration: InputDecoration(
                hintText: AppLocalization.get(
                  'search_hadith_hint',
                  appLanguage,
                ),
                hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.primaryMint,
                  size: 18,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: textSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context.read<HadithCubit>().clearSearch();
                        },
                      )
                    : null,
                border: InputBorder.none,
              ),
            ),
          ),
          body: Column(
            children: [
              const Gap(8),
              _buildScopeSelectionBar(state),
              Divider(color: borderDividerColor, height: 1),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.isSearching) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryMint,
                        ),
                      );
                    }

                    if (state.searchQuery.isEmpty) {
                      return _buildSuggestionsView(appLanguage);
                    }

                    if (resultsKeys.isEmpty) {
                      return _buildEmptyState(
                        icon: Icons.search_off_rounded,
                        title: AppLocalization.get(
                          'no_matches_title',
                          appLanguage,
                        ),
                        subtitle: AppLocalization.get(
                          'no_matches_desc',
                          appLanguage,
                          args: {'query': state.searchQuery},
                        ),
                      );
                    }

                    // Render dynamic tab controller mapped to matching resource results
                    return DefaultTabController(
                      length: resultsKeys.length,
                      child: Column(
                        children: [
                          Container(
                            color: surfaceColor,
                            child: TabBar(
                              isScrollable: true,
                              indicatorColor: AppTheme.primaryMint,
                              labelColor: AppTheme.primaryMint,
                              unselectedLabelColor: textSecondary,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              tabs: resultsKeys.map((key) {
                                final count = results[key]?.length ?? 0;
                                final bookName = _getBookName(state, key);
                                final flag = _getFlag(state, key);
                                return Tab(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(flag),
                                      const Gap(6),
                                      Text('$bookName ($count)'),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: resultsKeys.map((key) {
                                final bookHadiths = results[key] ?? const [];

                                return ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount: bookHadiths.length,
                                  itemBuilder: (context, index) {
                                    final hadith = bookHadiths[index];
                                    return _buildResultCard(
                                          hadith: hadith,
                                          bookKey: key,
                                          state: state,
                                          appLanguage: appLanguage,
                                        )
                                        .animate()
                                        .fadeIn(
                                          duration: 300.ms,
                                          delay: (index * 30).ms,
                                        )
                                        .slideY(begin: 0.05, end: 0);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

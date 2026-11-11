import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/data/models/hadith_model.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/data/services/preferences_service.dart';

class HadithSearchScreen extends StatefulWidget {
  const HadithSearchScreen({super.key});

  @override
  State<HadithSearchScreen> createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends State<HadithSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _sahihOnly = false;
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<HadithCubit>();
    if (cubit.state.selectedSearchBooks.isEmpty) {
      final allKeys = cubit.state.downloadedBooks.map((b) => b.book).toList();
      cubit.selectAllSearchBooks(allKeys);
    }

    _loadRecentSearches();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  void _loadRecentSearches() {
    try {
      final prefs = context.read<PreferencesService>();
      setState(() {
        _recentSearches = prefs.getRecentSearches();
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _triggerSearch(String val) {
    final query = val.trim();
    if (query.isNotEmpty) {
      try {
        context.read<PreferencesService>().addRecentSearch(query);
        _loadRecentSearches();
      } catch (_) {}
      context.read<HadithCubit>().searchHadiths(query);
      _searchFocusNode.unfocus();
    } else {
      context.read<HadithCubit>().clearSearch();
    }
  }

  void _removeRecent(String query) {
    try {
      context.read<PreferencesService>().removeRecentSearch(query);
      _loadRecentSearches();
    } catch (_) {}
  }

  void _clearAllRecents() {
    try {
      context.read<PreferencesService>().clearRecentSearches();
      _loadRecentSearches();
    } catch (_) {}
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

  bool _isSahih(HadithItem hadith) {
    if (hadith.grades.isEmpty) return true;
    return hadith.grades.any(
      (g) => g.grade.toLowerCase().contains('sahih'),
    );
  }

  ({String label, Color color, IconData icon})? _getGradeBadge(HadithItem hadith) {
    if (hadith.grades.isEmpty) return null;
    for (final g in hadith.grades) {
      final gl = g.grade.toLowerCase();
      if (gl.contains('sahih')) {
        return (label: 'Sahih', color: const Color(0xFF10B981), icon: Icons.check_circle_rounded);
      }
      if (gl.contains('hasan')) {
        return (label: 'Hasan', color: const Color(0xFFF59E0B), icon: Icons.verified_rounded);
      }
      if (gl.contains('da') || gl.contains('weak')) {
        return (label: "Da'if", color: const Color(0xFFEF4444), icon: Icons.error_outline_rounded);
      }
    }
    return (label: hadith.grades.first.grade, color: Colors.blueGrey, icon: Icons.info_outline_rounded);
  }

  Widget _buildHighlightedSnippet({
    required String text,
    required String query,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
  }) {
    if (query.trim().isEmpty) {
      return Text(
        text,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final terms = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (terms.isEmpty) {
      return Text(
        text,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    // Match-centered windowing: if match is deep in text, trim preceding narration
    String windowedText = text;
    int firstMatchIndex = -1;
    final lowerText = text.toLowerCase();
    for (final term in terms) {
      final idx = lowerText.indexOf(term);
      if (idx != -1 && (firstMatchIndex == -1 || idx < firstMatchIndex)) {
        firstMatchIndex = idx;
      }
    }

    if (firstMatchIndex > 150) {
      int windowStart = (firstMatchIndex - 50).clamp(0, text.length);
      // Try to find a space or punctuation to break naturally
      final spaceIdx = text.indexOf(' ', windowStart);
      if (spaceIdx != -1 && spaceIdx < firstMatchIndex) {
        windowStart = spaceIdx + 1;
      }
      windowedText = '... ${text.substring(windowStart)}';
    }

    final escapedTerms = terms.map(RegExp.escape).join('|');
    final regex = RegExp('($escapedTerms)', caseSensitive: false);
    final matches = regex.allMatches(windowedText);

    if (matches.isEmpty) {
      return Text(
        windowedText,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final spans = <InlineSpan>[];
    int current = 0;

    for (final match in matches) {
      if (match.start > current) {
        spans.add(TextSpan(
          text: windowedText.substring(current, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: windowedText.substring(match.start, match.end),
        style: highlightStyle,
      ));
      current = match.end;
    }

    if (current < windowedText.length) {
      spans.add(TextSpan(
        text: windowedText.substring(current),
        style: baseStyle,
      ));
    }

    return RichText(
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }

  Widget _buildScopeSelectionBar(HadithState state) {
    if (state.downloadedBooks.isEmpty) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final chipBgColor = isDark
        ? AppTheme.darkSurfaceCard
        : const Color(0xFFF1F5F9);

    final totalCount = state.downloadedBooks.length;
    final selectedCount = state.selectedSearchBooks.length;
    final allSelected = selectedCount == totalCount;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          // Master All/None Capsule
          InkWell(
            onTap: () {
              final cubit = context.read<HadithCubit>();
              if (allSelected) {
                cubit.deselectAllSearchBooks();
              } else {
                final allKeys =
                    state.downloadedBooks.map((b) => b.book).toList();
                cubit.selectAllSearchBooks(allKeys);
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: allSelected
                    ? AppTheme.primaryMint
                    : AppTheme.primaryMint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: allSelected
                      ? AppTheme.primaryMint
                      : AppTheme.primaryMint.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    allSelected
                        ? Icons.library_books_rounded
                        : Icons.filter_alt_outlined,
                    color: allSelected ? AppTheme.darkCanvas : AppTheme.primaryMint,
                    size: 14,
                  ),
                  const Gap(6),
                  Text(
                    allSelected
                        ? 'All Books ($totalCount)'
                        : '$selectedCount of $totalCount',
                    style: TextStyle(
                      color: allSelected
                          ? AppTheme.darkCanvas
                          : AppTheme.primaryMint,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(8),
          // Individual Book Choice Chips
          ...state.downloadedBooks.map((book) {
            final isSelected = state.selectedSearchBooks.contains(book.book);
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                onTap: () {
                  context.read<HadithCubit>().toggleSearchBookSelection(
                    book.book,
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AppTheme.primaryMint.withValues(alpha: 0.15)
                            : AppTheme.primaryMint.withValues(alpha: 0.12))
                        : chipBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryMint.withValues(alpha: 0.5)
                          : borderDividerColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(book.langFlag, style: const TextStyle(fontSize: 11)),
                      const Gap(6),
                      Text(
                        book.nameNative.isNotEmpty
                            ? book.nameNative
                            : book.name,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryMint
                              : textPrimary,
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      if (isSelected) ...[
                        const Gap(5),
                        const Icon(
                          Icons.check_rounded,
                          color: AppTheme.primaryMint,
                          size: 13,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.primaryMint.withValues(alpha: 0.07),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryMint.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryMint.withValues(alpha: 0.7),
                size: 38,
              ),
            ),
            const Gap(16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: -0.2,
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
      ).animate().fadeIn(duration: 350.ms),
    );
  }

  Widget _buildSuggestionsView(String appLanguage) {
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBgColor = isDark
        ? AppTheme.darkSurfaceCard
        : const Color(0xFFF1F5F9);
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);

    final topics = [
      {'title': 'Intention & Sincerity', 'query': 'Intention', 'icon': Icons.spa_rounded},
      {'title': 'Salat (Prayer)', 'query': 'Prayer', 'icon': Icons.access_time_filled_rounded},
      {'title': 'Zakat (Charity)', 'query': 'Charity', 'icon': Icons.volunteer_activism_rounded},
      {'title': 'Sawm (Fasting)', 'query': 'Fasting', 'icon': Icons.nights_stay_rounded},
      {'title': 'Parents & Family', 'query': 'Parents', 'icon': Icons.family_restroom_rounded},
      {'title': 'Patience (Sabr)', 'query': 'Patience', 'icon': Icons.shield_rounded},
      {'title': 'Seeking Knowledge', 'query': 'Knowledge', 'icon': Icons.school_rounded},
      {'title': 'Good Character (Akhlaq)', 'query': 'Character', 'icon': Icons.sentiment_satisfied_alt_rounded},
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Recent Searches Section (If Available)
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    color: AppTheme.primaryMint,
                    size: 16,
                  ),
                  const Gap(6),
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _clearAllRecents,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((query) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: chipBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderDividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        _searchController.text = query;
                        _triggerSearch(query);
                      },
                      child: Text(
                        query,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Gap(6),
                    InkWell(
                      onTap: () => _removeRecent(query),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const Gap(20),
        ],

        // Curated Topics Section
        Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.primaryMint,
              size: 16,
            ),
            const Gap(6),
            Text(
              'Curated Islamic Topics',
              style: TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Gap(10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics.map((t) {
            final title = t['title'] as String;
            final query = t['query'] as String;
            final icon = t['icon'] as IconData;

            return InkWell(
              onTap: () {
                _searchController.text = query;
                _triggerSearch(query);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: chipBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderDividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: AppTheme.primaryMint, size: 14),
                    const Gap(6),
                    Text(
                      title,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const Gap(24),

        // Offline Search Capability Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderDividerColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMint.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.offline_bolt_rounded,
                  color: AppTheme.primaryMint,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lightning Fast Offline Search',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      'SQLite FTS5 full-text queries run completely offline on your device without cellular or Wi-Fi.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildResultCard({
    required HadithItem hadith,
    required String bookKey,
    required HadithState state,
    required String appLanguage,
    required String searchQuery,
  }) {
    final flag = _getFlag(state, bookKey);
    final bookName = _getBookName(state, bookKey);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark
        ? AppTheme.darkSurfaceCard
        : Colors.white;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    final gradeBadge = _getGradeBadge(hadith);

    final normalStyle = TextStyle(
      color: textPrimary,
      fontSize: 13.5,
      height: 1.55,
      letterSpacing: -0.1,
    );

    final highlightStyle = TextStyle(
      color: isDark ? AppTheme.primaryMint : const Color(0xFF047857),
      fontSize: 13.5,
      fontWeight: FontWeight.bold,
      backgroundColor: isDark
          ? AppTheme.primaryMint.withValues(alpha: 0.22)
          : const Color(0xFFD1FAE5),
      height: 1.55,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/book/$bookKey/hadith/${hadith.hadithNumber}');
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Book Flag + Name + Number + Grade Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryMint.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(flag, style: const TextStyle(fontSize: 11)),
                          const Gap(5),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              bookName,
                              overflow: TextOverflow.ellipsis,
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
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderDividerColor),
                      ),
                      child: Text(
                        '#${hadith.hadithNumber}',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (gradeBadge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: gradeBadge.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: gradeBadge.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              gradeBadge.icon,
                              size: 11,
                              color: gradeBadge.color,
                            ),
                            const Gap(4),
                            Text(
                              gradeBadge.label,
                              style: TextStyle(
                                color: gradeBadge.color,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const Gap(10),
                // Highlighted Text Body
                _buildHighlightedSnippet(
                  text: hadith.text,
                  query: searchQuery,
                  baseStyle: normalStyle,
                  highlightStyle: highlightStyle,
                ),
                const Gap(12),
                Divider(color: borderDividerColor, height: 1),
                const Gap(8),
                // Bottom Quick Action Strip
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        final copyText =
                            '${hadith.text}\n\n— $bookName, Hadith #${hadith.hadithNumber}';
                        Clipboard.setData(ClipboardData(text: copyText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Hadith copied to clipboard'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.darkCanvas,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              size: 13,
                              color: textSecondary,
                            ),
                            const Gap(4),
                            Text(
                              'Copy',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(6),
                    InkWell(
                      onTap: () {
                        final shareText =
                            '${hadith.text}\n\n— $bookName, Hadith #${hadith.hadithNumber}\n\nShared via Al Hadith App';
                        SharePlus.instance.share(
                          ShareParams(
                            text: shareText,
                            subject: '$bookName #${hadith.hadithNumber}',
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.share_outlined,
                              size: 13,
                              color: textSecondary,
                            ),
                            const Gap(4),
                            Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'Read Hadith',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryMint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(2),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: AppTheme.primaryMint,
                        ),
                      ],
                    ),
                  ],
                ),
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
        : const Color(0xFFE2E8F0);
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;

    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        final rawResults = state.searchResultsGrouped;
        
        // Filter results by Sahih if toggle enabled
        final Map<String, List<HadithItem>> results = {};
        for (final entry in rawResults.entries) {
          final items = _sahihOnly
              ? entry.value.where(_isSahih).toList()
              : entry.value;
          if (items.isNotEmpty) {
            results[entry.key] = items;
          }
        }

        final resultsKeys = results.keys.toList();
        final int totalMatches = results.values.fold(0, (sum, list) => sum + list.length);

        // Build unified list for "All Results" tab
        final List<({HadithItem hadith, String bookKey})> allMatches = [];
        for (final key in resultsKeys) {
          final list = results[key] ?? [];
          for (final item in list) {
            allMatches.add((hadith: item, bookKey: key));
          }
        }

        return Scaffold(
          backgroundColor: canvasColor,
          appBar: AppBar(
            backgroundColor: surfaceColor,
            elevation: 0,
            toolbarHeight: 60,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: textPrimary,
                size: 19,
              ),
              onPressed: () {
                context.read<HadithCubit>().clearSearch();
                Navigator.pop(context);
              },
            ),
            titleSpacing: 0,
            title: Container(
              height: 42,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderDividerColor),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _triggerSearch,
                decoration: InputDecoration(
                  hintText: AppLocalization.get(
                    'search_hadith_hint',
                    appLanguage,
                  ),
                  hintStyle: TextStyle(
                    color: textSecondary.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.primaryMint,
                    size: 19,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: textSecondary,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<HadithCubit>().clearSearch();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // Scope Selection Bar
              _buildScopeSelectionBar(state),
              Divider(color: borderDividerColor, height: 1),

              // Content Body
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

                    // Total number of tabs = 1 ("All Matches") + number of books
                    final totalTabs = 1 + resultsKeys.length;

                    return DefaultTabController(
                      length: totalTabs,
                      child: Column(
                        children: [
                          // Search Results Sub-Header: Count + Sahih Only Filter
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            color: isDark
                                ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                                : const Color(0xFFF8FAFC),
                            child: Row(
                              children: [
                                Text(
                                  'Found $totalMatches matches across ${resultsKeys.length} ${resultsKeys.length == 1 ? 'book' : 'books'}',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _sahihOnly = !_sahihOnly;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _sahihOnly
                                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                          : chipBgColor(isDark),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _sahihOnly
                                            ? const Color(0xFF10B981)
                                            : borderDividerColor,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _sahihOnly
                                              ? Icons.check_circle_rounded
                                              : Icons.verified_outlined,
                                          size: 12,
                                          color: _sahihOnly
                                              ? const Color(0xFF10B981)
                                              : textSecondary,
                                        ),
                                        const Gap(4),
                                        Text(
                                          'Sahih Only',
                                          style: TextStyle(
                                            color: _sahihOnly
                                                ? const Color(0xFF10B981)
                                                : textSecondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: borderDividerColor, height: 1),

                          // Scrollable Filter Tabs
                          Container(
                            color: surfaceColor,
                            child: TabBar(
                              isScrollable: true,
                              indicatorColor: AppTheme.primaryMint,
                              indicatorWeight: 2.5,
                              labelColor: AppTheme.primaryMint,
                              unselectedLabelColor: textSecondary,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              tabAlignment: TabAlignment.start,
                              tabs: [
                                // All Results Tab
                                Tab(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.layers_rounded,
                                        size: 14,
                                      ),
                                      const Gap(6),
                                      Text(
                                        'All Matches ($totalMatches)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Individual Book Tabs
                                ...resultsKeys.map((key) {
                                  final count = results[key]?.length ?? 0;
                                  final bookName = _getBookName(state, key);
                                  final flag = _getFlag(state, key);
                                  return Tab(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(flag, style: const TextStyle(fontSize: 11)),
                                        const Gap(5),
                                        Text(
                                          '$bookName ($count)',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          Divider(color: borderDividerColor, height: 1),

                          // Tab Pages
                          Expanded(
                            child: TabBarView(
                              children: [
                                // Page 0: Aggregated Feed
                                ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.all(14),
                                  itemCount: allMatches.length,
                                  itemBuilder: (context, index) {
                                    final match = allMatches[index];
                                    return _buildResultCard(
                                          hadith: match.hadith,
                                          bookKey: match.bookKey,
                                          state: state,
                                          appLanguage: appLanguage,
                                          searchQuery: state.searchQuery,
                                        )
                                        .animate()
                                        .fadeIn(
                                          duration: 250.ms,
                                          delay: (index * 25).clamp(0, 300).ms,
                                        )
                                        .slideY(begin: 0.04, end: 0);
                                  },
                                ),
                                // Pages 1..N: Book-specific Feed
                                ...resultsKeys.map((key) {
                                  final bookHadiths = results[key] ?? const [];

                                  return ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(14),
                                    itemCount: bookHadiths.length,
                                    itemBuilder: (context, index) {
                                      final hadith = bookHadiths[index];
                                      return _buildResultCard(
                                            hadith: hadith,
                                            bookKey: key,
                                            state: state,
                                            appLanguage: appLanguage,
                                            searchQuery: state.searchQuery,
                                          )
                                          .animate()
                                          .fadeIn(
                                            duration: 250.ms,
                                            delay:
                                                (index * 25).clamp(0, 300).ms,
                                          )
                                          .slideY(begin: 0.04, end: 0);
                                    },
                                  );
                                }),
                              ],
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

  Color chipBgColor(bool isDark) =>
      isDark ? AppTheme.darkSurfaceCard : const Color(0xFFF1F5F9);
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/data/models/hadith_model.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/core/localization/app_localization.dart';
import '../../data/models/resource_model.dart';

class HadithCollectionsView extends StatefulWidget {
  const HadithCollectionsView({super.key});

  @override
  State<HadithCollectionsView> createState() => _HadithCollectionsViewState();
}

class _HadithCollectionsViewState extends State<HadithCollectionsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    // Refresh collections whenever view mounts
    context.read<HadithCubit>().loadCollections();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  HadithResource? _getBookName(HadithState state, String bookKey) {
    final books = state.downloadedBooks;
    if (books.any((b) => b.book == bookKey)) {
      return books.firstWhere((b) => b.book == bookKey);
    }
    return null;
  }

  String _getFlag(HadithState state, String bookKey) {
    final books = state.downloadedBooks;
    if (books.any((b) => b.book == bookKey)) {
      return books.firstWhere((b) => b.book == bookKey).langFlag;
    }
    return '📖';
  }

  void _showEditNoteDialog(
    BuildContext context,
    String bookKey,
    int hadithNumber,
    String currentNote,
  ) {
    final textController = TextEditingController(text: currentNote);
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
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(color: borderDividerColor, width: 1.5),
              ),
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
                      color: textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Gap(14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalization.get('edit_note', appLanguage),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textSecondary, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Gap(14),
                Container(
                  decoration: BoxDecoration(
                    color: canvasColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderDividerColor),
                  ),
                  child: TextField(
                    controller: textController,
                    maxLines: 4,
                    autofocus: true,
                    style: TextStyle(color: textPrimary, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: AppLocalization.get(
                        'note_reflection_hint',
                        appLanguage,
                      ),
                      hintStyle: TextStyle(
                        color: textSecondary.withValues(alpha: 0.7),
                        fontSize: 12.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                const Gap(16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryMint,
                      foregroundColor: isDark ? AppTheme.darkCanvas : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      context.read<HadithCubit>().saveHadithNote(
                        bookKey,
                        hadithNumber,
                        textController.text,
                      );
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(
                      AppLocalization.get('update_note', appLanguage),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? ctaLabel,
    VoidCallback? onCta,
  }) {
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryMint.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryMint.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryMint,
                size: 28,
              ),
            ),
            const Gap(14),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const Gap(6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            if (ctaLabel != null && onCta != null) ...[
              const Gap(16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppTheme.primaryMint.withValues(alpha: 0.4),
                  ),
                  foregroundColor: AppTheme.primaryMint,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onCta,
                icon: const Icon(Icons.explore_outlined, size: 15),
                label: Text(
                  ctaLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCard({
    required String ref,
    required HadithItem hadith,
    required HadithState state,
    required bool isBookmark,
  }) {
    final parts = ref.split('_');
    final bookKey = parts[0];
    final hadithResources = _getBookName(state, bookKey);
    final flag = _getFlag(state, bookKey);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark
        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.25)
        : const Color(0xFFF8FAFC);
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderDividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () {
            context.push('/book/$bookKey/hadith/${hadith.hadithNumber}');
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Book badge + Hadith # + Actions (Copy, Toggle)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryMint.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(flag, style: const TextStyle(fontSize: 11)),
                          const Gap(4),
                          Text(
                            hadithResources?.nameNative.isNotEmpty == true
                                ? hadithResources!.nameNative
                                : (hadithResources?.name ?? bookKey),
                            style: const TextStyle(
                              color: AppTheme.primaryMint,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: borderDividerColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${hadith.hadithNumber}',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Copy icon
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: hadith.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalization.get('copied_to_clipboard', appLanguage),
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.copy_rounded,
                          color: textSecondary.withValues(alpha: 0.6),
                          size: 15,
                        ),
                      ),
                    ),
                    const Gap(4),
                    // Toggle bookmark/pin button
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (isBookmark) {
                          context.read<HadithCubit>().toggleBookmark(
                            bookKey,
                            hadith.hadithNumber,
                          );
                        } else {
                          context.read<HadithCubit>().togglePin(
                            bookKey,
                            hadith.hadithNumber,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isBookmark
                              ? Icons.bookmark_remove_rounded
                              : Icons.push_pin_rounded,
                          color: isBookmark ? Colors.redAccent.withValues(alpha: 0.8) : AppTheme.primaryMint,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(7),
                // Hadith Preview Text
                Text(
                  hadith.text.replaceAll('\n', ' ').trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                // Grades summary if available
                if (hadith.grades.isNotEmpty) ...[
                  const Gap(6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: hadith.grades.take(2).map((g) {
                      final gradeLower = g.grade.toLowerCase();
                      final isSahih = gradeLower.contains('sahih') || gradeLower.contains('সহীহ');
                      final isHasan = gradeLower.contains('hasan') || gradeLower.contains('হাসান');
                      final badgeColor = isSahih
                          ? const Color(0xFF10B981)
                          : isHasan
                              ? Colors.amber.shade700
                              : textSecondary;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: badgeColor.withValues(alpha: 0.2),
                            width: 0.7,
                          ),
                        ),
                        child: Text(
                          '${g.scholarName}: ${g.grade}',
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 9.5,
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

  Widget _buildNoteCollectionCard({
    required String ref,
    required HadithItem hadith,
    required String noteText,
    required HadithState state,
  }) {
    final parts = ref.split('_');
    final bookKey = parts[0];
    final hadithResources = _getBookName(state, bookKey);
    final flag = _getFlag(state, bookKey);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark
        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.25)
        : const Color(0xFFF8FAFC);
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: borderDividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speech Bubble Note Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppTheme.primaryMint.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: borderDividerColor, width: 0.8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.edit_note_rounded,
                      color: AppTheme.primaryMint,
                      size: 16,
                    ),
                    const Gap(5),
                    Text(
                      AppLocalization.get(
                        'study_notes',
                        context.read<SettingsCubit>().state.appLanguage,
                      ),
                      style: const TextStyle(
                        color: AppTheme.primaryMint,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Edit Note icon
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _showEditNoteDialog(
                        context,
                        bookKey,
                        hadith.hadithNumber,
                        noteText,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.edit_rounded,
                          color: textSecondary,
                          size: 14,
                        ),
                      ),
                    ),
                    const Gap(6),
                    // Delete Note icon
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => context.read<HadithCubit>().deleteHadithNote(
                        bookKey,
                        hadith.hadithNumber,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  noteText,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 12.5,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Related Hadith Info Link
          InkWell(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            onTap: () {
              context.push('/book/$bookKey/hadith/${hadith.hadithNumber}');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: borderDividerColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(flag, style: const TextStyle(fontSize: 10)),
                        const Gap(4),
                        Text(
                          hadithResources?.nameNative.isNotEmpty == true
                              ? hadithResources!.nameNative
                              : bookKey,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(6),
                  Text(
                    '#${hadith.hadithNumber}',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      hadith.text.replaceAll('\n', ' ').trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: textSecondary.withValues(alpha: 0.6),
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksTab(HadithState state) {
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;
    var bookmarks = state.bookmarkedRefs.toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      bookmarks = bookmarks.where((ref) {
        final hadith = state.collectionsHadiths[ref];
        if (hadith == null) return false;
        return hadith.text.toLowerCase().contains(q) ||
            hadith.hadithNumber.toString().contains(q) ||
            ref.toLowerCase().contains(q);
      }).toList();
    }

    if (bookmarks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_outline_rounded,
        title: _searchQuery.isNotEmpty
            ? 'কোনো ফলাফল পাওয়া যায়নি'
            : AppLocalization.get('no_bookmarks_title', appLanguage),
        subtitle: _searchQuery.isNotEmpty
            ? 'অন্য কোনো কি-ওয়ার্ড দিয়ে খুঁজে দেখুন'
            : AppLocalization.get('no_bookmarks_desc', appLanguage),
        ctaLabel: _searchQuery.isEmpty ? 'হাদিস পড়ুন' : null,
        onCta: _searchQuery.isEmpty ? () => context.go('/') : null,
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final ref = bookmarks[index];
        final hadith = state.collectionsHadiths[ref];
        if (hadith == null) return const SizedBox();

        return _buildCollectionCard(
          ref: ref,
          hadith: hadith,
          state: state,
          isBookmark: true,
        );
      },
    );
  }

  Widget _buildPinnedTab(HadithState state) {
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;
    var pins = state.pinnedRefs.toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      pins = pins.where((ref) {
        final hadith = state.collectionsHadiths[ref];
        if (hadith == null) return false;
        return hadith.text.toLowerCase().contains(q) ||
            hadith.hadithNumber.toString().contains(q) ||
            ref.toLowerCase().contains(q);
      }).toList();
    }

    if (pins.isEmpty) {
      return _buildEmptyState(
        icon: Icons.push_pin_outlined,
        title: _searchQuery.isNotEmpty
            ? 'কোনো ফলাফল পাওয়া যায়নি'
            : AppLocalization.get('no_pins_title', appLanguage),
        subtitle: _searchQuery.isNotEmpty
            ? 'অন্য কোনো কি-ওয়ার্ড দিয়ে খুঁজে দেখুন'
            : AppLocalization.get('no_pins_desc', appLanguage),
        ctaLabel: _searchQuery.isEmpty ? 'হাদিস পিন করুন' : null,
        onCta: _searchQuery.isEmpty ? () => context.go('/') : null,
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
      itemCount: pins.length,
      itemBuilder: (context, index) {
        final ref = pins[index];
        final hadith = state.collectionsHadiths[ref];
        if (hadith == null) return const SizedBox();

        return _buildCollectionCard(
          ref: ref,
          hadith: hadith,
          state: state,
          isBookmark: false,
        );
      },
    );
  }

  Widget _buildNotesTab(HadithState state) {
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;
    var notes = state.hadithNotes.entries.toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      notes = notes.where((entry) {
        final hadith = state.collectionsHadiths[entry.key];
        return entry.value.toLowerCase().contains(q) ||
            (hadith?.text.toLowerCase().contains(q) ?? false) ||
            entry.key.toLowerCase().contains(q);
      }).toList();
    }

    if (notes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.note_alt_outlined,
        title: _searchQuery.isNotEmpty
            ? 'কোনো ফলাফল পাওয়া যায়নি'
            : AppLocalization.get('no_notes_title', appLanguage),
        subtitle: _searchQuery.isNotEmpty
            ? 'অন্য কোনো কি-ওয়ার্ড দিয়ে খুঁজে দেখুন'
            : AppLocalization.get('no_notes_desc', appLanguage),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final entry = notes[index];
        final ref = entry.key;
        final noteText = entry.value;
        final hadith = state.collectionsHadiths[ref];
        if (hadith == null) return const SizedBox();

        return _buildNoteCollectionCard(
          ref: ref,
          hadith: hadith,
          noteText: noteText,
          state: state,
        );
      },
    );
  }

  Widget _buildHistoryTab(HadithState state) {
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;
    var history = state.readHistory;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      history = history.where((r) {
        return r.bookName.toLowerCase().contains(q) ||
            r.sectionTitle.toLowerCase().contains(q) ||
            r.hadithNumber.toString().contains(q) ||
            r.bookKey.toLowerCase().contains(q);
      }).toList();
    }

    if (history.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: _searchQuery.isNotEmpty
            ? 'কোনো ইতিহাস পাওয়া যায়নি'
            : AppLocalization.get('history_empty_title', appLanguage),
        subtitle: _searchQuery.isNotEmpty
            ? 'অন্য কোনো কি-ওয়ার্ড দিয়ে খুঁজে দেখুন'
            : AppLocalization.get('history_empty_desc', appLanguage),
        ctaLabel: _searchQuery.isEmpty ? 'হাদিস পড়া শুরু করুন' : null,
        onCta: _searchQuery.isEmpty ? () => context.go('/') : null,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final cardBgColor = isDark
        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.25)
        : const Color(0xFFF8FAFC);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final record = history[index];
        final flag = _getFlag(state, record.bookKey);
        final date = DateTime.fromMillisecondsSinceEpoch(record.timestamp);
        final timeAgo = _formatTimeAgo(date, appLanguage);

        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderDividerColor),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                final encodedSection = Uri.encodeComponent(record.sectionTitle);
                context.push(
                  '/book/${record.bookKey}/hadith/${record.hadithNumber}?sectionName=$encodedSection',
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.primaryMint.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(flag, style: const TextStyle(fontSize: 10)),
                          const Gap(4),
                          Text(
                            record.bookName.isNotEmpty ? record.bookName : record.bookKey,
                            style: const TextStyle(
                              color: AppTheme.primaryMint,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: borderDividerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${record.hadithNumber}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        record.sectionTitle.isNotEmpty
                            ? record.sectionTitle
                            : timeAgo,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: textSecondary.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                    const Gap(4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: textSecondary.withValues(alpha: 0.5),
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime time, String appLanguage) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) {
      return AppLocalization.get('just_now', appLanguage);
    }
    if (diff.inMinutes < 60) {
      return AppLocalization.get(
        'minutes_ago',
        appLanguage,
        args: {'minutes': diff.inMinutes.toString()},
      );
    }
    if (diff.inHours < 24) {
      return AppLocalization.get(
        'hours_ago',
        appLanguage,
        args: {'hours': diff.inHours.toString()},
      );
    }
    return '${time.day}/${time.month}/${time.year}';
  }

  void _showClearHistoryDialog(BuildContext context, String appLanguage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalization.get('clear_history', appLanguage),
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Text(
          AppLocalization.get('clear_history_confirm', appLanguage),
          style: TextStyle(color: textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalization.get('cancel', appLanguage),
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HadithCubit>().clearHistory();
            },
            child: Text(
              AppLocalization.get('delete', appLanguage),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required IconData icon,
    required String label,
    required int count,
    required bool isSelected,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderDividerColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryMint.withValues(alpha: isDark ? 0.2 : 0.12)
              : isDark
                  ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3)
                  : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryMint
                : borderDividerColor,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppTheme.primaryMint : textSecondary,
            ),
            const Gap(5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? (isDark ? AppTheme.primaryMint : const Color(0xFF0D9488)) : textSecondary,
              ),
            ),
            const Gap(5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryMint
                    : borderDividerColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? (isDark ? AppTheme.darkCanvas : Colors.white)
                      : textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);

    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        final bookmarkCount = state.bookmarkedRefs.length;
        final pinCount = state.pinnedRefs.length;
        final noteCount = state.hadithNotes.length;
        final historyCount = state.readHistory.length;

        return Column(
          children: [
            // Top Compact Header with Title, Search Toggle & History Clear
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
              child: Row(
                children: [
                  Text(
                    AppLocalization.get('my_library_collections', appLanguage),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Search toggle button
                  IconButton(
                    icon: Icon(
                      _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
                      color: _isSearchOpen ? AppTheme.primaryMint : textSecondary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _isSearchOpen = !_isSearchOpen;
                        if (!_isSearchOpen) {
                          _searchQuery = '';
                          _searchController.clear();
                        }
                      });
                    },
                  ),
                  if (_tabController.index == 3 && state.readHistory.isNotEmpty) ...[
                    const Gap(12),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_sweep_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: AppLocalization.get('clear_history', appLanguage),
                      onPressed: () => _showClearHistoryDialog(context, appLanguage),
                    ),
                  ],
                ],
              ),
            ),

            // Expandable Compact Search Field
            if (_isSearchOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderDividerColor),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(fontSize: 13, color: textPrimary),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'সংগ্রহ বা নোটে খুঁজুন...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: textSecondary.withValues(alpha: 0.7),
                      ),
                      prefixIcon: const Icon(Icons.search, size: 16, color: AppTheme.primaryMint),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      isDense: true,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 14),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

            // Horizontal Segmented Pill Switcher
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTabPill(
                      index: 0,
                      icon: Icons.bookmark_rounded,
                      label: AppLocalization.get('bookmarks', appLanguage),
                      count: bookmarkCount,
                      isSelected: _tabController.index == 0,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderDividerColor: borderDividerColor,
                    ),
                    const Gap(6),
                    _buildTabPill(
                      index: 1,
                      icon: Icons.push_pin_rounded,
                      label: AppLocalization.get('pinned', appLanguage),
                      count: pinCount,
                      isSelected: _tabController.index == 1,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderDividerColor: borderDividerColor,
                    ),
                    const Gap(6),
                    _buildTabPill(
                      index: 2,
                      icon: Icons.note_alt_rounded,
                      label: AppLocalization.get('notes', appLanguage),
                      count: noteCount,
                      isSelected: _tabController.index == 2,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderDividerColor: borderDividerColor,
                    ),
                    const Gap(6),
                    _buildTabPill(
                      index: 3,
                      icon: Icons.history_rounded,
                      label: AppLocalization.get('history', appLanguage),
                      count: historyCount,
                      isSelected: _tabController.index == 3,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      borderDividerColor: borderDividerColor,
                    ),
                  ],
                ),
              ),
            ),
            const Gap(4),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookmarksTab(state),
                  _buildPinnedTab(state),
                  _buildNotesTab(state),
                  _buildHistoryTab(state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

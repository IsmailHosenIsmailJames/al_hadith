import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: borderDividerColor, width: 1.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalization.get('edit_note', appLanguage),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Gap(16),
                Container(
                  decoration: BoxDecoration(
                    color: canvasColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderDividerColor),
                  ),
                  child: TextField(
                    controller: textController,
                    maxLines: 5,
                    autofocus: true,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: AppLocalization.get(
                        'note_reflection_hint',
                        appLanguage,
                      ),
                      hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const Gap(20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryMint,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          context.read<HadithCubit>().saveHadithNote(
                            bookKey,
                            hadithNumber,
                            textController.text,
                          );
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          AppLocalization.get('update_note', appLanguage),
                        ),
                      ),
                    ),
                  ],
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
        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3)
        : const Color(0xFFF3F4F6);
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final surfaceColor = Theme.of(context).colorScheme.surface;

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
                            hadithResources?.nameNative ?? bookKey,
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
                        context.read<SettingsCubit>().state.appLanguage,
                        args: {'number': '${hadith.hadithNumber}'},
                      ),
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Remove button
                    GestureDetector(
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
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderDividerColor),
                        ),
                        child: Icon(
                          isBookmark
                              ? Icons.bookmark_rounded
                              : Icons.push_pin_rounded,
                          color: isBookmark
                              ? AppTheme.primaryMint
                              : Colors.orangeAccent,
                          size: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                Text(
                  hadith.text,
                  maxLines: 3,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speech Bubble Note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryMint.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: borderDividerColor)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.edit_note_rounded,
                      color: AppTheme.primaryMint,
                      size: 18,
                    ),
                    const Gap(6),
                    Text(
                      AppLocalization.get(
                        'study_notes',
                        context.read<SettingsCubit>().state.appLanguage,
                      ),
                      style: const TextStyle(
                        color: AppTheme.primaryMint,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Delete Note icon
                    GestureDetector(
                      onTap: () => context.read<HadithCubit>().deleteHadithNote(
                        bookKey,
                        hadith.hadithNumber,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                    ),
                    const Gap(10),
                    // Edit Note icon
                    GestureDetector(
                      onTap: () => _showEditNoteDialog(
                        context,
                        bookKey,
                        hadith.hadithNumber,
                        noteText,
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: textSecondary,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  noteText,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Related Hadith Info
          InkWell(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            onTap: () {
              context.push('/book/$bookKey/hadith/${hadith.hadithNumber}');
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: borderDividerColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(flag, style: const TextStyle(fontSize: 10)),
                            const Gap(4),
                            Text(
                              hadithResources?.nameNative ?? bookKey,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 9.5,
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
                          context.read<SettingsCubit>().state.appLanguage,
                          args: {'number': '${hadith.hadithNumber}'},
                        ),
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    hadith.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
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
    final bookmarks = state.bookmarkedRefs.toList();
    if (bookmarks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_outline_rounded,
        title: AppLocalization.get('no_bookmarks_title', appLanguage),
        subtitle: AppLocalization.get('no_bookmarks_desc', appLanguage),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
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
            )
            .animate()
            .fadeIn(duration: 350.ms, delay: (index * 40).ms)
            .slideY(begin: 0.08, end: 0);
      },
    );
  }

  Widget _buildPinnedTab(HadithState state) {
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;
    final pins = state.pinnedRefs.toList();
    if (pins.isEmpty) {
      return _buildEmptyState(
        icon: Icons.push_pin_outlined,
        title: AppLocalization.get('no_pins_title', appLanguage),
        subtitle: AppLocalization.get('no_pins_desc', appLanguage),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
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
            )
            .animate()
            .fadeIn(duration: 350.ms, delay: (index * 40).ms)
            .slideY(begin: 0.08, end: 0);
      },
    );
  }

  Widget _buildNotesTab(HadithState state) {
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;
    final notes = state.hadithNotes.entries.toList();
    if (notes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.note_alt_outlined,
        title: AppLocalization.get('no_notes_title', appLanguage),
        subtitle: AppLocalization.get('no_notes_desc', appLanguage),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
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
            )
            .animate()
            .fadeIn(duration: 350.ms, delay: (index * 40).ms)
            .slideY(begin: 0.08, end: 0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final canvasColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;

    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: canvasColor,
          appBar: AppBar(
            backgroundColor: surfaceColor,
            elevation: 0,
            iconTheme: IconThemeData(color: textPrimary),
            title: Text(
              AppLocalization.get('my_library_collections', appLanguage),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: textPrimary,
              ),
            ),
            actions: [
              if (_tabController.index == 3 && state.readHistory.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                  tooltip: AppLocalization.get('clear_history', appLanguage),
                  onPressed: () => _showClearHistoryDialog(context, appLanguage),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: surfaceColor,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primaryMint,
                  labelColor: AppTheme.primaryMint,
                  unselectedLabelColor: textSecondary,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                  tabs: [
                    Tab(
                      iconMargin: const EdgeInsets.only(bottom: 2),
                      icon: const Icon(Icons.bookmark_rounded, size: 18),
                      text: AppLocalization.get('bookmarks', appLanguage),
                    ),
                    Tab(
                      iconMargin: const EdgeInsets.only(bottom: 2),
                      icon: const Icon(Icons.push_pin_rounded, size: 18),
                      text: AppLocalization.get('pinned', appLanguage),
                    ),
                    Tab(
                      iconMargin: const EdgeInsets.only(bottom: 2),
                      icon: const Icon(Icons.note_alt_rounded, size: 18),
                      text: AppLocalization.get('notes', appLanguage),
                    ),
                    Tab(
                      iconMargin: const EdgeInsets.only(bottom: 2),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      text: AppLocalization.get('history', appLanguage),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildBookmarksTab(state),
              _buildPinnedTab(state),
              _buildNotesTab(state),
              _buildHistoryTab(state),
            ],
          ),
        );
      },
    );
  }
  Widget _buildHistoryTab(HadithState state) {
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;
    final history = state.readHistory;
    if (history.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: AppLocalization.get('history_empty_title', appLanguage),
        subtitle: AppLocalization.get('history_empty_desc', appLanguage),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final cardBgColor = isDark
        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3)
        : const Color(0xFFF3F4F6);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final record = history[index];
        final flag = _getFlag(state, record.bookKey);
        final date = DateTime.fromMillisecondsSinceEpoch(record.timestamp);
        final timeAgo = _formatTimeAgo(date, appLanguage);

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
                final encodedSection = Uri.encodeComponent(record.sectionTitle);
                context.push(
                  '/book/${record.bookKey}/hadith/${record.hadithNumber}?sectionName=$encodedSection',
                );
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
                                record.bookName.isNotEmpty ? record.bookName : record.bookKey,
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
                            args: {'number': '${record.hadithNumber}'},
                          ),
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    if (record.sectionTitle.isNotEmpty) ...[
                      const Gap(10),
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
                              record.sectionTitle,
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
                  ],
                ),
              ),
            ),
          ),
        ).animate()
         .fadeIn(duration: 350.ms, delay: (index * 45).ms)
         .slideY(begin: 0.08, end: 0);
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
        title: Text(
          AppLocalization.get('clear_history', appLanguage),
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalization.get('clear_history_confirm', appLanguage),
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalization.get('cancel', appLanguage),
              style: TextStyle(color: textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HadithCubit>().clearHistory();
            },
            child: Text(
              AppLocalization.get('delete', appLanguage),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

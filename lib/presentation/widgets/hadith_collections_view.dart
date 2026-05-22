import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/data/models/hadith_model.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/hadiths/hadith_state.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
            decoration: const BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(color: Color(0xFF1E293B), width: 1.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Note',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Gap(16),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkCanvas,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: TextField(
                    controller: textController,
                    maxLines: 5,
                    autofocus: true,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter note reflection details...',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
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
                          foregroundColor: AppTheme.darkCanvas,
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
                        label: const Text('Update Note'),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurfaceCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
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
                      'Hadith #${hadith.hadithNumber}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
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
                          color: AppTheme.darkSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1E293B)),
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
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                if (hadith.grades.isNotEmpty) ...[
                  const Gap(12),
                  const Divider(color: Color(0xFF1E293B), height: 1),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurfaceCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
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
              border: const Border(
                bottom: BorderSide(color: Color(0xFF1E293B)),
              ),
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
                    const Text(
                      'Study Notes',
                      style: TextStyle(
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
                      child: const Icon(
                        Icons.edit_rounded,
                        color: AppTheme.textSecondary,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  noteText,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
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
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(flag, style: const TextStyle(fontSize: 10)),
                            const Gap(4),
                            Text(
                              hadithResources?.nameNative ?? bookKey,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Hadith #${hadith.hadithNumber}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    hadith.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
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
    final bookmarks = state.bookmarkedRefs.toList();
    if (bookmarks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_outline_rounded,
        title: 'No Bookmarks Yet',
        subtitle: 'Save important Hadiths to quick-access them here.',
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
    final pins = state.pinnedRefs.toList();
    if (pins.isEmpty) {
      return _buildEmptyState(
        icon: Icons.push_pin_outlined,
        title: 'No Pinned Hadiths',
        subtitle: 'Pin hadiths that you are currently studying or reviewing.',
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
    final notes = state.hadithNotes.entries.toList();
    if (notes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.note_alt_outlined,
        title: 'No Notes Found',
        subtitle: 'Record personal reflections and bookmarks will show up.',
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
    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.darkCanvas,
          appBar: AppBar(
            backgroundColor: AppTheme.darkSurface,
            elevation: 0,
            title: const Text(
              'My Library Collections',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: AppTheme.darkSurface,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primaryMint,
                  labelColor: AppTheme.primaryMint,
                  unselectedLabelColor: AppTheme.textSecondary,
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
                  tabs: const [
                    Tab(
                      iconMargin: EdgeInsets.only(bottom: 2),
                      icon: Icon(Icons.bookmark_rounded, size: 18),
                      text: 'Bookmarks',
                    ),
                    Tab(
                      iconMargin: EdgeInsets.only(bottom: 2),
                      icon: Icon(Icons.push_pin_rounded, size: 18),
                      text: 'Pinned',
                    ),
                    Tab(
                      iconMargin: EdgeInsets.only(bottom: 2),
                      icon: Icon(Icons.note_alt_rounded, size: 18),
                      text: 'Notes',
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
            ],
          ),
        );
      },
    );
  }
}

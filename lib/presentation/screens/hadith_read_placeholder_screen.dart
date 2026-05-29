import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/data/models/hadith_model.dart';
import 'package:al_hadith/data/repositories/hadith_repository.dart';
import 'package:al_hadith/data/services/history_service.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';
import 'package:al_hadith/logic/settings/settings_cubit.dart';
import 'package:al_hadith/logic/settings/settings_state.dart';
import 'package:al_hadith/core/localization/app_localization.dart';

enum _ViewMode { page, list }

class HadithReadPlaceholderScreen extends StatefulWidget {
  final String bookKey;
  final int initialHadithNumber;
  final int? initialSectionId;
  final String sectionName;

  const HadithReadPlaceholderScreen({
    super.key,
    required this.bookKey,
    required this.initialHadithNumber,
    this.initialSectionId,
    this.sectionName = '',
  });

  @override
  State<HadithReadPlaceholderScreen> createState() =>
      _HadithReadPlaceholderScreenState();
}

class _HadithReadPlaceholderScreenState
    extends State<HadithReadPlaceholderScreen> {
  List<HadithItem> _hadiths = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;
  _ViewMode _viewMode = _ViewMode.page;
  String _bookName = '';

  late PageController _pageController;
  final ItemScrollController _listScrollController = ItemScrollController();
  final ItemPositionsListener _listPositionsListener =
      ItemPositionsListener.create();

  // Dwell timer: marks a hadith as read only after the user
  // stays on it for 5 continuous seconds.
  Timer? _dwellTimer;
  int? _dwellIndex; // index the timer is currently tracking

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadSection();
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSection() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<HadithRepository>();
      final cubit = context.read<HadithCubit>();

      // Resolve book name
      final books = cubit.state.downloadedBooks;
      if (books.any((b) => b.book == widget.bookKey)) {
        final book = books.firstWhere((b) => b.book == widget.bookKey);
        _bookName = book.nameNative.isNotEmpty ? book.nameNative : book.name;
      } else {
        _bookName = widget.bookKey;
      }

      List<HadithItem> loaded;
      if (widget.initialSectionId != null) {
        loaded = await repo.getHadithsForSection(
          widget.bookKey,
          widget.initialSectionId!,
        );
      } else {
        // Fallback: load single hadith
        final single = await repo.getHadithByNumber(
          widget.bookKey,
          widget.initialHadithNumber,
        );
        loaded = single != null ? [single] : [];
      }

      if (loaded.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'No hadiths found for this section.';
        });
        return;
      }

      // Find starting index
      int startIdx = loaded.indexWhere(
        (h) => h.hadithNumber == widget.initialHadithNumber,
      );
      if (startIdx == -1) startIdx = 0;

      setState(() {
        _hadiths = loaded;
        _currentIndex = startIdx;
        _isLoading = false;
      });

      // Jump PageController to correct page after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && startIdx > 0) {
          _pageController.jumpToPage(startIdx);
        }
      });

      // Save reading session
      await cubit.saveReadingSession(
        bookKey: widget.bookKey,
        bookName: _bookName,
        hadithNumber: loaded[startIdx].hadithNumber,
        sectionTitle: widget.sectionName,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load hadiths: ${e.toString()}';
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _saveSession();
    _startDwellTimer(index);
  }

  void _onListScroll() {
    final positions = _listPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final first = positions
          .where((p) => p.itemTrailingEdge > 0)
          .reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b);
      if (first.index != _currentIndex) {
        setState(() => _currentIndex = first.index);
        _saveSession();
        _startDwellTimer(first.index);
      }
    }
  }

  Future<void> _saveSession() async {
    if (_hadiths.isEmpty) return;
    final cubit = context.read<HadithCubit>();
    await cubit.saveReadingSession(
      bookKey: widget.bookKey,
      bookName: _bookName,
      hadithNumber: _hadiths[_currentIndex].hadithNumber,
      sectionTitle: widget.sectionName,
    );
  }

  void _startDwellTimer(int index) {
    final settings = context.read<SettingsCubit>().state;
    if (!settings.autoMarkRead) return;

    _dwellTimer?.cancel();
    _dwellIndex = index;
    _dwellTimer = Timer(Duration(seconds: settings.dwellTimerSeconds), () {
      // Ensure we are still mounted and still on the same hadith
      if (!mounted) return;
      if (_currentIndex != _dwellIndex) return;
      if (_hadiths.isEmpty || index >= _hadiths.length) return;

      final hadith = _hadiths[index];
      final historyService = context.read<HistoryService>();
      // Only mark if not already read
      if (!historyService.isHadithRead(widget.bookKey, hadith.hadithNumber)) {
        context.read<HadithCubit>().toggleHadithReadStatus(
          bookKey: widget.bookKey,
          hadithNumber: hadith.hadithNumber,
          isRead: true,
        );
        // Rebuild the card to reflect the new read state
        setState(() {});
      }
    });
  }

  void _switchView() {
    final newMode = _viewMode == _ViewMode.page
        ? _ViewMode.list
        : _ViewMode.page;
    setState(() => _viewMode = newMode);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (newMode == _ViewMode.list && _listScrollController.isAttached) {
        _listScrollController.jumpTo(index: _currentIndex);
      } else if (newMode == _ViewMode.page && _pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
    });
  }

  void _showJumpDialog() {
    if (_hadiths.isEmpty) return;
    int selected = _currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final navBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;

    showModalBottomSheet(
      context: context,
      backgroundColor: navBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                AppLocalization.get('jump_to_hadith', appLanguage),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const Gap(6),
              Text(
                AppLocalization.get('jump_to_hadith_count', appLanguage, args: {'current': '${selected + 1}', 'total': '${_hadiths.length}'}),
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
              const Gap(20),
              SliderTheme(
                data: SliderTheme.of(ctx).copyWith(
                  activeTrackColor: AppTheme.primaryMint,
                  thumbColor: AppTheme.primaryMint,
                  inactiveTrackColor: borderDividerColor,
                  overlayColor: AppTheme.primaryMint.withValues(alpha: 0.15),
                ),
                child: Slider(
                  value: selected.toDouble(),
                  min: 0,
                  max: (_hadiths.length - 1).toDouble(),
                  divisions: _hadiths.length > 1 ? _hadiths.length - 1 : 1,
                  onChanged: (v) => setModal(() => selected = v.round()),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalization.get('hadith_no', appLanguage, args: {'number': '${_hadiths.first.hadithNumber}'}),
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    AppLocalization.get('hadith_no', appLanguage, args: {'number': '${_hadiths.last.hadithNumber}'}),
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Gap(20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMint,
                    foregroundColor: AppTheme.darkCanvas,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _currentIndex = selected);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_viewMode == _ViewMode.page &&
                          _pageController.hasClients) {
                        _pageController.jumpToPage(selected);
                      } else if (_listScrollController.isAttached) {
                        _listScrollController.jumpTo(index: selected);
                      }
                    });
                  },
                  child: Text(
                    AppLocalization.get('go_to_hadith_number', appLanguage, args: {'number': '${_hadiths[selected].hadithNumber}'}),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareHadith(HadithItem hadith) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final navBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;

    showModalBottomSheet(
      context: context,
      backgroundColor: navBgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(20),
            // Visual Share Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryMint.withValues(alpha: 0.12),
                    AppTheme.secondaryIndigo.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryMint.withValues(alpha: 0.25),
                ),
              ),
            ),
            const Gap(20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: BorderSide(color: borderDividerColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      final text =
                          '${AppLocalization.get('hadith_no', appLanguage, args: {'number': '${hadith.hadithNumber}'})}\n\n${hadith.text}\n\n— $_bookName\n\n${AppLocalization.get('shared_via_app', appLanguage)}';
                      Clipboard.setData(ClipboardData(text: text));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.copy_all,
                                color: AppTheme.darkCanvas,
                                size: 16,
                              ),
                              const Gap(8),
                              Text(AppLocalization.get('copied_to_clipboard', appLanguage)),
                            ],
                          ),
                          backgroundColor: AppTheme.primaryMint,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    label: Text(AppLocalization.get('copy', appLanguage)),
                  ),
                ),
                const Gap(12),
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
                      final text =
                          '${AppLocalization.get('hadith_no', appLanguage, args: {'number': '${hadith.hadithNumber}'})}\n\n${hadith.text}\n\n— $_bookName\n\n${AppLocalization.get('shared_via_app', appLanguage)}';
                      Share.share(
                        text,
                        subject: AppLocalization.get('hadith_no', appLanguage, args: {'number': '${hadith.hadithNumber}'}),
                      );
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: Text(AppLocalization.get('share', appLanguage)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;
    final title = widget.sectionName.isNotEmpty
        ? widget.sectionName
        : _bookName.isNotEmpty
        ? _bookName
        : AppLocalization.get('hadith_book_default_title', appLanguage);
    final canvasColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (_hadiths.isNotEmpty)
              Text(
                '${AppLocalization.get('hadith_no', appLanguage, args: {'number': '${_hadiths[_currentIndex].hadithNumber}'})} · ${AppLocalization.get('jump_to_hadith_count', appLanguage, args: {'current': '${_currentIndex + 1}', 'total': '${_hadiths.length}'})}',
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_hadiths.isNotEmpty) ...[
            IconButton(
              tooltip: AppLocalization.get('jump_to_hadith', appLanguage),
              icon: Icon(
                Icons.subdirectory_arrow_left,
                color: textSecondary,
                size: 22,
              ),
              onPressed: _showJumpDialog,
            ),
            IconButton(
              tooltip: _viewMode == _ViewMode.page
                  ? 'Switch to List View'
                  : 'Switch to Page View',
              icon: Icon(
                _viewMode == _ViewMode.page
                    ? Icons.view_list_rounded
                    : Icons.auto_stories_rounded,
                color: AppTheme.primaryMint,
                size: 22,
              ),
              onPressed: _switchView,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryMint),
            )
          : _error != null
          ? _buildError()
          : _hadiths.isEmpty
          ? Center(
              child: Text(
                AppLocalization.get('no_hadiths_available', appLanguage),
                style: TextStyle(color: textSecondary),
              ),
            )
          : _viewMode == _ViewMode.page
          ? _buildPageView()
          : _buildListView(),
      bottomNavigationBar: (_viewMode == _ViewMode.page && _hadiths.isNotEmpty)
          ? _buildPageNavBar()
          : null,
    );
  }
  
    Widget _buildPageNavBar() {
      final canPrev = _currentIndex > 0;
      final canNext = _currentIndex < _hadiths.length - 1;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
      final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
      final navBgColor = isDark ? AppTheme.darkSurface : Colors.white;
      final pillBgColor = isDark ? AppTheme.darkSurfaceCard : const Color(0xFFF3F4F6);
      final appLanguage = context.read<SettingsCubit>().state.appLanguage;
  
      return Container(
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(top: BorderSide(color: borderDividerColor, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Previous button
                Expanded(
                  child: AnimatedOpacity(
                    opacity: canPrev ? 1.0 : 0.35,
                    duration: 200.ms,
                    child: TextButton.icon(
                      onPressed: canPrev
                          ? () => _pageController.animateToPage(
                              _currentIndex - 1,
                              duration: 300.ms,
                              curve: Curves.easeInOut,
                            )
                          : null,
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 14,
                        color: AppTheme.primaryMint,
                      ),
                      label: Text(
                        AppLocalization.get('previous', appLanguage),
                        style: const TextStyle(
                          color: AppTheme.primaryMint,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
  
                // Centre progress pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: pillBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderDividerColor),
                  ),
                  child: Text(
                    AppLocalization.get('jump_to_hadith_count', appLanguage, args: {'current': '${_currentIndex + 1}', 'total': '${_hadiths.length}'}),
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
  
                // Next button
                Expanded(
                  child: AnimatedOpacity(
                    opacity: canNext ? 1.0 : 0.35,
                    duration: 200.ms,
                    child: TextButton.icon(
                      onPressed: canNext
                          ? () => _pageController.animateToPage(
                              _currentIndex + 1,
                              duration: 300.ms,
                              curve: Curves.easeInOut,
                            )
                          : null,
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppTheme.primaryMint,
                      ),
                      label: Text(
                        AppLocalization.get('next', appLanguage),
                        style: const TextStyle(
                          color: AppTheme.primaryMint,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  
    Widget _buildError() {
      final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
      final appLanguage = context.read<SettingsCubit>().state.appLanguage;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const Gap(16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary),
              ),
              const Gap(20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryMint,
                  foregroundColor: AppTheme.darkCanvas,
                ),
                onPressed: _loadSection,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalization.get('retry_setup_download', appLanguage)),
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      itemCount: _hadiths.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        return _HadithCard(
          hadith: _hadiths[index],
          bookKey: widget.bookKey,
          totalInSection: _hadiths.length,
          indexInSection: index,
          onShare: _shareHadith,
        );
      },
    );
  }

  Widget _buildListView() {
    _listPositionsListener.itemPositions.addListener(_onListScroll);
    return ScrollablePositionedList.builder(
      itemCount: _hadiths.length,
      itemScrollController: _listScrollController,
      itemPositionsListener: _listPositionsListener,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return _HadithCard(
          hadith: _hadiths[index],
          bookKey: widget.bookKey,
          totalInSection: _hadiths.length,
          indexInSection: index,
          onShare: _shareHadith,
          isListItem: true,
        ).animate().fadeIn(duration: 300.ms, delay: (index * 15).ms);
      },
    );
  }
}

/// ─────────────────────────────────────────────
/// Reusable Hadith Card (used in both view modes)
/// ─────────────────────────────────────────────
class _HadithCard extends StatelessWidget {
  final HadithItem hadith;
  final String bookKey;
  final int totalInSection;
  final int indexInSection;
  final void Function(HadithItem) onShare;
  final bool isListItem;

  const _HadithCard({
    required this.hadith,
    required this.bookKey,
    required this.totalInSection,
    required this.indexInSection,
    required this.onShare,
    this.isListItem = false,
  });

  void _showNoteDialog(
    BuildContext context,
    String bookKey,
    int hadithNumber,
    String currentNote,
  ) {
    final textController = TextEditingController(text: currentNote);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final sheetBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final dialogCanvasColor = isDark ? AppTheme.darkCanvas : const Color(0xFFF3F4F6);
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
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
              color: sheetBgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                      AppLocalization.get('study_notes', appLanguage),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: textSecondary,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Gap(16),
                Container(
                  decoration: BoxDecoration(
                    color: dialogCanvasColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderDividerColor),
                  ),
                  child: TextField(
                    controller: textController,
                    maxLines: 5,
                    autofocus: true,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          AppLocalization.get('write_notes_hint', appLanguage),
                      hintStyle: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const Gap(20),
                Row(
                  children: [
                    if (currentNote.isNotEmpty) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          context.read<HadithCubit>().deleteHadithNote(
                            bookKey,
                            hadithNumber,
                          );
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: Text(AppLocalization.get('delete', appLanguage)),
                      ),
                      const Gap(12),
                    ],
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
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: Text(AppLocalization.get('save', appLanguage)),
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

  Widget _buildCardAction({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
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
    final historyService = context.read<HistoryService>();
    final isRead = historyService.isHadithRead(bookKey, hadith.hadithNumber);

    final books = context.read<HadithCubit>().state.downloadedBooks;
    final book = books.any((b) => b.book == bookKey) ? books.firstWhere((b) => b.book == bookKey) : null;
    final bookName = book != null ? (book.nameNative.isNotEmpty ? book.nameNative : book.name) : bookKey;

    // Watch Collections states for live color feedback
    final state = context.watch<HadithCubit>().state;
    final ref = '${bookKey}_${hadith.hadithNumber}';
    final isBookmarked = state.bookmarkedRefs.contains(ref);
    final isPinned = state.pinnedRefs.contains(ref);
    final noteText = state.hadithNotes[ref];
    final hasNote = noteText != null && noteText.trim().isNotEmpty;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final cardBgColor = isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3) : Colors.white;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        isListItem ? 6 : 16,
        16,
        isListItem ? 6 : 20,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderDividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppLocalization.get('hadith_no', appLanguage, args: {'number': '${hadith.hadithNumber}'}),
                        style: const TextStyle(
                          color: AppTheme.primaryMint,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Read toggle
                    GestureDetector(
                      onTap: () {
                        context.read<HadithCubit>().toggleHadithReadStatus(
                          bookKey: bookKey,
                          hadithNumber: hadith.hadithNumber,
                          isRead: !isRead,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isRead
                              ? AppTheme.primaryMint.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isRead
                                ? AppTheme.primaryMint.withValues(alpha: 0.4)
                                : textSecondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isRead
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isRead
                                  ? AppTheme.primaryMint
                                  : textSecondary,
                              size: 14,
                            ),
                            const Gap(4),
                            Text(
                              isRead ? AppLocalization.get('read', appLanguage) : AppLocalization.get('mark_read', appLanguage),
                              style: TextStyle(
                                color: isRead
                                    ? AppTheme.primaryMint
                                    : textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                // Hadith text
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, settingsState) {
                    final isArabic = bookKey.toLowerCase().startsWith('ara');
                    final isLocalFont =
                        settingsState.arabicFontFamily == 'Me Quran' ||
                        settingsState.arabicFontFamily == 'QPC Hafs' ||
                        settingsState.arabicFontFamily == 'Indopak Nastaleeq';

                    final textStyle = isArabic
                        ? (isLocalFont
                              ? TextStyle(
                                  fontFamily: settingsState.arabicFontFamily,
                                  fontSize: settingsState.arabicFontSize,
                                  color: textPrimary,
                                  height: 1.8,
                                  fontFamilyFallback: [
                                    isLocalFont ? 'Me Quran' : 'Arial',
                                  ],
                                )
                              : GoogleFonts.getFont(
                                  settingsState.arabicFontFamily,
                                  fontSize: settingsState.arabicFontSize,
                                  color: textPrimary,
                                  height: 1.8,
                                ))
                        : TextStyle(
                            fontSize: settingsState.translationFontSize,
                            color: textPrimary,
                            height: 1.6,
                            letterSpacing: 0.1,
                            fontFamilyFallback: [
                              settingsState.arabicFontFamily,
                            ],
                          );
                    return Text(
                      hadith.text,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: textStyle,
                    );
                  },
                ),
                // Custom Note Display Speech Bubble
                if (hasNote) ...[
                  const Gap(16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMint.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.primaryMint.withValues(alpha: 0.25),
                        width: 1,
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
                            Text(
                              AppLocalization.get('my_notes', appLanguage),
                              style: const TextStyle(
                                color: AppTheme.primaryMint,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _showNoteDialog(
                                context,
                                bookKey,
                                hadith.hadithNumber,
                                noteText,
                              ),
                              child: Text(
                                AppLocalization.get('edit', appLanguage),
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Grades
                if (hadith.grades.isNotEmpty) ...[
                  const Gap(20),
                  Divider(color: borderDividerColor, height: 1),
                  const Gap(12),
                  Text(
                    AppLocalization.get('authenticity_grading', appLanguage),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: hadith.grades.map((g) {
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
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: c.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${g.scholarName}: ${g.grade}',
                          style: TextStyle(
                            color: c,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                // Bottom Action Bar Row
                const Gap(16),
                Divider(color: borderDividerColor, height: 1),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCardAction(
                      icon: isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: isBookmarked
                          ? AppTheme.primaryMint
                          : textSecondary,
                      label: AppLocalization.get('bookmarks', appLanguage),
                      onTap: () => context.read<HadithCubit>().toggleBookmark(
                        bookKey,
                        hadith.hadithNumber,
                      ),
                    ),
                    _buildCardAction(
                      icon: isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      color: isPinned
                          ? Colors.orangeAccent
                          : textSecondary,
                      label: AppLocalization.get('pinned', appLanguage),
                      onTap: () => context.read<HadithCubit>().togglePin(
                        bookKey,
                        hadith.hadithNumber,
                      ),
                    ),
                    _buildCardAction(
                      icon: hasNote
                          ? Icons.note_alt_rounded
                          : Icons.note_alt_outlined,
                      color: hasNote
                          ? Colors.tealAccent
                          : textSecondary,
                      label: AppLocalization.get('notes', appLanguage),
                      onTap: () => _showNoteDialog(
                        context,
                        bookKey,
                        hadith.hadithNumber,
                        noteText ?? '',
                      ),
                    ),
                    _buildCardAction(
                      icon: Icons.content_copy_rounded,
                      color: textSecondary,
                      label: AppLocalization.get('copy', appLanguage),
                      onTap: () {
                        final copyText =
                            '${AppLocalization.get('hadith_no', appLanguage, args: {'number': '${hadith.hadithNumber}'})}\n\n${hadith.text}\n\n— $bookName\n\n${AppLocalization.get('shared_via_app', appLanguage)}';
                        Clipboard.setData(ClipboardData(text: copyText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalization.get('copied_to_clipboard', appLanguage)),
                            backgroundColor: AppTheme.primaryMint,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    _buildCardAction(
                      icon: Icons.share_rounded,
                      color: textSecondary,
                      label: AppLocalization.get('share', appLanguage),
                      onTap: () => onShare(hadith),
                    ),
                  ],
                ),
                // Page view swipe hint (only in page mode, first card)
                if (!isListItem &&
                    indexInSection == 0 &&
                    totalInSection > 1) ...[
                  const Gap(14),
                  Divider(color: borderDividerColor, height: 1),
                  const Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swipe_rounded,
                        color: textSecondary,
                        size: 14,
                      ),
                      const Gap(6),
                      Text(
                        AppLocalization.get('swipe_nav_hint', appLanguage),
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

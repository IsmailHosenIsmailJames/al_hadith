import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:al_hadith/core/theme/app_theme.dart';
import 'package:al_hadith/data/models/hadith_model.dart';
import 'package:al_hadith/data/repositories/hadith_repository.dart';
import 'package:al_hadith/data/services/history_service.dart';
import 'package:al_hadith/logic/hadiths/hadith_cubit.dart';

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
      _bookName = books.any((b) => b.book == widget.bookKey)
          ? books.firstWhere((b) => b.book == widget.bookKey).name
          : widget.bookKey;

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

  /// Starts (or resets) the 5-second dwell timer for [index].
  /// When it fires and the user is still on the same hadith, it is
  /// automatically marked as read.
  void _startDwellTimer(int index) {
    _dwellTimer?.cancel();
    _dwellIndex = index;
    _dwellTimer = Timer(const Duration(seconds: 5), () {
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
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
                    color: AppTheme.textSecondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(20),
              const Text(
                'Jump to Hadith',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Gap(6),
              Text(
                '${selected + 1} of ${_hadiths.length}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Gap(20),
              SliderTheme(
                data: SliderTheme.of(ctx).copyWith(
                  activeTrackColor: AppTheme.primaryMint,
                  thumbColor: AppTheme.primaryMint,
                  inactiveTrackColor: const Color(0xFF1E293B),
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
                    'Hadith #${_hadiths.first.hadithNumber}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Hadith #${_hadiths.last.hadithNumber}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
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
                        _pageController.animateToPage(
                          selected,
                          duration: 300.ms,
                          curve: Curves.easeInOut,
                        );
                      } else if (_listScrollController.isAttached) {
                        _listScrollController.scrollTo(
                          index: selected,
                          duration: 400.ms,
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  },
                  child: Text(
                    'Go to Hadith #${_hadiths[selected].hadithNumber}',
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
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
                color: AppTheme.textSecondary.withValues(alpha: 0.4),
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
                          color: AppTheme.primaryMint.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Hadith #${hadith.hadithNumber}',
                          style: const TextStyle(
                            color: AppTheme.primaryMint,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.menu_book_rounded,
                        color: AppTheme.primaryMint,
                        size: 18,
                      ),
                    ],
                  ),
                  const Gap(14),
                  Text(
                    hadith.text,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(16),
                  const Divider(color: Color(0xFF1E293B), height: 1),
                  const Gap(12),
                  Row(
                    children: [
                      Text(
                        _bookName,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Al Hadith App',
                        style: TextStyle(
                          color: AppTheme.primaryMint,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: Color(0xFF1E293B)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      final text =
                          'Hadith #${hadith.hadithNumber}\n\n${hadith.text}\n\n— $_bookName\n\nShared via Al Hadith App';
                      Clipboard.setData(ClipboardData(text: text));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(
                                Icons.copy_all,
                                color: AppTheme.darkCanvas,
                                size: 16,
                              ),
                              Gap(8),
                              Text('Copied to clipboard!'),
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
                    label: const Text('Copy'),
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
                          'Hadith #${hadith.hadithNumber}\n\n${hadith.text}\n\n— $_bookName\n\nShared via Al Hadith App';
                      Share.share(
                        text,
                        subject: 'Hadith #${hadith.hadithNumber}',
                      );
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share'),
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
    final title = widget.sectionName.isNotEmpty
        ? widget.sectionName
        : _bookName.isNotEmpty
        ? _bookName
        : 'Reading';

    return Scaffold(
      backgroundColor: AppTheme.darkCanvas,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (_hadiths.isNotEmpty)
              Text(
                'Hadith ${_hadiths[_currentIndex].hadithNumber} · ${_currentIndex + 1} / ${_hadiths.length}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_hadiths.isNotEmpty) ...[
            IconButton(
              tooltip: 'Jump to hadith',
              icon: const Icon(
                Icons.subdirectory_arrow_left,
                color: AppTheme.textSecondary,
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
          ? const Center(
              child: Text(
                'No hadiths available.',
                style: TextStyle(color: AppTheme.textSecondary),
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

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
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
                    label: const Text(
                      'Previous',
                      style: TextStyle(
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${_hadiths.length}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
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
                    label: const Text(
                      'Next',
                      style: TextStyle(
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
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const Gap(20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMint,
                foregroundColor: AppTheme.darkCanvas,
              ),
              onPressed: _loadSection,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
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

  @override
  Widget build(BuildContext context) {
    final historyService = context.read<HistoryService>();
    final isRead = historyService.isHadithRead(bookKey, hadith.hadithNumber);

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
              color: AppTheme.darkSurfaceCard.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E293B)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
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
                        'Hadith #${hadith.hadithNumber}',
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
                                : AppTheme.textSecondary.withValues(alpha: 0.3),
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
                                  : AppTheme.textSecondary,
                              size: 14,
                            ),
                            const Gap(4),
                            Text(
                              isRead ? 'Read' : 'Mark Read',
                              style: TextStyle(
                                color: isRead
                                    ? AppTheme.primaryMint
                                    : AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(8),
                    // Share button inline
                    GestureDetector(
                      onTap: () => onShare(hadith),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: AppTheme.textSecondary,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                // Hadith text
                Text(
                  hadith.text,
                  style: const TextStyle(
                    fontSize: 15.5,
                    color: AppTheme.textPrimary,
                    height: 1.7,
                    letterSpacing: 0.1,
                  ),
                ),
                // Grades
                if (hadith.grades.isNotEmpty) ...[
                  const Gap(20),
                  const Divider(color: Color(0xFF1E293B), height: 1),
                  const Gap(12),
                  const Text(
                    'Authenticity Grading',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
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
                // Page view swipe hint (only in page mode, first card)
                if (!isListItem &&
                    indexInSection == 0 &&
                    totalInSection > 1) ...[
                  const Gap(20),
                  const Divider(color: Color(0xFF1E293B), height: 1),
                  const Gap(10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swipe_rounded,
                        color: AppTheme.textSecondary,
                        size: 14,
                      ),
                      Gap(6),
                      Text(
                        'Swipe left/right to navigate',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
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

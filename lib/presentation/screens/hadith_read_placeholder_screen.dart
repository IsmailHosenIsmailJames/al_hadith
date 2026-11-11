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
import 'package:al_hadith/data/services/preferences_service.dart';
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
  String _sectionName = '';

  late PageController _pageController;
  final ItemScrollController _listScrollController = ItemScrollController();
  final ItemPositionsListener _listPositionsListener =
      ItemPositionsListener.create();

  // Dwell timer: marks a hadith as read only after the user
  // stays on it for 5 continuous seconds.
  Timer? _dwellTimer;
  int? _dwellIndex; // index the timer is currently tracking

  late HadithCubit _hadithCubit;
  late DateTime _sessionStartTime;
  final Set<int> _readHadithsInSession = {};

  @override
  void initState() {
    super.initState();
    _sectionName = widget.sectionName;

    // Load saved view mode preference
    final prefs = context.read<PreferencesService>();
    final savedMode = prefs.getHadithViewMode();
    _viewMode = savedMode == 'list' ? _ViewMode.list : _ViewMode.page;

    _pageController = PageController(initialPage: 0);
    _loadSection();

    _hadithCubit = context.read<HadithCubit>();
    _sessionStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _pageController.dispose();

    // Log the reading session if it lasted more than 10 seconds
    final durationSeconds = DateTime.now().difference(_sessionStartTime).inSeconds;
    if (durationSeconds >= 10) {
      // Limit to max 30 minutes (1800s) to avoid idle tab background leakage
      final loggedDuration = durationSeconds > 1800 ? 1800 : durationSeconds;
      _hadithCubit.recordReadingSession(
        durationSeconds: loggedDuration,
        hadithsReadCount: _readHadithsInSession.length,
      );
    }

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

      int? resolvedSectionId = widget.initialSectionId;
      List<HadithItem> loaded;
      if (resolvedSectionId != null) {
        loaded = await repo.getHadithsForSection(
          widget.bookKey,
          resolvedSectionId,
        );
      } else {
        // Fallback: load single hadith to find sectionId, then load entire section!
        final single = await repo.getHadithByNumber(
          widget.bookKey,
          widget.initialHadithNumber,
        );
        if (single != null) {
          resolvedSectionId = single.sectionId;
          loaded = await repo.getHadithsForSection(
            widget.bookKey,
            resolvedSectionId,
          );
          if (loaded.isEmpty) {
            loaded = [single];
          }
        } else {
          loaded = [];
        }
      }

      if (_sectionName.isEmpty && resolvedSectionId != null) {
        final section = await repo.getSectionById(
          widget.bookKey,
          resolvedSectionId,
        );
        if (section != null) {
          _sectionName = section.sectionNameNative.isNotEmpty
              ? section.sectionNameNative
              : section.sectionName;
        }
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

      // Jump to correct page/index after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_viewMode == _ViewMode.page && _pageController.hasClients && startIdx > 0) {
          _pageController.jumpToPage(startIdx);
        } else if (_viewMode == _ViewMode.list && _listScrollController.isAttached && startIdx > 0) {
          _listScrollController.jumpTo(index: startIdx);
        }
      });

      // Save reading session
      await cubit.saveReadingSession(
        bookKey: widget.bookKey,
        bookName: _bookName,
        hadithNumber: loaded[startIdx].hadithNumber,
        sectionTitle: _sectionName,
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
      sectionTitle: _sectionName,
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
          bookName: _bookName,
          sectionTitle: _sectionName,
        );
        _readHadithsInSession.add(hadith.hadithNumber);
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

    // Save view mode preference
    context.read<PreferencesService>().setHadithViewMode(
      newMode == _ViewMode.list ? 'list' : 'page',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (newMode == _ViewMode.list && _listScrollController.isAttached) {
        _listScrollController.jumpTo(index: _currentIndex);
      } else if (newMode == _ViewMode.page && _pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
    });
  }

  void _showTypographyStudio() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    final fonts = [
      'Me Quran',
      'QPC Hafs',
      'Indopak Nastaleeq',
      'Amiri',
      'Scheherazade New',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final settings = context.watch<SettingsCubit>().state;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.format_size_rounded,
                          color: AppTheme.primaryMint,
                          size: 20,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        'Reading Typography & Studio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: textSecondary,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Gap(16),
                  // Arabic Font Size
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Arabic Font Size',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${settings.arabicFontSize.toInt()} pt',
                          style: const TextStyle(
                            color: AppTheme.primaryMint,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(ctx).copyWith(
                      activeTrackColor: AppTheme.primaryMint,
                      thumbColor: AppTheme.primaryMint,
                      inactiveTrackColor: borderDividerColor,
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: settings.arabicFontSize,
                      min: 18.0,
                      max: 38.0,
                      divisions: 20,
                      onChanged: (val) {
                        context.read<SettingsCubit>().setArabicFontSize(val);
                        setSheetState(() {});
                      },
                    ),
                  ),
                  const Gap(8),
                  // Translation Font Size
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Translation Font Size',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${settings.translationFontSize.toInt()} pt',
                          style: const TextStyle(
                            color: AppTheme.primaryMint,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(ctx).copyWith(
                      activeTrackColor: AppTheme.primaryMint,
                      thumbColor: AppTheme.primaryMint,
                      inactiveTrackColor: borderDividerColor,
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: settings.translationFontSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 12,
                      onChanged: (val) {
                        context
                            .read<SettingsCubit>()
                            .setTranslationFontSize(val);
                        setSheetState(() {});
                      },
                    ),
                  ),
                  const Gap(12),
                  // Arabic Font Family
                  Text(
                    'Arabic Font Family',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const Gap(8),
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: fonts.length,
                      separatorBuilder: (context, index) => const Gap(8),
                      itemBuilder: (context, idx) {
                        final f = fonts[idx];
                        final isSelected = settings.arabicFontFamily == f;
                        return InkWell(
                          onTap: () {
                            context
                                .read<SettingsCubit>()
                                .setArabicFontFamily(f);
                            setSheetState(() {});
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryMint
                                  : (isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryMint
                                    : borderDividerColor,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppTheme.darkCanvas
                                      : textPrimary,
                                ),
                              ),
                            ),
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
      },
    );
  }

  void _showJumpDialog() {
    if (_hadiths.isEmpty) return;
    int selected = _currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final navBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final inputBgColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);
    final appLanguage = context.read<SettingsCubit>().state.appLanguage;
    final numberController = TextEditingController(text: '${selected + 1}');

    showModalBottomSheet(
      context: context,
      backgroundColor: navBgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
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
                    color: textSecondary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.dialpad_rounded,
                      color: AppTheme.primaryMint,
                      size: 20,
                    ),
                  ),
                  const Gap(10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalization.get('jump_to_hadith', appLanguage),
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Direct Jump Dial • ${_hadiths.length} Hadiths',
                        style: TextStyle(fontSize: 11.5, color: textSecondary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: textSecondary,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Gap(16),
              // Direct Number Input & Quick Presets Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: inputBgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderDividerColor),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '#',
                            style: TextStyle(
                              color: AppTheme.primaryMint,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            child: TextField(
                              controller: numberController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter number...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (val) {
                                final n = int.tryParse(val);
                                if (n != null &&
                                    n >= 1 &&
                                    n <= _hadiths.length) {
                                  setModal(() {
                                    selected = n - 1;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(8),
                  // Preset: First
                  _buildJumpPreset(
                    label: 'First',
                    isSelected: selected == 0,
                    onTap: () {
                      setModal(() {
                        selected = 0;
                        numberController.text = '1';
                      });
                    },
                    isDark: isDark,
                    borderDividerColor: borderDividerColor,
                    textPrimary: textPrimary,
                  ),
                  const Gap(6),
                  // Preset: Mid
                  _buildJumpPreset(
                    label: 'Mid',
                    isSelected: selected == _hadiths.length ~/ 2,
                    onTap: () {
                      setModal(() {
                        selected = _hadiths.length ~/ 2;
                        numberController.text = '${selected + 1}';
                      });
                    },
                    isDark: isDark,
                    borderDividerColor: borderDividerColor,
                    textPrimary: textPrimary,
                  ),
                  const Gap(6),
                  // Preset: Last
                  _buildJumpPreset(
                    label: 'Last',
                    isSelected: selected == _hadiths.length - 1,
                    onTap: () {
                      setModal(() {
                        selected = _hadiths.length - 1;
                        numberController.text = '${selected + 1}';
                      });
                    },
                    isDark: isDark,
                    borderDividerColor: borderDividerColor,
                    textPrimary: textPrimary,
                  ),
                ],
              ),
              const Gap(16),
              // Slider
              SliderTheme(
                data: SliderTheme.of(ctx).copyWith(
                  activeTrackColor: AppTheme.primaryMint,
                  thumbColor: AppTheme.primaryMint,
                  inactiveTrackColor: borderDividerColor,
                  overlayColor: AppTheme.primaryMint.withValues(alpha: 0.15),
                  trackHeight: 3.5,
                ),
                child: Slider(
                  value: selected
                      .toDouble()
                      .clamp(0.0, (_hadiths.length - 1).toDouble()),
                  min: 0,
                  max: (_hadiths.length - 1).toDouble(),
                  divisions: _hadiths.length > 1 ? _hadiths.length - 1 : 1,
                  onChanged: (v) {
                    setModal(() {
                      selected = v.round();
                      numberController.text = '${selected + 1}';
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${_hadiths.first.hadithNumber}',
                    style: TextStyle(color: textSecondary, fontSize: 11.5),
                  ),
                  Text(
                    'Selected: #${_hadiths[selected].hadithNumber} (${selected + 1}/${_hadiths.length})',
                    style: const TextStyle(
                      color: AppTheme.primaryMint,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '#${_hadiths.last.hadithNumber}',
                    style: TextStyle(color: textSecondary, fontSize: 11.5),
                  ),
                ],
              ),
              const Gap(18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMint,
                    foregroundColor: AppTheme.darkCanvas,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                    'Go to Hadith #${_hadiths[selected].hadithNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
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

  Widget _buildJumpPreset({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color borderDividerColor,
    required Color textPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryMint
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryMint : borderDividerColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? AppTheme.darkCanvas : textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  void _shareHadith(HadithItem hadith) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final navBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.book_rounded,
                        color: AppTheme.primaryMint,
                        size: 20,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          _bookName,
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        AppLocalization.get(
                          'hadith_no',
                          appLanguage,
                          args: {'number': '${hadith.hadithNumber}'},
                        ),
                        style: const TextStyle(
                          color: AppTheme.primaryMint,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Divider(
                    color: AppTheme.primaryMint.withValues(alpha: 0.2),
                    height: 1,
                  ),
                  const Gap(12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        hadith.text,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
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
                              Text(
                                AppLocalization.get(
                                  'copied_to_clipboard',
                                  appLanguage,
                                ),
                              ),
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
                      SharePlus.instance.share(
                        ShareParams(
                          text: text,
                          subject: AppLocalization.get(
                            'hadith_no',
                            appLanguage,
                            args: {'number': '${hadith.hadithNumber}'},
                          ),
                        ),
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
    final title = _sectionName.isNotEmpty
        ? _sectionName
        : _bookName.isNotEmpty
        ? _bookName
        : AppLocalization.get('hadith_book_default_title', appLanguage);
    final canvasColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        toolbarHeight: 52,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (_hadiths.isNotEmpty)
              Text(
                'Hadith #${_hadiths[_currentIndex].hadithNumber} • ${_currentIndex + 1}/${_hadiths.length}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.primaryMint,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_hadiths.isNotEmpty) ...[
            IconButton(
              tooltip: 'Typography Studio',
              icon: const Icon(
                Icons.format_size_rounded,
                color: AppTheme.primaryMint,
                size: 20,
              ),
              onPressed: _showTypographyStudio,
            ),
            IconButton(
              tooltip: AppLocalization.get('jump_to_hadith', appLanguage),
              icon: Icon(
                Icons.dialpad_rounded,
                color: textSecondary,
                size: 19,
              ),
              onPressed: _showJumpDialog,
            ),
            IconButton(
              tooltip: _viewMode == _ViewMode.page
                  ? 'Switch to Continuous Scroll'
                  : 'Switch to Page View',
              icon: Icon(
                _viewMode == _ViewMode.page
                    ? Icons.view_list_rounded
                    : Icons.auto_stories_rounded,
                color: textSecondary,
                size: 20,
              ),
              onPressed: _switchView,
            ),
            const Gap(4),
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
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    final percent = _hadiths.isNotEmpty
        ? ((_currentIndex + 1) / _hadiths.length * 100).toInt()
        : 0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        6,
        16,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(color: borderDividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          InkWell(
            onTap: canPrev
                ? () => _pageController.animateToPage(
                      _currentIndex - 1,
                      duration: 250.ms,
                      curve: Curves.easeOutCubic,
                    )
                : null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: canPrev
                    ? (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: canPrev ? borderDividerColor : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 13,
                    color: canPrev
                        ? AppTheme.primaryMint
                        : textSecondary.withValues(alpha: 0.3),
                  ),
                  const Gap(5),
                  Text(
                    'Prev',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: canPrev
                          ? textPrimary
                          : textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(10),
          // Interactive Progress Capsule (Tapping opens Jump Dial)
          Expanded(
            child: InkWell(
              onTap: _showJumpDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderDividerColor),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_currentIndex + 1} of ${_hadiths.length}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryMint,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: _hadiths.isNotEmpty
                            ? (_currentIndex + 1) / _hadiths.length
                            : 0,
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                        color: AppTheme.primaryMint,
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(10),
          // Next button
          InkWell(
            onTap: canNext
                ? () => _pageController.animateToPage(
                      _currentIndex + 1,
                      duration: 250.ms,
                      curve: Curves.easeOutCubic,
                    )
                : null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: canNext
                    ? AppTheme.primaryMint
                    : (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: canNext
                          ? AppTheme.darkCanvas
                          : textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                  const Gap(5),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: canNext
                        ? AppTheme.darkCanvas
                        : textSecondary.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
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
              label: Text(
                AppLocalization.get('retry_setup_download', appLanguage),
              ),
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
        ).animate().fadeIn(duration: 250.ms, delay: (index * 12).ms);
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
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final sheetBgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final dialogCanvasColor = isDark
        ? AppTheme.darkCanvas
        : const Color(0xFFF3F4F6);
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
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
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: sheetBgColor,
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
                      AppLocalization.get('study_notes', appLanguage),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Gap(14),
                Container(
                  decoration: BoxDecoration(
                    color: dialogCanvasColor,
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
                        'write_notes_hint',
                        appLanguage,
                      ),
                      hintStyle: TextStyle(color: textSecondary, fontSize: 12.5),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                const Gap(16),
                Row(
                  children: [
                    if (currentNote.isNotEmpty) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          context.read<HadithCubit>().deleteHadithNote(
                            bookKey,
                            hadithNumber,
                          );
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: Text(AppLocalization.get('delete', appLanguage)),
                      ),
                      const Gap(10),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryMint,
                          foregroundColor: AppTheme.darkCanvas,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                        icon: const Icon(Icons.save_rounded, size: 16),
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

  Widget _buildPrimaryGradeBadge(HadithGrade grade) {
    final gl = grade.grade.toLowerCase();
    Color c = Colors.grey;
    IconData icon = Icons.verified_outlined;
    if (gl.contains('sahih')) {
      c = const Color(0xFF10B981);
      icon = Icons.verified_rounded;
    } else if (gl.contains('hasan')) {
      c = Colors.orangeAccent;
      icon = Icons.star_rounded;
    } else if (gl.contains('da') || gl.contains('weak')) {
      c = Colors.redAccent;
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: c),
          const Gap(4),
          Text(
            grade.grade,
            style: TextStyle(
              color: c,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required bool isActive,
    Color? activeColor,
    String? badgeText,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final effectiveColor = isActive
        ? (activeColor ?? AppTheme.primaryMint)
        : textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? (activeColor ?? AppTheme.primaryMint).withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: effectiveColor, size: 17),
                  if (badgeText != null)
                    Positioned(
                      top: -4,
                      right: -7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: effectiveColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: AppTheme.darkCanvas,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const Gap(3),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? effectiveColor : textPrimary,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
              ),
            ],
          ),
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
    final book = books.any((b) => b.book == bookKey)
        ? books.firstWhere((b) => b.book == bookKey)
        : null;
    final bookName = book != null
        ? (book.nameNative.isNotEmpty ? book.nameNative : book.name)
        : bookKey;

    // Watch Collections states for live color feedback
    final state = context.watch<HadithCubit>().state;
    final ref = '${bookKey}_${hadith.hadithNumber}';
    final isBookmarked = state.bookmarkedRefs.contains(ref);
    final isPinned = state.pinnedRefs.contains(ref);
    final noteText = state.hadithNotes[ref];
    final hasNote = noteText != null && noteText.trim().isNotEmpty;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderDividerColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE5E7EB);
    final cardBgColor = isDark
        ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3)
        : Colors.white;
    final pillBgColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        14,
        isListItem ? 5 : 12,
        14,
        isListItem ? 5 : 16,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderDividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Hadith Number Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            color: AppTheme.primaryMint,
                            size: 12,
                          ),
                          const Gap(4),
                          Text(
                            AppLocalization.get(
                              'hadith_no',
                              appLanguage,
                              args: {'number': '${hadith.hadithNumber}'},
                            ),
                            style: const TextStyle(
                              color: AppTheme.primaryMint,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    // Primary Authenticity Grade Pill (if available)
                    if (hadith.grades.isNotEmpty) ...[
                      _buildPrimaryGradeBadge(hadith.grades.first),
                      if (hadith.grades.length > 1) ...[
                        const Gap(4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: pillBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${hadith.grades.length - 1}',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                    const Spacer(),
                    // Read toggle capsule
                    InkWell(
                      onTap: () {
                        context.read<HadithCubit>().toggleHadithReadStatus(
                          bookKey: bookKey,
                          hadithNumber: hadith.hadithNumber,
                          isRead: !isRead,
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isRead
                              ? AppTheme.primaryMint.withValues(alpha: 0.12)
                              : pillBgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isRead
                                ? AppTheme.primaryMint.withValues(alpha: 0.45)
                                : borderDividerColor,
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
                              size: 13,
                            ),
                            const Gap(4),
                            Text(
                              isRead
                                  ? AppLocalization.get('read', appLanguage)
                                  : AppLocalization.get(
                                      'mark_read',
                                      appLanguage,
                                    ),
                              style: TextStyle(
                                color: isRead
                                    ? AppTheme.primaryMint
                                    : textSecondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(14),
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
                                  height: 1.85,
                                  fontFamilyFallback: [
                                    isLocalFont ? 'Me Quran' : 'Arial',
                                  ],
                                )
                              : GoogleFonts.getFont(
                                  settingsState.arabicFontFamily,
                                  fontSize: settingsState.arabicFontSize,
                                  color: textPrimary,
                                  height: 1.85,
                                ))
                        : TextStyle(
                            fontSize: settingsState.translationFontSize,
                            color: textPrimary,
                            height: 1.65,
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
                  const Gap(14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMint.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
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
                              size: 16,
                            ),
                            const Gap(5),
                            Text(
                              AppLocalization.get('my_notes', appLanguage),
                              style: const TextStyle(
                                color: AppTheme.primaryMint,
                                fontSize: 11.5,
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
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(6),
                        Text(
                          noteText,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 12.5,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Detailed Authenticity Grades (if available)
                if (hadith.grades.isNotEmpty) ...[
                  const Gap(16),
                  Divider(color: borderDividerColor, height: 1),
                  const Gap(10),
                  Text(
                    AppLocalization.get('authenticity_grading', appLanguage),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: hadith.grades.map((g) {
                      final gl = g.grade.toLowerCase();
                      Color c = Colors.grey;
                      if (gl.contains('sahih')) {
                        c = const Color(0xFF10B981);
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
                          color: c.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: c.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '${g.scholarName}: ${g.grade}',
                          style: TextStyle(
                            color: c,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                // Bottom Action Bar Row
                const Gap(14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111C28) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderDividerColor, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      _buildActionItem(
                        icon: isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        label: AppLocalization.get('bookmarks', appLanguage),
                        isActive: isBookmarked,
                        activeColor: AppTheme.primaryMint,
                        context: context,
                        onTap: () => context.read<HadithCubit>().toggleBookmark(
                          bookKey,
                          hadith.hadithNumber,
                        ),
                      ),
                      _buildActionItem(
                        icon: isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        label: AppLocalization.get('pinned', appLanguage),
                        isActive: isPinned,
                        activeColor: Colors.orangeAccent,
                        context: context,
                        onTap: () => context.read<HadithCubit>().togglePin(
                          bookKey,
                          hadith.hadithNumber,
                        ),
                      ),
                      _buildActionItem(
                        icon: hasNote
                            ? Icons.note_alt_rounded
                            : Icons.note_alt_outlined,
                        label: AppLocalization.get('notes', appLanguage),
                        isActive: hasNote,
                        activeColor: Colors.tealAccent,
                        badgeText: hasNote ? '1' : null,
                        context: context,
                        onTap: () => _showNoteDialog(
                          context,
                          bookKey,
                          hadith.hadithNumber,
                          noteText ?? '',
                        ),
                      ),
                      _buildActionItem(
                        icon: Icons.content_copy_rounded,
                        label: AppLocalization.get('copy', appLanguage),
                        isActive: false,
                        context: context,
                        onTap: () {
                          final copyText =
                              '${AppLocalization.get('hadith_no', appLanguage, args: {'number': '${hadith.hadithNumber}'})}\n\n${hadith.text}\n\n— $bookName\n\n${AppLocalization.get('shared_via_app', appLanguage)}';
                          Clipboard.setData(ClipboardData(text: copyText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalization.get(
                                  'copied_to_clipboard',
                                  appLanguage,
                                ),
                              ),
                              backgroundColor: AppTheme.primaryMint,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      _buildActionItem(
                        icon: Icons.share_rounded,
                        label: AppLocalization.get('share', appLanguage),
                        isActive: false,
                        context: context,
                        onTap: () => onShare(hadith),
                      ),
                    ],
                  ),
                ),
                // Page view swipe hint (only in page mode, first card)
                if (!isListItem &&
                    indexInSection == 0 &&
                    totalInSection > 1) ...[
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swipe_rounded, color: textSecondary, size: 13),
                      const Gap(5),
                      Text(
                        AppLocalization.get('swipe_nav_hint', appLanguage),
                        style: TextStyle(color: textSecondary, fontSize: 10.5),
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

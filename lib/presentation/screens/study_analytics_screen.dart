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

class StudyAnalyticsScreen extends StatefulWidget {
  const StudyAnalyticsScreen({super.key});

  @override
  State<StudyAnalyticsScreen> createState() => _StudyAnalyticsScreenState();
}

class _StudyAnalyticsScreenState extends State<StudyAnalyticsScreen> {
  DateTime _selectedMonth = DateTime.now();
  int _selectedWeekOffset = 0;
  DateTime _selectedCalendarDay = DateTime.now();

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  String _formatDateTime(DateTime dt) {
    final monthStr = _months[dt.month - 1];
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minStr = dt.minute.toString().padLeft(2, '0');
    return '$monthStr ${dt.day}, ${dt.year} $hour:$minStr $amPm';
  }

  String _getWeekRangeString(DateTime now, int offset) {
    final startDay = now.subtract(Duration(days: (offset * 7) + 6));
    final endDay = now.subtract(Duration(days: offset * 7));
    
    final startMonthStr = _months[startDay.month - 1].substring(0, 3);
    final endMonthStr = _months[endDay.month - 1].substring(0, 3);
    
    if (startDay.year == endDay.year) {
      if (startDay.month == endDay.month) {
        return '$startMonthStr ${startDay.day} - ${endDay.day}, ${endDay.year}';
      } else {
        return '$startMonthStr ${startDay.day} - $endMonthStr ${endDay.day}, ${endDay.year}';
      }
    } else {
      return '$startMonthStr ${startDay.day}, ${startDay.year} - $endMonthStr ${endDay.day}, ${endDay.year}';
    }
  }

  String _formatTimeOnly(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minStr = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minStr $amPm';
  }

  void _onPrevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _selectedCalendarDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    });
  }

  void _onNextMonth() {
    final now = DateTime.now();
    if (_selectedMonth.year < now.year || (_selectedMonth.year == now.year && _selectedMonth.month < now.month)) {
      setState(() {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
        if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) {
          _selectedCalendarDay = now;
        } else {
          _selectedCalendarDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
        }
      });
    }
  }

  void _showDailyGoalBottomSheet(BuildContext context, int currentGoal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                const Gap(16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.track_changes_rounded,
                        color: AppTheme.primaryMint,
                        size: 20,
                      ),
                    ),
                    const Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adjust Daily Goal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Set your daily target for reading Hadiths',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [1, 3, 5, 7, 10, 15].map((g) {
                    final isSelected = g == currentGoal;
                    return InkWell(
                      onTap: () {
                        context.read<HadithCubit>().updateDailyGoal(g);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryMint
                              : (isDark
                                  ? AppTheme.darkSurfaceCard
                                  : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryMint
                                : (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Text(
                          '$g ${g == 1 ? 'Hadith' : 'Hadiths'} / day',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppTheme.darkCanvas
                                : textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final cardBgColor = isDark ? AppTheme.darkSurfaceCard : Colors.white;
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;

    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        int totalDurationSecs = 0;
        for (final session in state.readingSessions) {
          totalDurationSecs += session.durationSeconds;
        }
        final totalMinutes = (totalDurationSecs / 60).round();

        // Calculate count of read Hadiths per day from readHistory
        final Map<String, int> dailyReadCounts = {};
        for (final record in state.readHistory) {
          final dt = DateTime.fromMillisecondsSinceEpoch(record.timestamp);
          final dateStr = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
          dailyReadCounts[dateStr] = (dailyReadCounts[dateStr] ?? 0) + 1;
        }

        // Today's reading count
        final today = DateTime.now();
        final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        final todayCount = dailyReadCounts[todayStr] ?? 0;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            toolbarHeight: 52,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 19, color: textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              AppLocalization.get('study_analytics', appLanguage),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              children: [
                // 1. Hero Telemetry Strip (High-Density 4-Column Capsule)
                _buildHeroTelemetryStrip(
                  state: state,
                  totalMinutes: totalMinutes,
                  cardBgColor: cardBgColor,
                  borderDividerColor: borderDividerColor,
                  isDark: isDark,
                ),

                const Gap(14),

                // 2. Daily Goal Mastery Card (Ring Gauge + Goal Status)
                _buildDailyGoalMasteryCard(
                  state: state,
                  todayCount: todayCount,
                  cardBgColor: cardBgColor,
                  borderDividerColor: borderDividerColor,
                  isDark: isDark,
                ),

                const Gap(14),

                // 3. Weekly Reading Time Chart with Goal Benchmark
                _buildBarChartCard(
                  state: state,
                  appLang: appLanguage,
                  cardBgColor: cardBgColor,
                  borderColor: borderDividerColor,
                  isDark: isDark,
                ),

                const Gap(14),

                // 4. Monthly Activity Heat-Map with Inline Day Inspector
                _buildCalendarCard(
                  state: state,
                  dailyReadCounts: dailyReadCounts,
                  appLang: appLanguage,
                  cardBgColor: cardBgColor,
                  borderColor: borderDividerColor,
                  isDark: isDark,
                ),

                const Gap(14),

                // 5. Unlockable Milestones & Achievements Carousel
                _buildMilestonesSection(
                  state: state,
                  totalMinutes: totalMinutes,
                  cardBgColor: cardBgColor,
                  borderDividerColor: borderDividerColor,
                  isDark: isDark,
                ),

                const Gap(14),

                // 6. Recent Reading Sessions
                _buildRecentSessionsCard(
                  state: state,
                  appLang: appLanguage,
                  cardBgColor: cardBgColor,
                  borderColor: borderDividerColor,
                  isDark: isDark,
                ),

                const Gap(20),
              ],
            ),
          ),
        );
      },
    );
  }

  // 1. High-Density Hero Telemetry Strip
  Widget _buildHeroTelemetryStrip({
    required HadithState state,
    required int totalMinutes,
    required Color cardBgColor,
    required Color borderDividerColor,
    required bool isDark,
  }) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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
      child: Row(
        children: [
          // Current Streak
          Expanded(
            child: _buildTelemetryColumn(
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFF97316),
              value: '${state.currentStreak}d',
              label: 'Streak',
              subLabel: 'Best: ${state.longestStreak}d',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),
          Container(width: 1, height: 42, color: borderDividerColor),

          // Longest Streak
          Expanded(
            child: _buildTelemetryColumn(
              icon: Icons.emoji_events_rounded,
              iconColor: const Color(0xFFEAB308),
              value: '${state.longestStreak}d',
              label: 'Record',
              subLabel: 'All-Time',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),
          Container(width: 1, height: 42, color: borderDividerColor),

          // Active Reading Days
          Expanded(
            child: _buildTelemetryColumn(
              icon: Icons.calendar_today_rounded,
              iconColor: AppTheme.primaryMint,
              value: '${state.activityDays.length}d',
              label: 'Active',
              subLabel: 'Reading Days',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),
          Container(width: 1, height: 42, color: borderDividerColor),

          // Total Reading Time
          Expanded(
            child: _buildTelemetryColumn(
              icon: Icons.timer_rounded,
              iconColor: const Color(0xFF6366F1),
              value: '${totalMinutes}m',
              label: 'Total Time',
              subLabel: '${state.readingSessions.length} sessions',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildTelemetryColumn({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String subLabel,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const Gap(6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const Gap(1),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        Text(
          subLabel,
          style: TextStyle(
            fontSize: 9,
            color: textSecondary.withValues(alpha: 0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 2. Daily Goal Mastery Card
  Widget _buildDailyGoalMasteryCard({
    required HadithState state,
    required int todayCount,
    required Color cardBgColor,
    required Color borderDividerColor,
    required bool isDark,
  }) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final isGoalMet = todayCount >= state.dailyGoal;
    final progress = (todayCount / state.dailyGoal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGoalMet
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : borderDividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGoalMet ? const Color(0xFF10B981) : Colors.black)
                .withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Arc
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isGoalMet ? const Color(0xFF10B981) : AppTheme.primaryMint,
                  ),
                ),
                Icon(
                  isGoalMet
                      ? Icons.check_circle_rounded
                      : Icons.track_changes_rounded,
                  color: isGoalMet
                      ? const Color(0xFF10B981)
                      : AppTheme.primaryMint,
                  size: 22,
                ),
              ],
            ),
          ),
          const Gap(16),
          // Goal text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Today\'s Goal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const Gap(6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isGoalMet
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : AppTheme.primaryMint.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isGoalMet ? 'Achieved 🎉' : 'In Progress',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isGoalMet
                              ? const Color(0xFF10B981)
                              : AppTheme.primaryMint,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(3),
                Text(
                  '$todayCount of ${state.dailyGoal} Hadiths completed (${(progress * 100).round()}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Tuning Action Button
          InkWell(
            onTap: () => _showDailyGoalBottomSheet(context, state.dailyGoal),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderDividerColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: textSecondary,
                    size: 14,
                  ),
                  const Gap(4),
                  Text(
                    'Tune',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 50.ms);
  }

  // 3. Weekly Reading Time Bar Chart
  Widget _buildBarChartCard({
    required HadithState state,
    required String appLang,
    required Color cardBgColor,
    required Color borderColor,
    required bool isDark,
  }) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final now = DateTime.now();

    // Calculate weekly total
    final List<DateTime> last7Days = List.generate(7, (i) {
      return now.subtract(Duration(days: (_selectedWeekOffset * 7) + 6 - i));
    });

    double weekTotalMins = 0;
    for (final s in state.readingSessions) {
      final dt = DateTime.fromMillisecondsSinceEpoch(s.timestamp);
      final key = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      for (final d in last7Days) {
        final dKey = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
        if (key == dKey) {
          weekTotalMins += s.durationSeconds / 60.0;
        }
      }
    }
    final avgDailyMins = (weekTotalMins / 7).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bar_chart_rounded,
                        color: AppTheme.primaryMint,
                        size: 18,
                      ),
                      const Gap(6),
                      Text(
                        'Weekly Reading Activity',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(2),
                  Text(
                    _getWeekRangeString(now, _selectedWeekOffset),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    onPressed: () {
                      setState(() {
                        _selectedWeekOffset++;
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: _selectedWeekOffset == 0 ? textSecondary.withValues(alpha: 0.3) : null,
                    ),
                    onPressed: _selectedWeekOffset == 0
                        ? null
                        : () {
                            setState(() {
                              _selectedWeekOffset--;
                            });
                          },
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const Gap(10),
          // Telemetry Summary Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: AppTheme.primaryMint,
                  size: 14,
                ),
                const Gap(4),
                Text(
                  '${weekTotalMins.round()}m this week • Avg $avgDailyMins m/day',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Gap(20),
          _ReadingTimeBarChart(
            sessions: state.readingSessions,
            weekOffset: _selectedWeekOffset,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms);
  }

  // 4. Monthly Heat-Map Activity Calendar & Inline History
  Widget _buildCalendarCard({
    required HadithState state,
    required Map<String, int> dailyReadCounts,
    required String appLang,
    required Color cardBgColor,
    required Color borderColor,
    required bool isDark,
  }) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    final int year = _selectedMonth.year;
    final int month = _selectedMonth.month;
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final int firstWeekday = DateTime(year, month, 1).weekday;
    final int startOffset = firstWeekday % 7;

    final today = DateTime.now();
    final disableNext = _selectedMonth.year >= today.year && _selectedMonth.month >= today.month;

    final selectedDateStr = "${_selectedCalendarDay.year}-${_selectedCalendarDay.month.toString().padLeft(2, '0')}-${_selectedCalendarDay.day.toString().padLeft(2, '0')}";
    final dayHistory = state.readHistory.where((r) {
      final dt = DateTime.fromMillisecondsSinceEpoch(r.timestamp);
      final dateStr = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      return dateStr == selectedDateStr;
    }).toList();

    final formattedSelectedDate = "${_months[_selectedCalendarDay.month - 1]} ${_selectedCalendarDay.day}, ${_selectedCalendarDay.year}";

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Navigation & Month Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppTheme.primaryMint,
                    size: 18,
                  ),
                  const Gap(6),
                  Text(
                    'Habit Calendar',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    onPressed: _onPrevMonth,
                    visualDensity: VisualDensity.compact,
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 80),
                    alignment: Alignment.center,
                    child: Text(
                      '${_months[month - 1].substring(0, 3)} $year',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right_rounded, 
                      size: 22,
                      color: disableNext ? textSecondary.withValues(alpha: 0.3) : null,
                    ),
                    onPressed: disableNext ? null : _onNextMonth,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const Gap(10),
          
          // Weekdays header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdays.map((day) => Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: textSecondary.withValues(alpha: 0.8),
                ),
              ),
            )).toList(),
          ),
          const Gap(8),

          // Monthly Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startOffset) {
                return const SizedBox.shrink();
              }
              final int day = index - startOffset + 1;
              final dateStr = "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
              
              final readCount = dailyReadCounts[dateStr] ?? 0;
              final isActive = readCount > 0;
              final isGoalMet = readCount >= state.dailyGoal;
              final isToday = today.year == year && today.month == month && today.day == day;
              final isSelected = _selectedCalendarDay.year == year &&
                  _selectedCalendarDay.month == month &&
                  _selectedCalendarDay.day == day;

              Color cellBg = Colors.transparent;
              if (isGoalMet) {
                cellBg = const Color(0xFF10B981).withValues(alpha: 0.22);
              } else if (isActive) {
                cellBg = AppTheme.primaryMint.withValues(alpha: 0.12);
              }

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCalendarDay = DateTime(year, month, day);
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6366F1).withValues(alpha: 0.18)
                        : cellBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : (isToday
                              ? AppTheme.primaryMint
                              : (isGoalMet
                                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                  : Colors.transparent)),
                      width: isSelected ? 2.0 : 1.2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday || isSelected || isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : (isGoalMet
                                  ? const Color(0xFF10B981)
                                  : (isActive
                                      ? AppTheme.primaryMint
                                      : textPrimary)),
                        ),
                      ),
                      if (isGoalMet)
                        const Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 9,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Gap(14),
          Divider(color: borderColor, height: 1),
          const Gap(12),

          // Inline Selected Day Inspector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedSelectedDate,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${dayHistory.length} Read',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryMint,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),

          if (dayHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No Hadiths read on this date.',
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dayHistory.length,
              itemBuilder: (context, index) {
                final record = dayHistory[index];
                final dt = DateTime.fromMillisecondsSinceEpoch(record.timestamp);
                final timeStr = _formatTimeOnly(dt);

                return Container(
                  margin: const EdgeInsets.only(bottom: 6.0),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.push('/book/${record.bookKey}/hadith/${record.hadithNumber}');
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMint.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: AppTheme.primaryMint,
                            size: 14,
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${record.bookName} • Hadith #${record.hadithNumber}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              if (record.sectionTitle.isNotEmpty)
                                Text(
                                  record.sectionTitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 150.ms);
  }

  // 5. Unlockable Milestones & Achievements Carousel
  Widget _buildMilestonesSection({
    required HadithState state,
    required int totalMinutes,
    required Color cardBgColor,
    required Color borderDividerColor,
    required bool isDark,
  }) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final totalRead = state.readHistory.length;
    final longestStreak = state.longestStreak;

    final milestones = [
      {
        'title': 'First Step',
        'desc': 'Read your 1st Hadith',
        'icon': Icons.spa_rounded,
        'unlocked': totalRead >= 1,
        'progress': (totalRead / 1).clamp(0.0, 1.0),
        'color': const Color(0xFF10B981),
      },
      {
        'title': '3-Day Habit',
        'desc': 'Reach a 3-day streak',
        'icon': Icons.local_fire_department_rounded,
        'unlocked': longestStreak >= 3,
        'progress': (longestStreak / 3).clamp(0.0, 1.0),
        'color': const Color(0xFFF97316),
      },
      {
        'title': 'Hadith Seeker',
        'desc': 'Read 10+ Hadiths',
        'icon': Icons.bolt_rounded,
        'unlocked': totalRead >= 10,
        'progress': (totalRead / 10).clamp(0.0, 1.0),
        'color': const Color(0xFF6366F1),
      },
      {
        'title': 'Hour of Study',
        'desc': 'Spend 60+ min in study',
        'icon': Icons.hourglass_top_rounded,
        'unlocked': totalMinutes >= 60,
        'progress': (totalMinutes / 60).clamp(0.0, 1.0),
        'color': const Color(0xFFEC4899),
      },
      {
        'title': 'Hadith Scholar',
        'desc': 'Read 50+ Hadiths',
        'icon': Icons.auto_stories_rounded,
        'unlocked': totalRead >= 50,
        'progress': (totalRead / 50).clamp(0.0, 1.0),
        'color': const Color(0xFFEAB308),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.military_tech_rounded,
              color: AppTheme.primaryMint,
              size: 18,
            ),
            const Gap(6),
            Text(
              'Milestones & Achievements',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const Gap(10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: milestones.length,
            separatorBuilder: (context, index) => const Gap(10),
            itemBuilder: (context, index) {
              final m = milestones[index];
              final isUnlocked = m['unlocked'] as bool;
              final color = m['color'] as Color;
              final progress = m['progress'] as double;

              return Container(
                width: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isUnlocked
                        ? color.withValues(alpha: 0.4)
                        : borderDividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: isUnlocked ? 0.15 : 0.07),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            m['icon'] as IconData,
                            size: 16,
                            color: isUnlocked ? color : Colors.grey,
                          ),
                        ),
                        if (isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Unlocked ✓',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? textPrimary : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          m['desc'] as String,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isUnlocked ? AppTheme.textSecondary : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            backgroundColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isUnlocked ? color : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms, delay: 200.ms);
  }

  // 6. Recent Sessions Card
  Widget _buildRecentSessionsCard({
    required HadithState state,
    required String appLang,
    required Color cardBgColor,
    required Color borderColor,
    required bool isDark,
  }) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    final sortedSessions = List.from(state.readingSessions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final displaySessions = sortedSessions.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
              const Icon(
                Icons.history_rounded,
                color: AppTheme.primaryMint,
                size: 18,
              ),
              const Gap(6),
              Text(
                'Recent Reading Sessions',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const Gap(12),
          if (displaySessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  AppLocalization.get('no_sessions_yet', appLang),
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displaySessions.length,
              itemBuilder: (context, index) {
                final session = displaySessions[index];
                final dt = DateTime.fromMillisecondsSinceEpoch(session.timestamp);
                final formattedDate = _formatDateTime(dt);

                final minutes = (session.durationSeconds / 60).floor();
                final seconds = session.durationSeconds % 60;
                final durationStr = minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';

                return Container(
                  margin: const EdgeInsets.only(bottom: 6.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFF6366F1),
                          size: 16,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duration: $durationStr',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMint.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${session.hadithsReadCount} Read',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryMint,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 250.ms);
  }
}

class _ReadingTimeBarChart extends StatelessWidget {
  final List<dynamic> sessions;
  final int weekOffset;

  const _ReadingTimeBarChart({required this.sessions, required this.weekOffset});

  String _getWeekdayAbbreviation(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (i) {
      return now.subtract(Duration(days: (weekOffset * 7) + 6 - i));
    });

    final Map<String, double> minsPerDay = {};
    for (final s in sessions) {
      final dt = DateTime.fromMillisecondsSinceEpoch(s.timestamp);
      final key = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      minsPerDay[key] = (minsPerDay[key] ?? 0) + (s.durationSeconds / 60.0);
    }

    double maxMins = 5.0;
    for (final date in last7Days) {
      final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final mins = minsPerDay[key] ?? 0.0;
      if (mins > maxMins) {
        maxMins = mins;
      }
    }

    const double maxBarHeight = 110.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: last7Days.map((date) {
        final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        final mins = minsPerDay[key] ?? 0.0;
        final weekdayLabel = _getWeekdayAbbreviation(date.weekday);
        final heightFraction = mins / maxMins;
        final barHeight = (heightFraction * maxBarHeight).clamp(6.0, maxBarHeight);
        final isToday = now.year == date.year && now.month == date.month && now.day == date.day;

        final displayMinsText = mins > 0 
            ? (mins >= 1.0 ? '${mins.round()}m' : '${(mins * 60).round()}s')
            : '0m';

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayMinsText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: mins > 0
                      ? AppTheme.primaryMint
                      : textSecondary.withValues(alpha: 0.5),
                ),
              ),
              const Gap(6),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: barHeight),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, animatedHeight, child) {
                  return Container(
                    width: 16,
                    height: animatedHeight,
                    decoration: BoxDecoration(
                      gradient: mins > 0 
                          ? const LinearGradient(
                              colors: [Color(0xFF34D399), Color(0xFF059669)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : LinearGradient(
                              colors: [borderColor, borderColor],
                            ),
                      borderRadius: BorderRadius.circular(6),
                      border: isToday
                          ? Border.all(
                              color: AppTheme.primaryMint,
                              width: 1.5,
                            )
                          : null,
                      boxShadow: mins > 0
                          ? [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  );
                },
              ),
              const Gap(8),
              Text(
                weekdayLabel,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                  color: isToday ? AppTheme.primaryMint : textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

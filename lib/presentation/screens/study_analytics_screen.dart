import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // Allow navigation only up to current month
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textPrimary;
    final borderDividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final cardBgColor = isDark ? AppTheme.darkSurfaceCard.withValues(alpha: 0.3) : const Color(0xFFF3F4F6);
    
    final appLanguage = context.watch<SettingsCubit>().state.appLanguage;

    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        // Calculate metrics
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

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Text(
              AppLocalization.get('study_analytics', appLanguage),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                // 1. Summary Metric Grid (2x2 Cards)
                _buildSummaryGrid(state, totalMinutes, appLanguage, cardBgColor, borderDividerColor),

                const Gap(20),

                // 2. Weekly Reading Time Bar Chart Card
                _buildBarChartCard(state, appLanguage, cardBgColor, borderDividerColor, isDark),

                const Gap(20),

                // 3. Monthly Calendar Card
                _buildCalendarCard(state, dailyReadCounts, appLanguage, cardBgColor, borderDividerColor, isDark),

                const Gap(20),

                // 3.5 Selected Date History Card
                _buildSelectedDateHistoryCard(state, appLanguage, cardBgColor, borderDividerColor, isDark),

                const Gap(20),

                // 4. Recent Sessions Card
                _buildRecentSessionsCard(state, appLanguage, cardBgColor, borderDividerColor, isDark),
                
                const Gap(24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryGrid(
    HadithState state,
    int totalMinutes,
    String appLang,
    Color cardBgColor,
    Color borderColor,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: [
        _buildMetricCard(
          icon: Icons.local_fire_department_rounded,
          iconColor: Colors.orangeAccent,
          value: '${state.currentStreak}d',
          label: AppLocalization.get('current_streak', appLang),
          subLabel: '${AppLocalization.get('best_streak', appLang)}: ${state.longestStreak}d',
          bgColor: cardBgColor,
          borderColor: borderColor,
        ),
        _buildMetricCard(
          icon: Icons.emoji_events_rounded,
          iconColor: Colors.amber,
          value: '${state.longestStreak}d',
          label: AppLocalization.get('best_streak', appLang),
          subLabel: 'Personal Record',
          bgColor: cardBgColor,
          borderColor: borderColor,
        ),
        _buildMetricCard(
          icon: Icons.calendar_month_rounded,
          iconColor: AppTheme.primaryMint,
          value: '${state.activityDays.length}d',
          label: AppLocalization.get('total_active_days', appLang),
          subLabel: 'Reading Days',
          bgColor: cardBgColor,
          borderColor: borderColor,
        ),
        _buildMetricCard(
          icon: Icons.timer_rounded,
          iconColor: AppTheme.secondaryIndigo,
          value: '${totalMinutes}m',
          label: AppLocalization.get('reading_time', appLang),
          subLabel: '${state.readingSessions.length} ${AppLocalization.get('total_sessions', appLang).toLowerCase()}',
          bgColor: cardBgColor,
          borderColor: borderColor,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String subLabel,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
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
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const Gap(4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subLabel,
                  style: TextStyle(
                    fontSize: 9,
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(
    HadithState state,
    Map<String, int> dailyReadCounts,
    String appLang,
    Color cardBgColor,
    Color borderColor,
    bool isDark,
  ) {
    final textPrimary = isDark ? Colors.white : AppTheme.textDark;
    final textSecondary = isDark ? AppTheme.textSecondary : const Color(0xFF6B7280);

    final int year = _selectedMonth.year;
    final int month = _selectedMonth.month;

    // Days in current month
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    // Weekday of the 1st of the month (1 = Mon, 7 = Sun)
    final int firstWeekday = DateTime(year, month, 1).weekday;
    // 0-indexed offset (0 for Sunday, 6 for Saturday)
    final int startOffset = firstWeekday % 7;

    final today = DateTime.now();
    final now = DateTime.now();
    final disableNext = _selectedMonth.year >= now.year && _selectedMonth.month >= now.month;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Navigation and Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalization.get('calendar_view', appLang),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 24),
                    onPressed: _onPrevMonth,
                    visualDensity: VisualDensity.compact,
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 90),
                    alignment: Alignment.center,
                    child: Text(
                      '${_months[month - 1]} $year',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right_rounded, 
                      size: 24,
                      color: disableNext ? textSecondary.withValues(alpha: 0.3) : null,
                    ),
                    onPressed: disableNext ? null : _onNextMonth,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const Gap(12),
          
          // Weekdays header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdays.map((day) => Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
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
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startOffset) {
                return const SizedBox.shrink();
              }
              final int day = index - startOffset + 1;
              final dateStr = "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
              
              final isActive = state.activityDays.contains(dateStr);
              final readCount = dailyReadCounts[dateStr] ?? 0;
              final isGoalMet = readCount >= state.dailyGoal;
              final isToday = today.year == year && today.month == month && today.day == day;
              final isSelected = _selectedCalendarDay.year == year &&
                  _selectedCalendarDay.month == month &&
                  _selectedCalendarDay.day == day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCalendarDay = DateTime(year, month, day);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.secondaryIndigo.withValues(alpha: 0.15)
                        : (isActive
                            ? AppTheme.primaryMint.withValues(alpha: 0.15)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.secondaryIndigo
                          : (isToday
                              ? AppTheme.secondaryIndigo.withValues(alpha: 0.5)
                              : (isActive
                                  ? AppTheme.primaryMint.withValues(alpha: 0.3)
                                  : Colors.transparent)),
                      width: isSelected ? 2.5 : (isToday ? 1.5 : 1.0),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday || isSelected || isActive ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppTheme.secondaryIndigo
                              : (isActive
                                  ? AppTheme.primaryMint
                                  : (isDark ? Colors.white70 : Colors.black87)),
                        ),
                      ),
                      if (isGoalMet)
                        const Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 10,
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
    );
  }

  Widget _buildSelectedDateHistoryCard(
    HadithState state,
    String appLang,
    Color cardBgColor,
    Color borderColor,
    bool isDark,
  ) {
    final textPrimary = isDark ? Colors.white : AppTheme.textDark;
    final textSecondary = isDark ? AppTheme.textSecondary : const Color(0xFF6B7280);

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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "History: $formattedSelectedDate",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${dayHistory.length} Read",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryMint,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          if (dayHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      color: textSecondary.withValues(alpha: 0.4),
                      size: 36,
                    ),
                    const Gap(8),
                    Text(
                      "No Hadiths read on this day.",
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],
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
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface.withValues(alpha: 0.5) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onTap: () {
                      context.push('/book/${record.bookKey}/hadith/${record.hadithNumber}');
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppTheme.primaryMint,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      "${record.bookName}, Hadith #${record.hadithNumber}",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      record.sectionTitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: textSecondary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard(
    HadithState state,
    String appLang,
    Color cardBgColor,
    Color borderColor,
    bool isDark,
  ) {
    final textPrimary = isDark ? Colors.white : AppTheme.textDark;
    final textSecondary = isDark ? AppTheme.textSecondary : const Color(0xFF6B7280);
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalization.get('reading_time_graph', appLang),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      _getWeekRangeString(now, _selectedWeekOffset),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 24),
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
                      size: 24,
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
          const Gap(24),
          _ReadingTimeBarChart(
            sessions: state.readingSessions,
            weekOffset: _selectedWeekOffset,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessionsCard(
    HadithState state,
    String appLang,
    Color cardBgColor,
    Color borderColor,
    bool isDark,
  ) {
    final textPrimary = isDark ? Colors.white : AppTheme.textDark;
    final textSecondary = isDark ? AppTheme.textSecondary : const Color(0xFF6B7280);

    // Get reverse chronological list of sessions, capped at 15
    final sortedSessions = List.from(state.readingSessions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final displaySessions = sortedSessions.take(15).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalization.get('recent_sessions', appLang),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const Gap(12),
          if (displaySessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  AppLocalization.get('no_sessions_yet', appLang),
                  style: TextStyle(fontSize: 13, color: textSecondary),
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
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface.withValues(alpha: 0.5) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryIndigo.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_circle_fill_rounded,
                          color: AppTheme.secondaryIndigo,
                          size: 20,
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalization.get('session_duration', appLang, args: {'duration': durationStr}),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryMint.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppLocalization.get('hadiths_read_count', appLang, args: {'count': '${session.hadithsReadCount}'}),
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
    );
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
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);

    // Generate selected week's days
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

    const double maxBarHeight = 120.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: last7Days.map((date) {
        final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        final mins = minsPerDay[key] ?? 0.0;
        final weekdayLabel = _getWeekdayAbbreviation(date.weekday);
        final heightFraction = mins / maxMins;
        final barHeight = (heightFraction * maxBarHeight).clamp(6.0, maxBarHeight);

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
                  color: mins > 0 ? AppTheme.primaryMint : textSecondary.withValues(alpha: 0.5),
                ),
              ),
              const Gap(6),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: barHeight),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, animatedHeight, child) {
                  return Container(
                    width: 14,
                    height: animatedHeight,
                    decoration: BoxDecoration(
                      gradient: mins > 0 
                          ? const LinearGradient(
                              colors: [AppTheme.primaryMint, Color(0xFF059669)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : LinearGradient(
                              colors: [borderColor, borderColor],
                            ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                },
              ),
              const Gap(8),
              Text(
                weekdayLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

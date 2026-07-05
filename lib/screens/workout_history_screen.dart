import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/workout_history_repository.dart';
import '../models/workout_session_record.dart';
import '../utils/duration_calculator.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({
    super.key,
    required this.historyRepository,
  });

  final WorkoutHistoryRepository historyRepository;

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  WorkoutHistoryRepository get _repo => widget.historyRepository;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedDay = now.day;
  }

  List<int> get _availableYears {
    final years = _repo.allRecords
        .map((record) => record.endedAt.toLocal().year)
        .toSet()
        .toList()
      ..sort();
    if (years.isEmpty) {
      return [DateTime.now().year];
    }
    final current = DateTime.now().year;
    if (!years.contains(current)) {
      years.add(current);
      years.sort();
    }
    return years;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = DateFormat.yMMMM(locale).format(
      DateTime(_selectedYear, _selectedMonth),
    );
    final monthSessions = _repo.sessionCountForMonth(_selectedYear, _selectedMonth);
    final monthDuration = _repo.totalDurationSecForMonth(
      _selectedYear,
      _selectedMonth,
    );
    final dailyStats = _repo.dailyStatsForMonth(_selectedYear, _selectedMonth);
    final activeDays = _repo.daysWithWorkoutsInMonth(_selectedYear, _selectedMonth);
    final daySessions = _repo.recordsForDay(
      DateTime(_selectedYear, _selectedMonth, _selectedDay),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutHistoryTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: ValueKey<int>(_selectedYear),
                  initialValue: _selectedYear,
                  decoration: InputDecoration(
                    labelText: l10n.workoutHistoryYearLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final year in _availableYears)
                      DropdownMenuItem(value: year, child: Text('$year')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedYear = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: ValueKey<int>(_selectedMonth),
                  initialValue: _selectedMonth,
                  decoration: InputDecoration(
                    labelText: l10n.workoutHistoryMonthLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (var month = 1; month <= 12; month++)
                      DropdownMenuItem(
                        value: month,
                        child: Text(DateFormat.MMM(locale).format(
                          DateTime(_selectedYear, month),
                        )),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedMonth = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            monthLabel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: l10n.workoutHistoryMonthWorkouts(monthSessions),
                  icon: Icons.fitness_center_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: l10n.workoutHistoryMonthDuration(
                    formatDurationShort(monthDuration, l10n),
                  ),
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (dailyStats.isNotEmpty) ...[
            Text(
              l10n.workoutHistoryChartTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: _MonthBarChart(stats: dailyStats, l10n: l10n),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            l10n.workoutHistoryCalendarTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _MonthCalendar(
            year: _selectedYear,
            month: _selectedMonth,
            selectedDay: _selectedDay,
            activeDays: activeDays,
            locale: locale,
            onDaySelected: (day) => setState(() => _selectedDay = day),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.workoutHistoryDayTitle(
              DateFormat.MMMd(locale).format(
                DateTime(_selectedYear, _selectedMonth, _selectedDay),
              ),
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (daySessions.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.workoutHistoryEmptyDay,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            )
          else
            ...daySessions.map(
              (session) => _SessionTile(session: session, l10n: l10n),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthBarChart extends StatelessWidget {
  const _MonthBarChart({required this.stats, required this.l10n});

  final List<WorkoutDailyStats> stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final axisLabelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final maxMinutes = stats
        .map((stat) => stat.totalDurationSec / 60)
        .fold<double>(0, (max, value) => value > max ? value : max);
    final maxY = maxMinutes <= 0 ? 10.0 : (maxMinutes * 1.2).ceilToDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBorderRadius: BorderRadius.circular(8),
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final durationSec = (rod.toY * 60).round();
                  return BarTooltipItem(
                    formatDurationShort(durationSec, l10n),
                    TextStyle(
                      color: theme.colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      inherit: false,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: maxY / 4,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: axisLabelStyle,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final day = value.toInt();
                    if (day <= 0 || day > 31) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$day',
                        style: axisLabelStyle,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (final stat in stats)
                BarChartGroupData(
                  x: stat.day,
                  barRods: [
                    BarChartRodData(
                      toY: stat.totalDurationSec / 60,
                      color: color,
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.activeDays,
    required this.locale,
    required this.onDaySelected,
  });

  final int year;
  final int month;
  final int selectedDay;
  final Set<int> activeDays;
  final String locale;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final weekdayLabels = MaterialLocalizations.of(context).narrowWeekdays;
    final leadingEmpty = firstDay.weekday % 7;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        weekdayLabels[i],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: leadingEmpty + daysInMonth,
              itemBuilder: (context, index) {
                if (index < leadingEmpty) {
                  return const SizedBox.shrink();
                }
                final day = index - leadingEmpty + 1;
                final isSelected = day == selectedDay;
                final hasWorkout = activeDays.contains(day);
                final theme = Theme.of(context);

                return Material(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onDaySelected(day),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                        if (hasWorkout)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
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
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.l10n});

  final WorkoutSessionRecord session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final timeLabel = DateFormat.Hm(locale).format(session.endedAt.toLocal());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: Text(session.routineTitle),
        subtitle: Text(
          l10n.workoutHistorySessionSubtitle(
            timeLabel,
            formatDurationShort(session.durationSec, l10n),
            session.exerciseCount,
          ),
        ),
        trailing: session.healthSynced
            ? Icon(
                Icons.favorite,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
      ),
    );
  }
}

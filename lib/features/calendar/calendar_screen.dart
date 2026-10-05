import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/disclaimer_badge.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/language_provider.dart';
import '../app_providers.dart';
import '../cycle/log_period_modal.dart';
import '../cycle/log_symptoms_modal.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDay = DateHelpers.toDateOnly(DateTime.now());

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cycleCalc = ref.watch(cycleCalculationProvider);
    final periodEntries = ref.watch(periodEntriesProvider);
    final symptomEntries = ref.watch(symptomEntriesProvider);
    final s = ref.watch(appStringsProvider);

    // Days in current month
    final firstDayWeekday = _currentMonth.weekday; // 1 = Mon, 7 = Sun
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    return Scaffold(
      backgroundColor: ClayColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      s.calendarTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: ClayColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DisclaimerBadge(text: s.calendarDisclaimer),
                ],
              ),
              const SizedBox(height: 16),

              // Calendar Card Container
              ClayCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    // Month Switcher Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: ClayColors.primary),
                          onPressed: _prevMonth,
                        ),
                        Text(
                          DateHelpers.formatMonthYear(_currentMonth),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: ClayColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: ClayColors.primary),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Weekdays Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: s.weekdayHeaders
                          .map((d) => SizedBox(
                                width: 34,
                                child: Text(
                                  d,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: ClayColors.textTertiary,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 10),

                    // Grid of Days
                    _buildDaysGrid(
                      firstDayWeekday: firstDayWeekday,
                      daysInMonth: daysInMonth,
                      periodEntries: periodEntries,
                      cycleCalc: cycleCalc,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Calendar Color Legend (Mandatory from spec)
              _buildLegend(s),

              const SizedBox(height: 18),

              // Selected Day Inspector & Quick Log
              _buildSelectedDayCard(periodEntries, symptomEntries),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysGrid({
    required int firstDayWeekday,
    required int daysInMonth,
    required List<dynamic> periodEntries,
    required dynamic cycleCalc,
  }) {
    final List<Widget> dayWidgets = [];

    // Blank cells before the 1st of the month (Monday = 1)
    for (int i = 1; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 36, height: 36));
    }

    // Days 1..daysInMonth
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected = DateHelpers.daysBetween(date, _selectedDay) == 0;
      final isToday = DateHelpers.daysBetween(date, DateTime.now()) == 0;

      // Check if logged confirmed period
      final hasConfirmedPeriod = periodEntries.any(
        (p) => DateHelpers.daysBetween(p.date, date) == 0,
      );

      // Check if within predicted next period window (5 days from nextEstimatedPeriod)
      final daysFromPredictedPeriod =
          DateHelpers.daysBetween(cycleCalc.nextEstimatedPeriod, date);
      final isPredictedPeriod =
          daysFromPredictedPeriod >= 0 && daysFromPredictedPeriod < 5;

      // Check if fertile window
      final isFertileWindow = date.isAfter(
              cycleCalc.fertileWindowStart.subtract(const Duration(days: 1))) &&
          date.isBefore(cycleCalc.fertileWindowEnd.add(const Duration(days: 1)));

      final isOvulationDay =
          DateHelpers.daysBetween(date, cycleCalc.estimatedOvulationDate) == 0;

      // Styling calculation
      Color? bg;
      Color textColor = ClayColors.textPrimary;
      Border? border;

      List<BoxShadow>? shadows;

      if (hasConfirmedPeriod) {
        bg = ClayColors.secondary;
        textColor = Colors.white;
        shadows = [
          BoxShadow(
            color: ClayColors.secondary.withValues(alpha: 0.4),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Colors.white70,
            blurRadius: 3,
            offset: Offset(-1, -1),
          ),
        ];
      } else if (isPredictedPeriod) {
        bg = ClayColors.secondaryContainer;
        textColor = ClayColors.secondary;
        border = Border.all(color: ClayColors.secondary, width: 1.2);
        shadows = [
          BoxShadow(
            color: ClayColors.secondary.withValues(alpha: 0.15),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ];
      } else if (isOvulationDay) {
        bg = const Color(0xFFF59E0B);
        textColor = Colors.white;
        shadows = [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 3,
            offset: Offset(-1, -1),
          ),
        ];
      } else if (isFertileWindow) {
        bg = ClayColors.sunnyContainer;
        textColor = const Color(0xFFB45309);
      } else if (isToday) {
        border = Border.all(color: ClayColors.primary, width: 2);
        shadows = [
          BoxShadow(
            color: ClayColors.primary.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
      }

      if (isSelected && shadows == null) {
        shadows = [
          BoxShadow(
            color: ClayColors.primary.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ];
      }

      dayWidgets.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDay = date),
          child: Container(
            margin: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: bg ?? (isSelected ? ClayColors.surfaceTint : Colors.transparent),
              shape: BoxShape.circle,
              boxShadow: shadows,
              border: border ??
                  (isSelected
                      ? Border.all(color: ClayColors.primary, width: 2)
                      : null),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: (hasConfirmedPeriod || isOvulationDay || isToday || isSelected)
                      ? FontWeight.w900
                      : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  Widget _buildLegend(AppStrings s) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legend',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: ClayColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(ClayColors.secondary, s.legendConfirmedPeriod),
              _buildLegendItem(
                ClayColors.secondaryContainer,
                s.legendPredictedPeriod,
                isOutline: true,
                borderColor: ClayColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(ClayColors.sunnyContainer, s.legendFertileWindow),
              _buildLegendItem(const Color(0xFFF59E0B), s.legendOvulationDay),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label,
      {bool isOutline = false, Color? borderColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isOutline
                ? Border.all(color: borderColor ?? color, width: 1.5)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSelectedDayCard(
      List<dynamic> periodEntries, List<dynamic> symptomEntries) {
    final periodsOnDay = periodEntries.where(
      (p) => DateHelpers.daysBetween(p.date, _selectedDay) == 0,
    );
    final symptomsOnDay = symptomEntries.where(
      (s) => DateHelpers.daysBetween(s.date, _selectedDay) == 0,
    );

    return ClayCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateHelpers.formatFriendly(_selectedDay),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ClayColors.textPrimary,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: ClayColors.textSecondary),
                onSelected: (val) {
                  if (val == 'period') {
                    LogPeriodModal.show(context, initialDate: _selectedDay);
                  } else if (val == 'symptom') {
                    LogSymptomsModal.show(context, initialDate: _selectedDay);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'period',
                    child: Text('Log Period Day'),
                  ),
                  const PopupMenuItem(
                    value: 'symptom',
                    child: Text('Log Symptoms / Mood'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (periodsOnDay.isEmpty && symptomsOnDay.isEmpty) ...[
            const Text(
              'No logs for this date. Tap actions to record flow or symptoms.',
              style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.water_drop, size: 16),
                    label: const Text('Add Period'),
                    onPressed: () =>
                        LogPeriodModal.show(context, initialDate: _selectedDay),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.healing, size: 16),
                    label: const Text('Add Symptoms'),
                    onPressed: () =>
                        LogSymptomsModal.show(context, initialDate: _selectedDay),
                  ),
                ),
              ],
            ),
          ] else ...[
            if (periodsOnDay.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.water_drop, size: 16, color: ClayColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    'Period Flow: ${periodsOnDay.first.flow.displayName}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ClayColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (symptomsOnDay.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...symptomsOnDay.first.moods.map((m) => Chip(
                        label: Text('Mood: $m', style: const TextStyle(fontSize: 11)),
                        backgroundColor: ClayColors.surfaceTint,
                      )),
                  ...symptomsOnDay.first.symptoms.map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 11)),
                        backgroundColor: ClayColors.secondaryContainer,
                      )),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

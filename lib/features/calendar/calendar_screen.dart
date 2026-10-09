import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/disclaimer_badge.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/language_provider.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/fertility_observation.dart';
import '../app_providers.dart';
import '../cycle/log_period_modal.dart';
import '../cycle/log_symptoms_modal.dart';
import '../appointments/appointment_modal.dart';
import '../pregnancy/kick_counter_modal.dart';
import '../fertility/intimacy_log_modal.dart';
import '../../core/widgets/living_3d_character.dart';

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
    final profile = ref.watch(userProfileProvider);
    final isPregnancyMode = profile.goal == AppGoal.alreadyPregnant;
    final cycleCalc = ref.watch(cycleCalculationProvider);
    final pregCalc = ref.watch(pregnancyCalculationProvider);
    final periodEntries = ref.watch(periodEntriesProvider);
    final symptomEntries = ref.watch(symptomEntriesProvider);
    final appointments = ref.watch(appointmentsProvider);
    final fertilityObservations = ref.watch(fertilityObservationsProvider);
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
                      isPregnancyMode ? 'Hamal (Pregnancy) Calendar' : s.calendarTitle,
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
                  DisclaimerBadge(text: isPregnancyMode ? 'Clinical Schedule' : s.calendarDisclaimer),
                ],
              ),
              const SizedBox(height: 12),

              // 3D Motion Companion Character
              Center(
                child: Living3DCharacter(
                  persona: isPregnancyMode
                      ? CharacterPersona.homePregnancy
                      : CharacterPersona.calendar,
                  pregnancyWeek: isPregnancyMode ? (pregCalc?.completedWeeks ?? 12) : null,
                  cyclePhase: isPregnancyMode ? null : cycleCalc.currentPhase,
                  cycleDay: isPregnancyMode ? null : cycleCalc.currentCycleDay,
                  todayMood: symptomEntries.isNotEmpty && symptomEntries.first.moods.isNotEmpty
                      ? symptomEntries.first.moods.first
                      : null,
                  todaySymptom: symptomEntries.isNotEmpty && symptomEntries.first.symptoms.isNotEmpty
                      ? symptomEntries.first.symptoms.first
                      : null,
                  size: 105,
                  showSpeechBubble: true,
                ),
              ),
              const SizedBox(height: 12),

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
                          icon: Icon(
                            Icons.chevron_left,
                            color: isPregnancyMode ? const Color(0xFFC2185B) : ClayColors.primary,
                          ),
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
                          icon: Icon(
                            Icons.chevron_right,
                            color: isPregnancyMode ? const Color(0xFFC2185B) : ClayColors.primary,
                          ),
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
                      isPregnancyMode: isPregnancyMode,
                      pregCalc: pregCalc,
                      appointments: appointments,
                      fertilityObservations: fertilityObservations,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Calendar Color Legend (Pakistani Roman Urdu)
              _buildLegend(s, isPregnancyMode),

              const SizedBox(height: 18),

              // Selected Day Inspector & Quick Log
              _buildSelectedDayCard(
                periodEntries: periodEntries,
                symptomEntries: symptomEntries,
                isPregnancyMode: isPregnancyMode,
                pregCalc: pregCalc,
                appointments: appointments,
                fertilityObservations: fertilityObservations,
                profile: profile,
                cycleCalc: cycleCalc,
              ),

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
    required bool isPregnancyMode,
    required dynamic pregCalc,
    required List<dynamic> appointments,
    required List<FertilityObservation> fertilityObservations,
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

      // In pregnancy mode: NO period and NO ovulation occurs (amenorrhea of pregnancy)
      final hasConfirmedPeriod = !isPregnancyMode &&
          periodEntries.any((p) => DateHelpers.daysBetween(p.date, date) == 0);

      final daysFromPredictedPeriod = !isPregnancyMode
          ? DateHelpers.daysBetween(cycleCalc.nextEstimatedPeriod, date)
          : -999;
      final isPredictedPeriod =
          !isPregnancyMode && daysFromPredictedPeriod >= 0 && daysFromPredictedPeriod < 5;

      final isFertileWindow = !isPregnancyMode &&
          date.isAfter(cycleCalc.fertileWindowStart.subtract(const Duration(days: 1))) &&
          date.isBefore(cycleCalc.fertileWindowEnd.add(const Duration(days: 1)));

      final isOvulationDay = !isPregnancyMode &&
          DateHelpers.daysBetween(date, cycleCalc.estimatedOvulationDate) == 0;

      final isSafeDay = !isPregnancyMode &&
          !hasConfirmedPeriod &&
          !isPredictedPeriod &&
          !isFertileWindow;

      // Intimacy logged on this date
      final hasIntimacy = fertilityObservations.any(
        (f) => DateHelpers.daysBetween(f.date, date) == 0 && f.hadIntimacy,
      );

      // Pregnancy Mode Highlights
      final hasAppointment = isPregnancyMode &&
          appointments.any((a) => DateHelpers.daysBetween(a.dateTime, date) == 0);

      final isDueDate = isPregnancyMode &&
          pregCalc != null &&
          DateHelpers.daysBetween(pregCalc.estimatedDueDate, date) == 0;

      // Styling calculation
      Color? bg;
      Color textColor = ClayColors.textPrimary;
      Border? border;
      List<BoxShadow>? shadows;
      Widget? miniIndicator;

      if (isPregnancyMode) {
        if (isDueDate) {
          bg = const Color(0xFFFFE4EC);
          textColor = const Color(0xFFC2185B);
          border = Border.all(color: const Color(0xFFE91E63), width: 2);
          miniIndicator = const Text('👶', style: TextStyle(fontSize: 8));
          shadows = [
            BoxShadow(
              color: const Color(0xFFE91E63).withValues(alpha: 0.35),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ];
        } else if (hasAppointment) {
          bg = const Color(0xFFE0F2F1);
          textColor = const Color(0xFF00695C);
          border = Border.all(color: const Color(0xFF00897B), width: 1.6);
          miniIndicator = const Text('🩺', style: TextStyle(fontSize: 8));
          shadows = [
            BoxShadow(
              color: const Color(0xFF00897B).withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ];
        } else if (hasIntimacy) {
          bg = const Color(0xFFFFF0F5);
          textColor = const Color(0xFFC2185B);
          miniIndicator = const Text('💕', style: TextStyle(fontSize: 8));
        } else if (isToday) {
          border = Border.all(color: const Color(0xFFC2185B), width: 2);
          shadows = [
            BoxShadow(
              color: const Color(0xFFC2185B).withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ];
        }
      } else {
        if (hasConfirmedPeriod) {
          bg = ClayColors.secondary;
          textColor = Colors.white;
          miniIndicator = const Text('🩸', style: TextStyle(fontSize: 8));
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
          miniIndicator = const Text('🩸', style: TextStyle(fontSize: 7));
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
          miniIndicator = const Text('⭐', style: TextStyle(fontSize: 8));
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
          miniIndicator = Text(hasIntimacy ? '💕' : '💖', style: const TextStyle(fontSize: 8));
        } else if (hasIntimacy) {
          bg = const Color(0xFFFFF0F5);
          textColor = const Color(0xFFAD1457);
          miniIndicator = const Text('💕', style: TextStyle(fontSize: 8));
        } else if (isSafeDay) {
          bg = const Color(0xFFF1F8F5);
          miniIndicator = const Text('🌿', style: TextStyle(fontSize: 7));
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
      }

      if (isSelected && shadows == null) {
        shadows = [
          BoxShadow(
            color: (isPregnancyMode ? const Color(0xFFC2185B) : ClayColors.primary).withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ];
      }

      dayWidgets.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDay = date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: bg ?? (isSelected ? (isPregnancyMode ? const Color(0xFFFCE4EC) : ClayColors.surfaceTint) : Colors.transparent),
              shape: BoxShape.circle,
              boxShadow: shadows,
              border: border ??
                  (isSelected
                      ? Border.all(color: isPregnancyMode ? const Color(0xFFC2185B) : ClayColors.primary, width: 2)
                      : null),
            ),
            child: Center(
              child: miniIndicator != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        miniIndicator,
                      ],
                    )
                  : Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: (hasConfirmedPeriod || isOvulationDay || isToday || isSelected || isDueDate || hasAppointment)
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

  Widget _buildLegend(AppStrings s, bool isPregnancyMode) {
    if (isPregnancyMode) {
      return ClayCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🩺', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  'Hamal (Pregnancy) Calendar Guide',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ClayColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem(const Color(0xFF00897B), '🩺 Doctor Checkup / Ultrasound'),
                _buildLegendItem(const Color(0xFFE91E63), '👶 Delivery Tareekh (EDD)'),
                _buildLegendItem(const Color(0xFFC2185B), '💕 Mehfooz Mubashrat (Intimacy)'),
                _buildLegendItem(ClayColors.secondary, '🌸 Alamaat / Symptoms'),
                _buildLegendItem(const Color(0xFFC2185B), '⭕ Aaj Ka Din', isOutline: true, borderColor: const Color(0xFFC2185B)),
              ],
            ),
          ],
        ),
      );
    }

    return ClayCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📅', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                'Calendar Guide & Hamal / Sex Ke Din',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: ClayColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendItem(ClayColors.secondary, '🩸 Mahwari Ka Din (Period)'),
              _buildLegendItem(ClayColors.secondaryContainer, '🩸 Mutawaqqa Mahwari (Expected)', isOutline: true, borderColor: ClayColors.secondary),
              _buildLegendItem(const Color(0xFFF59E0B), '⭐ Baiza Kharij (Peak Ovulation)'),
              _buildLegendItem(ClayColors.sunnyContainer, '💖 Hamal / Sex Ka Best Waqt (Fertile Window)'),
              _buildLegendItem(const Color(0xFFFFF0F5), '💕 Mubashrat Record (Sex Logged)'),
              _buildLegendItem(const Color(0xFFF1F8F5), '🌿 Mehfooz Din (Safe Days - Kam Imkaan)'),
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

  Widget _buildSelectedDayCard({
    required List<dynamic> periodEntries,
    required List<dynamic> symptomEntries,
    required bool isPregnancyMode,
    required dynamic pregCalc,
    required List<dynamic> appointments,
    required List<FertilityObservation> fertilityObservations,
    required UserProfile profile,
    required dynamic cycleCalc,
  }) {
    final periodsOnDay = !isPregnancyMode
        ? periodEntries.where((p) => DateHelpers.daysBetween(p.date, _selectedDay) == 0).toList()
        : [];
    final symptomsOnDay = symptomEntries
        .where((s) => DateHelpers.daysBetween(s.date, _selectedDay) == 0)
        .toList();
    final aptsOnDay = isPregnancyMode
        ? appointments
            .where((a) => DateHelpers.daysBetween(a.dateTime, _selectedDay) == 0)
            .toList()
        : [];
    final intimacyOnDay = fertilityObservations
        .where((f) => DateHelpers.daysBetween(f.date, _selectedDay) == 0 && f.hadIntimacy)
        .firstOrNull;

    // Calculate approximate gestational week for selected day
    int? gestWeek;
    if (isPregnancyMode && pregCalc != null) {
      final diffDays = DateHelpers.daysBetween(DateTime.now(), _selectedDay);
      final totalDays = (pregCalc.completedWeeks * 7) + pregCalc.remainingDays + diffDays;
      if (totalDays >= 0 && totalDays <= 300) {
        gestWeek = (totalDays / 7).floor();
      }
    }

    return ClayCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateHelpers.formatFriendly(_selectedDay),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  if (gestWeek != null) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Hamal Hafta $gestWeek · Trimester ${gestWeek <= 12 ? 1 : (gestWeek <= 27 ? 2 : 3)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC2185B),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: ClayColors.textSecondary),
                onSelected: (val) {
                  if (val == 'period') {
                    LogPeriodModal.show(context, initialDate: _selectedDay);
                  } else if (val == 'symptom') {
                    LogSymptomsModal.show(context, initialDate: _selectedDay);
                  } else if (val == 'intimacy') {
                    IntimacyLogModal.show(context, initialDate: _selectedDay);
                  } else if (val == 'appointment') {
                    AppointmentModal.show(context);
                  } else if (val == 'kick') {
                    KickCounterModal.show(context);
                  }
                },
                itemBuilder: (ctx) => [
                  if (!isPregnancyMode)
                    const PopupMenuItem(
                      value: 'period',
                      child: Text('🩸 Log Period Day'),
                    ),
                  const PopupMenuItem(
                    value: 'intimacy',
                    child: Text('💕 Log Intimacy / Mubashrat'),
                  ),
                  if (isPregnancyMode) ...[
                    const PopupMenuItem(
                      value: 'appointment',
                      child: Text('🩺 Doctor Appointment / Scan'),
                    ),
                    const PopupMenuItem(
                      value: 'kick',
                      child: Text('👣 Baby Kicks Count'),
                    ),
                  ],
                  const PopupMenuItem(
                    value: 'symptom',
                    child: Text('🌸 Log Symptoms & Mood'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Intimacy / Sex Record on selected day with Clinical Calculation
          if (intimacyOnDay != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFB6C1), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💕', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mubashrat: ${_getIntimacyLabel(intimacyOnDay.intimacyType)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF880E4F),
                          ),
                        ),
                      ),
                      if (intimacyOnDay.intimacyTiming != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _getTimingLabel(intimacyOnDay.intimacyTiming!),
                            style: const TextStyle(fontSize: 10, color: Color(0xFF880E4F), fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getIntimacyAnalysisText(
                      intimacy: intimacyOnDay,
                      selectedDate: _selectedDay,
                      isPregnancyMode: isPregnancyMode,
                      cycleCalc: cycleCalc,
                      profile: profile,
                    ),
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF4A148C), height: 1.3),
                  ),
                ],
              ),
            ),
          ],

          // Pregnancy Appointments on selected day
          if (isPregnancyMode && aptsOnDay.isNotEmpty) ...[
            ...aptsOnDay.map((apt) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF80CBC4)),
                  ),
                  child: Row(
                    children: [
                      const Text('🩺', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apt.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF004D40),
                              ),
                            ),
                            if (apt.clinicianName != null && apt.clinicianName!.isNotEmpty)
                              Text(
                                'Doctor: ${apt.clinicianName}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF00695C)),
                              ),
                            if (apt.location != null && apt.location!.isNotEmpty)
                              Text(
                                'Clinic: ${apt.location}',
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF00796B)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          if (isPregnancyMode) ...[
            if (aptsOnDay.isEmpty && symptomsOnDay.isEmpty && intimacyOnDay == null) ...[
              const Text(
                'Is tareekh ka koi record nahi hai. Doctor checkup, symptoms ya intimacy record karein.',
                style: TextStyle(fontSize: 12.5, color: ClayColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFE91E63)),
                    label: const Text('💕 Mubashrat', style: TextStyle(fontSize: 12, color: Color(0xFFE91E63))),
                    onPressed: () => IntimacyLogModal.show(context, initialDate: _selectedDay),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.medical_services_rounded, size: 16, color: Color(0xFF00796B)),
                    label: const Text('Doctor Visit', style: TextStyle(fontSize: 12, color: Color(0xFF00796B))),
                    onPressed: () => AppointmentModal.show(context),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.healing, size: 16, color: Color(0xFFC2185B)),
                    label: const Text('Symptoms', style: TextStyle(fontSize: 12, color: Color(0xFFC2185B))),
                    onPressed: () => LogSymptomsModal.show(context, initialDate: _selectedDay),
                  ),
                ],
              ),
            ] else ...[
              if (symptomsOnDay.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...symptomsOnDay.first.moods.map((m) => Chip(
                          label: Text('Mood: $m', style: const TextStyle(fontSize: 11)),
                          backgroundColor: const Color(0xFFFCE4EC),
                        )),
                    ...symptomsOnDay.first.symptoms.map((s) => Chip(
                          label: Text(s, style: const TextStyle(fontSize: 11)),
                          backgroundColor: const Color(0xFFEDE7F6),
                        )),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 10),
            // Clinical reassurance banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: const Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Medical Fact: Hamal ke dauran mahwari (period) bilkul nahi aati. Koi bhi bleeding ho to foran doctor ko dikhayein.',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFFE65100), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            if (periodsOnDay.isEmpty && symptomsOnDay.isEmpty && intimacyOnDay == null) ...[
              const Text(
                'Is tareekh ka koi log nahi hai. Mahwari, mubashrat ya symptoms record karein.',
                style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.water_drop, size: 16),
                    label: const Text('Add Period'),
                    onPressed: () => LogPeriodModal.show(context, initialDate: _selectedDay),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFE91E63)),
                    label: const Text('💕 Mubashrat', style: TextStyle(color: Color(0xFFE91E63))),
                    onPressed: () => IntimacyLogModal.show(context, initialDate: _selectedDay),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.healing, size: 16),
                    label: const Text('Add Symptoms'),
                    onPressed: () => LogSymptomsModal.show(context, initialDate: _selectedDay),
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
        ],
      ),
    );
  }

  String _getIntimacyLabel(IntimacyType type) {
    switch (type) {
      case IntimacyType.unprotectedInside:
        return 'Sperm / Mani Andar Gayi (Unprotected)';
      case IntimacyType.protected:
        return 'Mehfooz / Condom (Protected)';
      case IntimacyType.withdrawal:
        return 'Azal / Bahir Nikala (Withdrawal)';
      case IntimacyType.none:
        return 'Mubashrat';
    }
  }

  String _getTimingLabel(IntimacyTiming timing) {
    switch (timing) {
      case IntimacyTiming.morning:
        return '🌅 Subah';
      case IntimacyTiming.afternoon:
        return '☀️ Dopehar';
      case IntimacyTiming.night:
        return '🌙 Raat';
    }
  }

  String _getIntimacyAnalysisText({
    required FertilityObservation intimacy,
    required DateTime selectedDate,
    required bool isPregnancyMode,
    required dynamic cycleCalc,
    required UserProfile profile,
  }) {
    if (isPregnancyMode) {
      return '🤰 Hamal ke dauran mubashrat aam tor par mehfooz hoti hai. Agar kisi qism ka dard, cramping ya spotting ho to aaraam karein aur doctor se raabta karein.';
    }

    final isFertile = selectedDate.isAfter(cycleCalc.fertileWindowStart.subtract(const Duration(days: 1))) &&
        selectedDate.isBefore(cycleCalc.fertileWindowEnd.add(const Duration(days: 1)));

    if (isFertile) {
      if (intimacy.intimacyType == IntimacyType.unprotectedInside) {
        if (profile.goal == AppGoal.tryToConceive) {
          return '🎯 Zabardast Timing! Yeh baiza kharij hone (ovulation window) ka waqt tha aur sperm andar gaya hai. Hamal theherne ke 85% behtareen chances hain. Agli mahwari miss hone par subah pehlay peshab se pregnancy test karein.';
        } else {
          return '⚠️ INTEHAI AHEM ALERT! Yeh din fertile window me tha aur sperm andar gaya hai. Hamal theherne ka bohat ziyada khatra hai! Agar aap hamal nahi chahteen to foran 72 ghanton ke andar Emergency Contraceptive Pill (ECP / Postinor-2 / Famila) ka istemaal karein.';
        }
      } else if (intimacy.intimacyType == IntimacyType.protected) {
        return '🛡️ Condom istemaal hua hai, isliye hamal ka khatra intehai kam hai (98% mehfooz).';
      } else if (intimacy.intimacyType == IntimacyType.withdrawal) {
        return '⚠️ Azal (Withdrawal) kiya gaya hai. Pre-ejaculatory fluid (mazi) me bhi sperm ho sakte hain, isliye fertile dino me 20% tak pregnancy ka khatra rehta hai.';
      }
    } else {
      if (intimacy.intimacyType == IntimacyType.unprotectedInside) {
        return '🌿 Mehfooz Din (Safe Day). Yeh baiza kharij hone ka waqt nahi tha, isliye hamal theherne ke imkanaat bohat hi kam hain.';
      } else {
        return '🌿 Mehfooz din aur protection ke sath mubashrat hui hai. Hamal ka koi imkaan nahi.';
      }
    }
    return 'Mubashrat ka record mehfooz kar liya gaya hai.';
  }
}

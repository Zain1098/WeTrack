import '../models/cycle_record.dart';
import '../models/period_entry.dart';
import '../../core/constants/medical_constants.dart';
import '../../core/utils/date_helpers.dart';

enum CyclePhase {
  menstrual,
  follicular,
  fertileWindow,
  ovulationDay,
  luteal;

  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.fertileWindow:
        return 'Estimated Fertile Window';
      case CyclePhase.ovulationDay:
        return 'Estimated Ovulation Day';
      case CyclePhase.luteal:
        return 'Luteal Phase';
    }
  }

  String get summary {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Rest and gentle nourishment. Energy tends to be lower.';
      case CyclePhase.follicular:
        return 'Estrogen levels rise. Rising energy and mental clarity.';
      case CyclePhase.fertileWindow:
        return 'Peak conception probability. High fecundability window.';
      case CyclePhase.ovulationDay:
        return 'Peak LH surge and egg release window. Estimated.';
      case CyclePhase.luteal:
        return 'Progesterone rises. Prepare for rest and listen to your body.';
    }
  }
}

class CycleCalculationResult {
  final int currentCycleDay;
  final int estimatedCycleLength;
  final DateTime nextEstimatedPeriod;
  final int daysUntilNextPeriod;
  final DateTime estimatedOvulationDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final CyclePhase currentPhase;
  final bool isUsingFallbackEstimate;
  final bool isPregnancySuspended;

  const CycleCalculationResult({
    required this.currentCycleDay,
    required this.estimatedCycleLength,
    required this.nextEstimatedPeriod,
    required this.daysUntilNextPeriod,
    required this.estimatedOvulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.currentPhase,
    required this.isUsingFallbackEstimate,
    this.isPregnancySuspended = false,
  });
}

class CycleCalculationService {
  /// Computes average cycle length from recent completed valid cycles (up to last 6)
  static int calculateAverageCycleLength({
    required List<CycleRecord> history,
    int fallback = MedicalConstants.defaultCycleLengthDays,
  }) {
    final validLengths = history
        .where((c) =>
            c.isCompleted &&
            !c.isAnomalous &&
            c.cycleLengthDays != null &&
            c.cycleLengthDays! >= MedicalConstants.minPlausibleCycleLengthDays &&
            c.cycleLengthDays! <= MedicalConstants.maxPlausibleCycleLengthDays)
        .map((c) => c.cycleLengthDays!)
        .take(6)
        .toList();

    if (validLengths.length < 2) {
      return fallback;
    }

    final sum = validLengths.reduce((a, b) => a + b);
    return (sum / validLengths.length).round();
  }

  /// Automatically segments and groups raw [PeriodEntry] logs into structured [CycleRecord]s.
  /// Bleeding days separated by <= 3 non-bleeding days belong to the same period episode.
  /// Each cycle begins at the start of one episode and ends the day prior to the next episode.
  static List<CycleRecord> generateCycleRecordsFromEntries(List<PeriodEntry> entries) {
    if (entries.isEmpty) return [];

    // Sort chronologically ascending
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

    // Group into bleeding episodes
    final List<List<PeriodEntry>> episodes = [];
    List<PeriodEntry> currentEpisode = [];

    for (final entry in sorted) {
      if (currentEpisode.isEmpty) {
        currentEpisode.add(entry);
      } else {
        final daysDiff = DateHelpers.daysBetween(currentEpisode.last.date, entry.date);
        if (daysDiff <= 3) {
          currentEpisode.add(entry);
        } else {
          episodes.add(currentEpisode);
          currentEpisode = [entry];
        }
      }
    }
    if (currentEpisode.isNotEmpty) {
      episodes.add(currentEpisode);
    }

    final List<CycleRecord> records = [];

    for (int i = 0; i < episodes.length; i++) {
      final episode = episodes[i];
      final startDate = DateHelpers.toDateOnly(episode.first.date);
      final lastBleedDate = DateHelpers.toDateOnly(episode.last.date);
      final periodDurationDays = DateHelpers.daysBetween(startDate, lastBleedDate) + 1;

      if (i < episodes.length - 1) {
        final nextEpisodeStart = DateHelpers.toDateOnly(episodes[i + 1].first.date);
        final cycleLengthDays = DateHelpers.daysBetween(startDate, nextEpisodeStart);
        final endDate = DateHelpers.subtractDays(nextEpisodeStart, 1);
        final isAnomalous = cycleLengthDays < MedicalConstants.minPlausibleCycleLengthDays ||
            cycleLengthDays > MedicalConstants.maxPlausibleCycleLengthDays;

        records.add(CycleRecord(
          id: 'cycle_${startDate.millisecondsSinceEpoch}',
          startDate: startDate,
          endDate: endDate,
          cycleLengthDays: cycleLengthDays,
          periodDurationDays: periodDurationDays,
          isAnomalous: isAnomalous,
        ));
      } else {
        // Ongoing/current cycle (not completed yet)
        records.add(CycleRecord(
          id: 'cycle_${startDate.millisecondsSinceEpoch}',
          startDate: startDate,
          endDate: null,
          cycleLengthDays: null,
          periodDurationDays: periodDurationDays,
          isAnomalous: false,
        ));
      }
    }

    // Sort descending by startDate so most recent cycle is first
    records.sort((a, b) => b.startDate.compareTo(a.startDate));
    return records;
  }

  /// Safely merges newly derived [CycleRecord]s with [existingRecords].
  /// Any existing cycle record that cannot be re-derived from [entries]
  /// (such as legacy or imported cycle records with no underlying PeriodEntry logs)
  /// is preserved rather than overwritten.
  static List<CycleRecord> mergeCycleRecords({
    required List<CycleRecord> existingRecords,
    required List<CycleRecord> derivedRecords,
    required List<PeriodEntry> entries,
  }) {
    if (existingRecords.isEmpty) return derivedRecords;
    if (derivedRecords.isEmpty) return existingRecords;

    final List<CycleRecord> merged = [...derivedRecords];

    for (final legacy in existingRecords) {
      // Check if any period entry falls within or near this legacy cycle's start date
      final hasMatchingEntry = entries.any((entry) {
        final days = DateHelpers.daysBetween(legacy.startDate, entry.date).abs();
        return days <= 3;
      });

      // Also check if any derived record already shares this start date
      final hasMatchingDerived = derivedRecords.any((derived) {
        return DateHelpers.daysBetween(legacy.startDate, derived.startDate).abs() <= 3;
      });

      if (!hasMatchingEntry && !hasMatchingDerived) {
        // No underlying period entries cover this record; keep legacy record
        merged.add(legacy);
      }
    }

    // Sort descending by startDate so newest cycle is first
    merged.sort((a, b) => b.startDate.compareTo(a.startDate));
    return merged;
  }

  /// Calculates estimated next period start date
  static DateTime calculateNextPeriod({
    required DateTime lastPeriodStartDate,
    required int cycleLength,
  }) {
    return DateHelpers.addDays(lastPeriodStartDate, cycleLength);
  }

  /// Calculates estimated ovulation day (Cycle length minus luteal phase, typically 14 days)
  static DateTime calculateEstimatedOvulation({
    required DateTime lastPeriodStartDate,
    required int cycleLength,
    int lutealLength = MedicalConstants.defaultLutealPhaseDays,
  }) {
    final ovulationDayOffset = cycleLength - lutealLength;
    return DateHelpers.addDays(lastPeriodStartDate, ovulationDayOffset);
  }

  /// ASRM 6-day fertile window: 5 days prior to estimated ovulation plus ovulation day
  static DateTime calculateFertileWindowStart(DateTime estimatedOvulation) {
    return DateHelpers.subtractDays(
      estimatedOvulation,
      MedicalConstants.fertileWindowLeadingDays,
    );
  }

  /// Evaluates full cycle calculation status for a given reference date
  static CycleCalculationResult calculate({
    required DateTime lastPeriodStartDate,
    required List<CycleRecord> history,
    required int userFallbackCycleLength,
    required int periodDuration,
    DateTime? referenceDate,
  }) {
    final now = DateHelpers.toDateOnly(referenceDate ?? DateTime.now());
    final lmp = DateHelpers.toDateOnly(lastPeriodStartDate);

    final avgLength = calculateAverageCycleLength(
      history: history,
      fallback: userFallbackCycleLength,
    );
    final isFallback = history.where((c) => c.isCompleted).length < 2;

    final nextPeriod = calculateNextPeriod(
      lastPeriodStartDate: lmp,
      cycleLength: avgLength,
    );
    final daysUntilNext = DateHelpers.daysBetween(now, nextPeriod);
    final currentCycleDay = DateHelpers.daysBetween(lmp, now) + 1;

    final ovulationDate = calculateEstimatedOvulation(
      lastPeriodStartDate: lmp,
      cycleLength: avgLength,
    );
    final fertileStart = calculateFertileWindowStart(ovulationDate);
    final fertileEnd = ovulationDate;

    // Determine current phase
    CyclePhase phase;
    if (now.isBefore(lmp.add(Duration(days: periodDuration)))) {
      phase = CyclePhase.menstrual;
    } else if (now.isBefore(fertileStart)) {
      phase = CyclePhase.follicular;
    } else if (DateHelpers.daysBetween(now, ovulationDate) == 0) {
      phase = CyclePhase.ovulationDay;
    } else if (now.isAfter(fertileStart.subtract(const Duration(days: 1))) &&
        now.isBefore(fertileEnd.add(const Duration(days: 1)))) {
      phase = CyclePhase.fertileWindow;
    } else {
      phase = CyclePhase.luteal;
    }

    return CycleCalculationResult(
      currentCycleDay: currentCycleDay > 0 ? currentCycleDay : 1,
      estimatedCycleLength: avgLength,
      nextEstimatedPeriod: nextPeriod,
      daysUntilNextPeriod: daysUntilNext,
      estimatedOvulationDate: ovulationDate,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
      currentPhase: phase,
      isUsingFallbackEstimate: isFallback,
    );
  }
}

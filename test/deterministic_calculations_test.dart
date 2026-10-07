import 'package:flutter_test/flutter_test.dart';
import 'package:wetrack/core/constants/medical_constants.dart';
import 'package:wetrack/data/models/cycle_record.dart';
import 'package:wetrack/data/models/period_entry.dart';
import 'package:wetrack/data/models/pregnancy_record.dart';
import 'package:wetrack/data/services/cycle_calculation_service.dart';
import 'package:wetrack/data/services/pregnancy_calculation_service.dart';

void main() {
  group('CycleCalculationService Tests', () {
    test('Calculates standard 28-day cycle with leap year transition correctly', () {
      // 2024 is a leap year (February has 29 days)
      final lmp = DateTime(2024, 2, 15);
      final next = CycleCalculationService.calculateNextPeriod(
        lastPeriodStartDate: lmp,
        cycleLength: 28,
      );

      // Feb 15 + 28 days in 2024:
      // Feb 15 + 14 days = Feb 29 (14 days consumed)
      // Remaining 14 days in March: March 14, 2024
      expect(next, DateTime(2024, 3, 14));

      // Ovulation: 28 - 14 = Day 14 -> Feb 15 + 14 days = Feb 29, 2024
      final ovulation = CycleCalculationService.calculateEstimatedOvulation(
        lastPeriodStartDate: lmp,
        cycleLength: 28,
      );
      expect(ovulation, DateTime(2024, 2, 29));

      // Fertile window start: 5 days prior to Feb 29 = Feb 24, 2024
      final fertileStart = CycleCalculationService.calculateFertileWindowStart(ovulation);
      expect(fertileStart, DateTime(2024, 2, 24));
    });

    test('Calculates 32-day cycle across year boundary correctly', () {
      final lmp = DateTime(2025, 12, 15);
      final next = CycleCalculationService.calculateNextPeriod(
        lastPeriodStartDate: lmp,
        cycleLength: 32,
      );

      // Dec 15 + 32 days: 16 days in Dec (to Dec 31) + 16 days in Jan = Jan 16, 2026
      expect(next, DateTime(2026, 1, 16));

      // Ovulation: 32 - 14 = Day 18 -> Dec 15 + 18 days = Jan 2, 2026
      final ovulation = CycleCalculationService.calculateEstimatedOvulation(
        lastPeriodStartDate: lmp,
        cycleLength: 32,
      );
      expect(ovulation, DateTime(2026, 1, 2));

      // Fertile window: 5 days prior = Dec 28, 2025
      final fertileStart = CycleCalculationService.calculateFertileWindowStart(ovulation);
      expect(fertileStart, DateTime(2025, 12, 28));
    });

    test('Fallback to user baseline when history is insufficient', () {
      final history = [
        CycleRecord(
          id: '1',
          startDate: DateTime(2026, 1, 1),
          periodDurationDays: 5,
        ),
      ];

      final avg = CycleCalculationService.calculateAverageCycleLength(
        history: history,
        fallback: 30,
      );

      expect(avg, 30);
    });

    test('Calculates dynamic average when valid cycle history is logged', () {
      final history = [
        CycleRecord(
          id: '1',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 29),
          cycleLengthDays: 28,
          periodDurationDays: 5,
        ),
        CycleRecord(
          id: '2',
          startDate: DateTime(2026, 1, 29),
          endDate: DateTime(2026, 3, 2),
          cycleLengthDays: 32,
          periodDurationDays: 5,
        ),
      ];

      final avg = CycleCalculationService.calculateAverageCycleLength(
        history: history,
        fallback: 28,
      );

      // (28 + 32) / 2 = 30
      expect(avg, 30);
    });

    test('Disregards anomalous cycle lengths outside plausible limits', () {
      final history = [
        CycleRecord(
          id: '1',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 31),
          cycleLengthDays: 30,
          periodDurationDays: 5,
        ),
        CycleRecord(
          id: '2',
          startDate: DateTime(2026, 1, 31),
          endDate: DateTime(2026, 2, 10),
          cycleLengthDays: 10, // Non-plausible (< 20)
          periodDurationDays: 5,
        ),
        CycleRecord(
          id: '3',
          startDate: DateTime(2026, 2, 10),
          endDate: DateTime(2026, 3, 12),
          cycleLengthDays: 30,
          periodDurationDays: 5,
        ),
      ];

      final avg = CycleCalculationService.calculateAverageCycleLength(
        history: history,
        fallback: 28,
      );

      // Ignores 10 days, averages (30 + 30) / 2 = 30
      expect(avg, 30);
    });

    test('generateCycleRecordsFromEntries segments episodes and calculates cycle lengths correctly', () {
      final entries = [
        // Episode 1 (Jan 1 - Jan 4)
        PeriodEntry(id: '1', date: DateTime(2026, 1, 1), flow: FlowIntensity.heavy, loggedAt: DateTime.now()),
        PeriodEntry(id: '2', date: DateTime(2026, 1, 2), flow: FlowIntensity.medium, loggedAt: DateTime.now()),
        PeriodEntry(id: '3', date: DateTime(2026, 1, 3), flow: FlowIntensity.light, loggedAt: DateTime.now()),
        PeriodEntry(id: '4', date: DateTime(2026, 1, 4), flow: FlowIntensity.spotting, loggedAt: DateTime.now()),
        // Episode 2 (Jan 29 - Jan 31) -> Cycle 1 length = 28 days
        PeriodEntry(id: '5', date: DateTime(2026, 1, 29), flow: FlowIntensity.heavy, loggedAt: DateTime.now()),
        PeriodEntry(id: '6', date: DateTime(2026, 1, 30), flow: FlowIntensity.medium, loggedAt: DateTime.now()),
        PeriodEntry(id: '7', date: DateTime(2026, 1, 31), flow: FlowIntensity.light, loggedAt: DateTime.now()),
        // Episode 3 (Mar 2) -> Cycle 2 length = 32 days
        PeriodEntry(id: '8', date: DateTime(2026, 3, 2), flow: FlowIntensity.medium, loggedAt: DateTime.now()),
      ];

      final records = CycleCalculationService.generateCycleRecordsFromEntries(entries);
      expect(records.length, 3);

      // Newest first
      final currentCycle = records[0];
      expect(currentCycle.startDate, DateTime(2026, 3, 2));
      expect(currentCycle.isCompleted, false);
      expect(currentCycle.cycleLengthDays, null);

      final cycle2 = records[1];
      expect(cycle2.startDate, DateTime(2026, 1, 29));
      expect(cycle2.endDate, DateTime(2026, 3, 1));
      expect(cycle2.cycleLengthDays, 32);
      expect(cycle2.periodDurationDays, 3);
      expect(cycle2.isCompleted, true);

      final cycle1 = records[2];
      expect(cycle1.startDate, DateTime(2026, 1, 1));
      expect(cycle1.endDate, DateTime(2026, 1, 28));
      expect(cycle1.cycleLengthDays, 28);
      expect(cycle1.periodDurationDays, 4);
      expect(cycle1.isCompleted, true);

      final avg = CycleCalculationService.calculateAverageCycleLength(history: records);
      expect(avg, 30);
    });

    test('mergeCycleRecords preserves legacy CycleRecords when no matching period entries exist', () {
      final legacyRecord = CycleRecord(
        id: 'legacy_cycle_nov_2025',
        startDate: DateTime(2025, 11, 1),
        endDate: DateTime(2025, 11, 28),
        cycleLengthDays: 28,
        periodDurationDays: 5,
        isAnomalous: false,
      );

      final entries = [
        // Only 2026 entries logged; no matching entries for Nov 2025
        PeriodEntry(id: '1', date: DateTime(2026, 1, 1), flow: FlowIntensity.medium, loggedAt: DateTime.now()),
        PeriodEntry(id: '2', date: DateTime(2026, 1, 2), flow: FlowIntensity.medium, loggedAt: DateTime.now()),
        PeriodEntry(id: '3', date: DateTime(2026, 1, 3), flow: FlowIntensity.light, loggedAt: DateTime.now()),
      ];

      final derived = CycleCalculationService.generateCycleRecordsFromEntries(entries);
      expect(derived.length, 1);
      expect(derived.first.startDate, DateTime(2026, 1, 1));

      // Merge existing legacy records with derived records
      final merged = CycleCalculationService.mergeCycleRecords(
        existingRecords: [legacyRecord],
        derivedRecords: derived,
        entries: entries,
      );

      // Both the newly derived cycle and the legacy cycle without entries must exist
      expect(merged.length, 2);
      expect(merged.any((c) => c.id == 'legacy_cycle_nov_2025'), true);
      expect(merged.any((c) => c.startDate == DateTime(2025, 11, 1)), true);
      expect(merged.first.startDate, DateTime(2026, 1, 1)); // Sorted newest first
      expect(merged.last.startDate, DateTime(2025, 11, 1));
    });
  });

  group('PregnancyCalculationService Tests', () {
    test('Calculates standard 280-day gestational age and due date', () {
      final lmp = DateTime(2026, 1, 1);
      final record = PregnancyRecord.fromLmp(lmp);

      // Jan 1 + 280 days
      expect(record.estimatedDueDate, DateTime(2026, 10, 8));

      // Reference date: March 12, 2026 (Day 70 -> 10 weeks 0 days)
      final refDate = DateTime(2026, 3, 12);
      final res = PregnancyCalculationService.calculate(
        record: record,
        referenceDate: refDate,
      );

      expect(res.totalDaysPregnant, 70);
      expect(res.completedWeeks, 10);
      expect(res.remainingDays, 0);
      expect(res.formattedGestationalAge, '10 weeks 0 days');
      expect(res.currentTrimester, 1);
      expect(res.babyFruitComparison, 'Plum');
    });

    test('Trimester transitions at weeks 14 and 28', () {
      final lmp = DateTime(2026, 1, 1);
      final record = PregnancyRecord.fromLmp(lmp);

      // Week 14 -> Second Trimester
      final week14Date = lmp.add(const Duration(days: 14 * 7));
      final res14 = PregnancyCalculationService.calculate(
        record: record,
        referenceDate: week14Date,
      );
      expect(res14.completedWeeks, 14);
      expect(res14.currentTrimester, 2);

      // Week 28 -> Third Trimester
      final week28Date = lmp.add(const Duration(days: 28 * 7));
      final res28 = PregnancyCalculationService.calculate(
        record: record,
        referenceDate: week28Date,
      );
      expect(res28.completedWeeks, 28);
      expect(res28.currentTrimester, 3);
      expect(res28.babyFruitComparison, 'Eggplant');
    });

    test('Handles past due date without negative days countdown', () {
      final lmp = DateTime(2025, 1, 1);
      final record = PregnancyRecord.fromLmp(lmp);
      // Due date was in Oct 2025. Current date is in 2026.
      final refDate = DateTime(2026, 1, 1);

      final res = PregnancyCalculationService.calculate(
        record: record,
        referenceDate: refDate,
      );

      expect(res.daysUntilDueDate < 0, true);
      expect(res.dueDateCountdownText, 'Estimated due date passed');
    });

    test('Clinician ultrasound override takes precedence for gestational dating', () {
      final lmp = DateTime(2026, 1, 1);
      final ultrasoundEdd = DateTime(2026, 10, 1); // 7 days earlier than LMP estimate

      final record = PregnancyRecord(
        id: 'preg_1',
        lmpDate: lmp,
        estimatedDueDate: lmp.add(const Duration(days: MedicalConstants.standardGestationDays)),
        clinicianOverrideDueDate: ultrasoundEdd,
        datingMethod: 'Clinician/Ultrasound',
      );

      expect(record.effectiveDueDate, ultrasoundEdd);

      // On Oct 1, 2026, countdown should say due date is today!
      final res = PregnancyCalculationService.calculate(
        record: record,
        referenceDate: ultrasoundEdd,
      );

      expect(res.daysUntilDueDate, 0);
      expect(res.dueDateCountdownText, 'Estimated due date is today!');
      expect(res.completedWeeks, 40);
    });

    test('Calculates and returns localized Roman Urdu gestational milestones correctly', () {
      final lmp = DateTime(2026, 1, 1);
      final record = PregnancyRecord.fromLmp(lmp);

      // Reference date: March 12, 2026 (Day 70 -> 10 weeks 0 days)
      final refDate = DateTime(2026, 3, 12);
      final res = PregnancyCalculationService.calculate(
        record: record,
        referenceDate: refDate,
      );

      expect(res.formattedGestationalAgeUrdu, '10 hafte 0 din');
      expect(res.babyFruitComparisonUrdu.contains('Aloocha') || res.babyFruitComparisonUrdu.contains('Plum'), true);
      expect(res.dueDateCountdownTextUrdu.contains('din baqi'), true);
      expect(res.weeklyMilestoneSummaryUrdu.isNotEmpty, true);

      // Test milestone for week 28 (Eggplant / Baingan)
      final milestone28 = PregnancyCalculationService.getMilestoneForWeek(28);
      expect(milestone28['fruitUrdu'], 'Baingan (Eggplant) 🍆');
      expect(milestone28['summaryUrdu']!.contains('3rd Trimester shuru'), true);
    });
  });
}

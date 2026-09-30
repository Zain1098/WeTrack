import '../models/pregnancy_record.dart';
import '../../core/constants/medical_constants.dart';
import '../../core/utils/date_helpers.dart';

class PregnancyCalculationResult {
  final int totalDaysPregnant;
  final int completedWeeks;
  final int remainingDays;
  final String formattedGestationalAge; // e.g. "16 weeks 2 days"
  final int currentTrimester; // 1, 2, or 3
  final int daysUntilDueDate;
  final String dueDateCountdownText;
  final double progressFraction; // 0.0 to 1.0
  final String babyFruitComparison;
  final String babyApproximateLength;
  final String babyApproximateWeight;
  final String weeklyMilestoneSummary;

  const PregnancyCalculationResult({
    required this.totalDaysPregnant,
    required this.completedWeeks,
    required this.remainingDays,
    required this.formattedGestationalAge,
    required this.currentTrimester,
    required this.daysUntilDueDate,
    required this.dueDateCountdownText,
    required this.progressFraction,
    required this.babyFruitComparison,
    required this.babyApproximateLength,
    required this.babyApproximateWeight,
    required this.weeklyMilestoneSummary,
  });
}

class PregnancyCalculationService {
  /// Calculates gestational progress and milestones deterministically
  static PregnancyCalculationResult calculate({
    required PregnancyRecord record,
    DateTime? referenceDate,
  }) {
    final now = DateHelpers.toDateOnly(referenceDate ?? DateTime.now());
    final effectiveEdd = record.effectiveDueDate;

    int totalDays;
    if (record.clinicianOverrideDueDate != null) {
      // Derive backward from confirmed due date
      final daysToEdd = DateHelpers.daysBetween(now, effectiveEdd);
      totalDays = MedicalConstants.standardGestationDays - daysToEdd;
    } else {
      totalDays = DateHelpers.daysBetween(record.lmpDate, now);
    }

    if (totalDays < 0) totalDays = 0;

    final completedWeeks = totalDays ~/ 7;
    final remainingDays = totalDays % 7;
    final formattedAge = '$completedWeeks weeks $remainingDays days';

    // Trimester
    int trimester;
    if (completedWeeks <= MedicalConstants.trimester1EndWeek) {
      trimester = 1;
    } else if (completedWeeks <= MedicalConstants.trimester2EndWeek) {
      trimester = 2;
    } else {
      trimester = 3;
    }

    // Days to EDD
    final daysToEdd = DateHelpers.daysBetween(now, effectiveEdd);
    final String countdownText;
    if (daysToEdd > 0) {
      countdownText = '$daysToEdd days remaining';
    } else if (daysToEdd == 0) {
      countdownText = 'Estimated due date is today!';
    } else {
      countdownText = 'Estimated due date passed';
    }

    final progress = (totalDays / MedicalConstants.standardGestationDays).clamp(0.0, 1.0);

    final milestoneInfo = _getMilestoneForWeek(completedWeeks);

    return PregnancyCalculationResult(
      totalDaysPregnant: totalDays,
      completedWeeks: completedWeeks,
      remainingDays: remainingDays,
      formattedGestationalAge: formattedAge,
      currentTrimester: trimester,
      daysUntilDueDate: daysToEdd,
      dueDateCountdownText: countdownText,
      progressFraction: progress,
      babyFruitComparison: milestoneInfo['fruit']!,
      babyApproximateLength: milestoneInfo['length']!,
      babyApproximateWeight: milestoneInfo['weight']!,
      weeklyMilestoneSummary: milestoneInfo['summary']!,
    );
  }

  static Map<String, String> _getMilestoneForWeek(int week) {
    if (week < 4) {
      return {
        'fruit': 'Poppy Seed',
        'length': '1 mm',
        'weight': '< 1 g',
        'summary': 'Blastocyst implantation occurring. Cells dividing rapidly into embryo and placenta.',
      };
    } else if (week <= 8) {
      return {
        'fruit': 'Raspberry',
        'length': '1.6 cm',
        'weight': '1 g',
        'summary': 'Tiny facial features, neural tube formed, and tiny limb buds developing.',
      };
    } else if (week <= 12) {
      return {
        'fruit': 'Plum',
        'length': '5.4 cm',
        'weight': '14 g',
        'summary': 'Fingers and toes clearly separated. Reflexes and vocal cords forming.',
      };
    } else if (week <= 16) {
      return {
        'fruit': 'Avocado',
        'length': '11.6 cm',
        'weight': '100 g',
        'summary': 'Baby can make facial expressions and hear muffled sounds. Heart pumps 25 quarts a day.',
      };
    } else if (week <= 20) {
      return {
        'fruit': 'Banana',
        'length': '25 cm',
        'weight': '300 g',
        'summary': 'Halfway mark! Vernix protects skin, and mother may feel first butterfly flutters (quickening).',
      };
    } else if (week <= 24) {
      return {
        'fruit': 'Cantaloupe',
        'length': '30 cm',
        'weight': '600 g',
        'summary': 'Lungs forming air sacs. Baby responds to familiar voices and music.',
      };
    } else if (week <= 28) {
      return {
        'fruit': 'Eggplant',
        'length': '37 cm',
        'weight': '1 kg',
        'summary': 'Third trimester begins! Baby opens eyes and practices regular sleep-wake cycles.',
      };
    } else if (week <= 32) {
      return {
        'fruit': 'Pineapple',
        'length': '42 cm',
        'weight': '1.7 kg',
        'summary': 'Bones hardening, rapid brain growth, and regular kicking or stretching movements.',
      };
    } else if (week <= 36) {
      return {
        'fruit': 'Honeydew Melon',
        'length': '47 cm',
        'weight': '2.6 kg',
        'summary': 'Rapidly gaining protective fat layers. Head may start settling lower into pelvis.',
      };
    } else {
      return {
        'fruit': 'Watermelon',
        'length': '50 cm',
        'weight': '3.4 kg',
        'summary': 'Full term! Fully developed lungs and ready to meet you any day now.',
      };
    }
  }
}

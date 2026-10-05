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
  final DateTime estimatedDueDate;
  final String dueDateCountdownText;
  final double progressFraction; // 0.0 to 1.0
  final String babyFruitComparison;
  final String babyApproximateLength;
  final String babyApproximateWeight;
  final String weeklyMilestoneSummary;
  final String weeklyMilestoneSummaryUrdu;
  final String babyStageAsset;

  int get trimester => currentTrimester;

  const PregnancyCalculationResult({
    required this.totalDaysPregnant,
    required this.completedWeeks,
    required this.remainingDays,
    required this.formattedGestationalAge,
    required this.currentTrimester,
    required this.daysUntilDueDate,
    required this.estimatedDueDate,
    required this.dueDateCountdownText,
    required this.progressFraction,
    required this.babyFruitComparison,
    required this.babyApproximateLength,
    required this.babyApproximateWeight,
    required this.weeklyMilestoneSummary,
    this.weeklyMilestoneSummaryUrdu = '',
    this.babyStageAsset = 'UI/baby_stage_early.jpg',
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
    final formattedAge = '$completedWeeks hafte $remainingDays din';

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
      countdownText = '$daysToEdd din baqi hain delivery tak';
    } else if (daysToEdd == 0) {
      countdownText = 'Mubarak ho! Delivery ka din aaj hi hai! 🌸';
    } else {
      countdownText = 'Estimated due date guzar chuki hai (Doctor se milein)';
    }

    final progress = (totalDays / MedicalConstants.standardGestationDays).clamp(0.0, 1.0);

    final milestoneInfo = getMilestoneForWeek(completedWeeks);

    return PregnancyCalculationResult(
      totalDaysPregnant: totalDays,
      completedWeeks: completedWeeks,
      remainingDays: remainingDays,
      formattedGestationalAge: formattedAge,
      currentTrimester: trimester,
      daysUntilDueDate: daysToEdd,
      estimatedDueDate: effectiveEdd,
      dueDateCountdownText: countdownText,
      progressFraction: progress,
      babyFruitComparison: milestoneInfo['fruit']!,
      babyApproximateLength: milestoneInfo['length']!,
      babyApproximateWeight: milestoneInfo['weight']!,
      weeklyMilestoneSummary: milestoneInfo['summary']!,
      weeklyMilestoneSummaryUrdu: milestoneInfo['summaryUrdu']!,
      babyStageAsset: milestoneInfo['asset']!,
    );
  }

  static Map<String, String> getMilestoneForWeek(int week) {
    if (week < 4) {
      return {
        'fruit': 'Khashkhash ka Daana (Poppy Seed)',
        'length': '1 mm',
        'weight': '< 1 g',
        'summary': 'Blastocyst implantation occurring. Cells dividing rapidly into embryo and placenta.',
        'summaryUrdu': 'Blastocyst ki uterine wall mein implantation ho rahi hai. Cells tezi se divide ho kar nanha embryo aur placenta bana rahe hain.',
        'asset': 'UI/baby_stage_early.jpg',
      };
    } else if (week <= 8) {
      return {
        'fruit': 'Raspberry 🍓',
        'length': '1.6 cm',
        'weight': '1 g',
        'summary': 'Tiny facial features, neural tube formed, and tiny limb buds developing.',
        'summaryUrdu': 'Dil ki pehli dharakan shuru ho chuki hai! Nanha sa chehra, neural tube aur nanhe haath-paon ki kaliyan ban rahi hain.',
        'asset': 'UI/baby_stage_early.jpg',
      };
    } else if (week <= 12) {
      return {
        'fruit': 'Aalubukhara (Plum) 🍑',
        'length': '5.4 cm',
        'weight': '14 g',
        'summary': 'Fingers and toes clearly separated. Reflexes and vocal cords forming.',
        'summaryUrdu': 'Ungliyan aur angoothe alag ho chuke hain. Baby mutthi band kar sakta hai aur vocal cords tashkeel pa rahe hain.',
        'asset': 'UI/baby_stage_early.jpg',
      };
    } else if (week <= 16) {
      return {
        'fruit': 'Avocado 🥑',
        'length': '11.6 cm',
        'weight': '100 g',
        'summary': 'Baby can make facial expressions and hear muffled sounds. Heart pumps 25 quarts a day.',
        'summaryUrdu': 'Baby mummy ki aawaz aur dil ki dharakan sun sakta hai. Chehre par expressions bante hain aur mutthi band karta hai.',
        'asset': 'UI/baby_stage_mid.jpg',
      };
    } else if (week <= 20) {
      return {
        'fruit': 'Kela (Banana) 🍌',
        'length': '25 cm',
        'weight': '300 g',
        'summary': 'Halfway mark! Vernix protects skin, and mother may feel first butterfly flutters (quickening).',
        'summaryUrdu': 'Adha safar mukammal! Pet mein halki titliyan jaisi pehli harkat (quickening) mehsoos ho sakti hai. Vernix skin ko protect karti hai.',
        'asset': 'UI/baby_stage_mid.jpg',
      };
    } else if (week <= 24) {
      return {
        'fruit': 'Kharbooza (Cantaloupe) 🍈',
        'length': '30 cm',
        'weight': '600 g',
        'summary': 'Lungs forming air sacs. Baby responds to familiar voices and music.',
        'summaryUrdu': 'Fefron (lungs) mein air sacs ban rahe hain. Mummy aur papa ki aawaz par baby react karke halki kicks deta hai.',
        'asset': 'UI/baby_stage_mid.jpg',
      };
    } else if (week <= 28) {
      return {
        'fruit': 'Baingan (Eggplant) 🍆',
        'length': '37 cm',
        'weight': '1 kg',
        'summary': 'Third trimester begins! Baby opens eyes and practices regular sleep-wake cycles.',
        'summaryUrdu': '3rd Trimester shuru! Baby ne pehli baar aankhein kholi hain, roshni mehsoos karta hai aur sonay jagney ka cycle shuru ho gaya hai.',
        'asset': 'UI/baby_stage_late.jpg',
      };
    } else if (week <= 32) {
      return {
        'fruit': 'Anaanas (Pineapple) 🍍',
        'length': '42 cm',
        'weight': '1.7 kg',
        'summary': 'Bones hardening, rapid brain growth, and regular kicking or stretching movements.',
        'summaryUrdu': 'Haddiyan mazboot ho rahi hain aur dimaagh tezi se grow kar raha hai. Rozana regular kicks aur stretching mehsoos hoti hain.',
        'asset': 'UI/baby_stage_late.jpg',
      };
    } else if (week <= 36) {
      return {
        'fruit': 'Papita / Melon 🍈',
        'length': '47 cm',
        'weight': '2.6 kg',
        'summary': 'Rapidly gaining protective fat layers. Head may start settling lower into pelvis.',
        'summaryUrdu': 'Motay pyare gaal aur charbi ki layers ban rahi hain. Paidaish ki tayyari mein baby ka sar pelvis ki taraf settle ho sakta hai.',
        'asset': 'UI/baby_stage_late.jpg',
      };
    } else {
      return {
        'fruit': 'Tarbooz (Watermelon) 🍉',
        'length': '50 cm',
        'weight': '3.4 kg',
        'summary': 'Full term! Fully developed lungs and ready to meet you any day now.',
        'summaryUrdu': 'MashaAllah baby mukammal tayyar hai! Fefray mature hain aur baby kisi bhi waqt mummy ki godh mein aane ke liye tayyar hai.',
        'asset': 'UI/baby_stage_term.jpg',
      };
    }
  }
}

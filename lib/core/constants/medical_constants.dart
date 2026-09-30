/// Centralized Medical & Clinical Constants
/// All calculations, disclaimers, and clinical reference rules originate here.
/// Sources: American Society for Reproductive Medicine (ASRM)
class MedicalConstants {
  // Cycle defaults & limits
  static const int defaultCycleLengthDays = 28;
  static const int minPlausibleCycleLengthDays = 20;
  static const int maxPlausibleCycleLengthDays = 45;
  static const int defaultPeriodDurationDays = 5;
  static const int defaultLutealPhaseDays = 14;

  // Fertile Window: ASRM defines as the 6-day interval ending on day of ovulation
  static const int fertileWindowLeadingDays = 5; // 5 days before ovulation
  static const int fertileWindowTotalDays = 6; // 5 days + ovulation day

  // ASRM Infertility evaluation thresholds
  static const int infertilityMonthsUnder35 = 12;
  static const int infertilityMonths35AndOver = 6;
  static const int femaleAgeThresholdForInfertility = 35;

  // Nutritional Guidance
  static const String folicAcidDailyDose = '400 mcg';
  static const String folicAcidRationale =
      'ASRM recommends daily 400 mcg folic acid supplementation before and during early pregnancy to reduce neural tube defect risks.';

  // Gestational Constants
  static const int standardGestationDays = 280; // 40 weeks from LMP (Naegele model)
  static const int weeksInPregnancy = 40;

  // Trimester boundaries (in completed weeks)
  static const int trimester1EndWeek = 13;
  static const int trimester2EndWeek = 27;

  // Disclaimers
  static const String standardDisclaimer =
      'WeTrack provides educational cycle tracking and estimates, not medical diagnoses, treatment plans, or contraception guarantees. Always consult a qualified physician for healthcare needs.';

  static const String estimateQualifier =
      'Estimated based on statistical models. Ovulation and cycle timing naturally vary.';

  static const String pregnancyDatingDisclaimer =
      'Estimated due date is calculated using a 40-week gestational model and may be adjusted by your clinician following an ultrasound.';

  // Red Flag Symptoms (Urgent Medical Attention Required)
  static const List<String> pregnancyRedFlagSymptoms = [
    'Heavy vaginal bleeding (soaking a pad in an hour)',
    'Severe lower abdominal or pelvic cramping',
    'Sudden severe headache with blurred vision or spots',
    'Sudden severe swelling of face, hands, or ankles',
    'High fever (> 38°C / 100.4°F) with chills',
    'Fluid leaking from vagina prior to 37 weeks',
    'Significant decrease or absence of fetal movement after 28 weeks',
    'Persistent severe vomiting unable to keep liquids down for 24h',
  ];

  static const List<String> cycleRedFlagSymptoms = [
    'Sudden agonizing pelvic pain',
    'Continuous bleeding lasting longer than 10 days',
    'Fainting, severe dizziness, or pale skin with heavy flow',
  ];
}

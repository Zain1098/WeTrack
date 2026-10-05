enum AppLanguage {
  romanUrdu,
  english;

  String get displayName {
    switch (this) {
      case AppLanguage.romanUrdu:
        return 'Roman Urdu / English';
      case AppLanguage.english:
        return 'English';
    }
  }

  String get shortCode => this == AppLanguage.romanUrdu ? 'RU' : 'EN';
}

abstract class AppStrings {
  // Bottom Nav
  String get navHome;
  String get navCalendar;
  String get navInsights;
  String get navLearn;
  String get navSettings;

  // Quick Action Menu
  String get quickActionsTitle;
  String get logPeriodTitle;
  String get logPeriodSubtitle;
  String get logSymptomsTitle;
  String get logSymptomsSubtitle;
  String get logOvulationTitle;
  String get logOvulationSubtitle;
  String get positiveTestTitle;
  String get positiveTestSubtitle;
  String get askAiTitle;
  String get askAiSubtitle;

  // Home Screen
  String get assalamGreeting;
  String get journeyCycle;
  String get journeyPregnancy;
  String get quickOverviewTitle;
  String get moodHappy;
  String get actionIntimacy;
  String get moodRest;
  String get moodFine;
  String get moodCramps;
  String get logBleedingTile;
  String get logMoodTile;
  String get logPainTile;
  String get autoGuidanceTitle;
  String get emergencyGuideButton;
  String get husbandGuideButton;
  String get languageSwitchLabel;

  // Calendar Screen
  String get calendarTitle;
  String get calendarDisclaimer;
  String get selectDayPrompt;
  String get legendPeriod;
  String get legendFertile;
  String get legendOvulation;
  String get legendExpected;

  // Insights Screen
  String get insightsTitle;
  String get insightsSubtitle;
  String get averageCycleLength;
  String get averagePeriodLength;
  String get totalCyclesLogged;
  String get cycleConsistency;

  // Settings
  String get settingsTitle;
  String get preferencesHeader;
  String get languageSetting;
  String get pinLockSetting;
  String get partnerSharingSetting;
  String get backupSyncSetting;
  String get exportDataTitle;
  String get deleteDataTitle;
  String get logOutTitle;

  // General & Top Bar
  String get dictionaryButton;
  String get aiButton;
  List<String> get weekdayHeaders;

  // Trackers
  String get folicAcidTrackerTitle;
  String get folicAcidTrackerDesc;
  String get kickCounterCardTitle;
  String get kickCounterCardDesc;
  String get waterTrackerCardTitle;
  String get waterTrackerCardDesc;

  // Learn Screen
  String get learnTitle;
  String get learnSubtitle;
  String get categoryAll;
  String get categoryMyths;
  String get categoryFertility;
  String get categoryCycle;
  String get categoryPregnancy;
  String get categorySafety;

  // Calendar Legends
  String get legendConfirmedPeriod;
  String get legendPredictedPeriod;
  String get legendFertileWindow;
  String get legendOvulationDay;
}

class RomanUrduStrings implements AppStrings {
  const RomanUrduStrings();

  @override
  String get navHome => 'Ghar';
  @override
  String get navCalendar => 'Calendar';
  @override
  String get navInsights => 'Hisaab';
  @override
  String get navLearn => 'Rahnumai';
  @override
  String get navSettings => 'Settings';

  @override
  String get quickActionsTitle => 'Jaldi Actions';
  @override
  String get logPeriodTitle => 'Mahwari (Period) Log';
  @override
  String get logPeriodSubtitle => 'Flow, shuru ki tareekh aur din record karein';
  @override
  String get logSymptomsTitle => 'Alamat & Mood Log';
  @override
  String get logSymptomsSubtitle => 'Dard, cramps, thakawat aur tabiyat ka haal';
  @override
  String get logOvulationTitle => 'Ovulation Strip (LH) Test';
  @override
  String get logOvulationSubtitle => 'Egg release, reham ki rutubat aur milap log';
  @override
  String get positiveTestTitle => 'Pregnancy Positive Test ✨';
  @override
  String get positiveTestSubtitle => 'Hamal (Pregnancy) Dashboard shuru karein';
  @override
  String get askAiTitle => 'AI Health Companion';
  @override
  String get askAiSubtitle => 'Cycle, pregnancy aur science par foran jawab';

  @override
  String get assalamGreeting => 'Assalam-o-Alaikum';
  @override
  String get journeyCycle => 'Mahwari (Cycle)';
  @override
  String get journeyPregnancy => 'Hamal (Pregnancy)';
  @override
  String get quickOverviewTitle => 'Quick Overview • Aaj Ka Halat';
  @override
  String get moodHappy => 'Khush';
  @override
  String get actionIntimacy => 'Milap/Sex';
  @override
  String get moodRest => 'Aaram';
  @override
  String get moodFine => 'Sab Theek';
  @override
  String get moodCramps => 'Dard/Cramp';
  @override
  String get logBleedingTile => 'Bleeding Log';
  @override
  String get logMoodTile => 'Mood Log';
  @override
  String get logPainTile => 'Dard Log';
  @override
  String get autoGuidanceTitle => 'WETRACK AUTO GUIDANCE';
  @override
  String get emergencyGuideButton => 'Emergency Guide';
  @override
  String get husbandGuideButton => 'Husband Care Guide';
  @override
  String get languageSwitchLabel => 'Zubaan (Language)';

  @override
  String get calendarTitle => 'Mahwari Calendar';
  @override
  String get calendarDisclaimer => 'Takhmeena';
  @override
  String get selectDayPrompt => 'Tareekh par tap karke haalat dekhein ya log karein';
  @override
  String get legendPeriod => 'Mahwari (Period)';
  @override
  String get legendFertile => 'High Fertile Din';
  @override
  String get legendOvulation => 'Ovulation Day ⚡';
  @override
  String get legendExpected => 'Expected Period';

  @override
  String get insightsTitle => 'Cycle Ka Hisaab';
  @override
  String get insightsSubtitle => 'Record';
  @override
  String get averageCycleLength => 'Aam Cycle Ka Gap';
  @override
  String get averagePeriodLength => 'Period Kitne Din Chalta Hai';
  @override
  String get totalCyclesLogged => 'Kul Recorded Cycles';
  @override
  String get cycleConsistency => 'Cycle Regularity';

  @override
  String get settingsTitle => 'Settings & Security';
  @override
  String get preferencesHeader => 'Pasandida Settings';
  @override
  String get languageSetting => 'App Ki Zubaan (Language)';
  @override
  String get pinLockSetting => 'App PIN / Biometric Lock';
  @override
  String get partnerSharingSetting => 'Shohar / Partner Mode';
  @override
  String get backupSyncSetting => 'Cloud Database Sync';
  @override
  String get exportDataTitle => 'Tamam Data Export (JSON)';
  @override
  String get deleteDataTitle => 'Tamam Data Delete Karein';
  @override
  String get logOutTitle => 'Sign Out (Log Out)';

  @override
  String get dictionaryButton => 'Lughat';
  @override
  String get aiButton => 'AI Madadgar';
  @override
  List<String> get weekdayHeaders => const ['P', 'M', 'B', 'J', 'J', 'H', 'I'];

  @override
  String get folicAcidTrackerTitle => 'Rozana Folic Acid (400 mcg)';
  @override
  String get folicAcidTrackerDesc => 'Baby planning aur early pregnancy ke liye nihayat zaroori';
  @override
  String get kickCounterCardTitle => 'Baby Kicks Counter (Movement)';
  @override
  String get kickCounterCardDesc => '2 ghantay mein 10 movements ka hisaab';
  @override
  String get waterTrackerCardTitle => 'Hydration & Paani (Glasses)';
  @override
  String get waterTrackerCardDesc => 'Sehatmand amniotic fluid ke liye paani piyein';

  @override
  String get learnTitle => 'Tibbi Rahnumai (Learn)';
  @override
  String get learnSubtitle => 'Doctor ke mashwaray aur mustanad sciency haqaiq';
  @override
  String get categoryAll => 'Sab (All)';
  @override
  String get categoryMyths => 'Desi Myths vs Facts';
  @override
  String get categoryFertility => 'Fertility & Milap';
  @override
  String get categoryCycle => 'Cycle & Hormones';
  @override
  String get categoryPregnancy => 'Hamal (Pregnancy)';
  @override
  String get categorySafety => 'Safety & Emergency';

  @override
  String get legendConfirmedPeriod => 'Pukhta Mahwari';
  @override
  String get legendPredictedPeriod => 'Mutawaqa Mahwari';
  @override
  String get legendFertileWindow => 'Zarkhez Din (Fertile Window)';
  @override
  String get legendOvulationDay => 'Ovulation Day (Baiza) ⚡';
}

class EnglishStrings implements AppStrings {
  const EnglishStrings();

  @override
  String get navHome => 'Home';
  @override
  String get navCalendar => 'Calendar';
  @override
  String get navInsights => 'Insights';
  @override
  String get navLearn => 'Learn';
  @override
  String get navSettings => 'Settings';

  @override
  String get quickActionsTitle => 'Quick Actions';
  @override
  String get logPeriodTitle => 'Log Period Day';
  @override
  String get logPeriodSubtitle => 'Record flow intensity & start date';
  @override
  String get logSymptomsTitle => 'Log Symptoms & Mood';
  @override
  String get logSymptomsSubtitle => 'Record cramps, headaches, energy levels';
  @override
  String get logOvulationTitle => 'Log Ovulation Test (LH)';
  @override
  String get logOvulationSubtitle => 'Record test results, cervical fluid, intimacy';
  @override
  String get positiveTestTitle => 'Positive Pregnancy Test ✨';
  @override
  String get positiveTestSubtitle => 'Switch to pregnancy tracking mode';
  @override
  String get askAiTitle => 'Ask AI Health Companion';
  @override
  String get askAiSubtitle => 'Instant medical evidence & science questions';

  @override
  String get assalamGreeting => 'Welcome Back';
  @override
  String get journeyCycle => 'Cycle Tracking';
  @override
  String get journeyPregnancy => 'Pregnancy';
  @override
  String get quickOverviewTitle => 'Quick Overview • Today';
  @override
  String get moodHappy => 'Happy';
  @override
  String get actionIntimacy => 'Intimacy';
  @override
  String get moodRest => 'Rest';
  @override
  String get moodFine => 'All Good';
  @override
  String get moodCramps => 'Cramps';
  @override
  String get logBleedingTile => 'Bleeding Log';
  @override
  String get logMoodTile => 'Mood Log';
  @override
  String get logPainTile => 'Pain Log';
  @override
  String get autoGuidanceTitle => 'WETRACK AUTO GUIDANCE';
  @override
  String get emergencyGuideButton => 'Emergency Guide';
  @override
  String get husbandGuideButton => 'Partner Care Guide';
  @override
  String get languageSwitchLabel => 'Language';

  @override
  String get calendarTitle => 'Cycle Calendar';
  @override
  String get calendarDisclaimer => 'Predictions';
  @override
  String get selectDayPrompt => 'Tap any date to inspect details or log symptoms';
  @override
  String get legendPeriod => 'Period Flow';
  @override
  String get legendFertile => 'High Fertility';
  @override
  String get legendOvulation => 'Ovulation Day ⚡';
  @override
  String get legendExpected => 'Expected Period';

  @override
  String get insightsTitle => 'Cycle Insights';
  @override
  String get insightsSubtitle => 'History';
  @override
  String get averageCycleLength => 'Average Cycle Gap';
  @override
  String get averagePeriodLength => 'Average Period Duration';
  @override
  String get totalCyclesLogged => 'Total Recorded Cycles';
  @override
  String get cycleConsistency => 'Cycle Regularity';

  @override
  String get settingsTitle => 'Settings & Security';
  @override
  String get preferencesHeader => 'Preferences';
  @override
  String get languageSetting => 'App Language';
  @override
  String get pinLockSetting => 'App PIN / Biometric Lock';
  @override
  String get partnerSharingSetting => 'Partner Sharing Mode';
  @override
  String get backupSyncSetting => 'Cloud Database Backup';
  @override
  String get exportDataTitle => 'Export All Data (JSON)';
  @override
  String get deleteDataTitle => 'Delete All Data';
  @override
  String get logOutTitle => 'Sign Out (Log Out)';

  @override
  String get dictionaryButton => 'Dictionary';
  @override
  String get aiButton => 'AI Assistant';
  @override
  List<String> get weekdayHeaders => const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  String get folicAcidTrackerTitle => 'Daily Folic Acid (400 mcg)';
  @override
  String get folicAcidTrackerDesc => 'Critical for preconception & early pregnancy';
  @override
  String get kickCounterCardTitle => 'Baby Kick Counter (Movement)';
  @override
  String get kickCounterCardDesc => 'Track 10 kicks within 2 hours';
  @override
  String get waterTrackerCardTitle => 'Daily Hydration (Glasses)';
  @override
  String get waterTrackerCardDesc => 'Essential for healthy amniotic fluid';

  @override
  String get learnTitle => 'Clinical Education (Learn)';
  @override
  String get learnSubtitle => 'Evidence-based guidance & scientific facts';
  @override
  String get categoryAll => 'All Topics';
  @override
  String get categoryMyths => 'Myths vs Facts';
  @override
  String get categoryFertility => 'Fertility & Conception';
  @override
  String get categoryCycle => 'Cycle & Hormones';
  @override
  String get categoryPregnancy => 'Pregnancy Care';
  @override
  String get categorySafety => 'Safety & Red Flags';

  @override
  String get legendConfirmedPeriod => 'Confirmed Period';
  @override
  String get legendPredictedPeriod => 'Predicted Period';
  @override
  String get legendFertileWindow => 'Fertile Window';
  @override
  String get legendOvulationDay => 'Ovulation Day ⚡';
}

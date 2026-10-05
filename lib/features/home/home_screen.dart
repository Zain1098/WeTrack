import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/clay_dial.dart';
import '../../core/widgets/living_3d_mascot.dart';
import '../../core/widgets/squishy_3d_button.dart';
import '../../core/widgets/period_mascot_alert_modal.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/cycle_calculation_service.dart';
import '../../data/services/pregnancy_calculation_service.dart';
import '../app_providers.dart';
import '../cycle/log_period_modal.dart';
import '../cycle/log_symptoms_modal.dart';
import '../fertility/log_fertility_modal.dart';
import '../pregnancy/positive_test_modal.dart';
import '../ai/ai_assistant_sheet.dart';
import '../dictionary/health_dictionary_modal.dart';
import '../profile/profile_screen.dart';
import '../appointments/appointment_modal.dart';
import '../safety/emergency_red_flags_modal.dart';
import '../pregnancy/kick_counter_modal.dart';
import '../partner/husband_care_card_modal.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/language_provider.dart';
import '../../core/widgets/clay_language_toggle.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _todayKicks = 0;
  int _waterGlasses = 4;
  bool _vitaminsTaken = false;
  bool _folicAcidTaken = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final cycleCalc = ref.watch(cycleCalculationProvider);
    final pregCalc = ref.watch(pregnancyCalculationProvider);
    final s = ref.watch(appStringsProvider);
    final todaySymptoms = ref.watch(symptomEntriesProvider).where(
          (s) => DateHelpers.daysBetween(s.date, DateTime.now()) == 0,
        );

    final isPregnancyMode = profile.goal == AppGoal.alreadyPregnant;

    return Scaffold(
      backgroundColor: ClayColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Greeting, Avatar, Language Toggle, Dictionary & AI
              _buildTopBar(context, profile, s),
              const SizedBox(height: 14),

              // Segmented Journey Switcher: [ 🌸 Mahwari ] [ 🤰 Hamal ]
              _buildJourneySwitcher(isPregnancyMode, s),
              const SizedBox(height: 12),

              // Quick Support Shortcuts: [ 🚨 Emergency Guide ] [ 🧔 Husband Care Guide ]
              _buildSupportShortcutsRow(context, profile, cycleCalc, pregCalc, s),
              const SizedBox(height: 16),

              if (!isPregnancyMode) ...[
                // --- CYCLE & PERIOD MODE ---
                // 0. Contextual Daily Briefing (Good morning! Cycle Day X · Trying to Conceive)
                _buildDailyBriefingCard(profile, cycleCalc),
                const SizedBox(height: 14),

                // 1. Horizontal Mini Calendar Strip (matching Period Tracker.jpg)
                _buildMiniCalendarStrip(),
                const SizedBox(height: 14),

                // 2. Living 3D Animated Mascot (Breathing, 3D Perspective Tilt & Dialogues)
                Living3DMascot(
                  phase: cycleCalc.currentPhase,
                  onTap: () {
                    final days = cycleCalc.daysUntilNextPeriod;
                    final message = days == 0
                        ? 'Aaj mahwari (period) expected hai!'
                        : days > 0
                            ? '$days Din Baqi Hain Agle Period Me'
                            : '${days.abs()} Din Upar Ho Chukay Hain';
                    PeriodMascotAlertModal.show(
                      context: context,
                      title: 'Mahwari (Period) Update',
                      daysMessage: message,
                      tips: const [
                        'Halka garam paani ya chamomile chai piyein.',
                        'Heating pad ya garam kapra aaram ke liye paas rakhein.',
                        'Bag me pads advance me rakh lein taake pareshani na ho.',
                        'Aaj ka mood aur dard ek tap me log karein.',
                      ],
                      onLogTap: () => LogPeriodModal.show(context),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 3. Circular 28-Day Segmented Dial (matching Period Tracker.jpg)
                ClayCycleDial(
                  calculation: cycleCalc,
                  onTap: () => LogPeriodModal.show(context),
                ),
                const SizedBox(height: 14),

                // 4. Automated Guidance Banner (Audio 3 & Audio 1)
                _buildAutomatedGuidanceCard(context, cycleCalc),
                const SizedBox(height: 14),

                // 4b. Pre-conception Daily Folic Acid Tracker (400 mcg - ASRM/NHS)
                _buildFolicAcidTracker(s),
                const SizedBox(height: 14),

                // 4c. 21-Day Smart Conception & DPO Countdown Timeline Card
                _buildSmartConceptionCountdownCard(context, cycleCalc),
                const SizedBox(height: 16),

                // 5. Quick Overview • Today (matching Period Tracker.jpg squircles)
                _buildQuickOverviewRow(context, s),
                const SizedBox(height: 16),

                // 6. Visual Quick Action Tiles
                _buildCycleQuickActions(context, s),
                const SizedBox(height: 16),

                // 7. Today Mood & Symptom Tracker Card
                _buildTodayStatusCard(context, todaySymptoms.isNotEmpty ? todaySymptoms.first : null),
                const SizedBox(height: 16),

                // 8a. Pregnancy Test Timing & Guidance Card (NHS & ASRM Rules)
                _buildPregnancyTestTimingCard(context, cycleCalc),
                const SizedBox(height: 16),

                // 8b. Doctor Pregnancy Confirmation Switch Banner (Audio 3)
                _buildDoctorPregnancyBanner(context),
                const SizedBox(height: 16),

                // 8c. Doctor Appointments & Ultrasound Card
                _buildDoctorAppointmentsCard(context),
                const SizedBox(height: 16),

                // 9. Cycle Phase Insight Card in Roman English
                _buildCycleInsightCard(cycleCalc),
              ] else ...[
                // --- PREGNANCY MODE (matching Pregnancy & Period Tracker Mobile App reference) ---
                if (pregCalc == null) ...[
                  _buildPregnancySetupCard(context),
                ] else ...[
                  // 1. Hero 3D Baby Milestone Card with Completed/Remaining tags
                  _buildBabyHeroCard(context, pregCalc),
                  const SizedBox(height: 16),

                  // 2. Mother's Health Monitor Timeline Banner (mother_timeline_banner.png)
                  _buildMotherTimelineBanner(pregCalc),
                  const SizedBox(height: 16),

                  // 3. Trimester Progress Slider
                  _buildTrimesterProgressBar(pregCalc),
                  const SizedBox(height: 16),

                  // 3b. Doctor Appointments & Ultrasound Scan Card
                  _buildDoctorAppointmentsCard(context),
                  const SizedBox(height: 16),

                  // 4. Mother & Baby Daily Tracker (Kicks, Water, Vitamins)
                  _buildMotherTrackRecordCard(),
                  const SizedBox(height: 16),

                  // 5. Weekly Baby Development Card
                  _buildBabyWeeklyInsightCard(pregCalc),
                ],
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Top Bar with Greeting, Avatar, Language Toggle, Roman Dictionary & AI
  Widget _buildTopBar(BuildContext context, UserProfile profile, AppStrings s) {
    final displayName = profile.name.isEmpty ? "Friend" : profile.name;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar + Greeting
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF04E78), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF04E78).withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profile.profileImagePath != null &&
                            File(profile.profileImagePath!).existsSync()
                        ? Image.file(
                            File(profile.profileImagePath!),
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'UI/Profile page character.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${s.assalamGreeting}, $displayName 🌸',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: ClayColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: ClayColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateHelpers.formatFriendly(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: ClayColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Action Buttons: Language Toggle + Roman Lughat + Ask AI
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3D Clay Language Capsule Toggle
            const ClayLanguageToggle(isCompact: true),
            const SizedBox(width: 6),

            // Dictionary Button (Audio 1)
            GestureDetector(
              onTap: () => HealthDictionaryModal.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFD5E2)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C8E24AA),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('📖', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 3),
                    Text(
                      s.dictionaryButton,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC2185B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),

            // AI Companion Button
            GestureDetector(
              onTap: () => AIAssistantSheet.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: ClayColors.outline),
                  boxShadow: [
                    BoxShadow(
                      color: ClayColors.primary.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 13, color: ClayColors.primary),
                    const SizedBox(width: 3),
                    Text(
                      s.aiButton,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ClayColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Segmented Journey Switcher
  Widget _buildJourneySwitcher(bool isPregnancyMode, AppStrings s) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (isPregnancyMode) {
                  ref.read(userProfileProvider.notifier).updateGoal(AppGoal.trackCycle);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: !isPregnancyMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: !isPregnancyMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🌸', style: TextStyle(fontSize: !isPregnancyMode ? 15 : 13)),
                    const SizedBox(width: 6),
                    Text(
                      s.journeyCycle,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: !isPregnancyMode ? ClayColors.primary : ClayColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isPregnancyMode) {
                  ref.read(userProfileProvider.notifier).updateGoal(AppGoal.alreadyPregnant);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isPregnancyMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: isPregnancyMode
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🤰', style: TextStyle(fontSize: isPregnancyMode ? 15 : 13)),
                    const SizedBox(width: 6),
                    Text(
                      s.journeyPregnancy,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isPregnancyMode ? ClayColors.secondary : ClayColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Horizontal Mini Calendar Strip (matching Period Tracker.jpg)
  Widget _buildMiniCalendarStrip() {
    final now = DateTime.now();
    // Start of current week (Monday)
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3EDF8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x082E1065),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final date = monday.add(Duration(days: i));
          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
          return Column(
            children: [
              Text(
                weekdays[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isToday ? const Color(0xFFE91E63) : const Color(0xFF8E849E),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday ? const Color(0xFFF04E78) : Colors.transparent,
                  boxShadow: isToday
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF04E78).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    date.day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                      color: isToday ? Colors.white : const Color(0xFF2E1A47),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }



  // 4. Automated Guidance Banner (Audio 3 & Audio 1)
  Widget _buildAutomatedGuidanceCard(BuildContext context, CycleCalculationResult cycleCalc) {
    final isFertile = cycleCalc.currentPhase == CyclePhase.fertileWindow ||
        cycleCalc.currentPhase == CyclePhase.ovulationDay;
    final isPeriod = cycleCalc.currentPhase == CyclePhase.menstrual;

    String title;
    String advice;
    String termForDictionary;

    if (isPeriod) {
      title = 'Mahwari (Period) Chal Rahi Hai 🩸';
      advice = 'Aapki body cleansing phase me hai. Aaram karein, garam doodh ya chai piyein aur hydration ka khayal rakhein.';
      termForDictionary = 'Menstrual Phase / Period';
    } else if (isFertile) {
      title = '⚡ Hamal / Pregnancy ke High Chances!';
      advice = 'Cycle ke ye din intercourse (sex) ke liye best hain agar baby plan kar rahi hain. Agar conceive nahi karna to ehtiyat karein.';
      termForDictionary = 'Fertile Window';
    } else if (cycleCalc.currentPhase == CyclePhase.follicular) {
      title = 'Period Khatam Hua Hai 🌱 (Follicular)';
      advice = 'Naya egg banna shuru ho raha hai. Body fresh mehsoos karegi. Agle dino me fertile window shuru hogi.';
      termForDictionary = 'Follicular Phase';
    } else {
      title = 'Agle Period ki Tayyari 🌙 (Luteal)';
      advice = 'Ovulation guzar chuki hai. Period aane me kuch din baqi hain. Mood swings ya mild cramps aam hain.';
      termForDictionary = 'Luteal Phase';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFertile ? const Color(0xFFFFF9E6) : const Color(0xFFF9F6FE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFertile ? const Color(0xFFFFE082) : const Color(0xFFE8DEF8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFertile ? const Color(0xFFFFD54F) : const Color(0xFF9E8CE7),
                  shape: BoxShape.circle,
                ),
                child: const Text('✨', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WETRACK AUTO GUIDANCE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7A6A8D),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isFertile ? const Color(0xFFB45309) : const Color(0xFF2E1A47),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            advice,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Color(0xFF4A3B60),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => HealthDictionaryModal.show(context, initialSearchTerm: termForDictionary),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📖 ', style: TextStyle(fontSize: 11)),
                Text(
                  'Roman Lughat me "$termForDictionary" samjhein',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9E8CE7),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Quick Overview • Today (Tactile 3D Squishy Buttons)
  Widget _buildQuickOverviewRow(BuildContext context, AppStrings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.quickOverviewTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: ClayColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              Squishy3DButton(
                emoji: '😊',
                label: s.moodHappy,
                primaryColor: const Color(0xFFFF9800),
                onTap: () => LogSymptomsModal.show(context),
              ),
              const SizedBox(width: 12),
              Squishy3DButton(
                emoji: '🔒',
                label: s.actionIntimacy,
                primaryColor: const Color(0xFF03A9F4),
                onTap: () => LogFertilityModal.show(context),
              ),
              const SizedBox(width: 12),
              Squishy3DButton(
                emoji: '🛋️',
                label: s.moodRest,
                primaryColor: const Color(0xFFE91E63),
                onTap: () => LogSymptomsModal.show(context),
              ),
              const SizedBox(width: 12),
              Squishy3DButton(
                emoji: '💧',
                label: s.moodFine,
                primaryColor: const Color(0xFF00BFA5),
                onTap: () => LogSymptomsModal.show(context),
              ),
              const SizedBox(width: 12),
              Squishy3DButton(
                emoji: '⚡',
                label: s.moodCramps,
                primaryColor: const Color(0xFF9C27B0),
                onTap: () => LogSymptomsModal.show(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. Visual Quick Action Tiles
  Widget _buildCycleQuickActions(BuildContext context, AppStrings s) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            icon: Icons.water_drop_rounded,
            color: const Color(0xFFFF5252),
            bgColor: const Color(0xFFFFEBEE),
            label: s.logBleedingTile,
            onTap: () => LogPeriodModal.show(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            icon: Icons.sentiment_satisfied_alt_rounded,
            color: const Color(0xFFAB47BC),
            bgColor: const Color(0xFFF3E5F5),
            label: s.logMoodTile,
            onTap: () => LogSymptomsModal.show(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            icon: Icons.healing_rounded,
            color: const Color(0xFF26A69A),
            bgColor: const Color(0xFFE0F2F1),
            label: s.logPainTile,
            onTap: () => LogSymptomsModal.show(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            icon: Icons.device_thermostat_rounded,
            color: const Color(0xFFFFA726),
            bgColor: const Color(0xFFFFF3E0),
            label: 'Fertility',
            onTap: () => LogFertilityModal.show(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClayCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        borderRadius: 20,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: ClayColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 7. Today Body Check-in Card
  Widget _buildTodayStatusCard(BuildContext context, dynamic todayEntry) {
    final hasLogs = todayEntry != null &&
        (todayEntry.symptoms.isNotEmpty || todayEntry.moods.isNotEmpty);

    return ClayCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.spa_rounded, color: Color(0xFF8E24AA), size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Aaj Ka Jism aur Mood",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => LogSymptomsModal.show(context),
                child: Text(
                  hasLogs ? 'Badlein' : '+ Naya Log',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: ClayColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!hasLogs) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('✨', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aaj abhi koi alamat note nahi hui. Tap karke record karein.',
                      style: TextStyle(fontSize: 12, color: ClayColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...todayEntry.moods.map<Widget>((m) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCE93D8)),
                      ),
                      child: Text(
                        '😊 $m',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                    )),
                ...todayEntry.symptoms.map<Widget>((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFA5D6A7)),
                      ),
                      child: Text(
                        '🌸 $s',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    )),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 8. Doctor Pregnancy Confirmation Switch Banner (Audio 3)
  Widget _buildDoctorPregnancyBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => PositivePregnancyTestModal.show(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFEFF5), Color(0xFFFFE0EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFB6C1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE91E63).withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Text('🤰', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doctor ne Hamal Confirm Kiya?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF880E4F),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Yahan tap karke Pregnancy Dashboard shuru karein ✨',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFFC2185B)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFC2185B)),
          ],
        ),
      ),
    );
  }

  // 9. Cycle Phase Insight Card in Roman English
  Widget _buildCycleInsightCard(CycleCalculationResult cycleCalc) {
    return ClayCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFFDF7FF),
      borderRadius: 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ClayColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.lightbulb_rounded, color: ClayColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cycleCalc.currentPhase.displayName} Maloomat',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: ClayColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cycleCalc.currentPhase.summary,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ClayColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- PREGNANCY MODE WIDGETS ---

  // Pregnancy Setup if no record
  Widget _buildPregnancySetupCard(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        children: [
          const Icon(Icons.child_care_rounded, size: 56, color: Color(0xFFE91E63)),
          const SizedBox(height: 12),
          const Text(
            'Hamal (Pregnancy) Ka Safar Mubarak!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hafte-ba-hafte 3D baby growth, fruit comparison aur health updates bina kisi pareshani ke track karein.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => PositivePregnancyTestModal.show(context),
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Tareekh Confirm Karein'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  // 1. Hero 3D Baby Milestone Card with Completed/Remaining tags
  Widget _buildBabyHeroCard(BuildContext context, PregnancyCalculationResult pregCalc) {
    final completed = pregCalc.completedWeeks;
    final remaining = (40 - completed).clamp(0, 40);

    return ClayCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Greeting & Trimester Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🍼', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'Hello Mummy! 🌸',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF8BBD0)),
                ),
                child: Text(
                  'Trimester ${pregCalc.currentTrimester}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC2185B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Central Living 3D Baby Visual with Interactive Float, Breathing, Tilt & Speech Bubble
          Living3DMascot(
            isPregnancyMode: true,
            pregnancyWeek: pregCalc.completedWeeks,
          ),
          const SizedBox(height: 12),

          // Floating Milestone Tags Row: Weeks Completed & Weeks Left
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3E5F5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('✨ ', style: TextStyle(fontSize: 11)),
                    Text(
                      '$completed Hafte Done',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E24AA),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCE4EC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('⏳ ', style: TextStyle(fontSize: 11)),
                    Text(
                      '$remaining Hafte Baqi',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gestational Age & Due Date Countdown
          Text(
            '${pregCalc.completedWeeks} hafte ${pregCalc.remainingDays} din',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: ClayColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pregCalc.dueDateCountdownText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 14),

          // Fruit Comparison & Dimensions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🥑', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Baby size: ${pregCalc.babyFruitComparison}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Length: ${pregCalc.babyApproximateLength} • Wazan: ${pregCalc.babyApproximateWeight}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Mother's Health Monitor Timeline Banner (mother_timeline_banner.png)
  Widget _buildMotherTimelineBanner(PregnancyCalculationResult pregCalc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3EDF8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E1065),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.asset(
              'UI/mother_timeline_banner.png',
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                height: 80,
                color: const Color(0xFFFFEEF3),
                child: const Center(child: Text('🤰 Pregnancy Timeline')),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maa aur Bacha Monitor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Doctor visits & milestones track karein',
                      style: TextStyle(fontSize: 11, color: ClayColors.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Week ${pregCalc.completedWeeks}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Trimester Progress Bar
  Widget _buildTrimesterProgressBar(PregnancyCalculationResult pregCalc) {
    return ClayCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pregnancy Ka Safar',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: ClayColors.textPrimary,
                ),
              ),
              Text(
                '${(pregCalc.progressFraction * 100).toInt()}% Safar Mukammal',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pregCalc.progressFraction.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: const Color(0xFFF3E5F5),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1st Trimester', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('2nd Trimester', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('3rd Trimester', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Mother & Baby Track Record Card (Kicks, Water, Vitamins)
  Widget _buildMotherTrackRecordCard() {
    return ClayCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mummy & Baby Daily Tracker',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: ClayColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Kick Counter (3D Tactile NHS Counter)
              Expanded(
                child: GestureDetector(
                  onTap: () => KickCounterModal.show(
                    context,
                    initialKicks: _todayKicks,
                    onSaveKicks: (val) => setState(() => _todayKicks = val),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F3),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        const Text('👣', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(
                          '$_todayKicks Kicks',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD81B60),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD81B60),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '3D Counter',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Water Intake
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F5FE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text('💧', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        '$_waterGlasses / 8 Glass',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0288D1),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => setState(() {
                          if (_waterGlasses < 12) _waterGlasses++;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0288D1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '+ Paani',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Vitamins
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text('💊', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        _vitaminsTaken ? 'Khali!' : 'Vitamins',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: _vitaminsTaken ? const Color(0xFF2E7D32) : const Color(0xFF7B1FA2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => setState(() => _vitaminsTaken = !_vitaminsTaken),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _vitaminsTaken ? const Color(0xFF2E7D32) : const Color(0xFF7B1FA2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _vitaminsTaken ? 'Done ✔' : 'Kha Li',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Weekly Baby Development Cartoon Card
  Widget _buildBabyWeeklyInsightCard(PregnancyCalculationResult pregCalc) {
    return ClayCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      backgroundColor: const Color(0xFFFFF9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD1DC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_stories_rounded, color: Color(0xFFC2185B), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Week ${pregCalc.completedWeeks} Baby Ki Growth',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ClayColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pregCalc.weeklyMilestoneSummary,
            style: const TextStyle(
              fontSize: 12,
              color: ClayColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // Contextual Daily Briefing (Good morning! Cycle Day X · Trying to Conceive)
  Widget _buildDailyBriefingCard(UserProfile profile, CycleCalculationResult cycleCalc) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning! ❤️' : (hour < 17 ? 'Good afternoon! 🌸' : 'Good evening! 🌙');
    final isFertile = cycleCalc.currentPhase == CyclePhase.fertileWindow ||
        cycleCalc.currentPhase == CyclePhase.ovulationDay;
    final days = cycleCalc.daysUntilNextPeriod;
    final nextPeriodText = days == 0
        ? 'Aaj expected hai'
        : (days > 0 ? 'Expected in $days days' : '${days.abs()} din upar ho chuke hain');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFertile
              ? [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)]
              : [const Color(0xFFF3E5F5), const Color(0xFFEDE7F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFertile ? const Color(0xFFFFD54F) : const Color(0xFFD1C4E9),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E1065),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E1A47),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isFertile ? const Color(0xFFFFA000) : const Color(0xFF9E8CE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Cycle Day ${cycleCalc.currentCycleDay} · ${profile.maritalStatus == 'Married' ? 'Trying to Conceive' : 'Cycle Tracking'}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isFertile
                ? '⚡ Aaj Ka Update: Estimated Fertile Window'
                : '🌸 Aaj Ka Update: ${cycleCalc.currentPhase.displayName}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isFertile ? const Color(0xFFB45309) : const Color(0xFF4A148C),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isFertile
                ? 'Tumhare recorded cycle ke mutabiq yeh pregnancy ke high chances wale din ho sakte hain. Yeh scientific prediction hai, medical confirmation nahi.'
                : 'Cycle record ke mutabiq body natural cycle ke mutabiq proceed kar rahi hai.',
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF5D4A72),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_repeat_rounded, size: 13, color: Color(0xFFE91E63)),
                const SizedBox(width: 6),
                Text(
                  'Next Period: $nextPeriodText',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF880E4F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Trying-to-Conceive Folic Acid (400 mcg) Daily Check (ASRM & NHS Guidelines)
  Widget _buildFolicAcidTracker(AppStrings s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _folicAcidTaken ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _folicAcidTaken ? const Color(0xFFA5D6A7) : const Color(0xFFFFE082),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _folicAcidTaken = !_folicAcidTaken);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _folicAcidTaken ? const Color(0xFF4CAF50) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _folicAcidTaken ? const Color(0xFF4CAF50) : const Color(0xFFFFB300),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_folicAcidTaken ? Colors.green : Colors.amber).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _folicAcidTaken ? Icons.check_rounded : Icons.medication_rounded,
                  color: _folicAcidTaken ? Colors.white : const Color(0xFFF57F17),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _folicAcidTaken
                      ? 'Folic Acid Done! ✨ (400 mcg)'
                      : s.folicAcidTrackerTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _folicAcidTaken ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.folicAcidTrackerDesc,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF5D4A72),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _folicAcidTaken ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: _folicAcidTaken ? const Color(0xFF2E7D32) : const Color(0xFFFFB300),
            ),
            onPressed: () => setState(() => _folicAcidTaken = !_folicAcidTaken),
          ),
        ],
      ),
    );
  }

  // Pregnancy Test Guidance & Timing Card (NHS & ASRM Rules)
  Widget _buildPregnancyTestTimingCard(BuildContext context, CycleCalculationResult cycleCalc) {
    final days = cycleCalc.daysUntilNextPeriod;
    final isPeriodDelayed = days <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPeriodDelayed ? const Color(0xFFFCE4EC) : const Color(0xFFF7F2FA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPeriodDelayed ? const Color(0xFFF48FB1) : const Color(0xFFE1BEE7),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPeriodDelayed ? const Color(0xFFE91E63) : const Color(0xFF9E8CE7),
                  shape: BoxShape.circle,
                ),
                child: const Text('🧪', style: TextStyle(fontSize: 15)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PREGNANCY TEST GUIDANCE (NHS / ASRM)',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7A6A8D),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      isPeriodDelayed
                          ? 'Period Miss Ho Gaya? Ab Test Karein! ✨'
                          : 'Pregnancy Test Kab Karna Chahiye?',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: isPeriodDelayed ? const Color(0xFF880E4F) : const Color(0xFF2E1A47),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '• Missed Period: Aam home test missed period ke pehle din se sab se zyada reliable aur accurate hota hai.\n• Irregular Cycle: Agar cycle ki date confirm na ho, to aakhri unprotected intercourse ke kam az kam 21 din baad test karein.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.45,
              color: Color(0xFF4A3B60),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => PositivePregnancyTestModal.show(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isPeriodDelayed ? const Color(0xFFE91E63) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPeriodDelayed ? const Color(0xFFC2185B) : const Color(0xFF9E8CE7),
                ),
              ),
              child: Center(
                child: Text(
                  isPeriodDelayed
                      ? '⚡ Test Positive Aaya? Hamal Confirm Karein'
                      : 'Pregnancy Test Result Log / Confirm Karein',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPeriodDelayed ? Colors.white : const Color(0xFF6A1B9A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Doctor Appointments & Ultrasound Card
  Widget _buildDoctorAppointmentsCard(BuildContext context) {
    final appointments = ref.watch(appointmentsProvider);
    final upcoming = appointments
        .where((a) => a.dateTime.isAfter(DateTime.now().subtract(const Duration(hours: 3))))
        .toList();
    final nextApt = upcoming.isNotEmpty ? upcoming.first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDE7F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E1065),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🏥', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'Doctor Appointments & Scans',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E1A47),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => AppointmentModal.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '+ Add / Dekhein',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8E24AA),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (nextApt != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD1DC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm_on_rounded, color: Color(0xFFE91E63), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextApt.title,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF880E4F),
                          ),
                        ),
                        Text(
                          '${DateHelpers.formatFriendly(nextApt.dateTime)} • ${nextApt.clinicianName != null ? 'Dr. ${nextApt.clinicianName}' : 'Clinic Visit'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFAD1457),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFFE91E63)),
                ],
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: () => AppointmentModal.show(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8FE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDE7F6)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, color: Color(0xFF9E8CE7), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Agla checkup, ultrasound ya blood test schedule karein',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF7A6A8D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF9E8CE7)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Quick Support Shortcuts Row: [ 🚨 Emergency Guide ] [ 🧔 Husband Care Guide ]
  Widget _buildSupportShortcutsRow(
    BuildContext context,
    UserProfile profile,
    CycleCalculationResult cycleCalc,
    PregnancyCalculationResult? pregCalc,
    AppStrings s,
  ) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => EmergencyRedFlagsModal.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFCDD2)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08E53935),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🚨', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    s.emergencyGuideButton,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => HusbandCareCardModal.show(
              context,
              profile: profile,
              cycleCalc: cycleCalc,
              pregCalc: pregCalc,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE1BEE7)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x087B1FA2),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🧔', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    s.husbandGuideButton,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 21-Day Smart Conception & DPO Countdown Timeline Card
  Widget _buildSmartConceptionCountdownCard(BuildContext context, CycleCalculationResult cycleCalc) {
    final day = cycleCalc.currentCycleDay;
    final int dpo = (day - 14).clamp(0, 21);
    final isPostOvulation = day >= 14;

    String phaseTitle;
    String phaseDetail;
    Color accentColor;
    double progress;

    if (!isPostOvulation) {
      phaseTitle = 'Pre-Ovulation Phase 🌱 (Egg Banna)';
      phaseDetail = 'Ovulation mein abhi ${14 - day} din baqi hain. Agle dino mein fertile window shuru hogi.';
      accentColor = const Color(0xFF9E8CE7);
      progress = (day / 14.0).clamp(0.1, 0.9);
    } else if (dpo <= 6) {
      phaseTitle = 'DPO $dpo: Fertilization Phase 🌱';
      phaseDetail = 'Egg aur sperm mil chuke hon to cell division shuru hai. Heavy lifting ya shadeed stress se perhez karein.';
      accentColor = const Color(0xFFE91E63);
      progress = (dpo / 14.0).clamp(0.2, 0.5);
    } else if (dpo <= 10) {
      phaseTitle = 'DPO $dpo: Implantation Window ✨';
      phaseDetail = 'Fertilized egg uterus ki deewar mein jud raha hai. Halka cramp ya brown spotting bilkul aam hai. Panic na karein!';
      accentColor = const Color(0xFFFF9800);
      progress = (dpo / 14.0).clamp(0.5, 0.75);
    } else if (dpo <= 13) {
      phaseTitle = 'DPO $dpo: Early Hormones Rising ⏳';
      phaseDetail = 'Jism mein hCG hormone banna shuru ho raha hai. Early test lene se false negative ka khatra hota hai, thoda sabar karein.';
      accentColor = const Color(0xFF8E24AA);
      progress = 0.85;
    } else {
      phaseTitle = 'DPO $dpo: 🎉 Test Day / Missed Period!';
      phaseDetail = 'Expected period ka din aa chuka hai! Subah ke pehle urine se pregnancy test karein taake 99% accurate result milay.';
      accentColor = const Color(0xFF2E7D32);
      progress = 1.0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9FA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD1DC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E1065),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text('⏳', style: TextStyle(fontSize: 14, color: accentColor)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '21-Day Conception Smart Timer',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E1A47),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isPostOvulation ? 'DPO $dpo / 14' : 'Day $day',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF0E5EB),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            phaseTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            phaseDetail,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF5D4A72),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          GestureDetector(
            onTap: () => LogFertilityModal.show(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_border_rounded, size: 13, color: Color(0xFFE91E63)),
                const SizedBox(width: 4),
                const Text(
                  'Milap / Intercourse Log Update Karein',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

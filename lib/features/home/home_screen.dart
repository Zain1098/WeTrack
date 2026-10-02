import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/clay_dial.dart';
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
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _todayKicks = 0;
  int _waterGlasses = 4;
  bool _vitaminsTaken = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final cycleCalc = ref.watch(cycleCalculationProvider);
    final pregCalc = ref.watch(pregnancyCalculationProvider);
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
              // Top Bar with Greeting & AI Mascot
              _buildTopBar(context, profile),
              const SizedBox(height: 14),

              // Segmented Journey Switcher: [ 🌸 Cycle ] [ 🤰 Pregnancy ]
              _buildJourneySwitcher(isPregnancyMode),
              const SizedBox(height: 18),

              if (!isPregnancyMode) ...[
                // --- CYCLE & PERIOD MODE ---
                // Mascot Alert Card (download.jpg Character)
                _buildMascotAlertCard(context, cycleCalc),
                const SizedBox(height: 16),

                // 28-Day Segmented Dial
                ClayCycleDial(
                  calculation: cycleCalc,
                  onTap: () => LogPeriodModal.show(context),
                ),
                const SizedBox(height: 14),

                // Phase & Ovulation Pill Info
                _buildCyclePhasePill(cycleCalc),
                const SizedBox(height: 20),

                // Visual Quick Action Tiles
                _buildCycleQuickActions(context),
                const SizedBox(height: 20),

                // Today Mood & Symptom Tracker Card
                _buildTodayStatusCard(context, todaySymptoms.isNotEmpty ? todaySymptoms.first : null),
                const SizedBox(height: 16),

                // Cycle Insight Card
                _buildCycleInsightCard(cycleCalc),
              ] else ...[
                // --- PREGNANCY MODE ---
                if (pregCalc == null) ...[
                  _buildPregnancySetupCard(context),
                ] else ...[
                  // Hero 3D Baby Milestone Card
                  _buildBabyHeroCard(context, pregCalc),
                  const SizedBox(height: 18),

                  // Trimester Progress Slider
                  _buildTrimesterProgressBar(pregCalc),
                  const SizedBox(height: 18),

                  // Mother & Baby Track Record (Kicks, Water, Vitamins)
                  _buildMotherTrackRecordCard(),
                  const SizedBox(height: 18),

                  // Weekly Baby Development Cartoon Card
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

  // Top Bar
  Widget _buildTopBar(BuildContext context, UserProfile profile) {
    final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'W';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
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
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Hello, ${profile.name.isEmpty ? "Friend" : profile.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ClayColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: ClayColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateHelpers.formatFriendly(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ClayColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // AI Companion Button
        GestureDetector(
          onTap: () => AIAssistantSheet.show(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ClayColors.outline),
              boxShadow: [
                BoxShadow(
                  color: ClayColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 16, color: ClayColors.primary),
                SizedBox(width: 6),
                Text(
                  'Ask AI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ClayColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Segmented Journey Switcher
  Widget _buildJourneySwitcher(bool isPregnancyMode) {
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
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                    Text('🌸', style: TextStyle(fontSize: !isPregnancyMode ? 16 : 14)),
                    const SizedBox(width: 6),
                    Text(
                      'Period Cycle',
                      style: TextStyle(
                        fontSize: 13,
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
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                    Text('🤰', style: TextStyle(fontSize: isPregnancyMode ? 16 : 14)),
                    const SizedBox(width: 6),
                    Text(
                      'Pregnancy',
                      style: TextStyle(
                        fontSize: 13,
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

  // Mascot Alert Banner (UI/download.jpg)
  Widget _buildMascotAlertCard(BuildContext context, CycleCalculationResult cycleCalc) {
    final days = cycleCalc.daysUntilNextPeriod;
    final message = days == 0
        ? 'Your period is predicted today!'
        : days > 0
            ? '$days Days Until Next Period'
            : '${days.abs()} Days Past Expected Date';

    return GestureDetector(
      onTap: () {
        PeriodMascotAlertModal.show(
          context: context,
          title: 'Period Cycle Update',
          daysMessage: message,
          tips: const [
            'Stay gently hydrated with warm water or herbal tea.',
            'Keep your favorite heat pad or blanket ready for comfort.',
            'Track any symptoms or mood changes today with one tap.',
          ],
          onLogTap: () => LogPeriodModal.show(context),
        );
      },
      child: ClayCard(
        backgroundColor: const Color(0xFFFFF0F3),
        borderRadius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ClayColors.secondary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: ClayColors.secondary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'UI/download.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.calendar_today_rounded,
                    color: ClayColors.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ClayColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'CYCLE REMINDER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF880E4F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap to view details & mascot tips',
                    style: TextStyle(fontSize: 11, color: Color(0xFFAD1457)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFD81B60)),
          ],
        ),
      ),
    );
  }

  // Phase Pill below dial
  Widget _buildCyclePhasePill(CycleCalculationResult cycleCalc) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ClayColors.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: ClayColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              cycleCalc.currentPhase.displayName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ClayColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '• Day ${cycleCalc.currentCycleDay} of ${cycleCalc.estimatedCycleLength}',
              style: const TextStyle(
                fontSize: 12,
                color: ClayColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cycle Quick Actions Row
  Widget _buildCycleQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            icon: Icons.water_drop_rounded,
            color: const Color(0xFFFF5252),
            bgColor: const Color(0xFFFFEBEE),
            label: 'Log Flow',
            onTap: () => LogPeriodModal.show(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            icon: Icons.sentiment_satisfied_alt_rounded,
            color: const Color(0xFFAB47BC),
            bgColor: const Color(0xFFF3E5F5),
            label: 'Log Mood',
            onTap: () => LogSymptomsModal.show(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            icon: Icons.healing_rounded,
            color: const Color(0xFF26A69A),
            bgColor: const Color(0xFFE0F2F1),
            label: 'Symptoms',
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
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: ClayColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Today Body Check-in Card
  Widget _buildTodayStatusCard(BuildContext context, dynamic todayEntry) {
    final hasLogs = todayEntry != null &&
        (todayEntry.symptoms.isNotEmpty || todayEntry.moods.isNotEmpty);

    return ClayCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.spa_rounded, color: Color(0xFF8E24AA), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Today's Body & Mood",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => LogSymptomsModal.show(context),
                child: Text(
                  hasLogs ? 'Edit' : '+ Add',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ClayColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasLogs) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('✨', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No symptoms logged today. Tap Add to record how your body feels.',
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
                          fontSize: 12,
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
                          fontSize: 12,
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

  // Cycle Phase Insight Card
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
            child: const Icon(Icons.lightbulb_rounded, color: ClayColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cycleCalc.currentPhase.displayName} Insights',
                  style: const TextStyle(
                    fontSize: 14,
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
            'Welcome to Pregnancy Journey',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your weekly 3D milestones, baby size comparisons, and health updates with zero stress.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => PositivePregnancyTestModal.show(context),
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Confirm Pregnancy Date'),
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

  // Hero 3D Baby Milestone Card
  Widget _buildBabyHeroCard(BuildContext context, PregnancyCalculationResult pregCalc) {
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
                    'Hello Mummy!',
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

          // Central 3D Baby Visual with Floating Milestone Tags
          Stack(
            alignment: Alignment.center,
            children: [
              // Circular Glow Backdrop
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF0F5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB6C1).withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),

              // 3D Baby Milestone Image
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'UI/baby_3d_milestone.png',
                  width: 190,
                  height: 190,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.child_care_rounded,
                    size: 90,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ),

              // Floating Tag Left: Weeks Completed
              Positioned(
                top: 14,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('✨ ', style: TextStyle(fontSize: 10)),
                      Text(
                        '${pregCalc.completedWeeks} Wks Done',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8E24AA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Floating Tag Right: Weeks Left
              Positioned(
                bottom: 14,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('⏳ ', style: TextStyle(fontSize: 10)),
                      Text(
                        '${(40 - pregCalc.completedWeeks).clamp(0, 40)} Wks Left',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gestational Age & Due Date Countdown
          Text(
            pregCalc.formattedGestationalAge,
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
                        'Length: ${pregCalc.babyApproximateLength} • Weight: ${pregCalc.babyApproximateWeight}',
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

  // Trimester Progress Bar
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
                'Journey Timeline',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: ClayColors.textPrimary,
                ),
              ),
              Text(
                '${(pregCalc.progressFraction * 100).toInt()}% Journey',
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
              Text('Trimester 1', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Trimester 2', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Trimester 3', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // Mother & Baby Track Record Card (Kicks, Water, Vitamins)
  Widget _buildMotherTrackRecordCard() {
    return ClayCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mother & Baby Daily Track',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: ClayColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Kick Counter
              Expanded(
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD81B60),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => setState(() => _todayKicks++),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD81B60),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '+ Tap Kick',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
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
                        '$_waterGlasses / 8 Glasses',
                        style: const TextStyle(
                          fontSize: 13,
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
                            '+ Drink',
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
                        _vitaminsTaken ? 'Done!' : 'Vitamins',
                        style: TextStyle(
                          fontSize: 13,
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
                            _vitaminsTaken ? 'Taken ✔' : 'Take',
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

  // Weekly Baby Development Cartoon Card
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
                'Week ${pregCalc.completedWeeks} Baby Development',
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
}

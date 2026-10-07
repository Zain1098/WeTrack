import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/disclaimer_badge.dart';
import '../../core/utils/date_helpers.dart';
import '../../core/localization/language_provider.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/pregnancy_calculation_service.dart';
import '../app_providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final isPregnancyMode = profile.goal == AppGoal.alreadyPregnant;
    final history = ref.watch(cycleHistoryProvider);
    final cycleCalc = ref.watch(cycleCalculationProvider);
    final pregCalc = ref.watch(pregnancyCalculationProvider);
    final appointments = ref.watch(appointmentsProvider);
    final s = ref.watch(appStringsProvider);
    final currentLanguage = ref.watch(languageProvider);
    final isUrdu = currentLanguage == AppLanguage.romanUrdu;

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
                      isPregnancyMode ? (isUrdu ? 'Hamal Ka Hisaab' : 'Pregnancy Overview') : s.insightsTitle,
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
                  DisclaimerBadge(text: isPregnancyMode ? (isUrdu ? 'Hamal Analytics' : 'Pregnancy Analytics') : s.insightsSubtitle),
                ],
              ),
              const SizedBox(height: 18),

              if (isPregnancyMode) ...[
                // --- PREGNANCY ANALYTICS & HISAAB ---
                _buildPregnancyAnalytics(context, pregCalc, appointments, isUrdu: isUrdu),
              ] else ...[
                // --- CYCLE ANALYTICS ---
                _buildCycleAnalytics(context, profile, cycleCalc, history, s),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Pregnancy Mode Analytics
  Widget _buildPregnancyAnalytics(
    BuildContext context,
    PregnancyCalculationResult? pregCalc,
    List<dynamic> appointments, {
    required bool isUrdu,
  }) {
    if (pregCalc == null) {
      return ClayCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.child_care_rounded, size: 48, color: Color(0xFFE91E63)),
            const SizedBox(height: 12),
            Text(
              isUrdu ? 'Hamal Record Setup Zaroori Hai' : 'Pregnancy Record Setup Required',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isUrdu
                  ? 'Home screen par ja kar apne hamal ki tareekh confirm karein.'
                  : 'Go to the Home screen to confirm your pregnancy due date.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: ClayColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final weeks = pregCalc.completedWeeks;
    final days = pregCalc.remainingDays;
    final daysToEdd = pregCalc.daysUntilDueDate;
    final progressPct = ((weeks / 40.0) * 100).clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2-Column Summary Cards
        Row(
          children: [
            // Gestational Age Card
            Expanded(
              child: ClayCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE91E63).withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.child_care_rounded,
                        color: Color(0xFFC2185B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isUrdu ? '$weeks hafte $days din' : '$weeks W $days D',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isUrdu
                          ? 'Hafta $weeks (Trim ${pregCalc.trimester})'
                          : 'Week $weeks (Trim ${pregCalc.trimester})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC2185B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // EDD Countdown Card
            Expanded(
              child: ClayCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00796B).withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        color: Color(0xFF00796B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isUrdu ? '$daysToEdd Din' : '$daysToEdd Days',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isUrdu ? 'Delivery Tak Baqi' : 'Until Due Date',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00796B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Trimester Journey Progress Bar
        ClayCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hamal Ka Safar (40 Haftay)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ClayColors.textPrimary),
                  ),
                  Text(
                    '${progressPct.toStringAsFixed(0)}% Mukammal',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFC2185B)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressPct / 100.0,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFF3E5F5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTrimesterBadge('Trimester 1\n(1-12w)', weeks >= 1, weeks >= 13),
                  _buildTrimesterBadge('Trimester 2\n(13-27w)', weeks >= 13, weeks >= 28),
                  _buildTrimesterBadge('Trimester 3\n(28-40w)', weeks >= 28, weeks >= 40),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Baby Vitals Estimate Card
        ClayCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: const Color(0xFFFFF0F5),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(child: Text('🍎', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrdu
                          ? 'Baby Size: ${pregCalc.babyFruitComparisonUrdu}'
                          : 'Baby Size: ${pregCalc.babyFruitComparison}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF880E4F),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isUrdu
                          ? 'Lambai ~${pregCalc.babyApproximateLength} · Wazan ~${pregCalc.babyApproximateWeight}'
                          : 'Length ~${pregCalc.babyApproximateLength} · Weight ~${pregCalc.babyApproximateWeight}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAD1457),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Medical Truth & Clarification Card (Period vs Pregnancy)
        ClayCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: const Color(0xFFFFF8E1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text('💡', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Clinical Fact: Hamal Aur Mahwari (Period)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Hamal (pregnancy) ke doran mahwari (period) bilkul nahi aati kyu ke Progesterone aur hCG hormones bache ki hifazat ke liye bache-dani ki deewar (uterine lining) ko girne nahi dete.\n\nAgar hamal ke doran kisi bhi qism ka khoon (bleeding) ya dard ho, toh yeh period nahi hai — foran apni gynecologist / doctor se ruju karein.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF5D4037),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Doctor Visits Timeline Card
        ClayCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Doctor Scans & Visits',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ClayColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${appointments.length} Visits Logged',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00796B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMilestoneScanItem('First Dating Scan', 'Week 8–12', weeks >= 12),
              _buildMilestoneScanItem('Anomaly Scan (Bache ki mukammal banawat)', 'Week 18–22', weeks >= 22),
              _buildMilestoneScanItem('Growth & Doppler Scan', 'Week 28–32', weeks >= 32),
              _buildMilestoneScanItem('Delivery & Position Checkup', 'Week 36–40', weeks >= 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrimesterBadge(String label, bool isStarted, bool isPassed) {
    Color bg = const Color(0xFFEEEEEE);
    Color tc = ClayColors.textSecondary;

    if (isPassed) {
      bg = const Color(0xFFE8F5E9);
      tc = const Color(0xFF2E7D32);
    } else if (isStarted) {
      bg = const Color(0xFFFCE4EC);
      tc = const Color(0xFFC2185B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: tc),
      ),
    );
  }

  Widget _buildMilestoneScanItem(String title, String timing, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: isCompleted ? const Color(0xFF2E7D32) : ClayColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w600,
                color: isCompleted ? ClayColors.textPrimary : ClayColors.textSecondary,
              ),
            ),
          ),
          Text(
            timing,
            style: const TextStyle(fontSize: 11, color: ClayColors.textTertiary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Cycle Mode Analytics
  Widget _buildCycleAnalytics(
    BuildContext context,
    UserProfile profile,
    dynamic cycleCalc,
    List<dynamic> history,
    dynamic s,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClayCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ClayColors.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ClayColors.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.timelapse_rounded,
                        color: ClayColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${cycleCalc.estimatedCycleLength} Days',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.averageCycleLength,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ClayColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClayCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ClayColors.secondaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ClayColors.secondary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: ClayColors.secondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${profile.usualPeriodDuration} Days',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.averagePeriodLength,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ClayColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Regularity Status Card
        ClayCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: ClayColors.mintContainer,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: ClayColors.mint),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cycle Consistency: Normal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cycleCalc.isUsingFallbackEstimate
                          ? 'Baseline estimates in use. Log at least 2 consecutive cycles to unlock personalized variation metrics.'
                          : 'Your recent cycles fall within the expected 24–35 day clinical range.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ClayColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Cycle History List
        const Text(
          'Recent Cycle History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ClayColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        if (history.isEmpty) ...[
          ClayCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 36,
                    color: ClayColors.textTertiary,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No completed past cycles logged yet.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'As you continue logging your periods, your cycle history and length distribution will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: ClayColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          ...history.map((cycle) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClayCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateHelpers.formatFriendly(cycle.startDate),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: ClayColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cycle.endDate != null
                                ? 'to ${DateHelpers.formatFriendly(cycle.endDate!)}'
                                : 'Current ongoing cycle',
                            style: const TextStyle(
                              fontSize: 12,
                              color: ClayColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ClayColors.surfaceTint,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          '${cycle.cycleLengthDays ?? cycleCalc.estimatedCycleLength} Days',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: ClayColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ],
    );
  }
}

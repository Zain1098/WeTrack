import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/disclaimer_badge.dart';
import '../../core/utils/date_helpers.dart';
import '../app_providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final history = ref.watch(cycleHistoryProvider);
    final cycleCalc = ref.watch(cycleCalculationProvider);

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
                  const Text(
                    'Cycle Insights',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: ClayColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const DisclaimerBadge(text: 'Historical Trends'),
                ],
              ),
              const SizedBox(height: 18),

              // Average Metrics Summary (2-Column Grid as in Stitch Spec)
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
                            decoration: const BoxDecoration(
                              color: ClayColors.primaryContainer,
                              shape: BoxShape.circle,
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
                          const Text(
                            'Average Cycle',
                            style: TextStyle(
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
                            decoration: const BoxDecoration(
                              color: ClayColors.secondaryContainer,
                              shape: BoxShape.circle,
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
                          const Text(
                            'Period Duration',
                            style: TextStyle(
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
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 36,
                          color: ClayColors.textTertiary,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No completed past cycles logged yet.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: ClayColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

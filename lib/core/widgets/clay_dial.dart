import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/clay_colors.dart';
import '../../data/services/cycle_calculation_service.dart';

class ClayCycleDial extends StatelessWidget {
  final CycleCalculationResult calculation;
  final VoidCallback? onTap;

  const ClayCycleDial({
    super.key,
    required this.calculation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: SizedBox(
          width: 290,
          height: 290,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ambient Glow
              Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: ClayColors.primary.withValues(alpha: 0.12),
                      blurRadius: 36,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                    const BoxShadow(
                      color: Color(0x0A2E1065),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),

              // Canvas Painted Ring
              CustomPaint(
                size: const Size(270, 270),
                painter: _CycleDialPainter(
                  cycleLength: calculation.estimatedCycleLength,
                  currentDay: calculation.currentCycleDay,
                  ovulationDay: calculation.estimatedCycleLength - 14,
                  fertileDaysCount: 6,
                ),
              ),

              // Central Porcelain Hub
              Container(
                width: 195,
                height: 195,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x0C2E1065),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: ClayColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cycle Day Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ClayColors.surfaceTint,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'Day ${calculation.currentCycleDay}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: ClayColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Big Countdown Headline
                    Text(
                      calculation.daysUntilNextPeriod > 0
                          ? '${calculation.daysUntilNextPeriod} Days'
                          : 'Period Due',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: ClayColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      calculation.daysUntilNextPeriod > 0
                          ? 'until next period'
                          : 'expected today',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ClayColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Phase Descriptor
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        calculation.currentPhase.displayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _getPhaseColor(calculation.currentPhase),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return ClayColors.secondary;
      case CyclePhase.follicular:
        return ClayColors.primary;
      case CyclePhase.fertileWindow:
      case CyclePhase.ovulationDay:
        return const Color(0xFFD97706);
      case CyclePhase.luteal:
        return ClayColors.mint;
    }
  }
}

class _CycleDialPainter extends CustomPainter {
  final int cycleLength;
  final int currentDay;
  final int ovulationDay;
  final int fertileDaysCount;

  _CycleDialPainter({
    required this.cycleLength,
    required this.currentDay,
    required this.ovulationDay,
    required this.fertileDaysCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 18;
    const strokeWidth = 22.0;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFF1EDF9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background track ring
    canvas.drawCircle(center, radius, backgroundPaint);

    final totalDays = cycleLength > 0 ? cycleLength : 28;
    final anglePerDay = (2 * pi) / totalDays;
    const startAngleOffset = -pi / 2; // Top 12 o'clock

    // 1. Menstrual segment (Days 1 to 5)
    final periodAngle = anglePerDay * 5;
    final periodPaint = Paint()
      ..color = ClayColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngleOffset,
      periodAngle,
      false,
      periodPaint,
    );

    // 2. Fertile Window segment (ovulation - 5 to ovulation)
    final fertileStartDay = (ovulationDay - fertileDaysCount + 1).clamp(1, totalDays);
    final fertileStartAngle = startAngleOffset + (fertileStartDay - 1) * anglePerDay;
    final fertileSweep = anglePerDay * fertileDaysCount;
    final fertilePaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      fertileStartAngle,
      fertileSweep,
      false,
      fertilePaint,
    );

    // 3. Ovulation Day marker
    final ovulationAngle = startAngleOffset + (ovulationDay - 1) * anglePerDay;
    final ovulationPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      ovulationAngle,
      anglePerDay,
      false,
      ovulationPaint,
    );

    // 4. Current Day Indicator Bead
    final safeCurrentDay = currentDay.clamp(1, totalDays);
    final currentDayAngle = startAngleOffset + (safeCurrentDay - 0.5) * anglePerDay;
    final beadX = center.dx + radius * cos(currentDayAngle);
    final beadY = center.dy + radius * sin(currentDayAngle);

    final beadShadowPaint = Paint()
      ..color = ClayColors.primary.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(beadX, beadY + 2), 14, beadShadowPaint);

    final beadBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(beadX, beadY), 13, beadBorderPaint);

    final beadFillPaint = Paint()
      ..color = ClayColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(beadX, beadY), 9, beadFillPaint);
  }

  @override
  bool shouldRepaint(covariant _CycleDialPainter oldDelegate) {
    return oldDelegate.cycleLength != cycleLength ||
        oldDelegate.currentDay != currentDay;
  }
}

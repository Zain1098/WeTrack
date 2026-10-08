import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/clay_colors.dart';
import '../../data/services/cycle_calculation_service.dart';

enum DialTimerMode {
  countdownNext, // Time left until next period
  elapsedSinceLast, // Time passed since last period started
}

class ClayCycleDial extends StatefulWidget {
  final CycleCalculationResult calculation;
  final VoidCallback? onTap;

  const ClayCycleDial({
    super.key,
    required this.calculation,
    this.onTap,
  });

  @override
  State<ClayCycleDial> createState() => _ClayCycleDialState();
}

class _ClayCycleDialState extends State<ClayCycleDial>
    with TickerProviderStateMixin {
  late Timer _secTimer;
  late DateTime _now;

  // Mode: Countdown to next period VS elapsed since last period
  DialTimerMode _timerMode = DialTimerMode.countdownNext;

  // Luminous rotating aura
  late final AnimationController _rotationController;

  // Gentle breathing glow
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  // Tactile tap squish
  late final AnimationController _squishController;
  late final Animation<double> _squishScale;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();

    // 1-second live ticker
    _secTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });

    // 12s smooth continuous rotation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    // 2.8s breathing pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.985, end: 1.015).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Tap feedback squish
    _squishController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _squishScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.94).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 60),
    ]).animate(_squishController);
  }

  @override
  void dispose() {
    _secTimer.cancel();
    _rotationController.dispose();
    _pulseController.dispose();
    _squishController.dispose();
    super.dispose();
  }

  void _toggleTimerMode() {
    _squishController.forward(from: 0.0);
    setState(() {
      _timerMode = _timerMode == DialTimerMode.countdownNext
          ? DialTimerMode.elapsedSinceLast
          : DialTimerMode.countdownNext;
    });
  }

  @override
  Widget build(BuildContext context) {
    final calc = widget.calculation;
    final isFertile = calc.currentPhase == CyclePhase.fertileWindow ||
        calc.currentPhase == CyclePhase.ovulationDay;

    // Cycle Start Date (approx: nextEstimatedPeriod minus cycleLength days)
    final cycleStartDate = calc.nextEstimatedPeriod.subtract(
      Duration(days: calc.estimatedCycleLength > 0 ? calc.estimatedCycleLength : 28),
    );

    // Compute live countdown/elapsed differences
    final nextTarget = calc.nextEstimatedPeriod;
    final bool isOverdue = _now.isAfter(nextTarget);

    Duration countdownDiff;
    if (isOverdue) {
      countdownDiff = _now.difference(nextTarget);
    } else {
      countdownDiff = nextTarget.difference(_now);
    }

    Duration elapsedDiff = _now.difference(cycleStartDate);
    if (elapsedDiff.isNegative) {
      elapsedDiff = Duration.zero;
    }

    // Active displayed duration
    final activeDiff = _timerMode == DialTimerMode.countdownNext ? countdownDiff : elapsedDiff;
    final days = activeDiff.inDays;
    final hours = activeDiff.inHours % 24;
    final minutes = activeDiff.inMinutes % 60;
    final seconds = activeDiff.inSeconds % 60;

    final phaseColor = _getPhaseColor(calc.currentPhase);

    return GestureDetector(
      onTap: () {
        _squishController.forward(from: 0.0);
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _pulseScale, _squishScale]),
          builder: (context, _) {
            final scale = _pulseScale.value * _squishScale.value;
            final rotAngle = _rotationController.value * 2 * pi;

            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 310,
                height: 310,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Dynamic Rotating Luminous Aura (Sweep Gradient Halo)
                    Transform.rotate(
                      angle: rotAngle,
                      child: Container(
                        width: 298,
                        height: 298,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              phaseColor.withValues(alpha: 0.0),
                              phaseColor.withValues(alpha: 0.22),
                              ClayColors.primary.withValues(alpha: 0.28),
                              const Color(0xFFFF8DA1).withValues(alpha: 0.15),
                              phaseColor.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.35, 0.70, 0.88, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // 2. Outer Soft Ambient Clay Shadow Base
                    Container(
                      width: 284,
                      height: 284,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: phaseColor.withValues(alpha: 0.18),
                            blurRadius: 36,
                            spreadRadius: 4,
                            offset: const Offset(0, 10),
                          ),
                          const BoxShadow(
                            color: Color(0x102E1065),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            blurRadius: 10,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                    ),

                    // 3. Canvas Painted Segmented Cycle Ring
                    CustomPaint(
                      size: const Size(284, 284),
                      painter: _CycleDialPainter(
                        cycleLength: calc.estimatedCycleLength,
                        currentDay: calc.currentCycleDay,
                        ovulationDay: calc.estimatedCycleLength - 14,
                        fertileDaysCount: 6,
                        pulseValue: _pulseController.value,
                      ),
                    ),

                    // 4. Central Porcelain Floating Hub
                    Container(
                      width: 206,
                      height: 206,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.95),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x122E1065),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: phaseColor.withValues(alpha: 0.10),
                            blurRadius: 12,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Cycle Day & Live Badge Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: phaseColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Day ${calc.currentCycleDay}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: phaseColor,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                // Pulsing Live Dot
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: const Color(0xFFA5D6A7), width: 0.8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'LIVE',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF2E7D32),
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Interactive Mode Pill Button (Toggle between Next and Elapsed)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _toggleTimerMode,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F4FD),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE9DFF7), width: 0.8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _timerMode == DialTimerMode.countdownNext
                                              ? 'Agle Period Tak ⏳'
                                              : 'Pichle Period Se ⌛',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 9.0,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF7E60E4),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(
                                          Icons.sync_rounded,
                                          size: 10,
                                          color: Color(0xFF7E60E4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            // LIVE SECONDS TICKER DISPLAY
                            // [ 12d : 08h : 34m : 19s ]
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF7FD),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: const Color(0xFFECE4F8), width: 1.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildTimeBox('${days}d', 'Din'),
                                    _buildColon(),
                                    _buildTimeBox('${hours.toString().padLeft(2, '0')}h', 'Ghante'),
                                    _buildColon(),
                                    _buildTimeBox('${minutes.toString().padLeft(2, '0')}m', 'Min'),
                                    _buildColon(),
                                    _buildTimeBox('${seconds.toString().padLeft(2, '0')}s', 'Sec', isSec: true),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Status Subtitle (Urdu/English)
                            Text(
                              _timerMode == DialTimerMode.countdownNext
                                  ? (isOverdue ? 'Period Expected Tha' : 'Expected Next Cycle')
                                  : 'Cycle Day $days Ki Progress',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: ClayColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Pregnancy Probability Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isFertile ? const Color(0xFFFFF3CD) : const Color(0xFFF3EEFA),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isFertile ? const Color(0xFFFFD56B) : const Color(0xFFE5DDF5),
                                ),
                              ),
                              child: Text(
                                isFertile
                                    ? '⚡ Hamal Ke Zyada Chance'
                                    : '🌱 Hamal Ke Kam Chance',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.2,
                                  fontWeight: FontWeight.w800,
                                  color: isFertile ? const Color(0xFFB45309) : const Color(0xFF6B5B80),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimeBox(String val, String label, {bool isSec = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          val,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: isSec ? const Color(0xFFF04E78) : const Color(0xFF2E1A47),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildColon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: Text(
        ':',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFB39DDB),
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
  final double pulseValue;

  _CycleDialPainter({
    required this.cycleLength,
    required this.currentDay,
    required this.ovulationDay,
    required this.fertileDaysCount,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
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

    // 4. Current Day Indicator Bead with Pulsing Aura
    final safeCurrentDay = currentDay.clamp(1, totalDays);
    final currentDayAngle = startAngleOffset + (safeCurrentDay - 0.5) * anglePerDay;
    final beadX = center.dx + radius * cos(currentDayAngle);
    final beadY = center.dy + radius * sin(currentDayAngle);

    final pulseRadius = 16.0 + 3.0 * pulseValue;
    final beadPulsePaint = Paint()
      ..color = ClayColors.primary.withValues(alpha: 0.25 * (1.0 - pulseValue * 0.4))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(beadX, beadY + 2), pulseRadius, beadPulsePaint);

    final beadShadowPaint = Paint()
      ..color = ClayColors.primary.withValues(alpha: 0.35)
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
        oldDelegate.currentDay != currentDay ||
        oldDelegate.pulseValue != pulseValue;
  }
}


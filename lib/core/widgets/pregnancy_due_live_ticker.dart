import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/date_helpers.dart';

class PregnancyDueLiveTicker extends StatefulWidget {
  final DateTime dueDate;
  final int currentWeek;

  const PregnancyDueLiveTicker({
    super.key,
    required this.dueDate,
    required this.currentWeek,
  });

  @override
  State<PregnancyDueLiveTicker> createState() => _PregnancyDueLiveTickerState();
}

class _PregnancyDueLiveTickerState extends State<PregnancyDueLiveTicker>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late DateTime _now;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();

    // 1-second live ticker
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });

    // Gentle pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.985, end: 1.015).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diff = widget.dueDate.isAfter(_now)
        ? widget.dueDate.difference(_now)
        : Duration.zero;

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    return AnimatedBuilder(
      animation: _pulseScale,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD4E2), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE91E63).withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              const BoxShadow(
                color: Color(0x0C2E1065),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEF3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('🍼', style: TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delivery (EDD) Countdown',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E1A29),
                        ),
                      ),
                    ],
                  ),

                  // LIVE SYNC BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                        const SizedBox(width: 4),
                        Text(
                          'LIVE SECONDS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2E7D32),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Live Seconds Digital Ticker Readout
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFE0EB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTimerUnit('${days}d', 'Din (Days)'),
                      _buildColon(),
                      _buildTimerUnit('${hours.toString().padLeft(2, '0')}h', 'Ghante (Hrs)'),
                      _buildColon(),
                      _buildTimerUnit('${minutes.toString().padLeft(2, '0')}m', 'Min'),
                      _buildColon(),
                      _buildTimerUnit(
                        '${seconds.toString().padLeft(2, '0')}s',
                        'Sec',
                        isSec: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Wiladat ki mutawaqqa tareekh: ${DateHelpers.formatFriendly(widget.dueDate)} • Baby ke aane me baqi waqt! ✨',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8C6B86),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerUnit(String value, String label, {bool isSec = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isSec ? const Color(0xFFE91E63) : const Color(0xFF1E1A29),
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: isSec ? const Color(0xFFE91E63) : const Color(0xFF9E8EAD),
          ),
        ),
      ],
    );
  }

  Widget _buildColon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(
        ':',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFFB6C1),
        ),
      ),
    );
  }
}

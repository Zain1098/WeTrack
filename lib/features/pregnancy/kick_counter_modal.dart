import 'dart:async';
import 'package:flutter/material.dart';

class KickCounterModal extends StatefulWidget {
  final int initialKicks;
  final ValueChanged<int>? onSaveKicks;

  const KickCounterModal({
    super.key,
    this.initialKicks = 0,
    this.onSaveKicks,
  });

  static Future<void> show(BuildContext context, {int initialKicks = 0, ValueChanged<int>? onSaveKicks}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => KickCounterModal(
        initialKicks: initialKicks,
        onSaveKicks: onSaveKicks,
      ),
    );
  }

  @override
  State<KickCounterModal> createState() => _KickCounterModalState();
}

class _KickCounterModalState extends State<KickCounterModal> {
  late int _count;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isButtonSquished = false;

  @override
  void initState() {
    super.initState();
    _count = widget.initialKicks;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _recordKick() {
    setState(() {
      _count++;
      _isButtonSquished = true;
    });

    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _isButtonSquished = false);
    });

    if (widget.onSaveKicks != null) {
      widget.onSaveKicks!(_count);
    }
  }

  void _reset() {
    setState(() {
      _count = 0;
      _secondsElapsed = 0;
    });
    if (widget.onSaveKicks != null) {
      widget.onSaveKicks!(0);
    }
  }

  String _formatTimer() {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isTargetMet = _count >= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x20E91E63),
            blurRadius: 36,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2D9EC),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('👣', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Baby Kick Counter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2E1A47),
                        ),
                      ),
                      Text(
                        'NHS Standard: 2 Ghante Mein 10 Kicks',
                        style: TextStyle(fontSize: 11, color: Color(0xFF7A6A8D)),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF7A6A8D)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timer & Target Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFD1DC)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Color(0xFFE91E63)),
                    const SizedBox(width: 6),
                    Text(
                      'Session Time: ${_formatTimer()}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF880E4F),
                      ),
                    ),
                  ],
                ),
                Text(
                  '$_count / 10 Target',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Big 3D Squishy Baby Foot Kick Button
          GestureDetector(
            onTap: _recordKick,
            child: AnimatedScale(
              scale: _isButtonSquished ? 0.90 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF80AB), Color(0xFFE91E63), Color(0xFFC2185B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 6,
                      offset: const Offset(-3, -3),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('👣', style: TextStyle(fontSize: 42)),
                      const SizedBox(height: 4),
                      Text(
                        '$_count',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Har Baar Baby Kick Mehsoos Hone Par Tap Karein',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3B60),
            ),
          ),
          const SizedBox(height: 16),

          // Success Banner if 10 kicks reached
          if (isTargetMet) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: const Row(
                children: [
                  Text('🎉', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Alhamdulillah! 10 Kicks Mukammal Ho Gayi Hain. Baby Bilkul Active Aur Healthy Hai! ✨',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action Buttons: Reset & Save/Done
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF7A6A8D)),
                  label: const Text('Reset Counter', style: TextStyle(color: Color(0xFF7A6A8D), fontSize: 12)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Done • Save', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/services/cycle_calculation_service.dart';

class Living3DMascot extends StatefulWidget {
  final CyclePhase? phase;
  final bool isPregnancyMode;
  final int? pregnancyWeek;
  final VoidCallback? onTap;

  const Living3DMascot({
    super.key,
    this.phase,
    this.isPregnancyMode = false,
    this.pregnancyWeek,
    this.onTap,
  });

  @override
  State<Living3DMascot> createState() => _Living3DMascotState();
}

class _Living3DMascotState extends State<Living3DMascot>
    with TickerProviderStateMixin {
  // 1. Continuous Floating & Breathing Animation
  late final AnimationController _floatController;
  late final Animation<double> _floatAnim;
  late final Animation<double> _breatheAnim;

  // 2. Interactive Tap Bounce & Reaction
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnim;

  // 3. Sparkle / Orbit particles animation
  late final AnimationController _sparkleController;

  // 3D Perspective Tilt Coordinates
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  // Speech bubble state
  bool _showSpeechBubble = true;
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();

    // Floating idle loop
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    _breatheAnim = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // Tap bounce spring
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.14).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.14, end: 0.95).chain(CurveTween(curve: Curves.easeInOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 25),
    ]).animate(_bounceController);

    // Particle sparkles orbit
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _bounceController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _onTapMascot() {
    _bounceController.forward(from: 0.0);
    setState(() {
      _showSpeechBubble = true;
      _quoteIndex++;
    });
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  List<String> _getPhaseDialogues() {
    if (widget.isPregnancyMode) {
      return [
        "Hello Mummy! Main aapke pet me bilkul mehfooz hoon 🍼",
        "Aaj baby ki thodi movement feel hui? Kicks count karein ✨",
        "Mummy paani ka glass zaroor piyein aur halki walk karein 🌸",
        "Week ${widget.pregnancyWeek ?? 12} ka safar kitna pyara chal raha hai! 🥑",
      ];
    }

    final p = widget.phase ?? CyclePhase.follicular;
    switch (p) {
      case CyclePhase.menstrual:
        return [
          "Aap aaram karein, main sab sambhal lungi ☕",
          "Garam paani ki botal se sekaayi karein, sukoon milega 🌸",
          "Heavy kaam aaj chorr dein, body rest mangti hai 🩸",
          "Chamomile chai pi kar thoda so jayein ✨",
        ];
      case CyclePhase.follicular:
        return [
          "Aaj aapki energy zabardast hai! Naye plans banayein 🌸",
          "Period khatam ho chuka hai, body fresh mehsoos kar rahi hai ✨",
          "Skin glow kar rahi hai aaj aapki! Keep smiling 😊",
          "Healthy fruits aur salads khane ka behtareen din hai 🥗",
        ];
      case CyclePhase.fertileWindow:
      case CyclePhase.ovulationDay:
        return [
          "⚡ Aaj conceive karne ka best din hai! Glow kar rahi hain aap 🌸",
          "High fertile window chal rahi hai, pregnancy ke zyada chances hain! 🌿",
          "Agar baby plan kar rahe hain to aaj intercourse ke liye best time hai ✨",
          "Body ka temperature halka sa warm reh sakta hai aaj kal 🌡️",
        ];
      case CyclePhase.luteal:
        return [
          "Thoda meetha khana hai ya aaram karna hai? Tension na lein 🍫",
          "Agla period aane me kuch din baqi hain, bag me pads rakh lein 🌙",
          "Chidchida-pan PMS ki wajah se hai, deep breaths lein 😌",
          "Garam doodh ya soup pi kar cozy ho jayein 🛋️",
        ];
    }
  }

  Color _getAuraColor() {
    if (widget.isPregnancyMode) return const Color(0xFFFFB300);
    final p = widget.phase ?? CyclePhase.follicular;
    switch (p) {
      case CyclePhase.menstrual:
        return const Color(0xFFF04E78);
      case CyclePhase.follicular:
        return const Color(0xFF9E8CE7);
      case CyclePhase.fertileWindow:
      case CyclePhase.ovulationDay:
        return const Color(0xFFFFA000);
      case CyclePhase.luteal:
        return const Color(0xFF8E24AA);
    }
  }

  String _getAssetImage() {
    if (widget.isPregnancyMode) {
      return 'UI/baby_3d_milestone.png';
    }
    final p = widget.phase ?? CyclePhase.follicular;
    if (p == CyclePhase.menstrual) {
      return 'UI/download.jpg';
    }
    return 'UI/login_screen_Character-removebg-preview.png';
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = _getAuraColor();
    final quotes = _getPhaseDialogues();
    final currentQuote = quotes[_quoteIndex % quotes.length];
    final assetImage = _getAssetImage();

    return GestureDetector(
      onTap: _onTapMascot,
      onPanUpdate: (details) {
        // Dynamic 3D tilt tracking user finger
        final delta = details.localPosition;
        setState(() {
          _tiltX = (delta.dy - 100) / 100 * -0.15;
          _tiltY = (delta.dx - 100) / 100 * 0.15;
        });
      },
      onPanEnd: (_) {
        // Spring back to neutral
        setState(() {
          _tiltX = 0.0;
          _tiltY = 0.0;
        });
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatAnim, _bounceAnim, _sparkleController]),
        builder: (context, child) {
          final floatOffset = _floatAnim.value;
          final breatheScale = _breatheAnim.value * _bounceAnim.value;
          final sparkleProgress = _sparkleController.value;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015) // Perspective depth
              ..rotateX(_tiltX)
              ..rotateY(_tiltY),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Floating Dynamic Speech Bubble (Roman English)
                if (_showSpeechBubble)
                  Transform.translate(
                    offset: Offset(0, floatOffset * 0.6),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 310),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: auraColor.withValues(alpha: 0.35), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: auraColor.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                          const BoxShadow(
                            color: Color(0x0C2E1065),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: auraColor.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('💬', style: TextStyle(fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentQuote,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2E1A47),
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('✨', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),

                // 2. The 3D Living Character Pedestal & Avatar
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Dynamic 3D Pedestal Base Glow
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            auraColor.withValues(alpha: 0.28),
                            auraColor.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          stops: const [0.4, 0.75, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: auraColor.withValues(alpha: 0.25),
                            blurRadius: 32,
                            spreadRadius: 4,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),

                    // Orbiting Sparkles & Hearts (Living effect)
                    ...List.generate(4, (index) {
                      final angle = (sparkleProgress * 2 * pi) + (index * pi / 2);
                      final orbitRadius = 88.0 + (index % 2 == 0 ? 8 : -8);
                      final x = cos(angle) * orbitRadius;
                      final y = sin(angle) * orbitRadius;
                      final emojis = ['✨', '🌸', '💖', '⭐'];

                      return Positioned(
                        left: 85 + x - 10,
                        top: 85 + y - 10,
                        child: Opacity(
                          opacity: (0.4 + 0.6 * sin(angle)).abs().clamp(0.2, 0.95),
                          child: Text(
                            emojis[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }),

                    // The Breathing & Floating 3D Character
                    Transform.translate(
                      offset: Offset(0, floatOffset),
                      child: Transform.scale(
                        scale: breatheScale,
                        child: Container(
                          width: 145,
                          height: 145,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: auraColor.withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Container(
                              color: const Color(0xFFFFF7FA),
                              child: Image.asset(
                                assetImage,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Center(
                                  child: Icon(
                                    Icons.face_3_rounded,
                                    size: 70,
                                    color: auraColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tap-Me Pulse Badge
                    Positioned(
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1A29),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x28000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('👆 ', style: TextStyle(fontSize: 9)),
                            Text(
                              'Tap Me to Talk',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
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
        },
      ),
    );
  }
}

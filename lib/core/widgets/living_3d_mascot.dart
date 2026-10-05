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
          _tiltX = (delta.dy - 80) / 80 * -0.15;
          _tiltY = (delta.dx - 80) / 80 * 0.15;
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
                // 1. Floating Dynamic Speech Bubble (Cute Roman Urdu/English)
                if (_showSpeechBubble)
                  Transform.translate(
                    offset: Offset(0, floatOffset * 0.6),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      constraints: const BoxConstraints(maxWidth: 290),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: auraColor.withValues(alpha: 0.35), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: auraColor.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                          const BoxShadow(
                            color: Color(0x082E1065),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: auraColor.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('💬', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentQuote,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E1A47),
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('🌸', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),

                // 2. The 3D Living Character Pedestal & Avatar
                SizedBox(
                  height: 150,
                  width: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // 3D Pedestal Base Ground Shadow
                      Positioned(
                        bottom: 6,
                        child: Container(
                          width: 110,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: auraColor.withValues(alpha: 0.25),
                                blurRadius: 16,
                                spreadRadius: 3,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Orbiting Sparkles & Hearts (Living Cute Particle Aura)
                      ...List.generate(4, (index) {
                        final angle = (sparkleProgress * 2 * pi) + (index * pi / 2);
                        final orbitRadiusX = 64.0;
                        final orbitRadiusY = 52.0;
                        final x = cos(angle) * orbitRadiusX;
                        final y = sin(angle) * orbitRadiusY;
                        final emojis = ['✨', '🌸', '💖', '⭐'];

                        return Positioned(
                          left: 78 + x - 8,
                          top: 55 + y - 8,
                          child: Opacity(
                            opacity: (0.4 + 0.6 * sin(angle)).abs().clamp(0.25, 0.95),
                            child: Text(
                              emojis[index],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      }),

                      // The Breathing & Floating 3D Character Figurine
                      Positioned(
                        top: 0,
                        child: Transform.translate(
                          offset: Offset(0, floatOffset),
                          child: Transform.scale(
                            scale: breatheScale,
                            child: SizedBox(
                              width: 125,
                              height: 125,
                              child: Image.asset(
                                assetImage,
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, err, stack) => Center(
                                  child: Icon(
                                    Icons.face_3_rounded,
                                    size: 64,
                                    color: auraColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Tap-Me Friendly Capsule Tag
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: auraColor.withValues(alpha: 0.4), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: auraColor.withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Tap karein ✨',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: auraColor,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

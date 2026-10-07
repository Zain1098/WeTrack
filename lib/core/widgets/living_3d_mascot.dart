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

  // 2. Fetal Heartbeat Pulse Animation (Simulating ~140 bpm fetal rhythm)
  late final AnimationController _heartbeatController;
  late final Animation<double> _heartbeatScale;
  late final Animation<double> _heartbeatGlow;

  // 3. Interactive Tap Bounce & Kick Reaction
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnim;

  // 4. Sparkle / Orbit particles animation
  late final AnimationController _sparkleController;

  // 3D Perspective Tilt Coordinates (Driven via ValueNotifier to avoid 60fps setState rebuilds)
  final ValueNotifier<Offset> _tiltNotifier = ValueNotifier<Offset>(Offset.zero);

  // Speech bubble state
  bool _showSpeechBubble = true;
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();

    // Floating idle loop
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    _breatheAnim = Tween<double>(begin: 0.98, end: 1.025).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // Fetal Heartbeat (approx 140 bpm double pulse: lub-dub)
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat();

    _heartbeatScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 0.98).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.98, end: 1.03).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 40),
    ]).animate(_heartbeatController);

    _heartbeatGlow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 0.65), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.65, end: 0.2), weight: 70),
    ]).animate(_heartbeatController);

    // Tap bounce spring
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.94).chain(CurveTween(curve: Curves.easeInOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 30),
    ]).animate(_bounceController);

    // Particle sparkles orbit
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _heartbeatController.dispose();
    _bounceController.dispose();
    _sparkleController.dispose();
    _tiltNotifier.dispose();
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
    final week = widget.pregnancyWeek ?? 12;
    if (widget.isPregnancyMode) {
      if (week <= 12) {
        return [
          "Hello Mummy! Main aapke pet me bilkul mehfooz aur cozy hoon 🍼",
          "Dhak-dhak! Mera nanha dil tezi se dharak raha hai rozana ❤️",
          "Mummy rozana Folic acid lena na bhoolna, mere dimaagh ke liye zaroori hai 💊",
          "Week $week: Mere nanhe haath aur paon tashkeel pa rahe hain ✨",
          "Mummy paani khoob piyein taake amniotic fluid fresh rahe 💧",
        ];
      } else if (week <= 24) {
        return [
          "Mummy! Main aapki aur papa ki meethi aawazein sun sakta hoon 🌸",
          "Aaj maine halki si kick aur flutter kiya, mehsoos hua? 👣",
          "Main amniotic fluid me tair raha hoon, bohot maza aa raha hai 🌊",
          "Week $week par mere baal aur nanhe naakhun ban rahe hain ✨",
          "Mummy healthy khuraak khayein, mujhe thodi bhook lagti hai 🥑",
        ];
      } else if (week <= 34) {
        return [
          "Mummy main ab aankhein khol sakta hoon aur roshni pehchanta hoon! ✨",
          "Main angootha choos raha hoon aur breathing practice kar raha hoon 🍼",
          "Dhak-dhak! Meri 10 kicks note karein, main bohot active hoon 👣",
          "Mummy aaram karein aur soft music sunein, mujhe sukoon milta hai 🎶",
          "Week $week: Mere gaal ab motay aur rosy ho rahe hain 😊",
        ];
      } else {
        return [
          "MashaAllah Mummy! Hamara safar aakhri marhale par hai 🌸",
          "Main poora tayyar hoon aur aapse milne ke liye beqarar hoon! 🍼",
          "Hospital bag check kar lein mummy, kisi bhi waqt mulakat ho sakti hai 👜",
          "Mujhe har waqt aapke dil ki dharakan sunai deti hai ❤️",
          "Mummy deep breaths lein, Allah sab aasan karega ✨",
        ];
      }
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
    if (widget.isPregnancyMode) {
      final week = widget.pregnancyWeek ?? 12;
      if (week <= 12) return const Color(0xFFFFB300); // Warm amber
      if (week <= 24) return const Color(0xFFF06292); // Sweet pink
      if (week <= 34) return const Color(0xFFBA68C8); // Soft purple
      return const Color(0xFFFF7043); // Coral glow
    }
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
      final week = widget.pregnancyWeek ?? 12;
      if (week <= 12) {
        return 'UI/baby_stage_early.jpg';
      } else if (week <= 24) {
        return 'UI/baby_stage_mid.jpg';
      } else if (week <= 34) {
        return 'UI/baby_stage_late.jpg';
      } else {
        return 'UI/baby_stage_term.jpg';
      }
    }
    return 'UI/login_screen_Character-removebg-preview.png';
  }

  /// Calculates dynamic baby visual growth scale (from 0.85 to 1.18) based on gestation week
  double _getDynamicGrowthScale() {
    if (!widget.isPregnancyMode) return 1.0;
    final week = (widget.pregnancyWeek ?? 12).clamp(4, 40);
    // Smooth linear interpolation from 0.84 (early embryo) to 1.18 (full-term baby)
    return 0.84 + ((week - 4) / 36.0) * 0.34;
  }

  String _getStageTitle() {
    final week = widget.pregnancyWeek ?? 12;
    if (week <= 12) return 'Trimester 1 • Embryo to Fetus 🥑';
    if (week <= 24) return 'Trimester 2 • Active Development 🌸';
    if (week <= 34) return 'Trimester 3 • Chubby & Breathing 👣';
    return 'Full Term • Ready to Meet Mummy! 👶';
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = _getAuraColor();
    final quotes = _getPhaseDialogues();
    final currentQuote = quotes[_quoteIndex % quotes.length];
    final assetImage = _getAssetImage();
    final growthScale = _getDynamicGrowthScale();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: _onTapMascot,
        onPanUpdate: (details) {
          final delta = details.localPosition;
          _tiltNotifier.value = Offset(
            (delta.dy - 90) / 90 * -0.18,
            (delta.dx - 90) / 90 * 0.18,
          );
        },
        onPanEnd: (_) {
          _tiltNotifier.value = Offset.zero;
        },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _floatAnim,
          _breatheAnim,
          _heartbeatController,
          _bounceAnim,
          _sparkleController,
        ]),
        builder: (context, child) {
          final floatOffset = _floatAnim.value;
          final breatheScale = _breatheAnim.value * _bounceAnim.value;
          final heartbeatVal = _heartbeatScale.value;
          final heartbeatGlowVal = _heartbeatGlow.value;
          final sparkleProgress = _sparkleController.value;

          return ValueListenableBuilder<Offset>(
            valueListenable: _tiltNotifier,
            builder: (context, tilt, _) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015) // Deep 3D perspective
                  ..rotateX(tilt.dx)
                  ..rotateY(tilt.dy),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Floating Dynamic Roman Urdu Dialogue Bubble
                if (_showSpeechBubble)
                  Transform.translate(
                    offset: Offset(0, floatOffset * 0.5),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: auraColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: auraColor.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                          const BoxShadow(
                            color: Color(0x0A2E1065),
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
                              color: auraColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              widget.isPregnancyMode ? '🍼' : '💬',
                              style: const TextStyle(fontSize: 12),
                            ),
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
                          Text(
                            widget.isPregnancyMode ? '💖' : '🌸',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 2. The Living 3D Baby/Character Cocoon & Pod
                SizedBox(
                  height: widget.isPregnancyMode ? 190 : 160,
                  width: widget.isPregnancyMode ? 210 : 180,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // 3D Pedestal Base Ground Shadow
                      Positioned(
                        bottom: 4,
                        child: Container(
                          width: 130,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: auraColor.withValues(alpha: 0.30),
                                blurRadius: 18,
                                spreadRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Heartbeat Pulsing Aura Ring (For Pregnancy Mode)
                      if (widget.isPregnancyMode)
                        Positioned(
                          top: 10,
                          child: Transform.scale(
                            scale: heartbeatVal * growthScale,
                            child: Container(
                              width: 165,
                              height: 165,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: auraColor.withValues(alpha: heartbeatGlowVal),
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: auraColor.withValues(alpha: heartbeatGlowVal * 0.4),
                                    blurRadius: 24,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Orbiting Sparkles & Hearts (Living Cute Particle Aura)
                      ...List.generate(5, (index) {
                        final angle = (sparkleProgress * 2 * pi) + (index * 2 * pi / 5);
                        final orbitRadiusX = widget.isPregnancyMode ? 82.0 : 70.0;
                        final orbitRadiusY = widget.isPregnancyMode ? 68.0 : 54.0;
                        final x = cos(angle) * orbitRadiusX;
                        final y = sin(angle) * orbitRadiusY;
                        final emojis = widget.isPregnancyMode
                            ? ['✨', '👣', '💖', '⭐', '🍼']
                            : ['✨', '🌸', '💖', '⭐', '🌿'];

                        return Positioned(
                          left: (widget.isPregnancyMode ? 95 : 82) + x,
                          top: (widget.isPregnancyMode ? 80 : 65) + y,
                          child: Opacity(
                            opacity: (0.45 + 0.55 * sin(angle)).abs().clamp(0.2, 0.95),
                            child: Text(
                              emojis[index],
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      }),

                      // The 3D Living Character / Baby Figurine inside Cocoon
                      Positioned(
                        top: 8,
                        child: Transform.translate(
                          offset: Offset(0, floatOffset),
                          child: Transform.scale(
                            scale: breatheScale * growthScale,
                            child: Container(
                              width: 148,
                              height: 148,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white,
                                    auraColor.withValues(alpha: 0.12),
                                    auraColor.withValues(alpha: 0.28),
                                  ],
                                  stops: const [0.65, 0.88, 1.0],
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: auraColor.withValues(alpha: 0.25),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 6),
                                  ),
                                  const BoxShadow(
                                    color: Color(0x122E1065),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  assetImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Center(
                                    child: Icon(
                                      widget.isPregnancyMode
                                          ? Icons.child_care_rounded
                                          : Icons.face_3_rounded,
                                      size: 72,
                                      color: auraColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Heartbeat BPM Badge (Only in pregnancy mode)
                      if (widget.isPregnancyMode)
                        Positioned(
                          top: 6,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFF80AB), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF4081).withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.scale(
                                  scale: heartbeatVal,
                                  child: const Text('💓', style: TextStyle(fontSize: 10)),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '140 bpm',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFC2185B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Interactive Tap-Me Capsule Tag
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: auraColor.withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: auraColor.withValues(alpha: 0.20),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.isPregnancyMode ? '👣 Kick karein ✨' : 'Tap karein ✨',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: auraColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Stage Subtitle Pill (For Pregnancy Mode)
                if (widget.isPregnancyMode) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: auraColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStageTitle(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: auraColor,
                      ),
                    ),
                  ),
                  ],
                ],
              ),
            );
          },
        );
      },
    ),
  ),
);
  }
}

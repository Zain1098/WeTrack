import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/cycle_calculation_service.dart';

enum CharacterPersona {
  homeCycle,
  homePregnancy,
  calendar,
  insights,
  learn,
  profile,
}

class Living3DCharacter extends StatefulWidget {
  final CharacterPersona persona;
  final CyclePhase? cyclePhase;
  final int? cycleDay;
  final int? pregnancyWeek;
  final String? todayMood;
  final String? todaySymptom;
  final String? customSpeech;
  final double size;
  final bool showSpeechBubble;
  final VoidCallback? onTap;

  const Living3DCharacter({
    super.key,
    this.persona = CharacterPersona.homeCycle,
    this.cyclePhase,
    this.cycleDay,
    this.pregnancyWeek,
    this.todayMood,
    this.todaySymptom,
    this.customSpeech,
    this.size = 140,
    this.showSpeechBubble = true,
    this.onTap,
  });

  @override
  State<Living3DCharacter> createState() => _Living3DCharacterState();
}

class _Living3DCharacterState extends State<Living3DCharacter>
    with TickerProviderStateMixin {
  // 1. Idle Floating & Breathing
  late final AnimationController _idleController;
  late final Animation<double> _floatAnim;
  late final Animation<double> _breatheAnim;
  late final Animation<double> _swayAnim;

  // 2. Natural Eye Blinking (every 3.5s)
  late final AnimationController _blinkController;
  late final Animation<double> _blinkAnim;

  // 3. Interactive Jump / Bounce Reaction
  late final AnimationController _bounceController;
  late final Animation<double> _bounceScale;
  late final Animation<double> _bounceTranslate;

  // 4. Sparkle & Particle Burst on Tap
  late final AnimationController _burstController;

  // 5. Orbiting Celestial Particles
  late final AnimationController _orbitController;

  // 3D Tilt Coordinates
  final ValueNotifier<Offset> _tiltNotifier = ValueNotifier<Offset>(Offset.zero);

  int _dialogueIndex = 0;
  bool _isWinking = false;

  @override
  void initState() {
    super.initState();

    // 1. Idle Floating (2.6s loop)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );

    _breatheAnim = Tween<double>(begin: 0.97, end: 1.035).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );

    _swayAnim = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );

    // 2. Natural Blinking Loop
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    _blinkAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 88),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.08).chain(CurveTween(curve: Curves.easeIn)), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 0.08, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 7),
    ]).animate(_blinkController);

    // 3. Tap Bounce
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.92).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 30),
    ]).animate(_bounceController);

    _bounceTranslate = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -18.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: -18.0, end: 4.0).chain(CurveTween(curve: Curves.easeInQuad)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 25),
    ]).animate(_bounceController);

    // 4. Sparkle Burst
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 5. Continuous Orbiting Glow
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
  }

  @override
  void dispose() {
    _idleController.dispose();
    _blinkController.dispose();
    _bounceController.dispose();
    _burstController.dispose();
    _orbitController.dispose();
    _tiltNotifier.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _dialogueIndex++;
      _isWinking = !_isWinking;
    });
    _bounceController.forward(from: 0.0);
    _burstController.forward(from: 0.0);
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  List<String> _getDialogues() {
    if (widget.customSpeech != null) return [widget.customSpeech!];

    // Reactive Mood & Symptom Dialogue
    if (widget.todayMood != null && widget.todayMood!.isNotEmpty) {
      final m = widget.todayMood!.toLowerCase();
      if (m.contains('sad') || m.contains('udaas') || m.contains('emotional') || m.contains('crying')) {
        return [
          'Dil udaas na karein, hormonal tabdeeli aam hai 🫂❤️',
          'Aap akele nahi hain, WeTrack hamesha sath hai 🌸',
          'Thora waqt apne liye nikalein aur aaram karein ☕',
        ];
      } else if (m.contains('cramp') || m.contains('pain') || m.contains('dard')) {
        return [
          'Dard mehsoos ho to garam patti ya kahwah aaram dega ☕🌸',
          'Deep breaths lein aur comfortable let jayein 🫂',
          'Agar dard shadeed ho to doctor se zaroor mashwara karein 🩺',
        ];
      } else if (m.contains('happy') || m.contains('energetic') || m.contains('khush')) {
        return [
          'Aapki khushi dekh kar dil baagh baagh ho gaya! ✨🎉',
          'Shandar energy! Aaj ka din khubsurat guzre 🌸',
          'Positive vibes ko enjoy karein 💖',
        ];
      }
    }

    if (widget.todaySymptom != null && widget.todaySymptom!.isNotEmpty) {
      final s = widget.todaySymptom!.toLowerCase();
      if (s.contains('nausea') || s.contains('ulti') || s.contains('vomit')) {
        return [
          'Nausea ke liye chota chota paani aur lemon ginger tea lein 🍋💧',
          'Khali pet na rahein, crackers ya dry biscuit chabayen 🍪',
        ];
      } else if (s.contains('headache') || s.contains('sar dard')) {
        return [
          'Room ki lights halki karein aur thanda paani piyein 🌙💧',
          'Screen time kam karein aur aaraam karein 🌸',
        ];
      }
    }

    switch (widget.persona) {
      case CharacterPersona.homeCycle:
        final phase = widget.cyclePhase ?? CyclePhase.follicular;
        if (phase == CyclePhase.menstrual) {
          return [
            'Warm tea piyein aur thora rest karein! ☕❤️',
            'Cramps me heating pad bohat aaram deta hai 🌸',
            'Aap bohat strong hain! Proud of you 🫂',
          ];
        } else if (phase == CyclePhase.fertileWindow || phase == CyclePhase.ovulationDay) {
          return [
            'Fertile window active hai! Mood khushgawar hai 🌸',
            'Aaj energy high hai, gentle walk karein ✨',
            'Folic acid supplement yaad se lein 💊',
          ];
        } else if (phase == CyclePhase.luteal) {
          return [
            'PMS days hain, relax rahein aur pani piyein 🌙',
            'Thakan mehsoos ho to thora aaram karein 🌿',
            'Aapka mood valid hai, sab theek ho jaye ga 💖',
          ];
        }
        return [
          'Assalam-o-Alaikum! Aaj ka din khushgawar ho 🌸',
          'Apni sehat ka khayal rakhna sab se pehle hai ✨',
          'Aaj ka status log karna na bhoolein 📝',
        ];

      case CharacterPersona.homePregnancy:
        final week = widget.pregnancyWeek ?? 12;
        if (week <= 12) {
          return [
            'Hafta $week: Nanna sa embryo maze se barh raha hai 🌱🍼',
            'Folic Acid aur pani lena bilkul na bhoolein 💊💧',
            'Subah ulti ya thakan ho to aaram karein 🌸',
          ];
        } else if (week <= 27) {
          return [
            'Hafta $week: Golden Trimester! Baby active ho raha hai 👣✨',
            'Baby ki movement par tawajjo dein ❤️',
            'Healthy protein aur fruits khana na bhoolein 🍎',
          ];
        } else {
          return [
            'Hafta $week: Baby jald duniya me aane wala hai! 👶🎒',
            'Daily 10 kicks count karein aur delivery bag tayyar rakhein 🦶',
            'Shohar aur doctor ka rabta tayyar rakhein 🩺❤️',
          ];
        }

      case CharacterPersona.calendar:
        return [
          'Cycle Calendar: Dates aur phases check karein 📅',
          'Kisi bhi din par tap kar ke logs dekhein 🌸',
          'Ovulation aur period prediction synced hai ✨',
        ];

      case CharacterPersona.insights:
        return [
          'Health Analytics: Aapka cycle pattern bilkul regular hai 📊',
          'Symptoms trend check karein aur doctor se share karein 🩺',
          'Data local aur secure save hai 🔒',
        ];

      case CharacterPersona.learn:
        return [
          'Tibbi Maloomat: Women\'s health articles parhein 📚',
          'Aham facts aur myths ke baray mein janiye 💡',
          'Healthy lifestyle ke aasan mashwaray 🌿',
        ];

      case CharacterPersona.profile:
        return [
          'Profile Hub: Aapka personal health space 🌸',
          'PIN lock aur partner sharing yahan se customize karein ⚙️',
          'Always here to support you! ❤️',
        ];
    }
  }

  Color _getThemeColor() {
    switch (widget.persona) {
      case CharacterPersona.homeCycle:
        final p = widget.cyclePhase ?? CyclePhase.follicular;
        if (p == CyclePhase.menstrual) return const Color(0xFFF04E78);
        if (p == CyclePhase.fertileWindow || p == CyclePhase.ovulationDay) return const Color(0xFFF59E0B);
        if (p == CyclePhase.luteal) return const Color(0xFF8E24AA);
        return const Color(0xFF7E60E4);
      case CharacterPersona.homePregnancy:
        return const Color(0xFFE91E63);
      case CharacterPersona.calendar:
        return const Color(0xFF7E60E4);
      case CharacterPersona.insights:
        return const Color(0xFF00897B);
      case CharacterPersona.learn:
        return const Color(0xFF3949AB);
      case CharacterPersona.profile:
        return const Color(0xFF7E60E4);
    }
  }

  String _getPersonaEmoji() {
    switch (widget.persona) {
      case CharacterPersona.homeCycle:
        return '🌸';
      case CharacterPersona.homePregnancy:
        return '🍼';
      case CharacterPersona.calendar:
        return '📅';
      case CharacterPersona.insights:
        return '📊';
      case CharacterPersona.learn:
        return '📚';
      case CharacterPersona.profile:
        return '👑';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor();
    final dialogues = _getDialogues();
    final dialogue = dialogues[_dialogueIndex % dialogues.length];
    final size = widget.size;

    return GestureDetector(
      onTap: _handleTap,
      onPanUpdate: (details) {
        final delta = details.localPosition;
        _tiltNotifier.value = Offset(
          (delta.dy - size / 2) / (size / 2) * -0.15,
          (delta.dx - size / 2) / (size / 2) * 0.15,
        );
      },
      onPanEnd: (_) => _tiltNotifier.value = Offset.zero,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _floatAnim,
          _breatheAnim,
          _swayAnim,
          _blinkAnim,
          _bounceScale,
          _bounceTranslate,
          _burstController,
          _orbitController,
        ]),
        builder: (context, _) {
          final floatY = _floatAnim.value + _bounceTranslate.value;
          final currentScale = _breatheAnim.value * _bounceScale.value;
          final swayAngle = _swayAnim.value;
          final orbitProgress = _orbitController.value;
          final burstProgress = _burstController.value;

          return ValueListenableBuilder<Offset>(
            valueListenable: _tiltNotifier,
            builder: (context, tilt, _) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateX(tilt.dx)
                  ..rotateY(tilt.dy)
                  ..rotateZ(swayAngle),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Speech Bubble with Living Floating Motion
                    if (widget.showSpeechBubble)
                      Transform.translate(
                        offset: Offset(0, floatY * 0.4),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          constraints: const BoxConstraints(maxWidth: 290),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: themeColor.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.16),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
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
                                  color: themeColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(_getPersonaEmoji(), style: const TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  dialogue,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2E1A47),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 3D Character Pod
                    SizedBox(
                      width: size + 36,
                      height: size + 20,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Soft Dynamic Ground Shadow
                          Positioned(
                            bottom: 2,
                            child: Container(
                              width: size * 0.75,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: themeColor.withValues(alpha: 0.30),
                                    blurRadius: 18,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 3),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 2. Orbiting Celestial Floating Beads
                          ...List.generate(4, (i) {
                            final angle = (orbitProgress * 2 * pi) + (i * pi / 2);
                            final rx = (size / 2) + 14;
                            final ry = (size / 2) * 0.72;
                            final ox = cos(angle) * rx;
                            final oy = sin(angle) * ry;
                            final emojis = ['✨', '🌸', '💖', '⭐'];

                            return Positioned(
                              left: (size / 2 + 18) + ox - 8,
                              top: (size / 2 + 6) + oy - 8,
                              child: Opacity(
                                opacity: (0.4 + 0.6 * sin(angle)).abs().clamp(0.25, 0.95),
                                child: Text(emojis[i], style: const TextStyle(fontSize: 12)),
                              ),
                            );
                          }),

                          // 3. Tap Starburst Particles
                          if (burstProgress > 0 && burstProgress < 1)
                            ...List.generate(6, (i) {
                              final bAngle = i * (pi / 3);
                              final bDist = burstProgress * 65.0;
                              final bx = cos(bAngle) * bDist;
                              final by = sin(bAngle) * bDist;
                              return Positioned(
                                left: (size / 2 + 18) + bx - 6,
                                top: (size / 2 + 10) + by - 6,
                                child: Opacity(
                                  opacity: (1.0 - burstProgress).clamp(0.0, 1.0),
                                  child: const Text('✨', style: TextStyle(fontSize: 13)),
                                ),
                              );
                            }),

                          // 4. Animated 3D Figurine
                          Positioned(
                            top: 4,
                            child: Transform.translate(
                              offset: Offset(0, floatY),
                              child: Transform.scale(
                                scale: currentScale,
                                child: Container(
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white,
                                        themeColor.withValues(alpha: 0.10),
                                        themeColor.withValues(alpha: 0.28),
                                      ],
                                      stops: const [0.60, 0.85, 1.0],
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: themeColor.withValues(alpha: 0.28),
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
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Base Character Image
                                      ClipOval(
                                        child: Image.asset(
                                          widget.persona == CharacterPersona.homePregnancy
                                              ? 'UI/baby_3d_milestone.png'
                                              : (widget.persona == CharacterPersona.profile
                                                  ? 'UI/Profile page character.png'
                                                  : 'UI/login_screen_Character-removebg-preview.png'),
                                          width: size,
                                          height: size,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => Center(
                                            child: Icon(
                                              widget.persona == CharacterPersona.homePregnancy
                                                  ? Icons.child_care_rounded
                                                  : Icons.face_3_rounded,
                                              size: size * 0.6,
                                              color: themeColor,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Living Blinking Eyelid Overlay
                                      Positioned(
                                        top: size * 0.32,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Left Eye Lid
                                            Transform.scale(
                                              scaleY: _isWinking ? 0.1 : _blinkAnim.value,
                                              child: Container(
                                                width: size * 0.12,
                                                height: size * 0.12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _blinkAnim.value < 0.2
                                                      ? const Color(0xFF4A148C).withValues(alpha: 0.85)
                                                      : Colors.transparent,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: size * 0.24),
                                            // Right Eye Lid
                                            Transform.scale(
                                              scaleY: _blinkAnim.value,
                                              child: Container(
                                                width: size * 0.12,
                                                height: size * 0.12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _blinkAnim.value < 0.2
                                                      ? const Color(0xFF4A148C).withValues(alpha: 0.85)
                                                      : Colors.transparent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Rosy Blushing Cheeks
                                      Positioned(
                                        top: size * 0.46,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: size * 0.16,
                                              height: size * 0.08,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: const Color(0xFFFF4081).withValues(alpha: 0.28),
                                              ),
                                            ),
                                            SizedBox(width: size * 0.38),
                                            Container(
                                              width: size * 0.16,
                                              height: size * 0.08,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: const Color(0xFFFF4081).withValues(alpha: 0.28),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
          );
        },
      ),
    );
  }
}

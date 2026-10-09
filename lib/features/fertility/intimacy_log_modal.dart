import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/fertility_observation.dart';
import '../../data/models/user_profile.dart';
import '../app_providers.dart';

class IntimacyLogModal extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const IntimacyLogModal({super.key, this.initialDate});

  static Future<void> show(BuildContext context, {DateTime? initialDate}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IntimacyLogModal(initialDate: initialDate),
    );
  }

  @override
  ConsumerState<IntimacyLogModal> createState() => _IntimacyLogModalState();
}

class _IntimacyLogModalState extends ConsumerState<IntimacyLogModal> {
  late DateTime _selectedDate;
  IntimacyType _intimacyType = IntimacyType.unprotectedInside;
  IntimacyTiming _intimacyTiming = IntimacyTiming.night;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(fertilityObservationsProvider.notifier).logObservation(
          date: _selectedDate,
          hadIntimacy: true,
          intimacyType: _intimacyType,
          intimacyTiming: _intimacyTiming,
          lhTest: OvulationTestResult.notTested,
          mucus: CervicalMucusType.none,
        );

    ref.invalidate(fertilityObservationsProvider);
    ref.invalidate(cycleCalculationProvider);

    if (mounted) {
      Navigator.pop(context);
      final profile = ref.read(userProfileProvider);
      final isPregnancy = profile.goal == AppGoal.alreadyPregnant;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPregnancy
                ? 'Intimacy record save ho gaya! Baby bilkul mehfooz hai 🍼✨'
                : (_intimacyType == IntimacyType.unprotectedInside
                    ? 'Intercourse record save! Conception window calculate ho gayi 🌸'
                    : 'Intimacy data kamyabi se save ho gaya 🛡️'),
          ),
          backgroundColor: const Color(0xFFE91E63),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final isPregnancy = profile.goal == AppGoal.alreadyPregnant;
    final cycleCalc = ref.watch(cycleCalculationProvider);

    // Calculate if selected date is in fertile window or ovulation
    final isFertile = !isPregnancy &&
        _selectedDate.isAfter(cycleCalc.fertileWindowStart.subtract(const Duration(days: 1))) &&
        _selectedDate.isBefore(cycleCalc.fertileWindowEnd.add(const Duration(days: 1)));

    final isOvulationDay = !isPregnancy &&
        DateHelpers.daysBetween(_selectedDate, cycleCalc.estimatedOvulationDate) == 0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22E91E63),
            blurRadius: 36,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD4E2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEF3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('💖', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Intimacy & Mubashrat Log',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E1A29),
                            ),
                          ),
                          Text(
                            isPregnancy
                                ? 'Hamal ke doran intimacy & safety guidance'
                                : 'Conception chance aur ehtiyat ka hisaab',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF7E768E)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 20, color: Color(0xFFF5EEF8)),

            // Content Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. Date Selector (Allows Today or Previous Date!)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFE0EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Intercourse Ki Tareekh',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E1A29),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateHelpers.daysBetween(_selectedDate, DateTime.now()) == 0
                                  ? 'Aaj ka din'
                                  : '${DateHelpers.daysBetween(_selectedDate, DateTime.now())} din pehle',
                              style: const TextStyle(fontSize: 11, color: Color(0xFFC2185B)),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 90)),
                              lastDate: DateTime.now(),
                              helpText: 'Intercourse ki tareekh chunein',
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE91E63).withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  DateHelpers.formatFriendly(_selectedDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Sperm & Ejaculation Status
                  const Text(
                    'Sperm Sharamgah (Vagina) Me Gaya?',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1A29),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Is maloomat se app conceive hone ke imkanaat ka bilkul sahi andaza lagati hai.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF7E768E)),
                  ),
                  const SizedBox(height: 12),

                  // Option A: Unprotected Sperm Inside
                  _buildIntimacyChoiceCard(
                    type: IntimacyType.unprotectedInside,
                    emoji: '🌸',
                    title: 'Haan, Sperm Andar Release Hua',
                    subtitle: 'Conception attempt (Baby planning ke liye zaroori)',
                    badge: isPregnancy ? 'Regular Intimacy' : (isFertile ? '⚡ Peak Conception Chance' : 'Standard Chance'),
                    badgeColor: const Color(0xFFE91E63),
                    cardColor: const Color(0xFFFFF0F5),
                    borderColor: const Color(0xFFFF80AB),
                  ),
                  const SizedBox(height: 10),

                  // Option B: Protected (Condom)
                  _buildIntimacyChoiceCard(
                    type: IntimacyType.protected,
                    emoji: '🛡️',
                    title: 'Nahi, Condom / Hifazat Use Ki',
                    subtitle: 'Barrier method use kiya gaya (Hamal ke chance na hone ke barabar)',
                    badge: 'Protected',
                    badgeColor: const Color(0xFF0288D1),
                    cardColor: const Color(0xFFE1F5FE),
                    borderColor: const Color(0xFF81D4FA),
                  ),
                  const SizedBox(height: 10),

                  // Option C: Withdrawal (Pull out / Azal)
                  _buildIntimacyChoiceCard(
                    type: IntimacyType.withdrawal,
                    emoji: '🔄',
                    title: 'Bahar Nikal Liya (Azal / Pull-Out)',
                    subtitle: 'Ejaculation bahar hui (Pre-cum ki wajah se partial risk rehta hai)',
                    badge: 'Withdrawal',
                    badgeColor: const Color(0xFF7B1FA2),
                    cardColor: const Color(0xFFF3E5F5),
                    borderColor: const Color(0xFFCE93D8),
                  ),
                  const SizedBox(height: 18),

                  // 3. Time of Day
                  const Text(
                    'Waqt (Time of Day)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1A29),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: IntimacyTiming.values.map((timing) {
                      final isSelected = _intimacyTiming == timing;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _intimacyTiming = timing),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE91E63) : const Color(0xFFFBF8FE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFC2185B) : const Color(0xFFE0D8E8),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE91E63).withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Text(timing.emoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(height: 4),
                                Text(
                                  timing.displayName.split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF4A3B60),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 4. Clinical Feedback & Intelligence Box
                  if (!isPregnancy) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isFertile ? const Color(0xFFFFF9E6) : const Color(0xFFF3F0FA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isFertile ? const Color(0xFFFFD54F) : const Color(0xFFE1D8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(isFertile ? '⚡' : '🌱', style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isFertile
                                      ? (isOvulationDay ? 'Ovulation Day • Peak Conception Window!' : 'Fertile Window Active Hai!')
                                      : 'Mehfooz Din (Safe Window / Low Risk)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isFertile ? const Color(0xFFB45309) : const Color(0xFF4A148C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isFertile
                                ? (_intimacyType == IntimacyType.unprotectedInside
                                    ? 'Aapne fertile window me unprotected sex log kiya hai. Sperm 3 se 5 din tak fallopian tube me anday ka intezar kar sakta hai. Conception ke high chances hain! Agle 14 dino me DPO test timeline observe karein.'
                                    : 'Fertile window active hai, lekin protected intercourse se hamal ke chances bohat kam hain.')
                                : 'Yeh din fertile window se bahar tha. Sperm aur anday ke milne ke imkanaat intehai kam hain.',
                            style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF4A3B60)),
                          ),
                          // Precaution / Emergency contraception guidance if avoided
                          if (isFertile &&
                              _intimacyType == IntimacyType.unprotectedInside &&
                              profile.goal != AppGoal.tryToConceive) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFCDD2)),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('⚠️', style: TextStyle(fontSize: 15)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Ahtiyat: Agar aap pregnancy plan nahi kar rahein, to 72 ghanton ke andar Emergency Contraceptive Pill (ECP) lene ke bare me doctor ya pharmacist se foran mashwara karein.',
                                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFC62828)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    // Pregnancy Mode Safety Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA5D6A7)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('🍼', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Text(
                                'Hamal Me Intimacy • Tibbi Maloomat',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'ACOG & NHS Guidelines: Normal pregnancy me intercourse bilkul mehfooz hota hai. Baby uterus ke andar amniotic fluid aur thick mucus plug me hifazat se hota hai.\n\n⚠️ Agar shadeed dard ya spotting ho to doctor se zaroor rabta karein.',
                            style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF1B5E20)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Save Button
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFF9E8CE7)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE91E63).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Intimacy Record Mehfooz Karein ✨',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntimacyChoiceCard({
    required IntimacyType type,
    required String emoji,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required Color cardColor,
    required Color borderColor,
  }) {
    final isSelected = _intimacyType == type;

    return GestureDetector(
      onTap: () => setState(() => _intimacyType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? cardColor : const Color(0xFFFBF8FE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? borderColor : const Color(0xFFEADFF5),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? const Color(0xFF1E1A29) : const Color(0xFF4A3B60),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF7E768E), height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? borderColor : const Color(0xFFD4C8E0),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/fertility_observation.dart';
import '../app_providers.dart';

class LogFertilityModal extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const LogFertilityModal({super.key, this.initialDate});

  static Future<void> show(BuildContext context, {DateTime? initialDate}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogFertilityModal(initialDate: initialDate),
    );
  }

  @override
  ConsumerState<LogFertilityModal> createState() => _LogFertilityModalState();
}

class _LogFertilityModalState extends ConsumerState<LogFertilityModal> {
  late DateTime _selectedDate;
  OvulationTestResult _lhResult = OvulationTestResult.notTested;
  CervicalMucusType _mucusType = CervicalMucusType.none;
  final TextEditingController _bbtController = TextEditingController();
  IntimacyType _intimacyType = IntimacyType.none;
  IntimacyTiming? _intimacyTiming;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _bbtController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bbtVal = double.tryParse(_bbtController.text.trim());
    await ref.read(fertilityObservationsProvider.notifier).logObservation(
          date: _selectedDate,
          lhTest: _lhResult,
          mucus: _mucusType,
          bbt: bbtVal,
          hadIntimacy: _intimacyType != IntimacyType.none,
          intimacyType: _intimacyType,
          intimacyTiming: _intimacyTiming,
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x208B5CF6),
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
            // Top Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2D9EC),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),

            // Modal Header with Privacy Shield
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFCE4EC),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🌸', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fertility & Intimacy Log',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E1A47),
                            ),
                          ),
                          Text(
                            'Date: ${DateHelpers.formatFriendly(_selectedDate)}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF7A6A8D),
                            ),
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
            ),

            // End-to-End Privacy Shield Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE1BEE7)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded, size: 14, color: Color(0xFF7B1FA2)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Strictly Private Vault: Yeh data 100% encrypted hai aur partner mode me kabhi share nahi hota.',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A148C),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16, color: Color(0xFFF0EBF5)),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Intercourse / Milap 3D Interactive Selector
                    const Row(
                      children: [
                        Text('🔒', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'Intercourse / Intimacy Ki Qisam',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E1A47),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sperm transfer ki accurate information se app conception timing estimate karti hai.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF7A6A8D)),
                    ),
                    const SizedBox(height: 12),

                    // 3D Tactile Cards for Intimacy
                    _build3DIntimacyCard(
                      type: IntimacyType.unprotectedInside,
                      title: 'Conception Attempt (Sperm Inside) 🌸',
                      subtitle: 'Vagina ke andar sperm release hua (Baby planning ke liye zaroori)',
                      badge: '⚡ High Conception Chance',
                      badgeColor: const Color(0xFFE91E63),
                      cardColor: const Color(0xFFFFF0F5),
                      borderColor: const Color(0xFFFF80AB),
                    ),
                    const SizedBox(height: 10),

                    _build3DIntimacyCard(
                      type: IntimacyType.protected,
                      title: 'Protected (Condom / Ehtiyat) 🛡️',
                      subtitle: 'Barrier method use kiya gaya (Conception chance low)',
                      badge: 'Protected',
                      badgeColor: const Color(0xFF0288D1),
                      cardColor: const Color(0xFFE1F5FE),
                      borderColor: const Color(0xFF81D4FA),
                    ),
                    const SizedBox(height: 10),

                    _build3DIntimacyCard(
                      type: IntimacyType.withdrawal,
                      title: 'Withdrawal (Pull-Out) 🔄',
                      subtitle: 'Ejaculation bahar hui (Conception chance partial)',
                      badge: 'Pull-Out',
                      badgeColor: const Color(0xFF7B1FA2),
                      cardColor: const Color(0xFFF3E5F5),
                      borderColor: const Color(0xFFCE93D8),
                    ),
                    const SizedBox(height: 10),

                    _build3DIntimacyCard(
                      type: IntimacyType.none,
                      title: 'Aaj Intercourse Nahi Hua ⚪',
                      subtitle: 'No intimacy logged for this date',
                      badge: 'None',
                      badgeColor: const Color(0xFF757575),
                      cardColor: const Color(0xFFFAFAFA),
                      borderColor: const Color(0xFFE0E0E0),
                    ),
                    const SizedBox(height: 18),

                    // Time of Day (if intimacy occurred)
                    if (_intimacyType != IntimacyType.none) ...[
                      const Text(
                        'Intercourse Ka Waqt (Time of Day)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4A3B60),
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
                                duration: const Duration(milliseconds: 160),
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
                    ],

                    // Section 2: Cervical Mucus (Reham Ki Rutubat)
                    const Row(
                      children: [
                        Text('💧', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'Cervical Fluid (Reham Ki Rutubat)',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E1A47),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Egg-white (stretchy) fluid sperm ko 3–5 din tak zinda rakhne me madad karta hai.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF7A6A8D)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CervicalMucusType.values.map((mucus) {
                        final isSelected = _mucusType == mucus;
                        return ChoiceChip(
                          label: Text(mucus.displayName),
                          selected: isSelected,
                          selectedColor: const Color(0xFFE0F2F1),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF00695C) : const Color(0xFF4A3B60),
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _mucusType = mucus);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Section 3: LH Ovulation Kit
                    const Row(
                      children: [
                        Text('📊', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'Ovulation Strip (LH Test)',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E1A47),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: OvulationTestResult.values.map((res) {
                        final isSelected = _lhResult == res;
                        return ChoiceChip(
                          label: Text(res.displayName),
                          selected: isSelected,
                          selectedColor: res == OvulationTestResult.positive
                              ? const Color(0xFFFFF3E0)
                              : const Color(0xFFEDE7F6),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: res == OvulationTestResult.positive
                                ? const Color(0xFFE65100)
                                : const Color(0xFF4A148C),
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _lhResult = res);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Section 4: Basal Body Temperature
                    const Row(
                      children: [
                        Text('🌡️', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'Basal Body Temperature (BBT)',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E1A47),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bbtController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'e.g. 36.6 °C ya 97.8 °F',
                        hintStyle: const TextStyle(color: Color(0xFFB0A4C0), fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFFBF8FE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE0D8E8)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 26),

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
                              color: const Color(0xFFE91E63).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Fertility & Intimacy Record Save Karein ✨',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DIntimacyCard({
    required IntimacyType type,
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
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? cardColor : const Color(0xFFFAFAFD),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? borderColor : const Color(0xFFEDE7F6),
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
                : const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? badgeColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? badgeColor : const Color(0xFFB0A4C0),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? const Color(0xFF2E1A47) : const Color(0xFF5D4A72),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 9,
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
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7A6A8D),
                        height: 1.3,
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
}

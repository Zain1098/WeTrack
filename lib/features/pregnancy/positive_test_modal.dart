import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_button.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/utils/date_helpers.dart';
import '../app_providers.dart';

class PositivePregnancyTestModal extends ConsumerStatefulWidget {
  const PositivePregnancyTestModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PositivePregnancyTestModal(),
    );
  }

  @override
  ConsumerState<PositivePregnancyTestModal> createState() =>
      _PositivePregnancyTestModalState();
}

class _PositivePregnancyTestModalState
    extends ConsumerState<PositivePregnancyTestModal> {
  // Dating mode: 0 = LMP, 1 = Gestational Weeks directly, 2 = Ultrasound EDD
  int _datingMode = 1; // Default to direct gestational weeks for flexibility
  int _selectedWeek = 24; // Default to 24 weeks as user preferred
  DateTime? _customLmpDate;
  DateTime? _ultrasoundDueDate;

  Future<void> _confirmPregnancy() async {
    final profile = ref.read(userProfileProvider);
    DateTime lmp;

    if (_datingMode == 1) {
      // Direct gestational week
      lmp = DateTime.now().subtract(Duration(days: _selectedWeek * 7));
    } else if (_datingMode == 0) {
      lmp = _customLmpDate ?? profile.lastPeriodDate;
    } else {
      // From Ultrasound due date (EDD - 280 days = LMP)
      final edd = _ultrasoundDueDate ?? DateTime.now().add(const Duration(days: 140));
      lmp = edd.subtract(const Duration(days: 280));
    }

    // Start pregnancy and switch active mode automatically
    await ref.read(userProfileProvider.notifier).switchToPregnancyMode(
      lmp: lmp,
      ultrasoundEdd: (_datingMode == 2) ? _ultrasoundDueDate : null,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFC2185B),
          content: Text(
            'Mubarak! WeTrack ab $_selectedWeek Hafton ke Hamal Mode mein active ho gaya hai 🍼✨',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final lmp = _customLmpDate ?? profile.lastPeriodDate;
    final estimatedEdd = _datingMode == 1
        ? DateTime.now().subtract(Duration(days: _selectedWeek * 7)).add(const Duration(days: 280))
        : lmp.add(const Duration(days: 280));

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with celebration icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCE4EC),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🍼', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hamal (Pregnancy) Confirm Karein',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: ClayColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Bache ki sahi growth aur safar track karein',
                          style: TextStyle(
                            fontSize: 12,
                            color: ClayColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: ClayColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Dating Method Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD2E2)),
                ),
                child: Row(
                  children: [
                    _buildModeTab(1, 'Hafte Chunein\n(Weeks)'),
                    _buildModeTab(0, 'Aakhri Period\n(LMP)'),
                    _buildModeTab(2, 'Doctor EDD\n(Delivery)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_datingMode == 1) ...[
                // Option 1: Direct Gestational Weeks Selector
                ClayCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFFFFF7F9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Maujuda Hamal Ka Hafta:',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC2185B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Hafta $_selectedWeek',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Slider(
                        value: _selectedWeek.toDouble(),
                        min: 4,
                        max: 40,
                        divisions: 36,
                        activeColor: const Color(0xFFC2185B),
                        inactiveColor: const Color(0xFFFFD2E2),
                        label: '$_selectedWeek Weeks',
                        onChanged: (val) => setState(() => _selectedWeek = val.round()),
                      ),
                      // Quick selection chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [4, 8, 12, 16, 20, 24, 28, 32, 36, 40].map((w) {
                            final isSel = _selectedWeek == w;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedWeek = w),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFFC2185B) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSel ? const Color(0xFF880E4F) : const Color(0xFFFFD2E2),
                                  ),
                                ),
                                child: Text(
                                  'W$w',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? Colors.white : const Color(0xFFC2185B),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_datingMode == 0) ...[
                // Option 0: LMP Date Picker
                ClayCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aakhri Mahwari Ka Pehla Din (LMP):',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ClayColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: lmp,
                            firstDate: DateTime.now().subtract(const Duration(days: 300)),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _customLmpDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ClayColors.surfaceTint,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateHelpers.formatFriendly(lmp),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ClayColors.textPrimary),
                              ),
                              const Icon(Icons.edit_calendar, color: ClayColors.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Option 2: Ultrasound EDD
                ClayCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Doctor / Ultrasound Ki Di Hui Delivery Date:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ClayColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _ultrasoundDueDate ?? estimatedEdd,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 300)),
                          );
                          if (picked != null) {
                            setState(() => _ultrasoundDueDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _ultrasoundDueDate != null
                                    ? DateHelpers.formatFriendly(_ultrasoundDueDate!)
                                    : 'Delivery Date Select Karein',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00796B)),
                              ),
                              const Icon(Icons.edit_calendar, color: Color(0xFF00796B), size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Estimated EDD Summary Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mutawaqqa Delivery Tareekh (EDD):',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4A148C)),
                    ),
                    Text(
                      DateHelpers.formatFriendly(_ultrasoundDueDate ?? estimatedEdd),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFC2185B)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Clinical Fact Note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: const Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hamal activate hone ke baad mahwari (period) countdowns band ho jayenge aur sirf delivery & baby health track hogi.',
                        style: TextStyle(fontSize: 11, color: Color(0xFFE65100), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Confirm Button
              ClayButton(
                text: 'Hamal Safar Shuru Karein',
                variant: ClayButtonVariant.primary,
                onPressed: _confirmPregnancy,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab(int mode, String title) {
    final isSel = _datingMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _datingMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSel
                ? [
                    BoxShadow(
                      color: const Color(0xFFC2185B).withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSel ? const Color(0xFFC2185B) : ClayColors.textSecondary,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

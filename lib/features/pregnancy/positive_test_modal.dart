import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_button.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/user_profile.dart';
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
  bool _hasUltrasoundDate = false;
  DateTime? _ultrasoundDueDate;

  Future<void> _confirmPregnancy() async {
    final profile = ref.read(userProfileProvider);
    final lmp = profile.lastPeriodDate;

    // Start pregnancy with LMP
    await ref.read(pregnancyRecordProvider.notifier).startPregnancyFromLmp(lmp);

    // If ultrasound due date provided, override
    if (_hasUltrasoundDate && _ultrasoundDueDate != null) {
      await ref
          .read(pregnancyRecordProvider.notifier)
          .setClinicianDueDate(_ultrasoundDueDate!);
    }

    // Switch active goal to alreadyPregnant
    await ref
        .read(userProfileProvider.notifier)
        .updateGoal(AppGoal.alreadyPregnant);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: ClayColors.mint,
          content: Text(
            'Warmest congratulations! WeTrack is now in Pregnancy Journey Mode.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final lmp = profile.lastPeriodDate;
    final estimatedEdd = lmp.add(const Duration(days: 280));

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
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
                    color: ClayColors.mintContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.child_care_rounded,
                    color: ClayColors.mint,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Positive Test!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: ClayColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Start your pregnancy tracking journey',
                        style: TextStyle(
                          fontSize: 13,
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
            const SizedBox(height: 20),

            // LMP Derivation Card
            ClayCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: ClayColors.canvas,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dating from your logged Last Period (LMP):',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ClayColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateHelpers.formatFriendly(lmp),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  const Divider(height: 20, color: ClayColors.outline),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated Due Date (40 weeks):',
                        style: TextStyle(
                          fontSize: 13,
                          color: ClayColors.textSecondary,
                        ),
                      ),
                      Text(
                        DateHelpers.formatFriendly(estimatedEdd),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ClayColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Clinician Ultrasound Override Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ClayColors.outline),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Have a doctor or ultrasound date?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: ClayColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Clinician dating will override standard LMP estimate.',
                          style: TextStyle(
                            fontSize: 11,
                            color: ClayColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _hasUltrasoundDate,
                    activeTrackColor: ClayColors.primary,
                    onChanged: (val) => setState(() => _hasUltrasoundDate = val),
                  ),
                ],
              ),
            ),

            if (_hasUltrasoundDate) ...[
              const SizedBox(height: 14),
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ClayColors.surfaceTint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _ultrasoundDueDate != null
                            ? DateHelpers.formatFriendly(_ultrasoundDueDate!)
                            : 'Tap to select confirmed Due Date',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ClayColors.primary,
                        ),
                      ),
                      const Icon(Icons.edit_calendar, color: ClayColors.primary, size: 20),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Confirm Button
            ClayButton(
              text: 'Start Pregnancy Journey',
              variant: ClayButtonVariant.primary,
              onPressed: _confirmPregnancy,
            ),
          ],
        ),
      ),
    ),
  );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_button.dart';
import '../../core/widgets/clay_pill.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/period_entry.dart';
import '../app_providers.dart';

class LogPeriodModal extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const LogPeriodModal({super.key, this.initialDate});

  static Future<void> show(BuildContext context, {DateTime? initialDate}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogPeriodModal(initialDate: initialDate),
    );
  }

  @override
  ConsumerState<LogPeriodModal> createState() => _LogPeriodModalState();
}

class _LogPeriodModalState extends ConsumerState<LogPeriodModal> {
  late DateTime _selectedDate;
  FlowIntensity _selectedFlow = FlowIntensity.medium;
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
    await ref.read(periodEntriesProvider.notifier).logPeriodDay(
          date: _selectedDate,
          flow: _selectedFlow,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    // If logging today or recent as period start, update profile lastPeriodDate
    final profile = ref.read(userProfileProvider);
    if (_selectedDate.isAfter(profile.lastPeriodDate)) {
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(lastPeriodDate: _selectedDate);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.water_drop_rounded, color: ClayColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'Log Period Day',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: ClayColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Selector
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 60)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: ClayColors.canvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ClayColors.outline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateHelpers.formatFriendly(_selectedDate),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ClayColors.textPrimary,
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 18, color: ClayColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Flow Intensity
            const Text(
              'Menstrual Flow Intensity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ClayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FlowIntensity.values.map((flow) {
                final isSelected = _selectedFlow == flow;
                return ClayPill(
                  label: flow.displayName,
                  isSelected: isSelected,
                  activeColor: ClayColors.secondary,
                  onTap: () => setState(() => _selectedFlow = flow),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Notes input
            const Text(
              'Notes (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ClayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Add private observations...',
                hintStyle: const TextStyle(color: ClayColors.textTertiary, fontSize: 13),
                filled: true,
                fillColor: ClayColors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),

            // Save CTA
            ClayButton(
              text: 'Save Period Entry',
              variant: ClayButtonVariant.secondary,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

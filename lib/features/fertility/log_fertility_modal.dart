import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_button.dart';
import '../../core/widgets/clay_pill.dart';
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
  bool _hadIntimacy = false;

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
          hadIntimacy: _hadIntimacy,
        );

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
                    Icon(Icons.favorite_rounded, color: ClayColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Log Fertility & Ovulation',
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
            const SizedBox(height: 12),
            Text(
              'Date: ${DateHelpers.formatFriendly(_selectedDate)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ClayColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // LH Ovulation Test
            const Text(
              'Ovulation Predictor Kit (LH Test)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: ClayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: OvulationTestResult.values.map((res) {
                final isSelected = _lhResult == res;
                return ClayPill(
                  label: res.displayName,
                  isSelected: isSelected,
                  activeColor: res == OvulationTestResult.positive
                      ? const Color(0xFFD97706)
                      : ClayColors.primary,
                  onTap: () => setState(() => _lhResult = res),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Cervical Mucus
            const Text(
              'Cervical Mucus Observation',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: ClayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CervicalMucusType.values.map((mucus) {
                final isSelected = _mucusType == mucus;
                return ClayPill(
                  label: mucus.displayName,
                  isSelected: isSelected,
                  activeColor: ClayColors.mint,
                  onTap: () => setState(() => _mucusType = mucus),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Basal Body Temp
            const Text(
              'Basal Body Temperature (BBT)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: ClayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bbtController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'e.g. 36.6 °C or 97.8 °F',
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
            const SizedBox(height: 20),

            // Intimacy Toggle (Private by default)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ClayColors.canvas,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ClayColors.outline),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: ClayColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: ClayColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Intimacy Log',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: ClayColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Private by default. Never shared with partner.',
                          style: TextStyle(
                            fontSize: 11,
                            color: ClayColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _hadIntimacy,
                    activeTrackColor: ClayColors.secondary,
                    onChanged: (val) => setState(() => _hadIntimacy = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save CTA
            ClayButton(
              text: 'Save Observations',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/clay_colors.dart';
import '../constants/medical_constants.dart';

/// Small tactile disclaimer and estimation badge
/// Directly ensures medical clarity and estimation transparency
class DisclaimerBadge extends StatelessWidget {
  final String text;
  final bool isWarning;
  final String? detailedExplanation;

  const DisclaimerBadge({
    super.key,
    required this.text,
    this.isWarning = false,
    this.detailedExplanation,
  });

  void _showDisclaimerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x208B5CF6),
              blurRadius: 30,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isWarning
                        ? ClayColors.errorContainer
                        : ClayColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isWarning ? Icons.warning_amber_rounded : Icons.info_outline,
                    color: isWarning ? ClayColors.error : ClayColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isWarning ? 'Medical Safety Notice' : 'Clinical Estimation Note',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: ClayColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              detailedExplanation ?? MedicalConstants.estimateQualifier,
              style: const TextStyle(
                fontSize: 14,
                color: ClayColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ClayColors.canvas,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                MedicalConstants.standardDisclaimer,
                style: TextStyle(
                  fontSize: 12,
                  color: ClayColors.textTertiary,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ClayColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = isWarning ? ClayColors.errorContainer : ClayColors.surfaceTint;
    final fg = isWarning ? ClayColors.error : ClayColors.primary;

    return GestureDetector(
      onTap: () => _showDisclaimerModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: fg.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 12, color: fg),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

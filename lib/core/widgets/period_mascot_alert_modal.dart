import 'package:flutter/material.dart';
import '../theme/clay_colors.dart';
import 'clay_card.dart';

class PeriodMascotAlertModal extends StatelessWidget {
  const PeriodMascotAlertModal({
    super.key,
    required this.title,
    required this.daysMessage,
    required this.tips,
    this.onLogTap,
  });

  final String title;
  final String daysMessage;
  final List<String> tips;
  final VoidCallback? onLogTap;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String daysMessage,
    required List<String> tips,
    VoidCallback? onLogTap,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PeriodMascotAlertModal(
        title: title,
        daysMessage: daysMessage,
        tips: tips,
        onLogTap: onLogTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClayCard(
        backgroundColor: Colors.white,
        borderRadius: 28,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Character Mascot from download.jpg
            Stack(
              alignment: Alignment.topRight,
              children: [
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFECEF),
                      boxShadow: [
                        BoxShadow(
                          color: ClayColors.secondary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'UI/download.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.calendar_month_rounded,
                          size: 70,
                          color: ClayColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Badge / Days Message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF859B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF859B).withValues(alpha: 0.4)),
              ),
              child: Text(
                daysMessage,
                style: const TextStyle(
                  color: Color(0xFFD81B60),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ClayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Tips list
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: tips.map((tip) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🌸 ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4A4458),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Got it', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                if (onLogTap != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onLogTap!();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF859B),
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: const Color(0xFFFF859B).withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Log Today', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

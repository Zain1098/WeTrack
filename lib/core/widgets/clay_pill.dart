import 'package:flutter/material.dart';
import '../theme/clay_colors.dart';

/// Reusable Pill-shaped chip for symptoms, moods, and toggles
class ClayPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? activeColor;
  final Color? activeTextColor;

  const ClayPill({
    super.key,
    required this.label,
    this.icon,
    this.emoji,
    this.isSelected = false,
    this.onTap,
    this.activeColor,
    this.activeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveBg = activeColor ?? ClayColors.primary;
    final effectiveActiveFg = activeTextColor ?? Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? effectiveActiveBg : Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? effectiveActiveBg
                : ClayColors.outline.withValues(alpha: 0.8),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: effectiveActiveBg.withValues(alpha: 0.35),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: -1,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0x062E1065),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? effectiveActiveFg : ClayColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? effectiveActiveFg : ClayColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

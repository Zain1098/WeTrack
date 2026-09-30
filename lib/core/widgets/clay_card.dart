import 'package:flutter/material.dart';
import '../theme/clay_colors.dart';

/// Reusable Tactile Claymorphic Card
/// Features soft diffuse shadow diffusion and white specular top rim
class ClayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final Border? border;
  final List<BoxShadow>? customShadow;

  const ClayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 28,
    this.backgroundColor = ClayColors.cardSurface,
    this.onTap,
    this.border,
    this.customShadow,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.2,
            ),
        boxShadow: customShadow ??
            [
              const BoxShadow(
                color: Color(0x108B5CF6),
                offset: Offset(0, 10),
                blurRadius: 24,
                spreadRadius: -2,
              ),
              const BoxShadow(
                color: Color(0x062E1065),
                offset: Offset(0, 3),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: cardContent,
      );
    }
    return cardContent;
  }
}

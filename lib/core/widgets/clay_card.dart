import 'package:flutter/material.dart';
import '../theme/clay_colors.dart';

/// Reusable Tactile 3D Claymorphic Card
/// Features soft diffuse shadow diffusion, white specular highlights, and spring press feedback
class ClayCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final Border? border;
  final List<BoxShadow>? customShadow;
  final bool enableBounce;

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
    this.enableBounce = true,
  });

  @override
  State<ClayCard> createState() => _ClayCardState();
}

class _ClayCardState extends State<ClayCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasTap = widget.onTap != null;

    final defaultShadows = _isPressed
        ? [
            const BoxShadow(
              color: Color(0x0E8B5CF6),
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ]
        : [
            // Soft bottom-right ambient shadow
            const BoxShadow(
              color: Color(0x127C3AED),
              offset: Offset(0, 10),
              blurRadius: 24,
              spreadRadius: -2,
            ),
            // Subtler micro-shadow
            const BoxShadow(
              color: Color(0x082E1065),
              offset: Offset(0, 3),
              blurRadius: 8,
            ),
            // Top-left specular ambient shine
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-3, -3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ];

    final cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.border ??
            Border.all(
              color: Colors.white.withValues(alpha: 0.95),
              width: 1.5,
            ),
        boxShadow: widget.customShadow ?? defaultShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: widget.child,
      ),
    );

    if (hasTap && widget.enableBounce) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap!();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: cardContent,
        ),
      );
    } else if (hasTap) {
      return GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

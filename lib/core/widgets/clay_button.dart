import 'package:flutter/material.dart';
import '../theme/clay_colors.dart';

enum ClayButtonVariant { primary, secondary, subtle, outline }

/// Extruded Pill-Shaped Clay CTA Button
class ClayButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ClayButtonVariant variant;
  final double height;
  final double? width;
  final bool isLoading;

  const ClayButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.variant = ClayButtonVariant.primary,
    this.height = 54,
    this.width,
    this.isLoading = false,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  final bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow> shadows = [];

    switch (widget.variant) {
      case ClayButtonVariant.primary:
        bg = ClayColors.primary;
        fg = Colors.white;
        shadows = _isPressed
            ? [
                const BoxShadow(
                  color: Color(0x258B5CF6),
                  offset: Offset(0, 3),
                  blurRadius: 8,
                ),
              ]
            : [
                const BoxShadow(
                  color: Color(0x458B5CF6),
                  offset: Offset(0, 10),
                  blurRadius: 22,
                  spreadRadius: -2,
                ),
                const BoxShadow(
                  color: Color(0x206D28D9),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                ),
              ];
        break;

      case ClayButtonVariant.secondary:
        bg = ClayColors.secondary;
        fg = Colors.white;
        shadows = _isPressed
            ? [
                const BoxShadow(
                  color: Color(0x20F472B6),
                  offset: Offset(0, 3),
                  blurRadius: 8,
                ),
              ]
            : [
                const BoxShadow(
                  color: Color(0x40F472B6),
                  offset: Offset(0, 8),
                  blurRadius: 20,
                  spreadRadius: -2,
                ),
              ];
        break;

      case ClayButtonVariant.subtle:
        bg = ClayColors.surfaceTint;
        fg = ClayColors.primary;
        shadows = [
          const BoxShadow(
            color: Color(0x0E8B5CF6),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ];
        break;

      case ClayButtonVariant.outline:
        bg = Colors.white;
        fg = ClayColors.textPrimary;
        border = Border.all(color: ClayColors.outline, width: 1.5);
        shadows = [
          const BoxShadow(
            color: Color(0x082E1065),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ];
        break;
    }

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: isEnabled ? bg : bg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(9999),
        border: border ??
            Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.2,
            ),
        boxShadow: isEnabled ? shadows : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(9999),
          onTap: widget.onPressed,
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: fg, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

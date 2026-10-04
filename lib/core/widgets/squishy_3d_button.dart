import 'package:flutter/material.dart';

class Squishy3DButton extends StatefulWidget {
  final String emoji;
  final String label;
  final Color primaryColor;
  final bool isSelected;
  final VoidCallback onTap;

  const Squishy3DButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.primaryColor,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<Squishy3DButton> createState() => _Squishy3DButtonState();
}

class _Squishy3DButtonState extends State<Squishy3DButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.primaryColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : (widget.isSelected ? 1.05 : 1.0),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(color, Colors.white, 0.28)!,
                    color,
                    Color.lerp(color, Colors.black, 0.15)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: widget.isSelected ? 0.9 : 0.4),
                  width: widget.isSelected ? 2.5 : 1.5,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 14,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                        const BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Specular Gloss Highlight at Top-Left
                  Positioned(
                    top: 4,
                    left: 6,
                    child: Container(
                      width: 22,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Center 3D Emoji
                  Center(
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),

                  // Selected Check Dot
                  if (widget.isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_rounded, size: 10, color: color),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: widget.isSelected ? FontWeight.w900 : FontWeight.w700,
                color: widget.isSelected ? color : const Color(0xFF5D4A72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

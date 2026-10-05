import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_strings.dart';
import '../localization/language_provider.dart';

class ClayLanguageToggle extends ConsumerWidget {
  final bool isCompact;

  const ClayLanguageToggle({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final isRomanUrdu = currentLang == AppLanguage.romanUrdu;

    if (isCompact) {
      return GestureDetector(
        onTap: () => ref.read(languageProvider.notifier).toggleLanguage(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D9EC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C8B5CF6),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isRomanUrdu ? '🌸 Roman' : '🇬🇧 EN',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFC2185B),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.swap_horiz_rounded, size: 14, color: Color(0xFF9E8CE7)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDF8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2D9EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x082E1065),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(
            label: '🌸 Roman Urdu',
            isSelected: isRomanUrdu,
            onTap: () => ref.read(languageProvider.notifier).setLanguage(AppLanguage.romanUrdu),
          ),
          _buildSegment(
            label: '🇬🇧 English',
            isSelected: !isRomanUrdu,
            onTap: () => ref.read(languageProvider.notifier).setLanguage(AppLanguage.english),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x18E91E63),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF7A6A8D),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/date_helpers.dart';
import '../cycle/log_period_modal.dart';
import '../cycle/log_symptoms_modal.dart';
import '../fertility/intimacy_log_modal.dart';

class PastDateLogModal extends ConsumerStatefulWidget {
  const PastDateLogModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PastDateLogModal(),
    );
  }

  @override
  ConsumerState<PastDateLogModal> createState() => _PastDateLogModalState();
}

class _PastDateLogModalState extends ConsumerState<PastDateLogModal> {
  late DateTime _selectedPastDate;

  @override
  void initState() {
    super.initState();
    // Default to yesterday
    _selectedPastDate = DateTime.now().subtract(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    final daysAgo = DateHelpers.daysBetween(_selectedPastDate, DateTime.now());

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x227E60E4),
            blurRadius: 36,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2D9EC),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EEFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('📅', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pichli Tareekh Ka Data',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E1A29),
                          ),
                        ),
                        const Text(
                          'Guzre hue din ka chhoota hua record darj karein',
                          style: TextStyle(fontSize: 11, color: Color(0xFF7E768E)),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFF5EEF8)),

            // Date Quick Switcher Buttons
            const Text(
              'Tareekh Chunein (Select Date)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E1A29)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Yesterday
                Expanded(
                  child: _buildQuickDayBtn(
                    label: 'Kal (Yesterday)',
                    daysBack: 1,
                    isSelected: daysAgo == 1,
                  ),
                ),
                const SizedBox(width: 8),
                // 2 days ago
                Expanded(
                  child: _buildQuickDayBtn(
                    label: 'Parso (2 Days Ago)',
                    daysBack: 2,
                    isSelected: daysAgo == 2,
                  ),
                ),
                const SizedBox(width: 8),
                // Custom Calendar Picker
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedPastDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now(),
                      helpText: 'Guzra hua din chunein',
                    );
                    if (picked != null) {
                      setState(() => _selectedPastDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: daysAgo > 2 ? const Color(0xFF7E60E4) : const Color(0xFFF7F4FD),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE9DFF7)),
                    ),
                    child: Icon(
                      Icons.edit_calendar_rounded,
                      size: 18,
                      color: daysAgo > 2 ? Colors.white : const Color(0xFF7E60E4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Active Date Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFECE4F8)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF7E60E4), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Selected: ${DateHelpers.formatFriendly(_selectedPastDate)} ($daysAgo din pehle)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4A148C)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Aap is din ka kya data log karna chahti hain?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E1A29)),
            ),
            const SizedBox(height: 12),

            // 1. Mahwari / Period Bleeding
            _buildLogOptionTile(
              icon: '🩸',
              title: 'Mahwari (Period Bleeding)',
              subtitle: 'Khoon ka bahaav (Light / Medium / Heavy flow) log karein',
              color: const Color(0xFFF04E78),
              bgColor: const Color(0xFFFFEEF3),
              onTap: () {
                Navigator.pop(context);
                LogPeriodModal.show(context, initialDate: _selectedPastDate);
              },
            ),
            const SizedBox(height: 10),

            // 2. Intimacy & Mubashrat (Sex)
            _buildLogOptionTile(
              icon: '💖',
              title: 'Intimacy & Mubashrat (Sex)',
              subtitle: 'Intercourse, sperm inside / protected status record karein',
              color: const Color(0xFFE91E63),
              bgColor: const Color(0xFFFFF0F5),
              onTap: () {
                Navigator.pop(context);
                IntimacyLogModal.show(context, initialDate: _selectedPastDate);
              },
            ),
            const SizedBox(height: 10),

            // 3. Dard / Symptoms / Mood
            _buildLogOptionTile(
              icon: '🩹',
              title: 'Dard, Cramps & Mood',
              subtitle: 'Pet dard, thakan, sir dard ya mood swings log karein',
              color: const Color(0xFF8E24AA),
              bgColor: const Color(0xFFF9F0FC),
              onTap: () {
                Navigator.pop(context);
                LogSymptomsModal.show(context, initialDate: _selectedPastDate);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDayBtn({
    required String label,
    required int daysBack,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPastDate = DateTime.now().subtract(Duration(days: daysBack));
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7E60E4) : const Color(0xFFFBF8FE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF6B4FD0) : const Color(0xFFEADFF5),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7E60E4).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF4A3B60),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogOptionTile({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1A29),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF7E768E)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

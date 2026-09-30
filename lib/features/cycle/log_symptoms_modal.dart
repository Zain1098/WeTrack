import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_button.dart';
import '../../core/widgets/clay_pill.dart';
import '../../core/utils/date_helpers.dart';
import '../app_providers.dart';

class LogSymptomsModal extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const LogSymptomsModal({super.key, this.initialDate});

  static Future<void> show(BuildContext context, {DateTime? initialDate}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogSymptomsModal(initialDate: initialDate),
    );
  }

  @override
  ConsumerState<LogSymptomsModal> createState() => _LogSymptomsModalState();
}

class _LogSymptomsModalState extends ConsumerState<LogSymptomsModal> {
  late DateTime _selectedDate;
  final Set<String> _selectedSymptoms = {};
  final Set<String> _selectedMoods = {};
  final TextEditingController _notesController = TextEditingController();

  static const List<String> _symptomList = [
    'Cramps',
    'Bloating',
    'Headache',
    'Tender Breasts',
    'Fatigue',
    'Lower Back Pain',
    'Acne',
    'Nausea',
    'Cravings',
    'Insomnia',
  ];

  static const List<Map<String, String>> _moodList = [
    {'label': 'Happy', 'emoji': '😊'},
    {'label': 'Calm', 'emoji': '🌿'},
    {'label': 'Sensitive', 'emoji': '🥺'},
    {'label': 'Anxious', 'emoji': '😰'},
    {'label': 'Energetic', 'emoji': '⚡'},
    {'label': 'Irritable', 'emoji': '😤'},
    {'label': 'Exhausted', 'emoji': '😴'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(symptomEntriesProvider.notifier).logSymptoms(
          date: _selectedDate,
          symptoms: _selectedSymptoms.toList(),
          moods: _selectedMoods.toList(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
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
                    Icon(Icons.healing_rounded, color: ClayColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Log Symptoms & Mood',
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

            // Date Tag
            Text(
              'Date: ${DateHelpers.formatFriendly(_selectedDate)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ClayColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),

            // Moods Section
            const Text(
              'How are you feeling today?',
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
              children: _moodList.map((m) {
                final label = m['label']!;
                final emoji = m['emoji']!;
                final isSelected = _selectedMoods.contains(label);
                return ClayPill(
                  label: label,
                  emoji: emoji,
                  isSelected: isSelected,
                  activeColor: ClayColors.primary,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedMoods.remove(label);
                      } else {
                        _selectedMoods.add(label);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Physical Symptoms Section
            const Text(
              'Physical Symptoms',
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
              children: _symptomList.map((s) {
                final isSelected = _selectedSymptoms.contains(s);
                return ClayPill(
                  label: s,
                  isSelected: isSelected,
                  activeColor: ClayColors.secondary,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSymptoms.remove(s);
                      } else {
                        _selectedSymptoms.add(s);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Notes
            const Text(
              'Private Journal Note',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: ClayColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Any extra observations...',
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
            const SizedBox(height: 24),

            // Save CTA
            ClayButton(
              text: 'Save Daily Log',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

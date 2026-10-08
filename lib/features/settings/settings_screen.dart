import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/constants/medical_constants.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_profile.dart';
import '../app_providers.dart';
import '../profile/profile_screen.dart';
import '../../core/localization/language_provider.dart';
import '../../core/widgets/clay_language_toggle.dart';
import '../auth/login_screen.dart';
import '../partner/partner_hub_modal.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showPinDialog(BuildContext context, String? currentPin) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(currentPin == null ? 'Set Up 4-Digit PIN' : 'Change PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your PIN protects your reproductive and health logs whenever the app is reopened.',
              style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: ClayColors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (currentPin != null)
            TextButton(
              onPressed: () async {
                await ref.read(userProfileProvider.notifier).setPin(null);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Disable PIN', style: TextStyle(color: ClayColors.error)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ClayColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final pin = pinController.text.trim();
              if (pin.length == 4) {
                await ref.read(userProfileProvider.notifier).setPin(pin);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  void _showPartnerModal(BuildContext context) {
    PartnerHubModal.show(context, initialTab: 1);
  }

  void _exportData(BuildContext context) {
    final repo = ref.read(localStorageRepositoryProvider);
    final data = repo.exportAllData();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Export My Data (JSON)'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonStr,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ClayColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data exported successfully!')),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showCycleSettingsModal(BuildContext context, UserProfile profile) {
    int cycleLen = profile.usualCycleLength > 0 ? profile.usualCycleLength : 28;
    int periodLen = profile.usualPeriodDuration > 0 ? profile.usualPeriodDuration : 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.water_drop_rounded, color: Color(0xFF7E60E4), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cycle & Period Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: ClayColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Mahwari aur cycle ke din set karein',
                            style: TextStyle(fontSize: 11.5, color: ClayColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 1. Average Cycle Length
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEDE7F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Average Cycle Length',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ClayColors.textPrimary),
                            ),
                            Text(
                              'Pichli period se agli period tak ka faasla',
                              style: TextStyle(fontSize: 11, color: ClayColors.textSecondary),
                            ),
                          ],
                        ),
                        // Value Badge with Steppers
                        Row(
                          children: [
                            InkWell(
                              onTap: cycleLen > 21 ? () => setSheetState(() => cycleLen--) : null,
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cycleLen > 21 ? const Color(0xFFEDE7F6) : Colors.grey.shade200,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: cycleLen > 21 ? const Color(0xFF7E60E4) : Colors.grey.shade400,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7E60E4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$cycleLen Din',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: cycleLen < 45 ? () => setSheetState(() => cycleLen++) : null,
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cycleLen < 45 ? const Color(0xFFEDE7F6) : Colors.grey.shade200,
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 18,
                                  color: cycleLen < 45 ? const Color(0xFF7E60E4) : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Interactive Slider
                    SliderTheme(
                      data: SliderTheme.of(ctx).copyWith(
                        activeTrackColor: const Color(0xFF7E60E4),
                        thumbColor: const Color(0xFF7E60E4),
                        inactiveTrackColor: const Color(0xFFD1C4E9),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: cycleLen.clamp(21, 45).toDouble(),
                        min: 21,
                        max: 45,
                        divisions: 24,
                        onChanged: (val) {
                          setSheetState(() => cycleLen = val.round());
                        },
                      ),
                    ),
                    // Quick Preset Chips
                    Wrap(
                      spacing: 6,
                      children: [24, 28, 30, 32, 35].map((val) {
                        final isSel = cycleLen == val;
                        return ChoiceChip(
                          label: Text(
                            val == 28 ? '28 d (Normal)' : '$val d',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel ? Colors.white : ClayColors.textPrimary,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: const Color(0xFF7E60E4),
                          backgroundColor: Colors.white,
                          onSelected: (_) => setSheetState(() => cycleLen = val),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Period Duration (Bleeding Days)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD1DC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bleeding / Period Duration',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ClayColors.textPrimary),
                            ),
                            Text(
                              'Mahwari ka khoon kitne din rehta hai',
                              style: TextStyle(fontSize: 11, color: ClayColors.textSecondary),
                            ),
                          ],
                        ),
                        // Value Badge with Steppers
                        Row(
                          children: [
                            InkWell(
                              onTap: periodLen > 2 ? () => setSheetState(() => periodLen--) : null,
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: periodLen > 2 ? const Color(0xFFFFD1DC) : Colors.grey.shade200,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: periodLen > 2 ? const Color(0xFFF04E78) : Colors.grey.shade400,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF04E78),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$periodLen Din',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: periodLen < 10 ? () => setSheetState(() => periodLen++) : null,
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: periodLen < 10 ? const Color(0xFFFFD1DC) : Colors.grey.shade200,
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 18,
                                  color: periodLen < 10 ? const Color(0xFFF04E78) : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Interactive Slider
                    SliderTheme(
                      data: SliderTheme.of(ctx).copyWith(
                        activeTrackColor: const Color(0xFFF04E78),
                        thumbColor: const Color(0xFFF04E78),
                        inactiveTrackColor: const Color(0xFFFFCDD2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: periodLen.clamp(2, 10).toDouble(),
                        min: 2,
                        max: 10,
                        divisions: 8,
                        onChanged: (val) {
                          setSheetState(() => periodLen = val.round());
                        },
                      ),
                    ),
                    // Quick Preset Chips
                    Wrap(
                      spacing: 6,
                      children: [3, 4, 5, 6, 7].map((val) {
                        final isSel = periodLen == val;
                        return ChoiceChip(
                          label: Text(
                            val == 5 ? '5 d (Normal)' : '$val d',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel ? Colors.white : ClayColors.textPrimary,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: const Color(0xFFF04E78),
                          backgroundColor: Colors.white,
                          onSelected: (_) => setSheetState(() => periodLen = val),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1A29),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 3,
                  ),
                  onPressed: () async {
                    await ref.read(userProfileProvider.notifier).updateProfile(
                          usualCycleLength: cycleLen,
                          usualPeriodDuration: periodLen,
                        );
                    ref.invalidate(cycleHistoryProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cycle settings update ho gayi: $cycleLen din cycle, $periodLen din bleeding ✨'),
                          backgroundColor: const Color(0xFF7E60E4),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save Settings / Mehfooz Karein',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearHealthLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear All Health Logs?'),
        content: const Text(
          'Kya aap waqai tamam period entries, cycle logs, symptoms aur pregnancy records saaf karna chahti hain? Aapka login account aur personal profile mehfooz rahega.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF57C00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              await ref.read(localStorageRepositoryProvider).clearHealthLogsOnly();
              ref.invalidate(periodEntriesProvider);
              ref.invalidate(cycleHistoryProvider);
              ref.invalidate(symptomEntriesProvider);
              ref.invalidate(fertilityObservationsProvider);
              ref.invalidate(pregnancyRecordProvider);
              ref.invalidate(appointmentsProvider);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Tamam cycle aur health logs saaf kar diye gaye hain. 🧹'),
                    backgroundColor: const Color(0xFFF57C00),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            child: const Text('Clear Logs'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: ClayColors.error),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Account & Data?',
                style: TextStyle(color: ClayColors.error, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          '⚠️ Khabardaar: Aapka WeTrack account, cloud database profile, shohar ke sath sharing aur is phone ka tamam personal data mukammal tor par delete ho jayega. Ye amal wapas nahi ho sakta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ClayColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final auth = ref.read(authServiceProvider);
              // 1. Delete from remote Supabase profiles database
              await auth.deleteAccountFromDatabase();
              // 2. Clear local storage on device
              await ref.read(localStorageRepositoryProvider).deleteAllData();
              // 3. Sign out
              await auth.signOut();
              // 4. Invalidate all Riverpod in-memory state
              ref.invalidate(userProfileProvider);
              ref.invalidate(periodEntriesProvider);
              ref.invalidate(cycleHistoryProvider);
              ref.invalidate(symptomEntriesProvider);
              ref.invalidate(fertilityObservationsProvider);
              ref.invalidate(pregnancyRecordProvider);
              ref.invalidate(appointmentsProvider);
              ref.invalidate(partnerPermissionProvider);
              ref.invalidate(notificationPreferencesProvider);

              if (ctx.mounted) {
                Navigator.pop(ctx);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Aapka account aur tamam data delete ho chuka hai.'),
                    backgroundColor: const Color(0xFF1E1A29),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
              }
            },
            child: const Text('Yes, Delete Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final s = ref.watch(appStringsProvider);
    final partner = ref.watch(partnerPermissionProvider);
    final isAllShared = partner.shareIntimacy &&
        partner.shareCycleDates &&
        partner.shareSymptoms &&
        partner.sharePregnancyMilestones &&
        partner.shareAppointments;

    return Scaffold(
      backgroundColor: ClayColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                s.settingsTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: ClayColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),

              // Profile Card
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: ClayCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: ClayColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: ClayColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name.isNotEmpty ? profile.name : 'WeTrack Member',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: ClayColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Active: ${profile.goal.displayName} Mode • Tap to edit',
                              style: const TextStyle(
                                fontSize: 12,
                                color: ClayColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: ClayColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Language & Zubaan Section (3D Clay Card with Interactive Toggle)
              Text(
                s.languageSetting,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ClayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ClayCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE4EC),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE91E63).withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text('🌸', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App Zubaan / Language',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: ClayColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Roman Urdu ya English',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ClayColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const ClayLanguageToggle(isCompact: false),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mahwari Ka Hisaab / Cycle & Period Settings
              const Text(
                'Mahwari Ka Hisaab / Cycle Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ClayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ClayCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.water_drop_rounded, color: Color(0xFF7E60E4), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cycle & Period Duration',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: ClayColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cycle: ${profile.usualCycleLength} din • Bleeding: ${profile.usualPeriodDuration} din',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF7E60E4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7E60E4),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showCycleSettingsModal(context, profile),
                          child: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF9FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEDE7F6)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF7E60E4)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cycle din change karne ke liye "Change" dabayein. Ovulation aur aglay periods foran update ho jayenge.',
                              style: TextStyle(fontSize: 11, color: ClayColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Security & PIN Lock Section
              const Text(
                'Security & App Lock',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ClayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ClayCard(
                padding: const EdgeInsets.all(14),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_rounded, color: ClayColors.primary),
                  title: Text(s.pinLockSetting, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    profile.pinCode != null ? 'PIN is Active' : 'No PIN configured',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: TextButton(
                    onPressed: () => _showPinDialog(context, profile.pinCode),
                    child: Text(
                      profile.pinCode != null ? 'Change' : 'Set PIN',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Shohar / Partner Mode Data Sharing & Privacy Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shohar / Partner Mode & Privacy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showPartnerModal(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.qr_code, size: 14, color: ClayColors.secondary),
                          SizedBox(width: 4),
                          Text('Code', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ClayColors.secondary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClayCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Master All-Sharing Switch Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isAllShared ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAllShared ? const Color(0xFF81C784) : const Color(0xFFFFB74D),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  isAllShared ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
                                  color: isAllShared ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isAllShared ? 'Sab Data Share Ho Raha Hai' : 'Custom Sharing Active',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: isAllShared ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isAllShared
                                            ? 'By default shohar ke sath 100% data shared hai'
                                            : 'Kuch logs private kiye gaye hain',
                                        style: const TextStyle(fontSize: 11, color: ClayColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: isAllShared,
                            activeTrackColor: ClayColors.primary,
                            onChanged: (val) {
                              ref.read(partnerPermissionProvider.notifier).update(
                                    partner.copyWith(
                                      shareIntimacy: val,
                                      shareCycleDates: val,
                                      sharePregnancyMilestones: val,
                                      shareSymptoms: val,
                                      shareAppointments: val,
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Explanation Note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F5FB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💡', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Partner ka matlab shohar ke sath mil kar family plan karna hai. Is liye intimacy / taluq aur cycle ka data by default share hota hai. Agar koi record private rakhna ho to neeche diye gaye switch se band kar sakti hain.',
                              style: TextStyle(fontSize: 11.5, color: ClayColors.textSecondary, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Granular Switches
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('🔒 Intimacy / Intercourse Logs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Conception planning & intimate logs (Default: On)', style: TextStyle(fontSize: 11, color: ClayColors.mint)),
                      value: partner.shareIntimacy,
                      activeTrackColor: ClayColors.primary,
                      onChanged: (val) {
                        ref.read(partnerPermissionProvider.notifier).update(
                              partner.copyWith(shareIntimacy: val),
                            );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('🌸 Shohar Ko Mahwari Dates Dikhana', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Shohar ke sath cycle dates aur fertile window share karein (Privacy toggle)', style: TextStyle(fontSize: 11, color: ClayColors.mint)),
                      value: partner.shareCycleDates,
                      activeTrackColor: ClayColors.primary,
                      onChanged: (val) {
                        ref.read(partnerPermissionProvider.notifier).update(
                              partner.copyWith(shareCycleDates: val),
                            );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('🤰 Hamal & Baby Milestones', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Baby growth aur weekly updates (Default: On)', style: TextStyle(fontSize: 11, color: ClayColors.mint)),
                      value: partner.sharePregnancyMilestones,
                      activeTrackColor: ClayColors.primary,
                      onChanged: (val) {
                        ref.read(partnerPermissionProvider.notifier).update(
                              partner.copyWith(sharePregnancyMilestones: val),
                            );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('🩺 Alamaat, Dard & Moods', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Shohar tabiyat ka khayal rakh sakay (Default: On)', style: TextStyle(fontSize: 11, color: ClayColors.mint)),
                      value: partner.shareSymptoms,
                      activeTrackColor: ClayColors.primary,
                      onChanged: (val) {
                        ref.read(partnerPermissionProvider.notifier).update(
                              partner.copyWith(shareSymptoms: val),
                            );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('📅 Doctor Appointments & Scans', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Checkup dates aur reminders (Default: On)', style: TextStyle(fontSize: 11, color: ClayColors.mint)),
                      value: partner.shareAppointments,
                      activeTrackColor: ClayColors.primary,
                      onChanged: (val) {
                        ref.read(partnerPermissionProvider.notifier).update(
                              partner.copyWith(shareAppointments: val),
                            );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Data & Sovereignty Section
              const Text(
                'Data & Sovereignty',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ClayColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ClayCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.download_rounded, color: ClayColors.mint),
                      title: Text(s.exportDataTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Download your complete local records (JSON)', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _exportData(context),
                    ),
                    const Divider(color: ClayColors.outline),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cleaning_services_rounded, color: Color(0xFFF57C00)),
                      title: const Text('Clear Cycle & Health Logs', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE65100))),
                      subtitle: const Text('Account mehfooz rahega, sirf periods aur health history saf hogi', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _confirmClearHealthLogs(context),
                    ),
                    const Divider(color: ClayColors.outline),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete_forever_rounded, color: ClayColors.error),
                      title: const Text('Delete Account & All Data', style: TextStyle(fontWeight: FontWeight.w700, color: ClayColors.error)),
                      subtitle: const Text('Database aur phone se account hamesha ke liye delete karein', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _confirmDeleteAccount(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Medical Disclaimer Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ClayColors.surfaceTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medical Guidance Notice',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: ClayColors.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      MedicalConstants.standardDisclaimer,
                      style: TextStyle(
                        fontSize: 11,
                        color: ClayColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Account & Log Out
              ClayCard(
                padding: const EdgeInsets.all(14),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout_rounded, color: ClayColors.error),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.w700, color: ClayColors.error),
                  ),
                  subtitle: const Text(
                    'Sign out of your account on this device',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        title: const Text('Log Out?'),
                        content: const Text(
                          'Are you sure you want to sign out? You will need to log back in.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ClayColors.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Log Out'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(authServiceProvider).signOut();
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

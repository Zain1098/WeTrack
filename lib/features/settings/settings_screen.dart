import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/constants/medical_constants.dart';
import '../../data/services/auth_service.dart';
import '../app_providers.dart';
import '../profile/profile_screen.dart';
import '../../core/localization/language_provider.dart';
import '../../core/widgets/clay_language_toggle.dart';

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
    final partner = ref.watch(partnerPermissionProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Partner Mode Sharing',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: ClayColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Share selected milestones with your partner. You have 100% control over which fields are visible.',
                style: TextStyle(fontSize: 13, color: ClayColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Pairing Code Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ClayColors.surfaceTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Secure Partner Code',
                          style: TextStyle(fontSize: 12, color: ClayColors.textSecondary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'WT-849-210',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: ClayColors.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ClayColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied to clipboard!')),
                        );
                      },
                      child: const Text('Share Code'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Master All-Sharing Switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: (partner.shareIntimacy && partner.shareCycleDates && partner.shareSymptoms && partner.sharePregnancyMilestones && partner.shareAppointments)
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (partner.shareIntimacy && partner.shareCycleDates && partner.shareSymptoms && partner.sharePregnancyMilestones && partner.shareAppointments)
                        ? const Color(0xFF81C784)
                        : const Color(0xFFFFB74D),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                (partner.shareIntimacy && partner.shareCycleDates && partner.shareSymptoms && partner.sharePregnancyMilestones && partner.shareAppointments)
                                    ? Icons.check_circle_rounded
                                    : Icons.lock_outline_rounded,
                                color: (partner.shareIntimacy && partner.shareCycleDates && partner.shareSymptoms && partner.sharePregnancyMilestones && partner.shareAppointments)
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFE65100),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Sab Data Share Karein',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: ClayColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Shohar ke sath tamam logs share honge',
                            style: TextStyle(fontSize: 11, color: ClayColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: partner.shareIntimacy && partner.shareCycleDates && partner.shareSymptoms && partner.sharePregnancyMilestones && partner.shareAppointments,
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
                        setSheetState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Permissions Toggles
              const Text(
                'Alag Alag Permissions (Agar koi cheez chupani ho):',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ClayColors.textPrimary),
              ),
              const SizedBox(height: 8),

              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Intimacy / Intercourse Logs', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                subtitle: const Text('Default: On • Shohar ke sath conception planning', style: TextStyle(fontSize: 11, color: ClayColors.mint)),
                value: partner.shareIntimacy,
                activeTrackColor: ClayColors.primary,
                onChanged: (val) {
                  ref.read(partnerPermissionProvider.notifier).update(
                        partner.copyWith(shareIntimacy: val),
                      );
                  setSheetState(() {});
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mahwari & Cycle Dates', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                subtitle: const Text('Default: On • Period start/end aur fertile window', style: TextStyle(fontSize: 11, color: ClayColors.mint)),
                value: partner.shareCycleDates,
                activeTrackColor: ClayColors.primary,
                onChanged: (val) {
                  ref.read(partnerPermissionProvider.notifier).update(
                        partner.copyWith(shareCycleDates: val),
                      );
                  setSheetState(() {});
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hamal & Baby Milestones', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                subtitle: const Text('Default: On • Baby growth aur weekly updates', style: TextStyle(fontSize: 11, color: ClayColors.mint)),
                value: partner.sharePregnancyMilestones,
                activeTrackColor: ClayColors.primary,
                onChanged: (val) {
                  ref.read(partnerPermissionProvider.notifier).update(
                        partner.copyWith(sharePregnancyMilestones: val),
                      );
                  setSheetState(() {});
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alamaat, Dard & Moods', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                subtitle: const Text('Default: On • Shohar khayal rakh sakay', style: TextStyle(fontSize: 11, color: ClayColors.mint)),
                value: partner.shareSymptoms,
                activeTrackColor: ClayColors.primary,
                onChanged: (val) {
                  ref.read(partnerPermissionProvider.notifier).update(
                        partner.copyWith(shareSymptoms: val),
                      );
                  setSheetState(() {});
                },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Doctor Appointments & Ultrasound', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                subtitle: const Text('Default: On • Checkup aur scan ki dates', style: TextStyle(fontSize: 11, color: ClayColors.mint)),
                value: partner.shareAppointments,
                activeTrackColor: ClayColors.primary,
                onChanged: (val) {
                  ref.read(partnerPermissionProvider.notifier).update(
                        partner.copyWith(shareAppointments: val),
                      );
                  setSheetState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
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

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete All Data Permanently?',
          style: TextStyle(color: ClayColors.error, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will permanently wipe out all your periods, cycles, symptoms, pregnancy, and settings from this device. This action cannot be undone.',
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
              await ref.read(localStorageRepositoryProvider).deleteAllData();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been permanently deleted.')),
                );
              }
            },
            child: const Text('Delete Everything'),
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
                      title: const Text('🌸 Mahwari & Cycle Dates', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Period dates aur fertile window (Default: On)', style: TextStyle(fontSize: 11, color: ClayColors.mint)),
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

              // Data Sovereignty Section
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
                      subtitle: const Text('Download your complete local records', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _exportData(context),
                    ),
                    const Divider(color: ClayColors.outline),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete_forever, color: ClayColors.error),
                      title: Text(s.deleteDataTitle, style: const TextStyle(fontWeight: FontWeight.w700, color: ClayColors.error)),
                      subtitle: const Text('Permanently erase everything from device', style: TextStyle(fontSize: 12)),
                      onTap: () => _confirmDeleteAll(context),
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

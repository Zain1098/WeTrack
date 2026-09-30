import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/clay_colors.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/constants/medical_constants.dart';
import '../../data/services/auth_service.dart';
import '../app_providers.dart';
import '../profile/profile_screen.dart';

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

              // Permissions Toggles
              const Text(
                'Field-by-Field Permissions',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Share Cycle Dates & Estimates', style: TextStyle(fontSize: 14)),
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
                title: const Text('Share Pregnancy Milestones', style: TextStyle(fontSize: 14)),
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
                title: const Text('Share Symptoms & Moods', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Default: Off', style: TextStyle(fontSize: 11)),
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
                title: const Text('Share Intimacy Logs', style: TextStyle(fontSize: 14)),
                subtitle: const Text('Default: Strictly Off (Private)', style: TextStyle(fontSize: 11)),
                value: partner.shareIntimacy,
                activeTrackColor: ClayColors.primary,
                onChanged: (val) {
                  ref.read(partnerPermissionProvider.notifier).update(
                        partner.copyWith(shareIntimacy: val),
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

    return Scaffold(
      backgroundColor: ClayColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Settings & Privacy',
                style: TextStyle(
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

              // Security & Privacy Section
              const Text(
                'Privacy & App Lock',
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
                      leading: const Icon(Icons.lock_rounded, color: ClayColors.primary),
                      title: const Text('PIN App Lock', style: TextStyle(fontWeight: FontWeight.w700)),
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
                    const Divider(color: ClayColors.outline),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.people_outline, color: ClayColors.secondary),
                      title: const Text('Partner Sharing', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Manage invite code and permissions', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _showPartnerModal(context),
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
                      title: const Text('Export All Data (JSON)', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text('Download your complete local records', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _exportData(context),
                    ),
                    const Divider(color: ClayColors.outline),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete_forever, color: ClayColors.error),
                      title: const Text('Delete All Data', style: TextStyle(fontWeight: FontWeight.w700, color: ClayColors.error)),
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

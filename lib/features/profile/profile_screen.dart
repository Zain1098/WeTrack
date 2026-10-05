import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/notification_preferences.dart';
import '../../data/services/auth_service.dart';
import '../app_providers.dart';
import '../auth/login_screen.dart';
import '../dictionary/health_dictionary_modal.dart';
import '../insights/insights_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  /// Profile Picture Picker Bottom Sheet (Set, Update, Delete)
  void _showImagePickerSheet(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2DCF0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Profile Picture',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1A29),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Upload your custom photo or use the default WeTrack 3D character.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF7E768E),
                  ),
                ),
                const SizedBox(height: 18),

                // 1. Choose from Gallery
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: Color(0xFF7E60E4)),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: const Text('Select a portrait from your device photo library', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _pickImage(ImageSource.gallery);
                  },
                ),

                // 2. Take Photo
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFFBF4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2E7D32)),
                  ),
                  title: Text(
                    'Take a Photo',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: const Text('Capture a new photo with your camera', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _pickImage(ImageSource.camera);
                  },
                ),

                // 3. Remove / Reset to default character (Only if custom image exists)
                if (profile.profileImagePath != null)
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935)),
                    ),
                    title: Text(
                      'Restore Default Mascot',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFFE53935),
                      ),
                    ),
                    subtitle: const Text('Revert back to the 3D WeTrack avatar character', style: TextStyle(fontSize: 12)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _deleteProfileImage();
                    },
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 88,
      );

      if (pickedFile != null) {
        // Save locally in user profile
        await ref.read(userProfileProvider.notifier).updateProfile(
              profileImagePath: pickedFile.path,
            );

        // Sync with Supabase profiles table
        final user = ref.read(authServiceProvider).currentUser;
        if (user != null) {
          await ref.read(authServiceProvider).syncUserToDatabase(
                userId: user.id,
                email: user.email ?? '',
                avatarUrl: pickedFile.path,
              );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile picture updated successfully! ✨'),
              backgroundColor: const Color(0xFF9E8CE7),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not set photo: $e'),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    await ref.read(userProfileProvider.notifier).updateProfile(
          clearProfileImage: true,
        );

    final user = ref.read(authServiceProvider).currentUser;
    if (user != null) {
      await ref.read(authServiceProvider).syncUserToDatabase(
            userId: user.id,
            email: user.email ?? '',
            avatarUrl: null,
          );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Default 3D mascot restored! 🌸'),
          backgroundColor: const Color(0xFF9E8CE7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  /// Personal Information Dialog
  void _editPersonalInformation(BuildContext context, UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final user = ref.read(authServiceProvider).currentUser;
    final email = user?.email ?? 'user@wetrack.app';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2DCF0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Personal Information',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1A29),
                  ),
                ),
                const SizedBox(height: 18),

                // Name field
                Text(
                  'Full Name',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF6B637C),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    filled: true,
                    fillColor: const Color(0xFFF7F5FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Email field (read-only)
                Text(
                  'Email Address (Verified)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF6B637C),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F0F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        email,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF534C60),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1A29),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final newName = nameController.text.trim();
                      if (newName.isNotEmpty) {
                        await ref.read(userProfileProvider.notifier).updateProfile(name: newName);
                        final auth = ref.read(authServiceProvider);
                        if (auth.currentUser != null) {
                          await auth.syncUserToDatabase(
                            userId: auth.currentUser!.id,
                            email: email,
                            name: newName,
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Cycle Settings Dialog
  void _editCycleSettings(BuildContext context, UserProfile profile) {
    int cycleLen = profile.usualCycleLength;
    int periodLen = profile.usualPeriodDuration;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Cycle & Health Preferences',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Average Cycle Length:',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF7E60E4)),
                        onPressed: cycleLen > 21 ? () => setDialogState(() => cycleLen--) : null,
                      ),
                      Text(
                        '$cycleLen d',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: const Color(0xFF7E60E4),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF7E60E4)),
                        onPressed: cycleLen < 45 ? () => setDialogState(() => cycleLen++) : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Period Duration:',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFF04E78)),
                        onPressed: periodLen > 2 ? () => setDialogState(() => periodLen--) : null,
                      ),
                      Text(
                        '$periodLen d',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: const Color(0xFFF04E78),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFFF04E78)),
                        onPressed: periodLen < 10 ? () => setDialogState(() => periodLen++) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1A29),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                await ref.read(userProfileProvider.notifier).updateProfile(
                      usualCycleLength: cycleLen,
                      usualPeriodDuration: periodLen,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// Security / PIN Dialog
  void _editSecurityPin(BuildContext context, UserProfile profile) {
    final pinController = TextEditingController(text: profile.pinCode ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          profile.pinCode == null ? 'Set 4-Digit Security PIN' : 'Update Security PIN',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your PIN safeguards confidential cycle logs and pregnancy records when the app is reopened.',
              style: TextStyle(fontSize: 13, color: Color(0xFF7E768E)),
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
                fillColor: const Color(0xFFF6F4FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (profile.pinCode != null)
            TextButton(
              onPressed: () async {
                await ref.read(userProfileProvider.notifier).setPin(null);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Disable PIN', style: TextStyle(color: Color(0xFFE53935))),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1A29),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  /// Dynamic Profile Completion Percentage (0 - 100%)
  int _calculateProfileCompletion(UserProfile p) {
    int score = 0;
    if (p.name.trim().isNotEmpty) score += 20;
    if (p.profileImagePath != null && File(p.profileImagePath!).existsSync()) {
      score += 15;
    }
    if (p.age != null && p.age! > 0) score += 15;
    if (p.maritalStatus != null && p.maritalStatus!.isNotEmpty) score += 10;
    if (p.heightCm != null && p.weightKg != null) score += 15;
    if (p.usualCycleLength > 0 && p.usualPeriodDuration > 0) score += 15;
    if (p.pinCode != null && p.pinCode!.isNotEmpty) score += 10;
    return score.clamp(0, 100);
  }

  /// In-Depth Notifications Modal
  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final notifs = ref.watch(notificationPreferencesProvider);

          void updateNotifs(NotificationPreferences updated) {
            ref.read(notificationPreferencesProvider.notifier).update(updated);
          }

          return Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2DCF0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reminders & Alerts 🔔',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E1A29),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ahem cycle dates, fertility aur sehat ke reminders customize karein taake koi zaroori din miss na ho.',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF7E768E)),
                        ),
                        const SizedBox(height: 18),

                        // Section 1: Cycle & Period
                        _buildNotificationCategoryHeader('🌸 Mahwari & Cycle Alerts'),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Period Prediction Alert (2 din pehle)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Cycle shuru hone se pehle tayyari ka notification', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFFF04E78),
                          value: notifs.periodPredictionReminder,
                          onChanged: (val) => updateNotifs(notifs.copyWith(periodPredictionReminder: val)),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Period Late Hone Ka Alert (3 din baad)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Agar period late ho jaye to check karne ki hidayat', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFFF04E78),
                          value: notifs.latePeriodAlert,
                          onChanged: (val) => updateNotifs(notifs.copyWith(latePeriodAlert: val)),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Daily Morning Cycle Advice', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Rozana subah energy aur phase mutabiq tips', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFFF04E78),
                          value: notifs.dailyCycleTip,
                          onChanged: (val) => updateNotifs(notifs.copyWith(dailyCycleTip: val)),
                        ),

                        const SizedBox(height: 14),
                        // Section 2: Fertility & Planning (TTC)
                        _buildNotificationCategoryHeader('🥚 Hamal Koshish (TTC) & Ovulation'),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Fertile Window Alerts', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Bacha theherne ke ahem din shuru hone par alert', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFFF57C00),
                          value: notifs.fertileWindowAlert,
                          onChanged: (val) => updateNotifs(notifs.copyWith(fertileWindowAlert: val)),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Ovulation Peak Day Alert', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Sab se zyada pregnancy chance wala din', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFFF57C00),
                          value: notifs.ovulationPeakAlert,
                          onChanged: (val) => updateNotifs(notifs.copyWith(ovulationPeakAlert: val)),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Pregnancy Test Ka Sahi Din', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Period miss hone ke baad test reminder', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFFF57C00),
                          value: notifs.pregnancyTestReminder,
                          onChanged: (val) => updateNotifs(notifs.copyWith(pregnancyTestReminder: val)),
                        ),

                        const SizedBox(height: 14),
                        // Section 3: Pregnancy Mode
                        _buildNotificationCategoryHeader('🤰 Hamal (Pregnancy) Updates'),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Weekly Baby Development', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Har naye hafte baby ki growth aur size card', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFF00897B),
                          value: notifs.weeklyBabyGrowthAlert,
                          onChanged: (val) => updateNotifs(notifs.copyWith(weeklyBabyGrowthAlert: val)),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Daily Kick Counter Reminder', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Baby ki harkat note karne ka shaam ka waqt', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFF00897B),
                          value: notifs.kickCounterReminder,
                          onChanged: (val) => updateNotifs(notifs.copyWith(kickCounterReminder: val)),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Doctor & Ultrasound Reminders', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Doctor appointment se 1 din pehle reminder', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFF00897B),
                          value: notifs.doctorAppointmentReminder,
                          onChanged: (val) => updateNotifs(notifs.copyWith(doctorAppointmentReminder: val)),
                        ),

                        const SizedBox(height: 14),
                        // Section 4: Daily Health, Vitamins & Water
                        _buildNotificationCategoryHeader('💊 Sehat, Dawayi & Routine'),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Folic Acid / Prenatal Vitamins (${notifs.folicAcidTime})', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Rozana subah dawayi lene ka reminder', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFF7E60E4),
                          value: notifs.folicAcidReminder,
                          onChanged: (val) => updateNotifs(notifs.copyWith(folicAcidReminder: val)),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Water & Hydration Nudges', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Din bhar taza paani peenay ki yaad dahani', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFF7E60E4),
                          value: notifs.waterHydrationReminder,
                          onChanged: (val) => updateNotifs(notifs.copyWith(waterHydrationReminder: val)),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Evening Symptoms & Mood Check-in (${notifs.eveningCheckinTime})', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Shaam ko aaj ki takleef aur mood note karna', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFF7E60E4),
                          value: notifs.eveningCheckinReminder,
                          onChanged: (val) => updateNotifs(notifs.copyWith(eveningCheckinReminder: val)),
                        ),

                        const SizedBox(height: 14),
                        // Section 5: Partner Notifications
                        _buildNotificationCategoryHeader('🧔 Shohar / Partner Alerts'),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Shohar Care & Mood Updates', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: const Text('Aapke mood aur cycle ke mutabiq shohar ko khayal rakhne ki hidayat', style: TextStyle(fontSize: 12)),
                          activeTrackColor: const Color(0xFF3949AB),
                          value: notifs.partnerSyncAlert,
                          onChanged: (val) => updateNotifs(notifs.copyWith(partnerSyncAlert: val)),
                        ),

                        const SizedBox(height: 14),
                        // Section 6: Sound & Vibration
                        _buildNotificationCategoryHeader('🔔 Sound & Vibration'),
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Sound', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                activeTrackColor: const Color(0xFF1E1A29),
                                value: notifs.soundEnabled,
                                onChanged: (val) => updateNotifs(notifs.copyWith(soundEnabled: val)),
                              ),
                            ),
                            Expanded(
                              child: SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Vibration', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                activeTrackColor: const Color(0xFF1E1A29),
                                value: notifs.vibrationEnabled,
                                onChanged: (val) => updateNotifs(notifs.copyWith(vibrationEnabled: val)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Close button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E1A29),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Reminders saved successfully! ✨'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFF9E8CE7),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                            },
                            child: const Text('Save & Close', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF3E364C),
        ),
      ),
    );
  }

  /// Full Partner Sharing & Sync Modal
  void _showPartnerSharingModal(BuildContext context) {
    final codeController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final partner = ref.watch(partnerPermissionProvider);
          final user = ref.read(authServiceProvider).currentUser;
          // Generate an 8-character stable code from user id or default
          final myShareCode = user != null
              ? 'WT-${user.id.substring(0, 3).toUpperCase()}-${user.id.substring(user.id.length - 3).toUpperCase()}'
              : 'WT-849-210';

          final isAllShared = partner.shareCycleDates &&
              partner.shareIntimacy &&
              partner.sharePregnancyMilestones &&
              partner.shareAppointments &&
              partner.shareSymptoms;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.90,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 44,
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2DCF0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEEF3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.favorite_rounded, color: Color(0xFFF04E78), size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Shohar / Partner Sync',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1E1A29),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Shohar ke sath pairing karein taake milap, ovulation aur doctor appointments ka dono ko pata ho. Har privacy control aapke hath mein hai.',
                            style: TextStyle(fontSize: 12.5, color: Color(0xFF7E768E)),
                          ),
                          const SizedBox(height: 16),

                          // Partner Connection Status Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: partner.isConnected
                                    ? [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)]
                                    : [const Color(0xFFFFF0F5), const Color(0xFFFFDAE8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: partner.isConnected ? const Color(0xFFA5D6A7) : const Color(0xFFFFBFD6),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  partner.isConnected ? Icons.check_circle_rounded : Icons.sync_rounded,
                                  color: partner.isConnected ? const Color(0xFF2E7D32) : const Color(0xFFF04E78),
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        partner.isConnected
                                            ? 'Connected: ${partner.partnerName.isNotEmpty ? partner.partnerName : "Shohar"}'
                                            : 'Pairing Ready: Code Share Karein',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: partner.isConnected ? const Color(0xFF1B5E20) : const Color(0xFFC2185B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        partner.isConnected
                                            ? 'Logs shohar ke phone par sync ho rahe hain'
                                            : 'Shohar apne WeTrack par aapka code enter karein',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: partner.isConnected ? const Color(0xFF2E7D32) : const Color(0xFF880E4F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // My Share Code Box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F5FC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFEDE8F6)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Aapka Partner Share Code', style: TextStyle(fontSize: 11, color: Color(0xFF7E768E))),
                                    const SizedBox(height: 3),
                                    Text(
                                      myShareCode,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF7E60E4),
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                  label: const Text('Copy'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7E60E4),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: myShareCode));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Partner Code $myShareCode copied to clipboard! 📋'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: const Color(0xFF7E60E4),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Enter Shohar's Code to Pair
                          if (!partner.isConnected) ...[
                            Text(
                              'Ya Shohar Ka Code Yahan Dalein:',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF3E364C)),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: codeController,
                                    textCapitalization: TextCapitalization.characters,
                                    decoration: InputDecoration(
                                      hintText: 'e.g. WT-924-118',
                                      filled: true,
                                      fillColor: const Color(0xFFF7F5FC),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E1A29),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  ),
                                  onPressed: () {
                                    final entered = codeController.text.trim();
                                    if (entered.isNotEmpty) {
                                      ref.read(partnerPermissionProvider.notifier).update(
                                            partner.copyWith(
                                              isConnected: true,
                                              partnerCode: entered,
                                              partnerName: 'Shohar (Ahmed)',
                                            ),
                                          );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Shohar connected successfully! 🌸'),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Color(0xFF2E7D32),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Connect'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Master All-Sharing Switch
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isAllShared ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isAllShared ? const Color(0xFF81C784) : const Color(0xFFFFB74D),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sab Data Share Karein (Master)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                        color: isAllShared ? const Color(0xFF1B5E20) : const Color(0xFFE65100),
                                      ),
                                    ),
                                    const Text('Shohar ko tamam zaroori logs dikhein ge', style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                                Switch.adaptive(
                                  value: isAllShared,
                                  activeTrackColor: const Color(0xFF2E7D32),
                                  onChanged: (val) {
                                    ref.read(partnerPermissionProvider.notifier).update(
                                          partner.copyWith(
                                            shareCycleDates: val,
                                            shareIntimacy: val,
                                            sharePregnancyMilestones: val,
                                            shareAppointments: val,
                                            shareSymptoms: val,
                                          ),
                                        );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Granular Permissions
                          Text(
                            'Alag Alag Permissions (Custom Control):',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13.5, color: const Color(0xFF1E1A29)),
                          ),
                          const SizedBox(height: 6),

                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('🌸 Mahwari & Aglay Period Ki Dates', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                            subtitle: const Text('Expected period aur cycle length share hogi', style: TextStyle(fontSize: 11.5)),
                            activeTrackColor: const Color(0xFFF04E78),
                            value: partner.shareCycleDates,
                            onChanged: (val) => ref.read(partnerPermissionProvider.notifier).update(partner.copyWith(shareCycleDates: val)),
                          ),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('💑 Milap & Conception (TTC) Logs', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                            subtitle: const Text('Fertile window aur milap taake bacha thehernay ka pata chale', style: TextStyle(fontSize: 11.5)),
                            activeTrackColor: const Color(0xFFF04E78),
                            value: partner.shareIntimacy,
                            onChanged: (val) => ref.read(partnerPermissionProvider.notifier).update(partner.copyWith(shareIntimacy: val)),
                          ),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('🤰 Pregnancy Milestones & Baby Growth', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                            subtitle: const Text('Baby size aur hafton ki updates shohar ko dikhein', style: TextStyle(fontSize: 11.5)),
                            activeTrackColor: const Color(0xFFF04E78),
                            value: partner.sharePregnancyMilestones,
                            onChanged: (val) => ref.read(partnerPermissionProvider.notifier).update(partner.copyWith(sharePregnancyMilestones: val)),
                          ),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('🩺 Doctor Appointments & Scans', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                            subtitle: const Text('Doctor checkup aur ultrasound ki dates', style: TextStyle(fontSize: 11.5)),
                            activeTrackColor: const Color(0xFFF04E78),
                            value: partner.shareAppointments,
                            onChanged: (val) => ref.read(partnerPermissionProvider.notifier).update(partner.copyWith(shareAppointments: val)),
                          ),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('🌿 Symptoms & Mood Updates', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                            subtitle: const Text('Takleef, dard aur mood updates', style: TextStyle(fontSize: 11.5)),
                            activeTrackColor: const Color(0xFFF04E78),
                            value: partner.shareSymptoms,
                            onChanged: (val) => ref.read(partnerPermissionProvider.notifier).update(partner.copyWith(shareSymptoms: val)),
                          ),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('🔒 Niji Diary / Private Notes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                            subtitle: const Text('Aapki personal diary (by default band hoti hai)', style: TextStyle(fontSize: 11.5)),
                            activeTrackColor: const Color(0xFFF04E78),
                            value: partner.sharePersonalNotes,
                            onChanged: (val) => ref.read(partnerPermissionProvider.notifier).update(partner.copyWith(sharePersonalNotes: val)),
                          ),
                          const SizedBox(height: 14),

                          // Disconnect button if connected
                          if (partner.isConnected)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.link_off_rounded, color: Color(0xFFE53935)),
                                label: const Text('Disconnect Partner', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w700)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFFFCDD2)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () {
                                  ref.read(partnerPermissionProvider.notifier).update(
                                        partner.copyWith(
                                          isConnected: false,
                                          partnerCode: '',
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Shohar disconnected.'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Data Privacy, Erase & Account Delete Modal
  void _showDataPrivacyAndEraseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2DCF0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shield_outlined, color: Color(0xFFE53935), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Data Privacy & Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E1A29),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aapka data 100% confidential aur aapke ikhtiyar mein hai. Aap jab chahein logs saaf kar sakti hain ya account hamesha ke liye delete kar sakti hain.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF7E768E)),
                ),
                const SizedBox(height: 18),

                // 1. Export Data Summary
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.download_rounded, color: Color(0xFF7E60E4)),
                  ),
                  title: Text(
                    'Export Health Data (JSON Summary)',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  subtitle: const Text('Apna tamam medical aur cycle record copy karein', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    final data = ref.read(localStorageRepositoryProvider).exportAllData();
                    Clipboard.setData(ClipboardData(text: jsonEncode(data)));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Tamam health data clipboard par copy ho gaya! 📋'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF7E60E4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),

                // 2. Clear Health & Cycle Logs Only (Keep Account)
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cleaning_services_rounded, color: Color(0xFFF57C00)),
                  ),
                  title: Text(
                    'Clear Cycle & Health Logs Only',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                  subtitle: const Text('Account baqi rahega, sirf pichlay periods aur logs saf honge', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        title: const Text('Clear All Health Logs?'),
                        content: const Text(
                          'Kya aap waqai tamam period, cycle, symptoms aur pregnancy records saaf karna chahti hain? Aapka login aur profile mehfooz rahega.',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF57C00),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(dCtx, true),
                            child: const Text('Haan, Clear Karein'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await ref.read(localStorageRepositoryProvider).clearHealthLogsOnly();
                      ref.invalidate(periodEntriesProvider);
                      ref.invalidate(cycleHistoryProvider);
                      ref.invalidate(symptomEntriesProvider);
                      ref.invalidate(fertilityObservationsProvider);
                      ref.invalidate(pregnancyRecordProvider);
                      ref.invalidate(appointmentsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Cycle aur health logs saf kar diye gaye hain. 🧹'),
                            backgroundColor: const Color(0xFFF57C00),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 6),

                // 3. Delete Account & Permanent Erase
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_forever_rounded, color: Color(0xFFE53935)),
                  ),
                  title: Text(
                    'Delete Account & Erase All Data',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                  subtitle: const Text('Account, profile, cloud sync aur tamam records hamesha ke liye mita dein', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        title: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935), size: 28),
                            const SizedBox(width: 8),
                            const Expanded(child: Text('Delete Account Permanently?')),
                          ],
                        ),
                        content: const Text(
                          '⚠️ Khabardaar: Aapka WeTrack account, tamam personal data, cloud profiles aur shohar ke sath sync mukammal tor par delete ho jayega. Ye amal wapas nahi kiya ja sakta.',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => Navigator.pop(dCtx, true),
                            child: const Text('Yes, Delete Everything'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      // Attempt Supabase deletion if authenticated
                      final auth = ref.read(authServiceProvider);
                      final user = auth.currentUser;
                      if (user != null) {
                        try {
                          await Supabase.instance.client.from('profiles').delete().eq('id', user.id);
                        } catch (_) {}
                      }

                      // Wipe local preferences
                      await ref.read(localStorageRepositoryProvider).deleteAllData();

                      // Sign out
                      await auth.signOut();

                      // Invalidate all providers
                      ref.invalidate(userProfileProvider);
                      ref.invalidate(periodEntriesProvider);
                      ref.invalidate(cycleHistoryProvider);
                      ref.invalidate(symptomEntriesProvider);
                      ref.invalidate(fertilityObservationsProvider);
                      ref.invalidate(pregnancyRecordProvider);
                      ref.invalidate(appointmentsProvider);
                      ref.invalidate(partnerPermissionProvider);
                      ref.invalidate(notificationPreferencesProvider);

                      if (context.mounted) {
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
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Interactive Health Metrics Modal
  void _editHealthMetricsModal(BuildContext context, UserProfile profile) {
    int age = profile.age ?? 24;
    String status = profile.maritalStatus ?? 'married';
    double height = profile.heightCm ?? 160.0;
    double weight = profile.weightKg ?? 54.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2DCF0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Health & Body Measurements',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1A29),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Aapki umar, wazan aur status se WeTrack cycle aur health predictions ko ziyada accurate banata hai.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF7E768E)),
                ),
                const SizedBox(height: 18),

                // Age Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🎂 Umar (Age)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF7E60E4)),
                          onPressed: age > 14 ? () => setModalState(() => age--) : null,
                        ),
                        Text('$age Saal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFF7E60E4))),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF7E60E4)),
                          onPressed: age < 60 ? () => setModalState(() => age++) : null,
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 16),

                // Marital Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('💍 Status', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Shadi Shuda'),
                          selected: status == 'married',
                          selectedColor: const Color(0xFFFFE0E8),
                          onSelected: (val) => setModalState(() => status = 'married'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Ghair Shadi'),
                          selected: status != 'married',
                          selectedColor: const Color(0xFFEDE7F6),
                          onSelected: (val) => setModalState(() => status = 'unmarried'),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 16),

                // Height Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('📏 Qad (Height)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('${height.round()} cm', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF2E7D32))),
                      ],
                    ),
                    Slider(
                      value: height,
                      min: 120,
                      max: 200,
                      divisions: 80,
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (val) => setModalState(() => height = val),
                    ),
                  ],
                ),

                // Weight Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('⚖️ Wazan (Weight)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('${weight.round()} kg', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFFF04E78))),
                      ],
                    ),
                    Slider(
                      value: weight,
                      min: 30,
                      max: 130,
                      divisions: 100,
                      activeColor: const Color(0xFFF04E78),
                      onChanged: (val) => setModalState(() => weight = val),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1A29),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      await ref.read(userProfileProvider.notifier).updateProfile(
                            age: age,
                            maritalStatus: status,
                            heightCm: height,
                            weightKg: weight,
                          );
                      final auth = ref.read(authServiceProvider);
                      if (auth.currentUser != null) {
                        await auth.syncUserToDatabase(
                          userId: auth.currentUser!.id,
                          email: auth.currentUser!.email ?? '',
                          age: age,
                          maritalStatus: status,
                          heightCm: height,
                          weightKg: weight,
                        );
                      }
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Body metrics updated successfully! 🌸'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF9E8CE7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }
                    },
                    child: const Text('Save Measurements', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Logout Flow
  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE53935),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1A29),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of WeTrack on this device?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF7E768E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7E768E),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      final auth = ref.read(authServiceProvider);
      await auth.signOut();
      ref.invalidate(userProfileProvider);

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final hasCustomImage = profile.profileImagePath != null &&
        File(profile.profileImagePath!).existsSync();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Navigation Bar (Profile Header & Notification Bell with Pink Dot)
              _buildTopBar(context),
              const SizedBox(height: 16),

              // 2. Main Hero Profile Card (matching Omostate design)
              _buildHeroProfileCard(context, profile, hasCustomImage),
              const SizedBox(height: 16),

              // 3. Twin Feature Highlight Cards
              _buildHighlightCards(context),
              const SizedBox(height: 24),

              // 4. "Setting" Heading
              Text(
                'Setting',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1A29),
                ),
              ),
              const SizedBox(height: 12),

              // 5. Settings List
              _buildSettingsList(context, profile),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Bar with Centered "Profile" and Notification Bell with Pink Dot
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Optional Back button if Navigator can pop
        if (Navigator.of(context).canPop())
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEDE8F5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF1E1A29),
              ),
            ),
          )
        else
          const SizedBox(width: 42),

        // Title
        Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E1A29),
          ),
        ),

        // Notification Bell with Pink Unread Dot
        GestureDetector(
          onTap: () => _showNotificationsSheet(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEDE8F5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: Color(0xFF1E1A29),
                ),
                // Pink Unread Dot
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF04E78),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Hero Profile Card matching Omostate reference layout
  Widget _buildHeroProfileCard(
    BuildContext context,
    UserProfile profile,
    bool hasCustomImage,
  ) {
    final displayName = profile.name.isNotEmpty ? profile.name : 'Maria Barry';
    final roleText = profile.goal == AppGoal.alreadyPregnant
        ? 'Pregnancy Journey'
        : (profile.goal == AppGoal.tryToConceive ? 'Conception (TTC)' : 'Cycle Tracker');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF0ECF7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A448E).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Center Avatar with Pink Disc & Top-Left Checkmark Badge
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Circular Pastel Pink Disc
                Container(
                  width: 146,
                  height: 146,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFFEEF3), Color(0xFFFFD4E2)],
                      center: Alignment.center,
                      radius: 0.85,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF04E78).withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasCustomImage
                        ? Image.file(
                            File(profile.profileImagePath!),
                            width: 146,
                            height: 146,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'UI/Profile page character.png',
                            width: 146,
                            height: 146,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.person_rounded,
                              size: 70,
                              color: Color(0xFFF04E78),
                            ),
                          ),
                  ),
                ),

                // Top-Left Pink Verified Badge (as seen in Omostate design)
                Positioned(
                  top: 2,
                  left: 2,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF04E78),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF04E78).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),

                // Bottom-Right Camera/Edit Badge to Set, Update, or Delete Picture
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => _showImagePickerSheet(context, profile),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1A29),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // User Name & Role Row with Right Edit Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1A29),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    roleText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF867E96),
                    ),
                  ),
                ],
              ),

              // Edit Button (matching the subtle circular button in reference)
              GestureDetector(
                onTap: () => _editPersonalInformation(context, profile),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5FC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE8E2F2)),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFF1E1A29),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Identity Verification Dynamic Progress Bar
          Builder(builder: (context) {
            final completion = _calculateProfileCompletion(profile);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile & Health Verification',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF524A61),
                      ),
                    ),
                    Text(
                      '$completion%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E1A29),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Dark Pill Progress Bar
                Container(
                  width: double.infinity,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE7F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (completion / 100.0).clamp(0.05, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: completion == 100
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF1E1A29),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),

          // Personal Health Metric Badges (Interactive: tap to edit)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Body & Health Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF867E96),
                ),
              ),
              GestureDetector(
                onTap: () => _editHealthMetricsModal(context, profile),
                child: Row(
                  children: [
                    Text(
                      'Edit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7E60E4),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.edit_outlined, size: 13, color: Color(0xFF7E60E4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricPill('🎂 Umar', '${profile.age ?? 24} Saal', () => _editHealthMetricsModal(context, profile)),
              _buildMetricPill('💍 Status', profile.maritalStatus == 'married' ? 'Shadi Shuda' : 'Ghair Shadi', () => _editHealthMetricsModal(context, profile)),
              _buildMetricPill('📏 Qad', '${profile.heightCm?.round() ?? 160} cm', () => _editHealthMetricsModal(context, profile)),
              _buildMetricPill('⚖️ Wazan', '${profile.weightKg?.round() ?? 54} kg', () => _editHealthMetricsModal(context, profile)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F5FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDE8F6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A3B60),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.touch_app_rounded, size: 11, color: Color(0xFF9E8EA8)),
          ],
        ),
      ),
    );
  }

  /// Twin Feature Cards (Now fully interactive!)
  Widget _buildHighlightCards(BuildContext context) {
    final partner = ref.watch(partnerPermissionProvider);

    return Row(
      children: [
        // Left Card: "Cycle Insights" -> Opens Insights Screen
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InsightsScreen()),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF0ECF7), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5A448E).withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F3FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'New',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E1A29),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_outward_rounded,
                        size: 16,
                        color: Color(0xFF1E1A29),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cycle\nInsights',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1A29),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ACOG smart predictions active',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF867E96),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Right Card: "WeTrack Partner Sync" -> Opens Partner Sharing Modal
        Expanded(
          child: GestureDetector(
            onTap: () => _showPartnerSharingModal(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF0ECF7), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5A448E).withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: partner.isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFFEEF3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          partner.isConnected ? 'Connected' : 'Sync Ready',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: partner.isConnected ? const Color(0xFF2E7D32) : const Color(0xFFF04E78),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F3FB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 14,
                          color: Color(0xFFF04E78),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Partner\nSharing',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1A29),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    partner.isConnected ? 'Shohar ke sath link hai' : 'Tap to pair & share logs',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF867E96),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Settings List section
  Widget _buildSettingsList(BuildContext context, UserProfile profile) {
    final partner = ref.watch(partnerPermissionProvider);

    return Column(
      children: [
        // 1. Personal Information
        _buildSettingTile(
          icon: Icons.person_outline_rounded,
          title: 'Personal information',
          subtitle: 'Naam aur verified email address',
          onTap: () => _editPersonalInformation(context, profile),
        ),
        const SizedBox(height: 10),

        // 2. Body & Health Measurements
        _buildSettingTile(
          icon: Icons.fitness_center_rounded,
          title: 'Body measurements & status',
          subtitle: 'Umar, shadi shuda status, qad aur wazan',
          onTap: () => _editHealthMetricsModal(context, profile),
        ),
        const SizedBox(height: 10),

        // 3. Cycle & Health Preferences
        _buildSettingTile(
          icon: Icons.water_drop_outlined,
          title: 'Cycle & Health preferences',
          subtitle: 'Aam cycle length aur mahwari ke din',
          onTap: () => _editCycleSettings(context, profile),
        ),
        const SizedBox(height: 10),

        // 4. Shohar / Partner Data Sharing & Sync
        _buildSettingTile(
          icon: Icons.favorite_border_rounded,
          title: 'Shohar / Partner Sharing & Sync',
          subtitle: partner.isConnected
              ? 'Connected with Shohar (Data sync active)'
              : 'Pair code share karein aur privacy set karein',
          badgeText: partner.isConnected ? 'Connected' : 'Setup',
          badgeColor: partner.isConnected ? const Color(0xFF2E7D32) : const Color(0xFFF04E78),
          onTap: () => _showPartnerSharingModal(context),
        ),
        const SizedBox(height: 10),

        // 5. Security & App Lock
        _buildSettingTile(
          icon: Icons.lock_outline_rounded,
          title: 'Security & App lock',
          subtitle: profile.pinCode != null ? '4-digit PIN lock active' : 'PIN lock set karein',
          onTap: () => _editSecurityPin(context, profile),
        ),
        const SizedBox(height: 10),

        // 6. Notifications & In-Depth Reminders
        _buildSettingTile(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications & Reminders',
          subtitle: 'Period prediction, ovulation, vitamins & baby updates',
          onTap: () => _showNotificationsSheet(context),
        ),
        const SizedBox(height: 10),

        // 7. Aasan Roman Lughat (Dictionary)
        _buildSettingTile(
          icon: Icons.menu_book_rounded,
          title: 'Aasan Roman Lughat (Dictionary)',
          subtitle: 'Medical aur cycle terms ka aasan tarjuma',
          onTap: () => HealthDictionaryModal.show(context),
        ),
        const SizedBox(height: 10),

        // 8. Data Privacy, Erase & Account Deletion
        _buildSettingTile(
          icon: Icons.shield_outlined,
          title: 'Data Privacy, Erase & Delete Account',
          subtitle: 'Export data, reset cycle records, ya account delete karein',
          isDestructive: false,
          isWarning: true,
          onTap: () => _showDataPrivacyAndEraseModal(context),
        ),
        const SizedBox(height: 10),

        // 9. Log Out (Red Styled)
        _buildSettingTile(
          icon: Icons.logout_rounded,
          title: 'Log Out',
          subtitle: 'Apne account se sign out karein',
          isDestructive: true,
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isWarning = false,
  }) {
    Color iconBgColor = const Color(0xFFF6F3FB);
    Color iconColor = const Color(0xFF1E1A29);
    Color borderColor = const Color(0xFFF0ECF7);

    if (isDestructive) {
      iconBgColor = const Color(0xFFFFEBEE);
      iconColor = const Color(0xFFE53935);
      borderColor = const Color(0xFFFFE0E4);
    } else if (isWarning) {
      iconBgColor = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFE65100);
      borderColor = const Color(0xFFFFE0B2);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDestructive
                ? const Color(0xFFE53935).withValues(alpha: 0.04)
                : const Color(0xFF5A448E).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: isDestructive
                      ? const Color(0xFFE53935)
                      : (isWarning ? const Color(0xFFD84315) : const Color(0xFF1E1A29)),
                ),
              ),
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? const Color(0xFF7E60E4)).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor ?? const Color(0xFF7E60E4),
                  ),
                ),
              ),
          ],
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF867E96)),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDestructive
              ? const Color(0xFFE53935)
              : (isWarning ? const Color(0xFFE65100) : const Color(0xFFB3ABC2)),
          size: 20,
        ),
      ),
    );
  }
}

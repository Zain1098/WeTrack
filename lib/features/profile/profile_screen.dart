import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/clay_colors.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/auth_service.dart';
import '../app_providers.dart';
import '../auth/login_screen.dart';

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

  /// Notifications modal
  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
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
              const SizedBox(height: 16),
              Text(
                'Reminders & Notifications',
                style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: true,
                onChanged: (val) {},
                title: Text('Period Predictions (2 days before)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Get notified ahead of your predicted cycle day', style: TextStyle(fontSize: 12)),
                activeColor: const Color(0xFFF04E78),
              ),
              SwitchListTile(
                value: true,
                onChanged: (val) {},
                title: Text('Fertile Window Alerts', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Estimated ovulation & peak probability days', style: TextStyle(fontSize: 12)),
                activeColor: const Color(0xFFF04E78),
              ),
              SwitchListTile(
                value: false,
                onChanged: (val) {},
                title: Text('Daily Hydration & Vitamins', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Gentle daily nudges for wellness', style: TextStyle(fontSize: 12)),
                activeColor: const Color(0xFFF04E78),
              ),
              const SizedBox(height: 10),
            ],
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

          // Identity Verification Progress Bar (matching Omostate: "Identity Verification  76%")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Identity Verification',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF524A61),
                ),
              ),
              Text(
                '76%',
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
              widthFactor: 0.76,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A29),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Twin Feature Cards (matching November Release Features / Omostate place)
  Widget _buildHighlightCards(BuildContext context) {
    return Row(
      children: [
        // Left Card: "New" badge + "November release features"
        Expanded(
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

        const SizedBox(width: 12),

        // Right Card: "WeTrack Partner Sync"
        Expanded(
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                  'It is simple to pair & start sync',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF867E96),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Settings List section (Personal information, Cycle, Security, Notifications, Logout)
  Widget _buildSettingsList(BuildContext context, UserProfile profile) {
    return Column(
      children: [
        // 1. Personal Information
        _buildSettingTile(
          icon: Icons.person_outline_rounded,
          title: 'Personal information',
          onTap: () => _editPersonalInformation(context, profile),
        ),
        const SizedBox(height: 10),

        // 2. Cycle & Health Preferences
        _buildSettingTile(
          icon: Icons.water_drop_outlined,
          title: 'Cycle & Health preferences',
          onTap: () => _editCycleSettings(context, profile),
        ),
        const SizedBox(height: 10),

        // 3. Security & App Lock
        _buildSettingTile(
          icon: Icons.lock_outline_rounded,
          title: 'Security & App lock',
          onTap: () => _editSecurityPin(context, profile),
        ),
        const SizedBox(height: 10),

        // 4. Notifications & Reminders
        _buildSettingTile(
          icon: Icons.notifications_none_rounded,
          title: 'Notifications & Reminders',
          onTap: () => _showNotificationsSheet(context),
        ),
        const SizedBox(height: 10),

        // 5. Log Out (Red Styled)
        _buildSettingTile(
          icon: Icons.logout_rounded,
          title: 'Log Out',
          isDestructive: true,
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDestructive ? const Color(0xFFFFE0E4) : const Color(0xFFF0ECF7),
          width: 1.2,
        ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDestructive ? const Color(0xFFFFEBEE) : const Color(0xFFF6F3FB),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDestructive ? const Color(0xFFE53935) : const Color(0xFF1E1A29),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDestructive ? const Color(0xFFE53935) : const Color(0xFF1E1A29),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDestructive ? const Color(0xFFE53935) : const Color(0xFFB3ABC2),
          size: 20,
        ),
      ),
    );
  }
}

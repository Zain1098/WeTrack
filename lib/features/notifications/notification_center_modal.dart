import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/notification_preferences.dart';
import '../../data/models/in_app_notification.dart';
import '../../data/services/notification_service.dart';
import '../app_providers.dart';
import '../pregnancy/positive_test_modal.dart';
import '../pregnancy/kick_counter_modal.dart';
import '../appointments/appointment_modal.dart';
import '../cycle/log_symptoms_modal.dart';
import '../partner/partner_hub_modal.dart';

class NotificationCenterModal extends ConsumerStatefulWidget {
  final int initialTab;
  const NotificationCenterModal({super.key, this.initialTab = 0});

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationCenterModal(initialTab: initialTab),
    );
  }

  @override
  ConsumerState<NotificationCenterModal> createState() => _NotificationCenterModalState();
}

class _NotificationCenterModalState extends ConsumerState<NotificationCenterModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Grab handle
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
              const SizedBox(height: 14),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Notifications & Reminders',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E1A29),
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF04E78),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$unreadCount New',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Custom Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: const Color(0xFFC2185B),
                  unselectedLabelColor: const Color(0xFF7E768E),
                  labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: [
                    Tab(text: unreadCount > 0 ? 'Alerts ($unreadCount) 🔔' : 'Alerts 🔔'),
                    const Tab(text: 'Settings & Timers ⚙️'),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInboxTab(),
                    _buildSettingsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 1: INBOX & ACTIVITY ALERTS ---
  Widget _buildInboxTab() {
    final notifications = ref.watch(inAppNotificationsProvider);
    final notifier = ref.read(inAppNotificationsProvider.notifier);

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F5FC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_rounded, size: 40, color: Color(0xFF9E8DB5)),
            ),
            const SizedBox(height: 14),
            const Text(
              'Koi Naya Alert Nahi Hai',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF2E243D)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aapka cycle aur routine bilkul up to date hai.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF7E768E)),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Haaliya Ahem Khabrein',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7E768E)),
            ),
            TextButton(
              onPressed: () => notifier.markAllAsRead(),
              child: const Text('Mark all as read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...notifications.map((item) => _buildNotificationCard(item, notifier)),
      ],
    );
  }

  Widget _buildNotificationCard(InAppNotificationItem item, InAppNotificationsNotifier notifier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : const Color(0xFFFFF9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isRead ? const Color(0xFFEDE8F5) : const Color(0xFFFFCDD2),
          width: item.isRead ? 1 : 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(item.icon, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E1A29),
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF04E78),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF5D536E), height: 1.3),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateHelpers.formatFriendly(item.timestamp),
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF9E8DB5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.actionLabel != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.iconColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    notifier.markAsRead(item.id);
                    _handleNotificationAction(item.actionType);
                  },
                  child: Text(item.actionLabel!, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _handleNotificationAction(String? actionType) {
    Navigator.pop(context); // Close sheet
    if (actionType == 'open_positive_test') {
      PositivePregnancyTestModal.show(context);
    } else if (actionType == 'open_kicks') {
      KickCounterModal.show(context);
    } else if (actionType == 'open_appointment') {
      AppointmentModal.show(context);
    } else if (actionType == 'open_symptoms') {
      LogSymptomsModal.show(context);
    } else if (actionType == 'open_partner_hub') {
      PartnerHubModal.show(context);
    }
  }

  // --- TAB 2: REMINDERS & CUSTOM TIMERS ---
  Widget _buildSettingsTab() {
    final notifs = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Instant Test Notification Button
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE1BEE7)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Text('🔔', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Notification',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF4A148C)),
                    ),
                    Text(
                      'Check karein ke aapke device par notification kaisa dikhta hai.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF7B1FA2)),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B1FA2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () async {
                  await NotificationService().showInstantNotification(
                    id: 999,
                    title: '🌸 WeTrack Test Notification',
                    body: 'Mubarak! Aapka WeTrack notification system kamyabi se active hai.',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test notification bheji gayi! 🔔')),
                    );
                  }
                },
                child: const Text('Test Karein', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Section: Custom User-Created Reminders (Medicine / Routine)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('⏰ Aapke Apne Custom Reminders'),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Naya', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => _showAddCustomReminderDialog(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (notifs.customReminders.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: const Text(
              'Koi custom reminder nahi hai. Aap Calcium, Iron, Thyroid ya koi bhi dawayi ka apna reminder waqt ke sath add kar sakti hain.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
            ),
          )
        else
          ...notifs.customReminders.map(
            (rem) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE8F5)),
              ),
              child: Row(
                children: [
                  Text(
                    rem.category == 'water' ? '💧' : (rem.category == 'exercise' ? '🏃‍♀️' : '💊'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rem.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(rem.time, style: const TextStyle(fontSize: 11, color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: rem.isEnabled,
                    activeTrackColor: const Color(0xFF1E88E5),
                    onChanged: (val) => notifier.toggleCustomReminder(rem.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () => notifier.removeCustomReminder(rem.id),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 18),

        // Section: Daily Routine & Time Customizers
        _buildSectionTitle('💊 Daily Routine & Time Settings'),
        const SizedBox(height: 8),
        _buildTimePickerTile(
          title: 'Folic Acid / Vitamins',
          subtitle: 'Rozana subah dawayi lene ka muqarrara waqt',
          timeStr: notifs.folicAcidTime,
          isEnabled: notifs.folicAcidReminder,
          onToggle: (val) => notifier.update(notifs.copyWith(folicAcidReminder: val)),
          onTimeTap: () => _pickTime(notifs.folicAcidTime, (newTime) {
            notifier.update(notifs.copyWith(folicAcidTime: newTime));
          }),
        ),
        _buildTimePickerTile(
          title: 'Shaam Ka Check-in',
          subtitle: 'Dard, takleef aur mood note karne ka waqt',
          timeStr: notifs.eveningCheckinTime,
          isEnabled: notifs.eveningCheckinReminder,
          onToggle: (val) => notifier.update(notifs.copyWith(eveningCheckinReminder: val)),
          onTimeTap: () => _pickTime(notifs.eveningCheckinTime, (newTime) {
            notifier.update(notifs.copyWith(eveningCheckinTime: newTime));
          }),
        ),

        const SizedBox(height: 18),

        // Section: Menstrual & Fertility Alerts
        _buildSectionTitle('🌸 Mahwari & Fertility Toggles'),
        const SizedBox(height: 6),
        _buildToggle(
          title: 'Period Prediction Alert',
          subtitle: '${notifs.periodPredictionDaysBefore} din pehle cycle shuru hone ka alert',
          value: notifs.periodPredictionReminder,
          onChanged: (v) => notifier.update(notifs.copyWith(periodPredictionReminder: v)),
        ),
        _buildToggle(
          title: 'Period Late Hone Ka Alert',
          subtitle: 'Date guzarne par test confirm karne ki hidayat',
          value: notifs.latePeriodAlert,
          onChanged: (v) => notifier.update(notifs.copyWith(latePeriodAlert: v)),
        ),
        _buildToggle(
          title: 'Fertile Window & Ovulation Peak',
          subtitle: 'Bacha theherne ke ahem din shuru hone par alert',
          value: notifs.fertileWindowAlert,
          onChanged: (v) => notifier.update(notifs.copyWith(fertileWindowAlert: v)),
        ),

        const SizedBox(height: 18),

        // Section: Pregnancy Mode Alerts
        _buildSectionTitle('🤰 Hamal (Pregnancy) Toggles'),
        const SizedBox(height: 6),
        _buildToggle(
          title: 'Weekly Baby Growth Card',
          subtitle: 'Har naye hafte baby ki growth aur size update',
          value: notifs.weeklyBabyGrowthAlert,
          onChanged: (v) => notifier.update(notifs.copyWith(weeklyBabyGrowthAlert: v)),
        ),
        _buildToggle(
          title: 'Daily Baby Kicks Counter',
          subtitle: 'Shaam ko baby ki harkat note karne ka reminder',
          value: notifs.kickCounterReminder,
          onChanged: (v) => notifier.update(notifs.copyWith(kickCounterReminder: v)),
        ),
        _buildToggle(
          title: 'Doctor & Ultrasound Reminders',
          subtitle: 'Appointment se 1 din pehle reminder',
          value: notifs.doctorAppointmentReminder,
          onChanged: (v) => notifier.update(notifs.copyWith(doctorAppointmentReminder: v)),
        ),

        const SizedBox(height: 24),
      ],
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1E1A29),
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF7E768E))),
      activeTrackColor: const Color(0xFFC2185B),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildTimePickerTile({
    required String title,
    required String subtitle,
    required String timeStr,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3E5F5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF7E768E))),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTimeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCE93D8)),
              ),
              child: Row(
                children: [
                  Text(timeStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 12, color: Color(0xFF4A148C)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Switch.adaptive(
            value: isEnabled,
            activeTrackColor: const Color(0xFFC2185B),
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(String currentStr, Function(String) onSaved) async {
    final parsed = NotificationService.parseTimeString(currentStr);
    final initialTime = TimeOfDay(hour: parsed.hour, minute: parsed.minute);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final formatted = '${hour.toString().padLeft(2, '0')}:$minute $period';
      onSaved(formatted);
    }
  }

  void _showAddCustomReminderDialog() {
    final titleController = TextEditingController();
    String category = 'medicine';
    String selectedTime = '10:00 AM';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Naya Reminder Add Karein ⏰', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Reminder Ka Naam',
                  hintText: 'e.g. Calcium Tablet, Thyroid, Paani',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Category:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildCategoryChoice('medicine', '💊 Dawayi', category, (val) => setDialogState(() => category = val)),
                  const SizedBox(width: 8),
                  _buildCategoryChoice('water', '💧 Paani', category, (val) => setDialogState(() => category = val)),
                  const SizedBox(width: 8),
                  _buildCategoryChoice('exercise', '🏃‍♀️ Walk', category, (val) => setDialogState(() => category = val)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Waqt (Time):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () async {
                      await _pickTime(selectedTime, (t) {
                        setDialogState(() => selectedTime = t);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: Text(selectedTime, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                    ),
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
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  ref.read(notificationPreferencesProvider.notifier).addCustomReminder(
                    CustomReminderItem(
                      id: const Uuid().v4(),
                      title: titleController.text.trim(),
                      time: selectedTime,
                      category: category,
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Karein'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChoice(String cat, String label, String selected, ValueChanged<String> onSelect) {
    final isSelected = selected == cat;
    return GestureDetector(
      onTap: () => onSelect(cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF495057),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_preferences.dart';
import '../models/appointment.dart';
import '../services/cycle_calculation_service.dart';
import '../services/pregnancy_calculation_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String channelId = 'wetrack_reminders_channel';
  static const String channelName = 'WeTrack Sehat & Cycle Reminders';
  static const String channelDesc = 'Mahwari, Hamal, Dawayi aur Doctor Checkup Alerts';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Timezone initialization error: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open notification');

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // Create Android Notification Channel
      if (!kIsWeb) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidImpl != null) {
          await androidImpl.createNotificationChannel(
            const AndroidNotificationChannel(
              channelId,
              channelName,
              description: channelDesc,
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
            ),
          );
        }
      }

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    try {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final granted = await iosImpl.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Notification permission error: $e');
    }
    return true;
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling daily notification: $e');
    }
  }

  Future<void> scheduleDateNotification({
    required int id,
    required String title,
    required String body,
    required DateTime targetDate,
    int hour = 9,
    int minute = 0,
    String? payload,
  }) async {
    await initialize();

    final scheduledDate = tz.TZDateTime(
      tz.local,
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );

    final now = tz.TZDateTime.now(tz.local);
    if (scheduledDate.isBefore(now)) return; // Don't schedule past dates

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling date notification: $e');
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  // Parses time string formatted like "09:00 AM" or "08:30 PM"
  static ({int hour, int minute}) parseTimeString(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPm = clean.contains('PM');
      final isAm = clean.contains('AM');
      final timeParts = clean.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;

      return (hour: hour, minute: minute);
    } catch (_) {
      return (hour: 9, minute: 0);
    }
  }

  /// Master Rescheduler: Evaluates current preferences & clinical states
  /// and updates all native alarms.
  Future<void> rescheduleAll({
    required NotificationPreferences prefs,
    CycleCalculationResult? cycle,
    PregnancyCalculationResult? pregnancy,
    List<Appointment>? appointments,
  }) async {
    await initialize();
    await cancelAll();

    // 1. Folic Acid Daily Reminder (ID: 101)
    if (prefs.folicAcidReminder) {
      final time = parseTimeString(prefs.folicAcidTime);
      await scheduleDailyNotification(
        id: 101,
        title: '💊 Folic Acid / Prenatal Vitamin Yaad Dahani',
        body: 'Subah ka waqt: Apni sehat aur bache ke liye daily vitamin lena na bhoolein.',
        hour: time.hour,
        minute: time.minute,
      );
    }

    // 2. Evening Checkin Daily Reminder (ID: 102)
    if (prefs.eveningCheckinReminder) {
      final time = parseTimeString(prefs.eveningCheckinTime);
      await scheduleDailyNotification(
        id: 102,
        title: '🌙 Shaam Ka Sehat & Mood Check-in',
        body: 'Aaj ka din kaisa raha? Apne symptoms aur dard note karein taake record rahe.',
        hour: time.hour,
        minute: time.minute,
      );
    }

    // 3. Water Hydration Reminder (ID: 103)
    if (prefs.waterHydrationReminder) {
      await scheduleDailyNotification(
        id: 103,
        title: '💧 Paani Peenay Ka Waqt',
        body: 'Sehatmand routine: Aik glass taza paani piyein aur hydration maintain karein.',
        hour: 14,
        minute: 0,
      );
    }

    // 4. Custom User-Created Reminders (ID: 200+)
    for (int i = 0; i < prefs.customReminders.length; i++) {
      final rem = prefs.customReminders[i];
      if (rem.isEnabled) {
        final time = parseTimeString(rem.time);
        await scheduleDailyNotification(
          id: 200 + i,
          title: '⏰ ${rem.title}',
          body: 'WeTrack Reminder: ${rem.title} ka muqarrara waqt ho gaya hai.',
          hour: time.hour,
          minute: time.minute,
        );
      }
    }

    // 5. Pregnancy-Specific Notifications (ID: 300+)
    if (pregnancy != null) {
      if (prefs.kickCounterReminder) {
        await scheduleDailyNotification(
          id: 301,
          title: '👣 Baby Kicks Count Karein',
          body: 'Shaam ka aaram: Apne bache ki harkat aur halchal note karein.',
          hour: 20,
          minute: 0,
        );
      }

      if (prefs.weeklyBabyGrowthAlert) {
        await scheduleDailyNotification(
          id: 302,
          title: '🤰 Hamal Hafta ${pregnancy.completedWeeks}: Nayi Growth Update!',
          body: 'Aapka baby ab ${pregnancy.babyFruitComparison} ke barabar hai! Weekly guide dekhein.',
          hour: 10,
          minute: 0,
        );
      }
    }

    // 6. Menstrual Cycle & Ovulation Notifications (ID: 400+)
    if (cycle != null && !cycle.isPregnancySuspended) {
      // Period due reminder
      if (prefs.periodPredictionReminder && cycle.daysUntilNextPeriod > 0) {
        final daysNotice = prefs.periodPredictionDaysBefore;
        final targetDate = DateTime.now().add(Duration(days: cycle.daysUntilNextPeriod - daysNotice));
        await scheduleDateNotification(
          id: 401,
          title: '🌸 Mahwari Ki Tayyari (Cycle Alert)',
          body: 'Aapka agla period taqreeban $daysNotice dino mein expected hai. Sanitory pads aur aaram tayyar rakhein.',
          targetDate: targetDate,
          hour: 9,
          minute: 30,
        );
      }

      // Ovulation Peak alert
      if (prefs.ovulationPeakAlert) {
        final targetDate = cycle.estimatedOvulationDate;
        await scheduleDateNotification(
          id: 402,
          title: '🥚 Ovulation Peak Day Alert',
          body: 'Aaj cycle ka peak ovulation din hai. Conception ke chances sab se zyada hain.',
          targetDate: targetDate,
          hour: 8,
          minute: 30,
        );
      }
    }

    // 7. Upcoming Doctor Appointments (ID: 500+)
    if (appointments != null && prefs.doctorAppointmentReminder) {
      for (int i = 0; i < appointments.length; i++) {
        final apt = appointments[i];
        if (apt.dateTime.isAfter(DateTime.now())) {
          final oneDayBefore = apt.dateTime.subtract(const Duration(days: 1));
          if (oneDayBefore.isAfter(DateTime.now())) {
            await scheduleDateNotification(
              id: 500 + i,
              title: '🩺 Doctor Appointment Kal Hai!',
              body: '${apt.title} kal ${apt.dateTime.hour}:${apt.dateTime.minute.toString().padLeft(2, '0')} par muqarrar hai.',
              targetDate: oneDayBefore,
              hour: 11,
              minute: 0,
            );
          }
        }
      }
    }

    debugPrint('Rescheduled all notifications successfully.');
  }
}

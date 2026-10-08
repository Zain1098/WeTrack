import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/repositories/local_storage_repository.dart';
import '../data/models/user_profile.dart';
import '../data/models/period_entry.dart';
import '../data/models/cycle_record.dart';
import '../data/models/symptom_entry.dart';
import '../data/models/fertility_observation.dart';
import '../data/models/pregnancy_record.dart';
import '../data/models/appointment.dart';
import '../data/models/partner_share_permission.dart';
import '../data/models/notification_preferences.dart';
import 'package:flutter/material.dart';
import '../data/services/cycle_calculation_service.dart';
import '../data/services/pregnancy_calculation_service.dart';
import '../data/services/notification_service.dart';
import '../data/models/in_app_notification.dart';
import '../data/services/auth_service.dart';
import '../core/utils/date_helpers.dart';

const _uuid = Uuid();

final localStorageRepositoryProvider = Provider<LocalStorageRepository>((ref) {
  throw UnimplementedError(
      'localStorageRepositoryProvider must be initialized with SharedPreferences');
});

// User Profile Notifier
class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final repo = ref.watch(localStorageRepositoryProvider);
    return repo.getUserProfile() ?? UserProfile.defaultProfile();
  }

  Future<void> updateGoal(AppGoal newGoal) async {
    final updated = state.copyWith(goal: newGoal);
    state = updated;
    await ref.read(localStorageRepositoryProvider).saveUserProfile(updated);
    _syncToDatabase(updated);
    if (newGoal == AppGoal.alreadyPregnant &&
        ref.read(pregnancyRecordProvider) == null) {
      await ref
          .read(pregnancyRecordProvider.notifier)
          .startPregnancyFromLmp(state.lastPeriodDate);
    }
  }

  /// Automatically activates Pregnancy Mode across the entire app
  Future<void> switchToPregnancyMode({
    DateTime? lmp,
    int? gestationalWeeks,
    DateTime? ultrasoundEdd,
  }) async {
    DateTime effectiveLmp;
    if (gestationalWeeks != null) {
      effectiveLmp = DateTime.now().subtract(Duration(days: gestationalWeeks * 7));
    } else if (ultrasoundEdd != null) {
      effectiveLmp = ultrasoundEdd.subtract(const Duration(days: 280));
    } else {
      effectiveLmp = lmp ?? state.lastPeriodDate;
    }

    await ref.read(pregnancyRecordProvider.notifier).startPregnancyFromLmp(effectiveLmp);
    if (ultrasoundEdd != null) {
      await ref.read(pregnancyRecordProvider.notifier).setClinicianDueDate(ultrasoundEdd);
    }

    final updated = state.copyWith(
      goal: AppGoal.alreadyPregnant,
      pregnancyConfirmedDate: DateTime.now(),
    );
    state = updated;
    await ref.read(localStorageRepositoryProvider).saveUserProfile(updated);
    _syncToDatabase(updated);
  }

  /// Automatically switches back to Cycle Tracking / Conception Mode
  Future<void> switchToCycleMode({bool clearPregnancy = true}) async {
    if (clearPregnancy) {
      await ref.read(pregnancyRecordProvider.notifier).resetPregnancy();
    }
    final updated = state.copyWith(
      goal: AppGoal.trackCycle,
      pregnancyConfirmedDate: null,
    );
    state = updated;
    await ref.read(localStorageRepositoryProvider).saveUserProfile(updated);
    _syncToDatabase(updated);
  }

  Future<void> updateProfile({
    String? name,
    int? usualCycleLength,
    int? usualPeriodDuration,
    DateTime? lastPeriodDate,
    AppGoal? goal,
    String? profileImagePath,
    bool clearProfileImage = false,
    int? age,
    String? maritalStatus,
    double? heightCm,
    double? weightKg,
    String? todayMood,
    DateTime? pregnancyConfirmedDate,
  }) async {
    final updated = state.copyWith(
      name: name,
      usualCycleLength: usualCycleLength,
      usualPeriodDuration: usualPeriodDuration,
      lastPeriodDate: lastPeriodDate,
      goal: goal,
      profileImagePath: profileImagePath,
      clearProfileImage: clearProfileImage,
      age: age,
      maritalStatus: maritalStatus,
      heightCm: heightCm,
      weightKg: weightKg,
      todayMood: todayMood,
      pregnancyConfirmedDate: pregnancyConfirmedDate,
    );
    state = updated;
    await ref.read(localStorageRepositoryProvider).saveUserProfile(updated);
    _syncToDatabase(updated);
  }

  Future<void> completeOnboarding({
    required String name,
    required AppGoal goal,
    required DateTime lastPeriodDate,
    required int usualCycleLength,
    required int usualPeriodDuration,
    int? age,
    String? maritalStatus,
    double? heightCm,
    double? weightKg,
    String? todayMood,
  }) async {
    final updated = state.copyWith(
      name: name,
      goal: goal,
      lastPeriodDate: lastPeriodDate,
      usualCycleLength: usualCycleLength,
      usualPeriodDuration: usualPeriodDuration,
      hasCompletedOnboarding: true,
      age: age,
      maritalStatus: maritalStatus,
      heightCm: heightCm,
      weightKg: weightKg,
      todayMood: todayMood,
    );
    state = updated;
    await ref.read(localStorageRepositoryProvider).saveUserProfile(updated);
    _syncToDatabase(updated);
  }

  void _syncToDatabase(UserProfile profile) {
    try {
      final auth = ref.read(authServiceProvider);
      final user = auth.currentUser;
      if (user != null) {
        auth.syncUserToDatabase(
          userId: user.id,
          email: user.email ?? '',
          name: profile.name,
          avatarUrl: profile.profileImagePath,
          age: profile.age,
          maritalStatus: profile.maritalStatus,
          heightCm: profile.heightCm,
          weightKg: profile.weightKg,
          goal: profile.goal.name,
          usualCycleLength: profile.usualCycleLength,
          usualPeriodDuration: profile.usualPeriodDuration,
          lastPeriodDate: profile.lastPeriodDate,
        );
      }
    } catch (e) {
      debugPrint('Cloud profile sync note: $e');
    }
  }

  Future<void> setPin(String? pin) async {
    final updated = state.copyWith(pinCode: pin);
    state = updated;
    final repo = ref.read(localStorageRepositoryProvider);
    await repo.saveUserProfile(updated);
    await repo.setPinCode(pin);
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile>(UserProfileNotifier.new);

// Period Entries Notifier
class PeriodEntriesNotifier extends Notifier<List<PeriodEntry>> {
  @override
  List<PeriodEntry> build() {
    final repo = ref.watch(localStorageRepositoryProvider);
    final entries = repo.getPeriodEntries();
    // Backfill cycle history if existing entries are present but history is empty
    if (entries.isNotEmpty && repo.getCycleRecords().isEmpty) {
      final records = CycleCalculationService.generateCycleRecordsFromEntries(entries);
      repo.saveCycleRecords(records);
    }
    return entries;
  }

  Future<void> logPeriodDay({
    required DateTime date,
    required FlowIntensity flow,
    String? notes,
  }) async {
    final repo = ref.read(localStorageRepositoryProvider);
    final entry = PeriodEntry(
      id: _uuid.v4(),
      date: DateHelpers.toDateOnly(date),
      flow: flow,
      notes: notes,
      loggedAt: DateTime.now(),
    );
    await repo.savePeriodEntry(entry);
    final updated = repo.getPeriodEntries();
    state = updated;

    // Automatically recalculate and sync completed/ongoing cycle history, merging legacy records safely
    final existingRecords = repo.getCycleRecords();
    final derived = CycleCalculationService.generateCycleRecordsFromEntries(updated);
    final merged = CycleCalculationService.mergeCycleRecords(
      existingRecords: existingRecords,
      derivedRecords: derived,
      entries: updated,
    );
    await repo.saveCycleRecords(merged);
    ref.read(cycleHistoryProvider.notifier).refresh();
  }

  Future<void> removePeriodDay(String id) async {
    final repo = ref.read(localStorageRepositoryProvider);
    await repo.deletePeriodEntry(id);
    final updated = repo.getPeriodEntries();
    state = updated;

    // Automatically recalculate and sync completed/ongoing cycle history, merging legacy records safely
    final existingRecords = repo.getCycleRecords();
    final derived = CycleCalculationService.generateCycleRecordsFromEntries(updated);
    final merged = CycleCalculationService.mergeCycleRecords(
      existingRecords: existingRecords,
      derivedRecords: derived,
      entries: updated,
    );
    await repo.saveCycleRecords(merged);
    ref.read(cycleHistoryProvider.notifier).refresh();
  }
}

final periodEntriesProvider =
    NotifierProvider<PeriodEntriesNotifier, List<PeriodEntry>>(
        PeriodEntriesNotifier.new);

// Cycle History Notifier
class CycleHistoryNotifier extends Notifier<List<CycleRecord>> {
  @override
  List<CycleRecord> build() {
    final repo = ref.watch(localStorageRepositoryProvider);
    return repo.getCycleRecords();
  }

  Future<void> addRecord(CycleRecord record) async {
    final repo = ref.read(localStorageRepositoryProvider);
    final list = [...state, record];
    state = list;
    await repo.saveCycleRecords(list);
  }

  Future<void> setRecords(List<CycleRecord> records) async {
    final repo = ref.read(localStorageRepositoryProvider);
    state = records;
    await repo.saveCycleRecords(records);
  }

  void refresh() {
    final repo = ref.read(localStorageRepositoryProvider);
    state = repo.getCycleRecords();
  }
}

final cycleHistoryProvider =
    NotifierProvider<CycleHistoryNotifier, List<CycleRecord>>(
        CycleHistoryNotifier.new);

// Symptom Entries Notifier
class SymptomEntriesNotifier extends Notifier<List<SymptomEntry>> {
  @override
  List<SymptomEntry> build() {
    final repo = ref.watch(localStorageRepositoryProvider);
    return repo.getSymptomEntries();
  }

  Future<void> logSymptoms({
    required DateTime date,
    required List<String> symptoms,
    required List<String> moods,
    String? notes,
  }) async {
    final repo = ref.read(localStorageRepositoryProvider);
    final entry = SymptomEntry(
      id: _uuid.v4(),
      date: DateHelpers.toDateOnly(date),
      symptoms: symptoms,
      moods: moods,
      notes: notes,
    );
    await repo.saveSymptomEntry(entry);
    state = repo.getSymptomEntries();
  }
}

final symptomEntriesProvider =
    NotifierProvider<SymptomEntriesNotifier, List<SymptomEntry>>(
        SymptomEntriesNotifier.new);

// Fertility Observations Notifier
class FertilityObservationsNotifier
    extends Notifier<List<FertilityObservation>> {
  @override
  List<FertilityObservation> build() {
    final repo = ref.watch(localStorageRepositoryProvider);
    return repo.getFertilityObservations();
  }

  Future<void> logObservation({
    required DateTime date,
    OvulationTestResult lhTest = OvulationTestResult.notTested,
    CervicalMucusType mucus = CervicalMucusType.none,
    double? bbt,
    bool hadIntimacy = false,
    IntimacyType intimacyType = IntimacyType.none,
    IntimacyTiming? intimacyTiming,
  }) async {
    final repo = ref.read(localStorageRepositoryProvider);
    final obs = FertilityObservation(
      id: _uuid.v4(),
      date: DateHelpers.toDateOnly(date),
      lhTest: lhTest,
      mucus: mucus,
      basalBodyTemp: bbt,
      hadIntimacy: hadIntimacy || intimacyType != IntimacyType.none,
      intimacyType: intimacyType != IntimacyType.none
          ? intimacyType
          : (hadIntimacy ? IntimacyType.unprotectedInside : IntimacyType.none),
      intimacyTiming: intimacyTiming,
    );
    await repo.saveFertilityObservation(obs);
    state = repo.getFertilityObservations();
  }
}

final fertilityObservationsProvider = NotifierProvider<
    FertilityObservationsNotifier,
    List<FertilityObservation>>(FertilityObservationsNotifier.new);

// Pregnancy Record Notifier
class PregnancyRecordNotifier extends Notifier<PregnancyRecord?> {
  @override
  PregnancyRecord? build() {
    final repo = ref.watch(localStorageRepositoryProvider);
    return repo.getPregnancyRecord();
  }

  Future<void> startPregnancyFromLmp(DateTime lmp) async {
    final repo = ref.read(localStorageRepositoryProvider);
    final rec = PregnancyRecord.fromLmp(lmp);
    await repo.savePregnancyRecord(rec);
    state = rec;
  }

  Future<void> setClinicianDueDate(DateTime clinicianEdd) async {
    if (state == null) return;
    final repo = ref.read(localStorageRepositoryProvider);
    final updated = PregnancyRecord(
      id: state!.id,
      lmpDate: state!.lmpDate,
      estimatedDueDate: state!.estimatedDueDate,
      clinicianOverrideDueDate: DateHelpers.toDateOnly(clinicianEdd),
      datingMethod: 'Clinician/Ultrasound',
      isActive: true,
      notes: state!.notes,
    );
    await repo.savePregnancyRecord(updated);
    state = updated;
  }

  Future<void> resetPregnancy() async {
    final repo = ref.read(localStorageRepositoryProvider);
    await repo.clearPregnancyRecord();
    state = null;
  }
}

final pregnancyRecordProvider =
    NotifierProvider<PregnancyRecordNotifier, PregnancyRecord?>(
        PregnancyRecordNotifier.new);

// Appointments Notifier
class AppointmentsNotifier extends Notifier<List<Appointment>> {
  @override
  List<Appointment> build() {
    final repo = ref.watch(localStorageRepositoryProvider);
    return repo.getAppointments();
  }

  Future<void> addAppointment({
    required DateTime dateTime,
    required String title,
    String? clinicianName,
    String? location,
    String? notes,
  }) async {
    final repo = ref.read(localStorageRepositoryProvider);
    final apt = Appointment(
      id: _uuid.v4(),
      dateTime: dateTime,
      title: title,
      clinicianName: clinicianName,
      location: location,
      notes: notes,
    );
    await repo.saveAppointment(apt);
    state = repo.getAppointments();
  }

  Future<void> removeAppointment(String id) async {
    final repo = ref.read(localStorageRepositoryProvider);
    await repo.deleteAppointment(id);
    state = repo.getAppointments();
  }
}

final appointmentsProvider =
    NotifierProvider<AppointmentsNotifier, List<Appointment>>(
        AppointmentsNotifier.new);

// Partner Permission Notifier
class PartnerPermissionNotifier extends Notifier<PartnerSharePermission> {
  @override
  PartnerSharePermission build() {
    final repo = ref.watch(localStorageRepositoryProvider);
    return repo.getPartnerSharePermission();
  }

  Future<void> update(PartnerSharePermission permission) async {
    final repo = ref.read(localStorageRepositoryProvider);
    state = permission;
    await repo.savePartnerSharePermission(permission);
  }
}

final partnerPermissionProvider =
    NotifierProvider<PartnerPermissionNotifier, PartnerSharePermission>(
        PartnerPermissionNotifier.new);

// Notification Preferences Notifier
class NotificationPreferencesNotifier extends Notifier<NotificationPreferences> {
  @override
  NotificationPreferences build() {
    final repo = ref.watch(localStorageRepositoryProvider);
    return repo.getNotificationPreferences();
  }

  Future<void> update(NotificationPreferences preferences) async {
    final repo = ref.read(localStorageRepositoryProvider);
    state = preferences;
    await repo.saveNotificationPreferences(preferences);
    _triggerReschedule();
  }

  Future<void> addCustomReminder(CustomReminderItem item) async {
    final updated = [...state.customReminders, item];
    await update(state.copyWith(customReminders: updated));
  }

  Future<void> removeCustomReminder(String id) async {
    final updated = state.customReminders.where((e) => e.id != id).toList();
    await update(state.copyWith(customReminders: updated));
  }

  Future<void> toggleCustomReminder(String id) async {
    final updated = state.customReminders.map((e) {
      if (e.id == id) return e.copyWith(isEnabled: !e.isEnabled);
      return e;
    }).toList();
    await update(state.copyWith(customReminders: updated));
  }

  void _triggerReschedule() {
    try {
      final cycle = ref.read(cycleCalculationProvider);
      final preg = ref.read(pregnancyCalculationProvider);
      final apts = ref.read(appointmentsProvider);
      NotificationService().rescheduleAll(
        prefs: state,
        cycle: cycle,
        pregnancy: preg,
        appointments: apts,
      );
    } catch (_) {}
  }
}

final notificationPreferencesProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
        NotificationPreferencesNotifier.new);

// Smart In-App Activity & Notification Inbox Provider
class InAppNotificationsNotifier extends Notifier<List<InAppNotificationItem>> {
  final Set<String> _readIds = {};

  @override
  List<InAppNotificationItem> build() {
    final profile = ref.watch(userProfileProvider);
    final cycle = ref.watch(cycleCalculationProvider);
    final preg = ref.watch(pregnancyCalculationProvider);
    final apts = ref.watch(appointmentsProvider);
    final prefs = ref.watch(notificationPreferencesProvider);

    final list = <InAppNotificationItem>[];
    final now = DateTime.now();

    // 1. Pregnancy Overdue / Positive Test Prompt
    if (profile.goal != AppGoal.alreadyPregnant && cycle.daysUntilNextPeriod <= 0 && prefs.latePeriodAlert) {
      final days = cycle.daysUntilNextPeriod.abs();
      list.add(InAppNotificationItem(
        id: 'late_period_alert',
        title: days == 0 ? 'Period Aaj Expected Hai!' : 'Period $days Din Late Hai! 🧪',
        message: 'Kya pregnancy test positive aaya hai? Aik tap mein Hamal Mode shuru karein.',
        timestamp: now,
        icon: '⚡',
        iconColor: const Color(0xFFE65100),
        iconBg: const Color(0xFFFFF3E0),
        isRead: _readIds.contains('late_period_alert'),
        actionLabel: 'Positive Test Confirm',
        actionType: 'open_positive_test',
      ));
    }

    // 2. Active Pregnancy Weekly Milestone
    if (profile.goal == AppGoal.alreadyPregnant && preg != null && prefs.weeklyBabyGrowthAlert) {
      list.add(InAppNotificationItem(
        id: 'pregnancy_week_${preg.completedWeeks}',
        title: 'Hafta ${preg.completedWeeks} Mubarak! 🍼',
        message: 'Aapka baby ab ${preg.babyFruitComparison} ke barabar hai. Trimester ${preg.trimester} updates check karein.',
        timestamp: now,
        icon: '👶',
        iconColor: const Color(0xFFD81B60),
        iconBg: const Color(0xFFFCE4EC),
        isRead: _readIds.contains('pregnancy_week_${preg.completedWeeks}'),
        actionLabel: 'Kicks Count Karein',
        actionType: 'open_kicks',
      ));
    }

    // 3. Upcoming Doctor Appointment
    if (prefs.doctorAppointmentReminder && apts.isNotEmpty) {
      final upcoming = apts.where((a) => a.dateTime.isAfter(now)).toList();
      if (upcoming.isNotEmpty) {
        final nextApt = upcoming.first;
        final daysAway = DateHelpers.daysBetween(now, nextApt.dateTime);
        list.add(InAppNotificationItem(
          id: 'apt_${nextApt.id}',
          title: 'Doctor Appointment ($daysAway din baaqi)',
          message: '${nextApt.title} scheduled for ${DateHelpers.formatFriendly(nextApt.dateTime)}.',
          timestamp: nextApt.dateTime,
          icon: '🩺',
          iconColor: const Color(0xFF00897B),
          iconBg: const Color(0xFFE0F2F1),
          isRead: _readIds.contains('apt_${nextApt.id}'),
          actionLabel: 'Details Dekhein',
          actionType: 'open_appointment',
        ));
      }
    }

    // 4. Ovulation Peak Alert
    final isFertile = cycle.currentPhase == CyclePhase.fertileWindow || cycle.currentPhase == CyclePhase.ovulationDay;
    if (profile.goal != AppGoal.alreadyPregnant && isFertile && prefs.fertileWindowAlert) {
      list.add(InAppNotificationItem(
        id: 'fertile_window_alert',
        title: 'Fertile Window Active Hai 🥚',
        message: 'Cycle Day ${cycle.currentCycleDay}: Hamal theherne ke ahem din active hain.',
        timestamp: now,
        icon: '🌸',
        iconColor: const Color(0xFFF57C00),
        iconBg: const Color(0xFFFFF8E1),
        isRead: _readIds.contains('fertile_window_alert'),
        actionLabel: 'Fertility Log',
        actionType: 'open_symptoms',
      ));
    }

    // 5. Daily Folic Acid Reminder
    if (prefs.folicAcidReminder) {
      list.add(InAppNotificationItem(
        id: 'daily_folic_acid',
        title: 'Folic Acid / Prenatal Vitamins 💊',
        message: 'Rozana subah ${prefs.folicAcidTime} par dawayi lena na bhoolein.',
        timestamp: now,
        icon: '💊',
        iconColor: const Color(0xFF7E60E4),
        iconBg: const Color(0xFFF3E5F5),
        isRead: _readIds.contains('daily_folic_acid'),
      ));
    }

    // 6. Custom Reminders Added by User
    for (final rem in prefs.customReminders) {
      if (rem.isEnabled) {
        list.add(InAppNotificationItem(
          id: 'custom_${rem.id}',
          title: '${rem.title} (${rem.time}) ⏰',
          message: 'Aapka banaya hua custom reminder active hai.',
          timestamp: now,
          icon: '⏰',
          iconColor: const Color(0xFF1E88E5),
          iconBg: const Color(0xFFE3F2FD),
          isRead: _readIds.contains('custom_${rem.id}'),
        ));
      }
    }

    return list;
  }

  void markAsRead(String id) {
    _readIds.add(id);
    ref.invalidateSelf();
  }

  void markAllAsRead() {
    for (final item in state) {
      _readIds.add(item.id);
    }
    ref.invalidateSelf();
  }
}

final inAppNotificationsProvider =
    NotifierProvider<InAppNotificationsNotifier, List<InAppNotificationItem>>(
        InAppNotificationsNotifier.new);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(inAppNotificationsProvider);
  return list.where((item) => !item.isRead).length;
});

// Deterministic Cycle Calculation Provider
final cycleCalculationProvider = Provider<CycleCalculationResult>((ref) {
  final profile = ref.watch(userProfileProvider);
  final history = ref.watch(cycleHistoryProvider);
  final pregRecord = ref.watch(pregnancyRecordProvider);
  final isPregnant = profile.goal == AppGoal.alreadyPregnant || (pregRecord != null && pregRecord.isActive);

  final base = CycleCalculationService.calculate(
    lastPeriodStartDate: profile.lastPeriodDate,
    history: history,
    userFallbackCycleLength: profile.usualCycleLength,
    periodDuration: profile.usualPeriodDuration,
  );

  if (isPregnant) {
    return CycleCalculationResult(
      currentCycleDay: base.currentCycleDay,
      estimatedCycleLength: base.estimatedCycleLength,
      nextEstimatedPeriod: base.nextEstimatedPeriod,
      daysUntilNextPeriod: 9999, // Suspended during pregnancy
      estimatedOvulationDate: base.estimatedOvulationDate,
      fertileWindowStart: base.fertileWindowStart,
      fertileWindowEnd: base.fertileWindowEnd,
      currentPhase: base.currentPhase,
      isUsingFallbackEstimate: base.isUsingFallbackEstimate,
      isPregnancySuspended: true,
    );
  }

  return base;
});

// Deterministic Pregnancy Calculation Provider
final pregnancyCalculationProvider =
    Provider<PregnancyCalculationResult?>((ref) {
  final pregRecord = ref.watch(pregnancyRecordProvider);
  if (pregRecord == null) return null;
  return PregnancyCalculationService.calculate(record: pregRecord);
});

// App Lock Notifier
class AppLockNotifier extends Notifier<bool> {
  @override
  bool build() {
    final repo = ref.watch(localStorageRepositoryProvider);
    return repo.getPinCode() != null;
  }

  void unlock() => state = false;
  void lock() {
    final repo = ref.read(localStorageRepositoryProvider);
    state = repo.getPinCode() != null;
  }
}

final appLockProvider =
    NotifierProvider<AppLockNotifier, bool>(AppLockNotifier.new);

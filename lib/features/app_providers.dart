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
import '../data/services/cycle_calculation_service.dart';
import '../data/services/pregnancy_calculation_service.dart';
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
    if (newGoal == AppGoal.alreadyPregnant &&
        ref.read(pregnancyRecordProvider) == null) {
      await ref
          .read(pregnancyRecordProvider.notifier)
          .startPregnancyFromLmp(state.lastPeriodDate);
    }
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
    return repo.getPeriodEntries();
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
    state = repo.getPeriodEntries();
  }

  Future<void> removePeriodDay(String id) async {
    final repo = ref.read(localStorageRepositoryProvider);
    await repo.deletePeriodEntry(id);
    state = repo.getPeriodEntries();
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
  }) async {
    final repo = ref.read(localStorageRepositoryProvider);
    final obs = FertilityObservation(
      id: _uuid.v4(),
      date: DateHelpers.toDateOnly(date),
      lhTest: lhTest,
      mucus: mucus,
      basalBodyTemp: bbt,
      hadIntimacy: hadIntimacy,
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

// Deterministic Cycle Calculation Provider
final cycleCalculationProvider = Provider<CycleCalculationResult>((ref) {
  final profile = ref.watch(userProfileProvider);
  final history = ref.watch(cycleHistoryProvider);

  return CycleCalculationService.calculate(
    lastPeriodStartDate: profile.lastPeriodDate,
    history: history,
    userFallbackCycleLength: profile.usualCycleLength,
    periodDuration: profile.usualPeriodDuration,
  );
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

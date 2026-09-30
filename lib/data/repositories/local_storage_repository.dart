import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/period_entry.dart';
import '../models/cycle_record.dart';
import '../models/symptom_entry.dart';
import '../models/fertility_observation.dart';
import '../models/pregnancy_record.dart';
import '../models/appointment.dart';
import '../models/partner_share_permission.dart';
import '../../core/utils/date_helpers.dart';

/// Offline-First Local Storage Repository backed by SharedPreferences
class LocalStorageRepository {
  static const String _kUserProfileKey = 'wt_user_profile';
  static const String _kPeriodEntriesKey = 'wt_period_entries';
  static const String _kCycleRecordsKey = 'wt_cycle_records';
  static const String _kSymptomEntriesKey = 'wt_symptom_entries';
  static const String _kFertilityObsKey = 'wt_fertility_obs';
  static const String _kPregnancyRecordKey = 'wt_pregnancy_record';
  static const String _kAppointmentsKey = 'wt_appointments';
  static const String _kPartnerKey = 'wt_partner_permission';
  static const String _kPinCodeKey = 'wt_pin_code';

  final SharedPreferences _prefs;

  LocalStorageRepository(this._prefs);

  // User Profile
  UserProfile? getUserProfile() {
    final raw = _prefs.getString(_kUserProfileKey);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs.setString(_kUserProfileKey, jsonEncode(profile.toJson()));
  }

  // Period Entries
  List<PeriodEntry> getPeriodEntries() {
    final list = _prefs.getStringList(_kPeriodEntriesKey) ?? [];
    return list
        .map((str) => PeriodEntry.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> savePeriodEntry(PeriodEntry entry) async {
    final entries = getPeriodEntries();
    // Replace if existing on same date, else add
    entries.removeWhere((e) => DateHelpers.daysBetween(e.date, entry.date) == 0);
    entries.add(entry);
    final jsonList = entries.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_kPeriodEntriesKey, jsonList);
  }

  Future<void> deletePeriodEntry(String id) async {
    final entries = getPeriodEntries()..removeWhere((e) => e.id == id);
    final jsonList = entries.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_kPeriodEntriesKey, jsonList);
  }

  // Cycle Records
  List<CycleRecord> getCycleRecords() {
    final list = _prefs.getStringList(_kCycleRecordsKey) ?? [];
    return list
        .map((str) => CycleRecord.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<void> saveCycleRecords(List<CycleRecord> records) async {
    final jsonList = records.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_kCycleRecordsKey, jsonList);
  }

  // Symptom Entries
  List<SymptomEntry> getSymptomEntries() {
    final list = _prefs.getStringList(_kSymptomEntriesKey) ?? [];
    return list
        .map((str) => SymptomEntry.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveSymptomEntry(SymptomEntry entry) async {
    final entries = getSymptomEntries();
    entries.removeWhere((e) => DateHelpers.daysBetween(e.date, entry.date) == 0);
    entries.add(entry);
    final jsonList = entries.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_kSymptomEntriesKey, jsonList);
  }

  // Fertility Observations (TTC)
  List<FertilityObservation> getFertilityObservations() {
    final list = _prefs.getStringList(_kFertilityObsKey) ?? [];
    return list
        .map((str) =>
            FertilityObservation.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveFertilityObservation(FertilityObservation obs) async {
    final list = getFertilityObservations();
    list.removeWhere((e) => DateHelpers.daysBetween(e.date, obs.date) == 0);
    list.add(obs);
    final jsonList = list.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_kFertilityObsKey, jsonList);
  }

  // Pregnancy Record
  PregnancyRecord? getPregnancyRecord() {
    final raw = _prefs.getString(_kPregnancyRecordKey);
    if (raw == null) return null;
    try {
      return PregnancyRecord.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePregnancyRecord(PregnancyRecord record) async {
    await _prefs.setString(_kPregnancyRecordKey, jsonEncode(record.toJson()));
  }

  Future<void> clearPregnancyRecord() async {
    await _prefs.remove(_kPregnancyRecordKey);
  }

  // Appointments
  List<Appointment> getAppointments() {
    final list = _prefs.getStringList(_kAppointmentsKey) ?? [];
    return list
        .map((str) => Appointment.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Future<void> saveAppointment(Appointment apt) async {
    final list = getAppointments();
    list.removeWhere((e) => e.id == apt.id);
    list.add(apt);
    final jsonList = list.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_kAppointmentsKey, jsonList);
  }

  Future<void> deleteAppointment(String id) async {
    final list = getAppointments()..removeWhere((e) => e.id == id);
    final jsonList = list.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_kAppointmentsKey, jsonList);
  }

  // Partner Share Permission
  PartnerSharePermission getPartnerSharePermission() {
    final raw = _prefs.getString(_kPartnerKey);
    if (raw == null) return const PartnerSharePermission();
    try {
      return PartnerSharePermission.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const PartnerSharePermission();
    }
  }

  Future<void> savePartnerSharePermission(PartnerSharePermission p) async {
    await _prefs.setString(_kPartnerKey, jsonEncode(p.toJson()));
  }

  // PIN Lock & Privacy
  String? getPinCode() => _prefs.getString(_kPinCodeKey);
  Future<void> setPinCode(String? pin) async {
    if (pin == null) {
      await _prefs.remove(_kPinCodeKey);
    } else {
      await _prefs.setString(_kPinCodeKey, pin);
    }
  }

  // Data Export (JSON dump)
  Map<String, dynamic> exportAllData() {
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': _prefs.getString(_kUserProfileKey),
      'periods': _prefs.getStringList(_kPeriodEntriesKey),
      'cycles': _prefs.getStringList(_kCycleRecordsKey),
      'symptoms': _prefs.getStringList(_kSymptomEntriesKey),
      'fertility': _prefs.getStringList(_kFertilityObsKey),
      'pregnancy': _prefs.getString(_kPregnancyRecordKey),
      'appointments': _prefs.getStringList(_kAppointmentsKey),
    };
  }

  // Permanent Wipe Out
  Future<void> deleteAllData() async {
    await _prefs.clear();
  }
}

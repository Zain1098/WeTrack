import '../../core/utils/date_helpers.dart';

enum AppGoal {
  trackCycle,
  tryToConceive,
  alreadyPregnant;

  String get displayName {
    switch (this) {
      case AppGoal.trackCycle:
        return 'Track Cycle';
      case AppGoal.tryToConceive:
        return 'Try to Conceive';
      case AppGoal.alreadyPregnant:
        return 'Pregnancy';
    }
  }

  String get description {
    switch (this) {
      case AppGoal.trackCycle:
        return 'Period predictions, cycle regularity, and symptom tracking';
      case AppGoal.tryToConceive:
        return 'Fertile window estimates, ovulation tests, and conception tips';
      case AppGoal.alreadyPregnant:
        return 'Gestational weeks, fetal milestones, appointments, and kicks';
    }
  }
}

class UserProfile {
  final String id;
  final String name;
  final AppGoal goal;
  final int usualCycleLength;
  final int usualPeriodDuration;
  final DateTime lastPeriodDate;
  final String? pinCode;
  final bool isBiometricsEnabled;
  final bool hasCompletedOnboarding;
  final String? profileImagePath;
  final DateTime createdAt;
  
  // New personalization fields (Audio 2 & 3)
  final int? age;
  final String? maritalStatus; // 'married' or 'unmarried'
  final double? heightCm;
  final double? weightKg;
  final String? todayMood;
  final DateTime? pregnancyConfirmedDate;

  const UserProfile({
    required this.id,
    required this.name,
    required this.goal,
    required this.usualCycleLength,
    required this.usualPeriodDuration,
    required this.lastPeriodDate,
    this.pinCode,
    this.isBiometricsEnabled = false,
    this.hasCompletedOnboarding = false,
    this.profileImagePath,
    required this.createdAt,
    this.age,
    this.maritalStatus,
    this.heightCm,
    this.weightKg,
    this.todayMood,
    this.pregnancyConfirmedDate,
  });

  bool get isMarried => maritalStatus == 'married';

  UserProfile copyWith({
    String? id,
    String? name,
    AppGoal? goal,
    int? usualCycleLength,
    int? usualPeriodDuration,
    DateTime? lastPeriodDate,
    String? pinCode,
    bool? isBiometricsEnabled,
    bool? hasCompletedOnboarding,
    String? profileImagePath,
    bool clearProfileImage = false,
    DateTime? createdAt,
    int? age,
    String? maritalStatus,
    double? heightCm,
    double? weightKg,
    String? todayMood,
    DateTime? pregnancyConfirmedDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      usualCycleLength: usualCycleLength ?? this.usualCycleLength,
      usualPeriodDuration: usualPeriodDuration ?? this.usualPeriodDuration,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      pinCode: pinCode ?? this.pinCode,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      profileImagePath: clearProfileImage ? null : (profileImagePath ?? this.profileImagePath),
      createdAt: createdAt ?? this.createdAt,
      age: age ?? this.age,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      todayMood: todayMood ?? this.todayMood,
      pregnancyConfirmedDate: pregnancyConfirmedDate ?? this.pregnancyConfirmedDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'goal': goal.name,
        'usualCycleLength': usualCycleLength,
        'usualPeriodDuration': usualPeriodDuration,
        'lastPeriodDate': DateHelpers.formatIso(lastPeriodDate),
        'pinCode': pinCode,
        'isBiometricsEnabled': isBiometricsEnabled,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'profileImagePath': profileImagePath,
        'createdAt': createdAt.toIso8601String(),
        'age': age,
        'maritalStatus': maritalStatus,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'todayMood': todayMood,
        'pregnancyConfirmedDate': pregnancyConfirmedDate?.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Friend',
        goal: AppGoal.values.byName(json['goal'] as String? ?? 'trackCycle'),
        usualCycleLength: json['usualCycleLength'] as int? ?? 28,
        usualPeriodDuration: json['usualPeriodDuration'] as int? ?? 5,
        lastPeriodDate: json['lastPeriodDate'] != null
            ? DateHelpers.parseIso(json['lastPeriodDate'] as String)
            : DateTime.now().subtract(const Duration(days: 14)),
        pinCode: json['pinCode'] as String?,
        isBiometricsEnabled: json['isBiometricsEnabled'] as bool? ?? false,
        hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
        profileImagePath: json['profileImagePath'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        age: json['age'] as int?,
        maritalStatus: json['maritalStatus'] as String?,
        heightCm: (json['heightCm'] as num?)?.toDouble(),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        todayMood: json['todayMood'] as String?,
        pregnancyConfirmedDate: json['pregnancyConfirmedDate'] != null
            ? DateTime.tryParse(json['pregnancyConfirmedDate'] as String)
            : null,
      );

  static UserProfile defaultProfile() => UserProfile(
        id: 'default_user',
        name: 'Sarah',
        goal: AppGoal.trackCycle,
        usualCycleLength: 28,
        usualPeriodDuration: 5,
        lastPeriodDate: DateTime.now().subtract(const Duration(days: 12)),
        createdAt: DateTime.now(),
        age: 24,
        maritalStatus: 'unmarried',
        heightCm: 162.0,
        weightKg: 54.0,
        todayMood: 'Khush (Happy)',
      );
}

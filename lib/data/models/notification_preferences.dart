class NotificationPreferences {
  // Cycle & Period
  final bool periodPredictionReminder;
  final int periodPredictionDaysBefore;
  final bool latePeriodAlert;
  final bool dailyCycleTip;

  // Fertility & TTC
  final bool fertileWindowAlert;
  final bool ovulationPeakAlert;
  final bool pregnancyTestReminder;

  // Pregnancy (when pregnant)
  final bool weeklyBabyGrowthAlert;
  final bool kickCounterReminder;
  final bool doctorAppointmentReminder;

  // Health Routine & Vitamins
  final bool folicAcidReminder;
  final String folicAcidTime;
  final bool waterHydrationReminder;
  final bool eveningCheckinReminder;
  final String eveningCheckinTime;

  // Partner Sync
  final bool partnerSyncAlert;

  // Tone & Alert
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationPreferences({
    this.periodPredictionReminder = true,
    this.periodPredictionDaysBefore = 2,
    this.latePeriodAlert = true,
    this.dailyCycleTip = true,
    this.fertileWindowAlert = true,
    this.ovulationPeakAlert = true,
    this.pregnancyTestReminder = true,
    this.weeklyBabyGrowthAlert = true,
    this.kickCounterReminder = true,
    this.doctorAppointmentReminder = true,
    this.folicAcidReminder = true,
    this.folicAcidTime = '09:00 AM',
    this.waterHydrationReminder = false,
    this.eveningCheckinReminder = true,
    this.eveningCheckinTime = '08:30 PM',
    this.partnerSyncAlert = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationPreferences copyWith({
    bool? periodPredictionReminder,
    int? periodPredictionDaysBefore,
    bool? latePeriodAlert,
    bool? dailyCycleTip,
    bool? fertileWindowAlert,
    bool? ovulationPeakAlert,
    bool? pregnancyTestReminder,
    bool? weeklyBabyGrowthAlert,
    bool? kickCounterReminder,
    bool? doctorAppointmentReminder,
    bool? folicAcidReminder,
    String? folicAcidTime,
    bool? waterHydrationReminder,
    bool? eveningCheckinReminder,
    String? eveningCheckinTime,
    bool? partnerSyncAlert,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationPreferences(
      periodPredictionReminder:
          periodPredictionReminder ?? this.periodPredictionReminder,
      periodPredictionDaysBefore:
          periodPredictionDaysBefore ?? this.periodPredictionDaysBefore,
      latePeriodAlert: latePeriodAlert ?? this.latePeriodAlert,
      dailyCycleTip: dailyCycleTip ?? this.dailyCycleTip,
      fertileWindowAlert: fertileWindowAlert ?? this.fertileWindowAlert,
      ovulationPeakAlert: ovulationPeakAlert ?? this.ovulationPeakAlert,
      pregnancyTestReminder:
          pregnancyTestReminder ?? this.pregnancyTestReminder,
      weeklyBabyGrowthAlert:
          weeklyBabyGrowthAlert ?? this.weeklyBabyGrowthAlert,
      kickCounterReminder: kickCounterReminder ?? this.kickCounterReminder,
      doctorAppointmentReminder:
          doctorAppointmentReminder ?? this.doctorAppointmentReminder,
      folicAcidReminder: folicAcidReminder ?? this.folicAcidReminder,
      folicAcidTime: folicAcidTime ?? this.folicAcidTime,
      waterHydrationReminder:
          waterHydrationReminder ?? this.waterHydrationReminder,
      eveningCheckinReminder:
          eveningCheckinReminder ?? this.eveningCheckinReminder,
      eveningCheckinTime: eveningCheckinTime ?? this.eveningCheckinTime,
      partnerSyncAlert: partnerSyncAlert ?? this.partnerSyncAlert,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'periodPredictionReminder': periodPredictionReminder,
        'periodPredictionDaysBefore': periodPredictionDaysBefore,
        'latePeriodAlert': latePeriodAlert,
        'dailyCycleTip': dailyCycleTip,
        'fertileWindowAlert': fertileWindowAlert,
        'ovulationPeakAlert': ovulationPeakAlert,
        'pregnancyTestReminder': pregnancyTestReminder,
        'weeklyBabyGrowthAlert': weeklyBabyGrowthAlert,
        'kickCounterReminder': kickCounterReminder,
        'doctorAppointmentReminder': doctorAppointmentReminder,
        'folicAcidReminder': folicAcidReminder,
        'folicAcidTime': folicAcidTime,
        'waterHydrationReminder': waterHydrationReminder,
        'eveningCheckinReminder': eveningCheckinReminder,
        'eveningCheckinTime': eveningCheckinTime,
        'partnerSyncAlert': partnerSyncAlert,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
      };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        periodPredictionReminder:
            json['periodPredictionReminder'] as bool? ?? true,
        periodPredictionDaysBefore:
            json['periodPredictionDaysBefore'] as int? ?? 2,
        latePeriodAlert: json['latePeriodAlert'] as bool? ?? true,
        dailyCycleTip: json['dailyCycleTip'] as bool? ?? true,
        fertileWindowAlert: json['fertileWindowAlert'] as bool? ?? true,
        ovulationPeakAlert: json['ovulationPeakAlert'] as bool? ?? true,
        pregnancyTestReminder: json['pregnancyTestReminder'] as bool? ?? true,
        weeklyBabyGrowthAlert: json['weeklyBabyGrowthAlert'] as bool? ?? true,
        kickCounterReminder: json['kickCounterReminder'] as bool? ?? true,
        doctorAppointmentReminder:
            json['doctorAppointmentReminder'] as bool? ?? true,
        folicAcidReminder: json['folicAcidReminder'] as bool? ?? true,
        folicAcidTime: json['folicAcidTime'] as String? ?? '09:00 AM',
        waterHydrationReminder:
            json['waterHydrationReminder'] as bool? ?? false,
        eveningCheckinReminder:
            json['eveningCheckinReminder'] as bool? ?? true,
        eveningCheckinTime: json['eveningCheckinTime'] as String? ?? '08:30 PM',
        partnerSyncAlert: json['partnerSyncAlert'] as bool? ?? true,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      );
}

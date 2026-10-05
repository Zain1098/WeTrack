class PartnerSharePermission {
  final String partnerName;
  final String partnerCode;
  final bool isConnected;
  final bool shareCycleDates;
  final bool sharePregnancyMilestones;
  final bool shareAppointments;
  final bool shareSymptoms;
  final bool shareIntimacy;
  final bool sharePersonalNotes;

  const PartnerSharePermission({
    this.partnerName = '',
    this.partnerCode = '',
    this.isConnected = false,
    this.shareCycleDates = true,
    this.sharePregnancyMilestones = true,
    this.shareAppointments = true,
    this.shareSymptoms = true, // Shared by default
    this.shareIntimacy = true, // Shared by default (partner intimacy & planning)
    this.sharePersonalNotes = false, // Private diary notes
  });

  PartnerSharePermission copyWith({
    String? partnerName,
    String? partnerCode,
    bool? isConnected,
    bool? shareCycleDates,
    bool? sharePregnancyMilestones,
    bool? shareAppointments,
    bool? shareSymptoms,
    bool? shareIntimacy,
    bool? sharePersonalNotes,
  }) {
    return PartnerSharePermission(
      partnerName: partnerName ?? this.partnerName,
      partnerCode: partnerCode ?? this.partnerCode,
      isConnected: isConnected ?? this.isConnected,
      shareCycleDates: shareCycleDates ?? this.shareCycleDates,
      sharePregnancyMilestones:
          sharePregnancyMilestones ?? this.sharePregnancyMilestones,
      shareAppointments: shareAppointments ?? this.shareAppointments,
      shareSymptoms: shareSymptoms ?? this.shareSymptoms,
      shareIntimacy: shareIntimacy ?? this.shareIntimacy,
      sharePersonalNotes: sharePersonalNotes ?? this.sharePersonalNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'partnerName': partnerName,
        'partnerCode': partnerCode,
        'isConnected': isConnected,
        'shareCycleDates': shareCycleDates,
        'sharePregnancyMilestones': sharePregnancyMilestones,
        'shareAppointments': shareAppointments,
        'shareSymptoms': shareSymptoms,
        'shareIntimacy': shareIntimacy,
        'sharePersonalNotes': sharePersonalNotes,
      };

  factory PartnerSharePermission.fromJson(Map<String, dynamic> json) =>
      PartnerSharePermission(
        partnerName: json['partnerName'] as String? ?? '',
        partnerCode: json['partnerCode'] as String? ?? '',
        isConnected: json['isConnected'] as bool? ?? false,
        shareCycleDates: json['shareCycleDates'] as bool? ?? true,
        sharePregnancyMilestones:
            json['sharePregnancyMilestones'] as bool? ?? true,
        shareAppointments: json['shareAppointments'] as bool? ?? true,
        shareSymptoms: json['shareSymptoms'] as bool? ?? true,
        shareIntimacy: json['shareIntimacy'] as bool? ?? true,
        sharePersonalNotes: json['sharePersonalNotes'] as bool? ?? false,
      );
}

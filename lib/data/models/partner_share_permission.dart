class PartnerSharePermission {
  final String partnerName;
  final String partnerCode;
  final String myUniqueCode;
  final bool isConnected;
  final DateTime? connectedAt;
  final String sharingPreset; // 'full', 'essential', 'custom'
  final String? lastCareMessage;
  final DateTime? lastCareMessageTime;
  final bool shareCycleDates;
  final bool sharePregnancyMilestones;
  final bool shareAppointments;
  final bool shareSymptoms;
  final bool shareIntimacy;
  final bool sharePersonalNotes;

  const PartnerSharePermission({
    this.partnerName = '',
    this.partnerCode = '',
    this.myUniqueCode = '',
    this.isConnected = false,
    this.connectedAt,
    this.sharingPreset = 'full',
    this.lastCareMessage,
    this.lastCareMessageTime,
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
    String? myUniqueCode,
    bool? isConnected,
    DateTime? connectedAt,
    String? sharingPreset,
    String? lastCareMessage,
    DateTime? lastCareMessageTime,
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
      myUniqueCode: myUniqueCode ?? this.myUniqueCode,
      isConnected: isConnected ?? this.isConnected,
      connectedAt: connectedAt ?? this.connectedAt,
      sharingPreset: sharingPreset ?? this.sharingPreset,
      lastCareMessage: lastCareMessage ?? this.lastCareMessage,
      lastCareMessageTime: lastCareMessageTime ?? this.lastCareMessageTime,
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
        'myUniqueCode': myUniqueCode,
        'isConnected': isConnected,
        'connectedAt': connectedAt?.toIso8601String(),
        'sharingPreset': sharingPreset,
        'lastCareMessage': lastCareMessage,
        'lastCareMessageTime': lastCareMessageTime?.toIso8601String(),
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
        myUniqueCode: json['myUniqueCode'] as String? ?? '',
        isConnected: json['isConnected'] as bool? ?? false,
        connectedAt: json['connectedAt'] != null
            ? DateTime.tryParse(json['connectedAt'] as String)
            : null,
        sharingPreset: json['sharingPreset'] as String? ?? 'full',
        lastCareMessage: json['lastCareMessage'] as String?,
        lastCareMessageTime: json['lastCareMessageTime'] != null
            ? DateTime.tryParse(json['lastCareMessageTime'] as String)
            : null,
        shareCycleDates: json['shareCycleDates'] as bool? ?? true,
        sharePregnancyMilestones:
            json['sharePregnancyMilestones'] as bool? ?? true,
        shareAppointments: json['shareAppointments'] as bool? ?? true,
        shareSymptoms: json['shareSymptoms'] as bool? ?? true,
        shareIntimacy: json['shareIntimacy'] as bool? ?? true,
        sharePersonalNotes: json['sharePersonalNotes'] as bool? ?? false,
      );
}

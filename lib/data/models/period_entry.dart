import '../../core/utils/date_helpers.dart';

enum FlowIntensity {
  spotting,
  light,
  medium,
  heavy;

  String get displayName {
    switch (this) {
      case FlowIntensity.spotting:
        return 'Spotting';
      case FlowIntensity.light:
        return 'Light';
      case FlowIntensity.medium:
        return 'Medium';
      case FlowIntensity.heavy:
        return 'Heavy';
    }
  }
}

class PeriodEntry {
  final String id;
  final DateTime date;
  final FlowIntensity flow;
  final bool isConfirmed;
  final String? notes;
  final DateTime loggedAt;

  const PeriodEntry({
    required this.id,
    required this.date,
    required this.flow,
    this.isConfirmed = true,
    this.notes,
    required this.loggedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': DateHelpers.formatIso(date),
        'flow': flow.name,
        'isConfirmed': isConfirmed,
        'notes': notes,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory PeriodEntry.fromJson(Map<String, dynamic> json) => PeriodEntry(
        id: json['id'] as String,
        date: DateHelpers.parseIso(json['date'] as String),
        flow: FlowIntensity.values.byName(json['flow'] as String? ?? 'medium'),
        isConfirmed: json['isConfirmed'] as bool? ?? true,
        notes: json['notes'] as String?,
        loggedAt: json['loggedAt'] != null
            ? DateTime.parse(json['loggedAt'] as String)
            : DateTime.now(),
      );
}

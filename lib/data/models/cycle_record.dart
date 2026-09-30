import '../../core/utils/date_helpers.dart';

class CycleRecord {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLengthDays;
  final int periodDurationDays;
  final bool isAnomalous;

  const CycleRecord({
    required this.id,
    required this.startDate,
    this.endDate,
    this.cycleLengthDays,
    required this.periodDurationDays,
    this.isAnomalous = false,
  });

  bool get isCompleted => endDate != null && cycleLengthDays != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': DateHelpers.formatIso(startDate),
        'endDate': endDate != null ? DateHelpers.formatIso(endDate!) : null,
        'cycleLengthDays': cycleLengthDays,
        'periodDurationDays': periodDurationDays,
        'isAnomalous': isAnomalous,
      };

  factory CycleRecord.fromJson(Map<String, dynamic> json) => CycleRecord(
        id: json['id'] as String,
        startDate: DateHelpers.parseIso(json['startDate'] as String),
        endDate: json['endDate'] != null
            ? DateHelpers.parseIso(json['endDate'] as String)
            : null,
        cycleLengthDays: json['cycleLengthDays'] as int?,
        periodDurationDays: json['periodDurationDays'] as int? ?? 5,
        isAnomalous: json['isAnomalous'] as bool? ?? false,
      );
}

import '../../core/utils/date_helpers.dart';

class SymptomEntry {
  final String id;
  final DateTime date;
  final List<String> symptoms;
  final List<String> moods;
  final String? notes;
  final bool isPrivate;

  const SymptomEntry({
    required this.id,
    required this.date,
    this.symptoms = const [],
    this.moods = const [],
    this.notes,
    this.isPrivate = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': DateHelpers.formatIso(date),
        'symptoms': symptoms,
        'moods': moods,
        'notes': notes,
        'isPrivate': isPrivate,
      };

  factory SymptomEntry.fromJson(Map<String, dynamic> json) => SymptomEntry(
        id: json['id'] as String,
        date: DateHelpers.parseIso(json['date'] as String),
        symptoms: List<String>.from(json['symptoms'] as List? ?? []),
        moods: List<String>.from(json['moods'] as List? ?? []),
        notes: json['notes'] as String?,
        isPrivate: json['isPrivate'] as bool? ?? true,
      );
}

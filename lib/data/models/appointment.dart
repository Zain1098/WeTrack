import '../../core/utils/date_helpers.dart';

class Appointment {
  final String id;
  final DateTime dateTime;
  final String title;
  final String? clinicianName;
  final String? location;
  final String? notes;
  final bool isCompleted;

  const Appointment({
    required this.id,
    required this.dateTime,
    required this.title,
    this.clinicianName,
    this.location,
    this.notes,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'title': title,
        'clinicianName': clinicianName,
        'location': location,
        'notes': notes,
        'isCompleted': isCompleted,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        title: json['title'] as String,
        clinicianName: json['clinicianName'] as String?,
        location: json['location'] as String?,
        notes: json['notes'] as String?,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  String get formattedDate => DateHelpers.formatFriendly(dateTime);
}

import '../../core/utils/date_helpers.dart';
import '../../core/constants/medical_constants.dart';

class PregnancyRecord {
  final String id;
  final DateTime lmpDate;
  final DateTime estimatedDueDate;
  final DateTime? clinicianOverrideDueDate;
  final String datingMethod; // 'LMP' or 'Clinician/Ultrasound'
  final bool isActive;
  final String? notes;

  const PregnancyRecord({
    required this.id,
    required this.lmpDate,
    required this.estimatedDueDate,
    this.clinicianOverrideDueDate,
    this.datingMethod = 'LMP',
    this.isActive = true,
    this.notes,
  });

  DateTime get effectiveDueDate => clinicianOverrideDueDate ?? estimatedDueDate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'lmpDate': DateHelpers.formatIso(lmpDate),
        'estimatedDueDate': DateHelpers.formatIso(estimatedDueDate),
        'clinicianOverrideDueDate': clinicianOverrideDueDate != null
            ? DateHelpers.formatIso(clinicianOverrideDueDate!)
            : null,
        'datingMethod': datingMethod,
        'isActive': isActive,
        'notes': notes,
      };

  factory PregnancyRecord.fromJson(Map<String, dynamic> json) => PregnancyRecord(
        id: json['id'] as String,
        lmpDate: DateHelpers.parseIso(json['lmpDate'] as String),
        estimatedDueDate: DateHelpers.parseIso(json['estimatedDueDate'] as String),
        clinicianOverrideDueDate: json['clinicianOverrideDueDate'] != null
            ? DateHelpers.parseIso(json['clinicianOverrideDueDate'] as String)
            : null,
        datingMethod: json['datingMethod'] as String? ?? 'LMP',
        isActive: json['isActive'] as bool? ?? true,
        notes: json['notes'] as String?,
      );

  factory PregnancyRecord.fromLmp(DateTime lmp, {String id = 'active_pregnancy'}) {
    final edd = DateHelpers.toDateOnly(
      lmp.add(const Duration(days: MedicalConstants.standardGestationDays)),
    );
    return PregnancyRecord(
      id: id,
      lmpDate: DateHelpers.toDateOnly(lmp),
      estimatedDueDate: edd,
      datingMethod: 'LMP',
    );
  }
}

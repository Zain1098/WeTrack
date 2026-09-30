import '../../core/utils/date_helpers.dart';

enum OvulationTestResult {
  notTested,
  negative,
  positive;

  String get displayName {
    switch (this) {
      case OvulationTestResult.notTested:
        return 'Not Tested';
      case OvulationTestResult.negative:
        return 'Negative (Low LH)';
      case OvulationTestResult.positive:
        return 'Positive (LH Surge)';
    }
  }
}

enum CervicalMucusType {
  none,
  dry,
  sticky,
  creamy,
  watery,
  eggWhite;

  String get displayName {
    switch (this) {
      case CervicalMucusType.none:
        return 'None';
      case CervicalMucusType.dry:
        return 'Dry';
      case CervicalMucusType.sticky:
        return 'Sticky';
      case CervicalMucusType.creamy:
        return 'Creamy';
      case CervicalMucusType.watery:
        return 'Watery (High)';
      case CervicalMucusType.eggWhite:
        return 'Egg White (Peak)';
    }
  }
}

class FertilityObservation {
  final String id;
  final DateTime date;
  final OvulationTestResult lhTest;
  final CervicalMucusType mucus;
  final double? basalBodyTemp;
  final bool hadIntimacy;
  final bool isPrivate;

  const FertilityObservation({
    required this.id,
    required this.date,
    this.lhTest = OvulationTestResult.notTested,
    this.mucus = CervicalMucusType.none,
    this.basalBodyTemp,
    this.hadIntimacy = false,
    this.isPrivate = true,
  });

  double? get bbt => basalBodyTemp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': DateHelpers.formatIso(date),
        'lhTest': lhTest.name,
        'mucus': mucus.name,
        'basalBodyTemp': basalBodyTemp,
        'hadIntimacy': hadIntimacy,
        'isPrivate': isPrivate,
      };

  factory FertilityObservation.fromJson(Map<String, dynamic> json) =>
      FertilityObservation(
        id: json['id'] as String,
        date: DateHelpers.parseIso(json['date'] as String),
        lhTest: OvulationTestResult.values
            .byName(json['lhTest'] as String? ?? 'notTested'),
        mucus: CervicalMucusType.values
            .byName(json['mucus'] as String? ?? 'none'),
        basalBodyTemp: (json['basalBodyTemp'] as num?)?.toDouble(),
        hadIntimacy: json['hadIntimacy'] as bool? ?? false,
        isPrivate: json['isPrivate'] as bool? ?? true,
      );
}

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
        return 'Egg White (Peak Fertility)';
    }
  }
}

enum IntimacyType {
  none,
  unprotectedInside, // Conception attempt (Sperm Inside)
  protected,         // Condom
  withdrawal;        // Pull-out

  String get displayName {
    switch (this) {
      case IntimacyType.none:
        return 'Nahi Hua (None)';
      case IntimacyType.unprotectedInside:
        return 'Conception Attempt (Sperm Inside)';
      case IntimacyType.protected:
        return 'Protected (Condom / Ehtiyat)';
      case IntimacyType.withdrawal:
        return 'Withdrawal (Pull-out)';
    }
  }

  String get urduDescription {
    switch (this) {
      case IntimacyType.none:
        return 'Aaj intercourse nahi hua';
      case IntimacyType.unprotectedInside:
        return 'Sperm andar release hua (Conception chance high)';
      case IntimacyType.protected:
        return 'Condom / Ehtiyat ke sath (Conception chance low)';
      case IntimacyType.withdrawal:
        return 'Bahar ejaculation hui (Pull-out method)';
    }
  }

  String get emoji {
    switch (this) {
      case IntimacyType.none:
        return '⚪';
      case IntimacyType.unprotectedInside:
        return '🌸';
      case IntimacyType.protected:
        return '🛡️';
      case IntimacyType.withdrawal:
        return '🔄';
    }
  }
}

enum IntimacyTiming {
  morning,
  afternoon,
  night;

  String get displayName {
    switch (this) {
      case IntimacyTiming.morning:
        return 'Subah (Morning)';
      case IntimacyTiming.afternoon:
        return 'Dopahar (Afternoon)';
      case IntimacyTiming.night:
        return 'Raat (Night)';
    }
  }

  String get emoji {
    switch (this) {
      case IntimacyTiming.morning:
        return '☀️';
      case IntimacyTiming.afternoon:
        return '🌤️';
      case IntimacyTiming.night:
        return '🌙';
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
  final IntimacyType intimacyType;
  final IntimacyTiming? intimacyTiming;
  final bool isPrivate;

  const FertilityObservation({
    required this.id,
    required this.date,
    this.lhTest = OvulationTestResult.notTested,
    this.mucus = CervicalMucusType.none,
    this.basalBodyTemp,
    this.hadIntimacy = false,
    this.intimacyType = IntimacyType.none,
    this.intimacyTiming,
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
        'intimacyType': intimacyType.name,
        'intimacyTiming': intimacyTiming?.name,
        'isPrivate': isPrivate,
      };

  factory FertilityObservation.fromJson(Map<String, dynamic> json) {
    final legacyHadIntimacy = json['hadIntimacy'] as bool? ?? false;
    IntimacyType parsedType = IntimacyType.none;
    if (json['intimacyType'] != null) {
      parsedType = IntimacyType.values.byName(json['intimacyType'] as String);
    } else if (legacyHadIntimacy) {
      parsedType = IntimacyType.unprotectedInside;
    }

    IntimacyTiming? parsedTiming;
    if (json['intimacyTiming'] != null) {
      parsedTiming =
          IntimacyTiming.values.byName(json['intimacyTiming'] as String);
    }

    return FertilityObservation(
      id: json['id'] as String,
      date: DateHelpers.parseIso(json['date'] as String),
      lhTest: OvulationTestResult.values
          .byName(json['lhTest'] as String? ?? 'notTested'),
      mucus: CervicalMucusType.values
          .byName(json['mucus'] as String? ?? 'none'),
      basalBodyTemp: (json['basalBodyTemp'] as num?)?.toDouble(),
      hadIntimacy: parsedType != IntimacyType.none || legacyHadIntimacy,
      intimacyType: parsedType,
      intimacyTiming: parsedTiming,
      isPrivate: json['isPrivate'] as bool? ?? true,
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_models.freezed.dart';
part 'profile_models.g.dart';

enum MetabolicSex {
  @JsonValue('FEMALE')
  female,
  @JsonValue('MALE')
  male,
}

enum ActivityLevel {
  @JsonValue('SEDENTARY')
  sedentary(1.20),
  @JsonValue('LIGHT')
  light(1.375),
  @JsonValue('MODERATE')
  moderate(1.55),
  @JsonValue('HIGH')
  high(1.725);

  final double multiplier;
  const ActivityLevel(this.multiplier);
}

enum GoalPace {
  @JsonValue('MILD')
  mild,
  @JsonValue('STANDARD')
  standard,
  @JsonValue('AGGRESSIVE')
  aggressive,
}

@freezed
abstract class PersonalProfile with _$PersonalProfile {
  const PersonalProfile._();

  const factory PersonalProfile({
    required int birthDateEpochDay,
    required MetabolicSex metabolicSex,
    required double heightCm,
    required double currentWeightKg,
    required double targetWeightKg,
    required ActivityLevel activityLevel,
    required GoalPace goalPace,
    required bool personalizationConsent,
    required bool cloudAiConsent,
  }) = _PersonalProfile;

  factory PersonalProfile.fromJson(Map<String, dynamic> json) =>
      _$PersonalProfileFromJson(json);

  List<String> validationIssues(DateTime today) {
    final issues = <String>[];
    
    // Convert epoch day to DateTime
    final birthDate = DateTime.fromMillisecondsSinceEpoch(
      birthDateEpochDay * 24 * 60 * 60 * 1000,
      isUtc: true,
    );
    
    // Calculate age
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    if (age < _minimumAge || age > _maximumAge) {
      issues.add("Độ tuổi phải từ 18 đến 100.");
    }
    if (!heightCm.isFinite ||
        heightCm < _minimumHeightCm ||
        heightCm > _maximumHeightCm) {
      issues.add("Chiều cao phải từ 100 đến 250 cm.");
    }
    if (!currentWeightKg.isFinite ||
        currentWeightKg < _minimumWeightKg ||
        currentWeightKg > _maximumWeightKg) {
      issues.add("Cân nặng hiện tại phải từ 30 đến 350 kg.");
    }
    if (!targetWeightKg.isFinite ||
        targetWeightKg < _minimumWeightKg ||
        targetWeightKg > _maximumWeightKg) {
      issues.add("Cân nặng mục tiêu phải từ 30 đến 350 kg.");
    }
    if (!personalizationConsent) {
      issues.add("Bạn cần đồng ý sử dụng dữ liệu hồ sơ để bật cá nhân hóa.");
    }

    return issues;
  }

  static const int _minimumAge = 18;
  static const int _maximumAge = 100;
  static const double _minimumHeightCm = 100.0;
  static const double _maximumHeightCm = 250.0;
  static const double _minimumWeightKg = 30.0;
  static const double _maximumWeightKg = 350.0;
}

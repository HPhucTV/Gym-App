import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_models.freezed.dart';
part 'achievement_models.g.dart';

enum AchievementType {
  @JsonValue('FIRST_WORKOUT')
  firstWorkout('🔥', 'Ngọn Lửa Đầu Tiên', 'Hoàn thành buổi tập đầu tiên'),
  @JsonValue('STREAK_7')
  streak7('⚡', 'Chuỗi 7 Ngày', 'Tập luyện 7 ngày liên tiếp'),
  @JsonValue('STREAK_14')
  streak14('💎', 'Chiến Binh 2 Tuần', 'Tập luyện 14 ngày liên tiếp'),
  @JsonValue('STREAK_30')
  streak30('👑', 'Huyền Thoại 30 Ngày', 'Tập luyện 30 ngày liên tiếp'),
  @JsonValue('PERFECT_WEEK')
  perfectWeek('🌟', 'Tuần Hoàn Hảo', 'Đủ số buổi tập mục tiêu trong tuần'),
  @JsonValue('HALF_PROGRAM')
  halfProgram('💪', 'Chinh Phục 50%', 'Hoàn thành 50% chương trình'),
  @JsonValue('FULL_PROGRAM')
  fullProgram('🎯', 'Mục Tiêu Hoàn Thành', 'Hoàn thành toàn bộ chương trình'),
  @JsonValue('SCAN_10')
  scan10('📸', 'Dinh Dưỡng Thông Minh', 'Quét 10 món ăn bằng AI'),
  @JsonValue('CHECKIN_4')
  checkin4('🗓️', 'Check-in Đều Đặn', '4 tuần check-in liên tiếp'),
  @JsonValue('ALL_MUSCLES')
  allMuscles('🦾', 'Toàn Diện', 'Tập đủ tất cả nhóm cơ trong 1 tuần'),
  @JsonValue('EARLY_BIRD')
  earlyBird('🌅', 'Chim Sớm', 'Tập trước 7 giờ sáng'),
  @JsonValue('NIGHT_OWL')
  nightOwl('🌙', 'Cú Đêm', 'Tập sau 9 giờ tối'),
  @JsonValue('WORKOUTS_10')
  workouts10('🏅', '10 Buổi Tập', 'Hoàn thành 10 buổi tập'),
  @JsonValue('WORKOUTS_50')
  workouts50('🏆', '50 Buổi Tập', 'Hoàn thành 50 buổi tập'),
  @JsonValue('WORKOUTS_100')
  workouts100('💯', '100 Buổi Tập', 'Hoàn thành 100 buổi tập');

  final String icon;
  final String titleVi;
  final String descriptionVi;
  const AchievementType(this.icon, this.titleVi, this.descriptionVi);
}

@freezed
abstract class Achievement with _$Achievement {
  const factory Achievement({
    required AchievementType type,
    required int unlockedAtEpochMillis,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

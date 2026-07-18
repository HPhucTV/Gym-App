import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class GymCustomColors extends ThemeExtension<GymCustomColors> {
  final Color orangeLight;
  final Color greenLight;
  final Color checkedCardBorder;
  final Color recoveryBlue;
  final Color recoveryBlueBg;
  final Color primaryText;
  final Color mutedText;

  const GymCustomColors({
    required this.orangeLight,
    required this.greenLight,
    required this.checkedCardBorder,
    required this.recoveryBlue,
    required this.recoveryBlueBg,
    required this.primaryText,
    required this.mutedText,
  });

  @override
  GymCustomColors copyWith({
    Color? orangeLight,
    Color? greenLight,
    Color? checkedCardBorder,
    Color? recoveryBlue,
    Color? recoveryBlueBg,
    Color? primaryText,
    Color? mutedText,
  }) {
    return GymCustomColors(
      orangeLight: orangeLight ?? this.orangeLight,
      greenLight: greenLight ?? this.greenLight,
      checkedCardBorder: checkedCardBorder ?? this.checkedCardBorder,
      recoveryBlue: recoveryBlue ?? this.recoveryBlue,
      recoveryBlueBg: recoveryBlueBg ?? this.recoveryBlueBg,
      primaryText: primaryText ?? this.primaryText,
      mutedText: mutedText ?? this.mutedText,
    );
  }

  @override
  GymCustomColors lerp(ThemeExtension<GymCustomColors>? other, double t) {
    if (other is! GymCustomColors) {
      return this;
    }
    return GymCustomColors(
      orangeLight: Color.lerp(orangeLight, other.orangeLight, t)!,
      greenLight: Color.lerp(greenLight, other.greenLight, t)!,
      checkedCardBorder: Color.lerp(checkedCardBorder, other.checkedCardBorder, t)!,
      recoveryBlue: Color.lerp(recoveryBlue, other.recoveryBlue, t)!,
      recoveryBlueBg: Color.lerp(recoveryBlueBg, other.recoveryBlueBg, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
    );
  }

  static const GymCustomColors light = GymCustomColors(
    orangeLight: AppColors.orangeLight,
    greenLight: AppColors.greenLight,
    checkedCardBorder: AppColors.checkedCardBorder,
    recoveryBlue: AppColors.recoveryBlue,
    recoveryBlueBg: AppColors.recoveryBlueBg,
    primaryText: AppColors.navy,
    mutedText: AppColors.mutedText,
  );

  static const GymCustomColors dark = GymCustomColors(
    orangeLight: AppColors.darkOrangeLight,
    greenLight: AppColors.darkGreenLight,
    checkedCardBorder: AppColors.darkCheckedCardBorder,
    recoveryBlue: AppColors.darkRecoveryBlue,
    recoveryBlueBg: AppColors.darkRecoveryBlueBg,
    primaryText: AppColors.darkText,
    mutedText: AppColors.darkMutedText,
  );
}

extension GymThemeExtension on BuildContext {
  GymCustomColors get customColors => Theme.of(this).extension<GymCustomColors>()!;
}

final ColorScheme gymLightColorScheme = const ColorScheme.light(
  primary: AppColors.energyOrange,
  onPrimary: AppColors.white,
  secondary: AppColors.successGreen,
  onSecondary: AppColors.navy,
  surface: AppColors.white,
  onSurface: AppColors.navy,
  surfaceContainerHighest: AppColors.surfaceGray,
  onSurfaceVariant: AppColors.mutedText,
  outline: AppColors.borderGray,
);

final ColorScheme gymDarkColorScheme = const ColorScheme.dark(
  primary: AppColors.energyOrange,
  onPrimary: AppColors.white,
  secondary: AppColors.successGreen,
  onSecondary: AppColors.darkBg,
  surface: AppColors.darkSurface,
  onSurface: AppColors.darkText,
  surfaceContainerHighest: AppColors.darkSurfaceVariant,
  onSurfaceVariant: AppColors.darkMutedText,
  outline: AppColors.darkBorder,
);

ThemeData getGymLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: gymLightColorScheme,
    textTheme: GymTypography.textTheme,
    scaffoldBackgroundColor: AppColors.white,
    extensions: const <ThemeExtension<dynamic>>[
      GymCustomColors.light,
    ],
  );
}

ThemeData getGymDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: gymDarkColorScheme,
    textTheme: GymTypography.textTheme,
    scaffoldBackgroundColor: AppColors.darkBg,
    extensions: const <ThemeExtension<dynamic>>[
      GymCustomColors.dark,
    ],
  );
}

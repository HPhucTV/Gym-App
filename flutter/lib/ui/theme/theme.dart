import 'package:flutter/cupertino.dart';
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
  final Color orangeAccent;
  final Color greenDark;
  final Color navyLight;
  final Color errorRed;
  final Color warningAmber;
  final Color navy10;
  final Color navy20;
  final Color orange10;
  final Color green10;
  final Color cardShadow;
  final Color divider;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const GymCustomColors({
    required this.orangeLight,
    required this.greenLight,
    required this.checkedCardBorder,
    required this.recoveryBlue,
    required this.recoveryBlueBg,
    required this.primaryText,
    required this.mutedText,
    required this.orangeAccent,
    required this.greenDark,
    required this.navyLight,
    required this.errorRed,
    required this.warningAmber,
    required this.navy10,
    required this.navy20,
    required this.orange10,
    required this.green10,
    required this.cardShadow,
    required this.divider,
    required this.shimmerBase,
    required this.shimmerHighlight,
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
    Color? orangeAccent,
    Color? greenDark,
    Color? navyLight,
    Color? errorRed,
    Color? warningAmber,
    Color? navy10,
    Color? navy20,
    Color? orange10,
    Color? green10,
    Color? cardShadow,
    Color? divider,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return GymCustomColors(
      orangeLight: orangeLight ?? this.orangeLight,
      greenLight: greenLight ?? this.greenLight,
      checkedCardBorder: checkedCardBorder ?? this.checkedCardBorder,
      recoveryBlue: recoveryBlue ?? this.recoveryBlue,
      recoveryBlueBg: recoveryBlueBg ?? this.recoveryBlueBg,
      primaryText: primaryText ?? this.primaryText,
      mutedText: mutedText ?? this.mutedText,
      orangeAccent: orangeAccent ?? this.orangeAccent,
      greenDark: greenDark ?? this.greenDark,
      navyLight: navyLight ?? this.navyLight,
      errorRed: errorRed ?? this.errorRed,
      warningAmber: warningAmber ?? this.warningAmber,
      navy10: navy10 ?? this.navy10,
      navy20: navy20 ?? this.navy20,
      orange10: orange10 ?? this.orange10,
      green10: green10 ?? this.green10,
      cardShadow: cardShadow ?? this.cardShadow,
      divider: divider ?? this.divider,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
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
      orangeAccent: Color.lerp(orangeAccent, other.orangeAccent, t)!,
      greenDark: Color.lerp(greenDark, other.greenDark, t)!,
      navyLight: Color.lerp(navyLight, other.navyLight, t)!,
      errorRed: Color.lerp(errorRed, other.errorRed, t)!,
      warningAmber: Color.lerp(warningAmber, other.warningAmber, t)!,
      navy10: Color.lerp(navy10, other.navy10, t)!,
      navy20: Color.lerp(navy20, other.navy20, t)!,
      orange10: Color.lerp(orange10, other.orange10, t)!,
      green10: Color.lerp(green10, other.green10, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
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
    orangeAccent: AppColors.orangeAccent,
    greenDark: AppColors.greenDark,
    navyLight: AppColors.navyLight,
    errorRed: AppColors.errorRed,
    warningAmber: AppColors.warningAmber,
    navy10: AppColors.navy10,
    navy20: AppColors.navy20,
    orange10: AppColors.orange10,
    green10: AppColors.green10,
    cardShadow: AppColors.cardShadow,
    divider: AppColors.divider,
    shimmerBase: AppColors.shimmerBase,
    shimmerHighlight: AppColors.shimmerHighlight,
  );

  static const GymCustomColors dark = GymCustomColors(
    orangeLight: AppColors.darkOrangeLight,
    greenLight: AppColors.darkGreenLight,
    checkedCardBorder: AppColors.darkCheckedCardBorder,
    recoveryBlue: AppColors.darkRecoveryBlue,
    recoveryBlueBg: AppColors.darkRecoveryBlueBg,
    primaryText: AppColors.darkText,
    mutedText: AppColors.darkMutedText,
    orangeAccent: AppColors.darkOrangeAccent,
    greenDark: AppColors.darkGreenDark,
    navyLight: AppColors.darkNavyLight,
    errorRed: AppColors.darkErrorRed,
    warningAmber: AppColors.darkWarningAmber,
    navy10: AppColors.darkNavy10,
    navy20: AppColors.darkNavy20,
    orange10: AppColors.darkOrange10,
    green10: AppColors.darkGreen10,
    cardShadow: AppColors.darkCardShadow,
    divider: AppColors.darkDivider,
    shimmerBase: AppColors.darkShimmerBase,
    shimmerHighlight: AppColors.darkShimmerHighlight,
  );
}

extension GymThemeExtension on BuildContext {
  GymCustomColors get customColors => Theme.of(this).extension<GymCustomColors>()!;
}

final ColorScheme gymLightColorScheme = const ColorScheme.light(
  primary: AppColors.energyOrange,
  onPrimary: AppColors.white,
  secondary: AppColors.successGreen,
  onSecondary: AppColors.white,
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
  onSecondary: AppColors.white,
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
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.navy),
      titleTextStyle: GymTypography.titleLarge.navy,
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.energyOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: GymTypography.titleMedium.white.copyWith(height: 1.1),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        side: const BorderSide(color: AppColors.navy, width: 1.5),
        textStyle: GymTypography.titleMedium.navy.copyWith(height: 1.1),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceGray,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.energyOrange, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceGray,
      selectedColor: AppColors.energyOrange,
      secondarySelectedColor: AppColors.energyOrange,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: StadiumBorder(side: BorderSide.none),
      labelStyle: GymTypography.labelSmall.navy,
      secondaryLabelStyle: GymTypography.labelSmall.white,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      modalBackgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
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
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.darkText),
      titleTextStyle: GymTypography.titleLarge.white,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.energyOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: GymTypography.titleMedium.white.copyWith(height: 1.1),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkText,
        side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        textStyle: GymTypography.titleMedium.white.copyWith(height: 1.1),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.energyOrange, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.energyOrange,
      secondarySelectedColor: AppColors.energyOrange,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: StadiumBorder(side: BorderSide.none),
      labelStyle: GymTypography.labelSmall.copyWith(color: AppColors.darkText),
      secondaryLabelStyle: GymTypography.labelSmall.white,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      modalBackgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    extensions: const <ThemeExtension<dynamic>>[
      GymCustomColors.dark,
    ],
  );
}

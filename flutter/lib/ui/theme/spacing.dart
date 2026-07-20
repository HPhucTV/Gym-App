import 'package:flutter/material.dart';

class GymSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Semantic paddings
  static const double screenHorizontal = 20.0;
  static const double screenVertical = 16.0;
  static const double cardPadding = 16.0;
  static const double sectionGap = 24.0;
}

class GymGap {
  static const SizedBox xs = SizedBox(width: GymSpacing.xs, height: GymSpacing.xs);
  static const SizedBox sm = SizedBox(width: GymSpacing.sm, height: GymSpacing.sm);
  static const SizedBox md = SizedBox(width: GymSpacing.md, height: GymSpacing.md);
  static const SizedBox lg = SizedBox(width: GymSpacing.lg, height: GymSpacing.lg);
  static const SizedBox xl = SizedBox(width: GymSpacing.xl, height: GymSpacing.xl);
  static const SizedBox xxl = SizedBox(width: GymSpacing.xxl, height: GymSpacing.xxl);
  static const SizedBox xxxl = SizedBox(width: GymSpacing.xxxl, height: GymSpacing.xxxl);

  // Semantic gaps
  static const SizedBox screenH = SizedBox(width: GymSpacing.screenHorizontal);
  static const SizedBox screenV = SizedBox(height: GymSpacing.screenVertical);
  static const SizedBox section = SizedBox(height: GymSpacing.sectionGap);
}

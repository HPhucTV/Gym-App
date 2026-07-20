import 'package:flutter/material.dart';

class GymRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 999.0;

  // BorderRadius helpers
  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get lgBorder => BorderRadius.circular(lg);
  static BorderRadius get xlBorder => BorderRadius.circular(xl);
  static BorderRadius get xxlBorder => BorderRadius.circular(xxl);
  static BorderRadius get pillBorder => BorderRadius.circular(pill);

  // Radius objects
  static const Radius smRadius = Radius.circular(sm);
  static const Radius mdRadius = Radius.circular(md);
  static const Radius lgRadius = Radius.circular(lg);
  static const Radius xlRadius = Radius.circular(xl);
  static const Radius xxlRadius = Radius.circular(xxl);
  static const Radius pillRadius = Radius.circular(pill);
}

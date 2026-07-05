import 'dart:ui';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> shadowLow = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowMid = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowHigh = [
    BoxShadow(
      color: Color(0x29000000),
      offset: Offset(0, 8),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowNav = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, -2),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
}

import 'package:flutter/material.dart';

class AppColors {
  static const Color seed = Color(0xFF546E7A);
  static const Color primary = Colors.white;
  static const Color accent = Color(0xFF87DBE6);
  static const Color background = Color(0xFF1E1E1E);
  static const Color secondary = Color.fromARGB(255, 34, 48, 58);
  static const Color confirmed = Colors.greenAccent;

  static const Color transparent = Colors.transparent;
  static const Color shadow = Colors.black;
  static const Color danger = Colors.red;
  static const Color white24 = Colors.white24;
  static const Color white38 = Colors.white38;
  static const Color blueGreyLight = Color(0xFFCFD8DC);
  static const Color blueGreyMid = Color(0xFF78909C);
  static const Color blueGreyDark = Color(0xFF263238);
  static const Color blueGrey700 = Color(0xFF455A64);
  static const Color translucentAccent = Color(0x87DBE7FF);
  static const Color neutralSurface = Color(0xFFD9D9D9);
  static const Color neutralText = Color(0xFF342D2D);
  static const Color shadowSoft = Color(0x3F000000);

  static Color transparentBackground = primary.withValues(alpha: 0.08);
  static Color primaryMuted = primary.withValues(alpha: 0.4);
  static Color secondaryMuted = secondary.withValues(alpha: 0.6);

  static LinearGradient backgroundGradient(Color accentColor) {
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [accentColor, background],
    );
  }
}

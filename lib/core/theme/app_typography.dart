import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

TextTheme buildCairoTextTheme() {
  final TextTheme base = ThemeData.light().textTheme;
  return GoogleFonts.cairoTextTheme(base).apply(
    bodyColor: EidColors.textPrimary,
    displayColor: EidColors.darkGreen,
  );
}

TextStyle eidTitleStyle({double fontSize = 22}) {
  return GoogleFonts.cairo(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: EidColors.darkGreen,
    height: 1.3,
  );
}

TextStyle eidBodyStyle({double fontSize = 15}) {
  return GoogleFonts.cairo(
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    color: EidColors.textPrimary,
    height: 1.5,
  );
}

TextStyle eidButtonStyle() {
  return GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}

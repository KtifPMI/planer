import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required Color color,
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.4,
  }) {
    return GoogleFonts.inter(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }

  // Headings
  static TextStyle h1(Color c) => _base(color: c, fontSize: 28, fontWeight: FontWeight.w700);
  static TextStyle h2(Color c) => _base(color: c, fontSize: 24, fontWeight: FontWeight.w700);
  static TextStyle h3(Color c) => _base(color: c, fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle h4(Color c) => _base(color: c, fontSize: 17, fontWeight: FontWeight.w600);

  // Body
  static TextStyle bodyLarge(Color c) => _base(color: c, fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle bodyMedium(Color c) => _base(color: c, fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle bodySmall(Color c) => _base(color: c, fontSize: 12, fontWeight: FontWeight.w400);

  // Labels
  static TextStyle labelLarge(Color c) => _base(color: c, fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle labelMedium(Color c) => _base(color: c, fontSize: 12, fontWeight: FontWeight.w500);
  static TextStyle labelSmall(Color c) => _base(color: c, fontSize: 10, fontWeight: FontWeight.w500);

  // Button
  static TextStyle buttonLarge(Color c) => _base(color: c, fontSize: 16, fontWeight: FontWeight.w600, height: 1.2);
  static TextStyle buttonMedium(Color c) => _base(color: c, fontSize: 14, fontWeight: FontWeight.w600, height: 1.2);
}

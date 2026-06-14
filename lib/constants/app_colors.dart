import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color muted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color blueSoft = Color(0xFFEFF6FF);
  static const Color cyanSoft = Color(0xFFECFEFF);
  static const Color cyanBorder = Color(0xFFA5F3FC);
  static const Color successSoft = Color(0xFFF0FDF4);
  static const Color successBorder = Color(0xFFBBF7D0);

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0D0F172A), blurRadius: 20, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(color: Color(0x1F0F172A), blurRadius: 20, offset: Offset(0, 8)),
  ];
}

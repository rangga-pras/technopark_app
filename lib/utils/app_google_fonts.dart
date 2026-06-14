import 'package:flutter/material.dart';

class GoogleFonts {
  const GoogleFonts._();

  static TextTheme interTextTheme(TextTheme textTheme) {
    return textTheme.apply(fontFamily: 'Inter');
  }

  static TextStyle inter({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      fontFamily: 'Inter',
    );
  }
}

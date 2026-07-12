import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/app_google_fonts.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 58,
    this.height = 46,
    this.radius = 14,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          'T',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: height * 0.45,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

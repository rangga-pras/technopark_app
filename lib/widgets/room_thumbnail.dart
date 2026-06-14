import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class RoomThumbnail extends StatelessWidget {
  const RoomThumbnail({super.key, required this.capacity});

  final int capacity;

  @override
  Widget build(BuildContext context) {
    final isLargeRoom = capacity == 8;
    final backgroundColor = isLargeRoom
        ? AppColors.cyanSoft
        : AppColors.blueSoft;
    final floorColor = isLargeRoom ? AppColors.secondary : AppColors.primary;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 42,
            child: _miniShape(
              width: 42,
              height: 5,
              color: floorColor,
              radius: 3,
            ),
          ),
          Positioned(
            left: 12,
            top: 34,
            child: _miniShape(
              width: 34,
              height: 7,
              color: AppColors.primaryDark,
              radius: 4,
            ),
          ),
          Positioned(
            left: 20,
            top: 18,
            child: _miniShape(
              width: 18,
              height: 14,
              color: AppColors.textPrimary,
              radius: 3,
            ),
          ),
          Positioned(
            left: 23,
            top: 21,
            child: _miniShape(
              width: 12,
              height: 8,
              color: AppColors.secondary,
              radius: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniShape({
    required double width,
    required double height,
    required Color color,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

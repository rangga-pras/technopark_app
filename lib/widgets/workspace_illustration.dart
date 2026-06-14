import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class WorkspaceIllustration extends StatelessWidget {
  const WorkspaceIllustration({super.key, this.height = 178});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scaleX = constraints.maxWidth / 346;
          final scaleY = height / 178;
          double x(double value) => value * scaleX;
          double y(double value) => value * scaleY;
          double r(double value) => value * scaleX;

          return ClipRRect(
            borderRadius: BorderRadius.circular(r(32)),
            child: Stack(
              children: [
                Positioned.fill(child: Container(color: AppColors.blueSoft)),
                Positioned(
                  left: x(-42),
                  top: y(45),
                  child: _circle(x(92), Colors.white),
                ),
                Positioned(
                  right: x(-8),
                  top: 0,
                  child: Container(
                    width: x(98),
                    height: y(100),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFFAFE),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(r(32)),
                        bottomLeft: Radius.circular(r(90)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: x(98),
                  top: y(101),
                  child: _roundedBox(
                    width: x(150),
                    height: y(21),
                    color: AppColors.primaryDark,
                    radius: r(10),
                  ),
                ),
                Positioned(
                  left: x(42),
                  top: y(136),
                  child: _roundedBox(
                    width: x(262),
                    height: y(15),
                    color: AppColors.primary,
                    radius: r(10),
                  ),
                ),
                Positioned(
                  left: x(64),
                  top: y(112),
                  child: _circle(x(36), const Color(0xFFD9E8FF)),
                ),
                Positioned(
                  left: x(263),
                  top: y(112),
                  child: _circle(x(36), const Color(0xFFD9E8FF)),
                ),
                Positioned(
                  left: x(88),
                  top: y(55),
                  child: Container(
                    width: x(78),
                    height: y(50),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(r(10)),
                      border: Border.all(
                        color: const Color(0xFF67E8F9),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: x(175),
                  top: y(61),
                  child: Container(
                    width: x(70),
                    height: y(50),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(r(10)),
                    ),
                    child: Center(
                      child: _roundedBox(
                        width: x(52),
                        height: y(30),
                        color: AppColors.secondary,
                        radius: r(7),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _roundedBox({
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

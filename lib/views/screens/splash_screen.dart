import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_routes.dart';
import '../../constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_google_fonts.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/workspace_illustration.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final authController = context.read<AuthController>();
    await authController.initializeSession();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      authController.isAuthenticated ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const WorkspaceIllustration(height: 170),
                  const SizedBox(height: 26),
                  const AppLogo(width: 72, height: 60, radius: 18),
                  const SizedBox(height: 14),
                  Text(
                    'TechnoPark',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Free workspace booking',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 34),
                  const CircularProgressIndicator(color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/booking_controller.dart';
import 'controllers/room_controller.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/secure_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(TechnoParkApp(notificationService: notificationService));
}

class TechnoParkApp extends StatelessWidget {
  const TechnoParkApp({super.key, required this.notificationService});

  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(SecureStorageService()),
        ),
        ChangeNotifierProvider(create: (_) => RoomController(apiService)),
        ChangeNotifierProvider(
          create: (_) => BookingController(apiService, notificationService),
        ),
      ],
      child: MaterialApp(
        title: 'TechnoPark',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

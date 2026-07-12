import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/booking.dart';

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  Future<void> initialize() async {
    timezone_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettings = InitializationSettings(android: android);

      await _plugin.initialize(initializationSettings);
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
      _isInitialized = true;
    } catch (error) {
      debugPrint('Notification initialization skipped: $error');
    }
  }

  Future<void> showBookingConfirmation(Booking booking) async {
    if (!_isInitialized) {
      return;
    }

    await _plugin.show(
      _notificationId(booking.id, offset: 1),
      'Booking TechnoPark berhasil',
      'Booking ${booking.roomName} pada ${booking.startTime}-${booking.endTime} berhasil dibuat.',
      _notificationDetails,
    );
  }

  Future<void> scheduleBookingReminder(Booking booking) async {
    if (!_isInitialized) {
      return;
    }

    final startHour = int.tryParse(booking.startTime.split(':').first) ?? 0;
    final bookingStart = DateTime(
      booking.date.year,
      booking.date.month,
      booking.date.day,
      startHour,
    );
    final reminderAt = bookingStart.subtract(const Duration(minutes: 30));

    if (!reminderAt.isAfter(DateTime.now())) {
      return;
    }

    await _plugin.zonedSchedule(
      _notificationId(booking.id, offset: 2),
      'Pengingat booking TechnoPark',
      'Booking ${booking.roomName} dimulai dalam 30 menit.',
      tz.TZDateTime.from(reminderAt, tz.local),
      _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelBookingReminder(String bookingId) async {
    if (!_isInitialized) {
      return;
    }

    await _plugin.cancel(_notificationId(bookingId, offset: 2));
  }

  NotificationDetails get _notificationDetails {
    const android = AndroidNotificationDetails(
      'technopark_booking_channel',
      'Booking TechnoPark',
      channelDescription: 'Notifikasi konfirmasi dan pengingat booking.',
      importance: Importance.max,
      priority: Priority.high,
    );

    return const NotificationDetails(android: android);
  }

  int _notificationId(String bookingId, {required int offset}) {
    var hash = 0;
    for (final codeUnit in bookingId.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x3fffffff;
    }
    return hash + offset;
  }
}

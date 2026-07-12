import 'package:flutter/foundation.dart';

import '../config/booking_rules.dart';
import '../models/app_user.dart';
import '../models/booking.dart';
import '../models/room.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

enum BookingCategory { upcoming, completed, cancelled }

class BookingController extends ChangeNotifier {
  BookingController(this._apiService, this._notificationService);

  final ApiService _apiService;
  final NotificationService _notificationService;

  List<Booking> _bookings = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  DateTime? _selectedDate;
  BookingTimeSlot? _selectedTimeSlot;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  DateTime? get selectedDate => _selectedDate;
  BookingTimeSlot? get selectedTimeSlot => _selectedTimeSlot;

  Future<void> fetchUserBookings(AppUser user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allBookings = await _apiService.getBookings();
      _bookings =
          allBookings
              .where(
                (booking) =>
                    booking.userId == user.id ||
                    booking.userEmail.toLowerCase() == user.email.toLowerCase(),
              )
              .toList()
            ..sort((first, second) => first.date.compareTo(second.date));
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Booking tidak dapat dimuat. Periksa koneksi internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date == null ? null : _dateOnly(date);
    _errorMessage = null;
    notifyListeners();
  }

  void setSelectedTimeSlot(BookingTimeSlot? slot) {
    _selectedTimeSlot = slot;
    _errorMessage = null;
    notifyListeners();
  }

  void resetBookingForm() {
    _selectedDate = null;
    _selectedTimeSlot = null;
    _errorMessage = null;
    notifyListeners();
  }

  bool isDateSelectable(DateTime date) {
    final normalizedDate = _dateOnly(date);
    final today = _dateOnly(DateTime.now());
    return !normalizedDate.isBefore(today) && !BookingRules.isClosedDate(date);
  }

  String? validateBooking({
    required AppUser? user,
    required Room room,
    DateTime? date,
    BookingTimeSlot? timeSlot,
  }) {
    if (_isSubmitting) {
      return 'Booking sedang diproses. Mohon tunggu.';
    }
    if (user == null) {
      return 'Silakan login terlebih dahulu.';
    }
    if (date == null) {
      return 'Pilih tanggal penggunaan ruangan.';
    }
    if (!isDateSelectable(date)) {
      return 'Tanggal tidak valid. TechnoPark tutup pada Minggu, hari libur, dan tanggal yang sudah lewat.';
    }
    if (timeSlot == null) {
      return 'Pilih salah satu slot waktu tersedia.';
    }
    if (!_isSlotInsideOperationalHours(timeSlot)) {
      return 'Slot waktu harus berada di antara pukul 09:00 sampai 19:00.';
    }

    final hasBookingOnSameDate = _bookings.any(
      (booking) =>
          booking.status != 'cancelled' &&
          booking.status != 'canceled' &&
          _isSameDate(booking.date, date),
    );
    if (hasBookingOnSameDate) {
      return 'Satu akun hanya dapat memiliki satu booking untuk tanggal penggunaan yang sama.';
    }
    if (!room.isAvailable) {
      return 'Ruangan ini sedang tidak tersedia.';
    }

    return null;
  }

  Future<Booking?> createBooking({
    required AppUser user,
    required Room room,
  }) async {
    final validationMessage = validateBooking(
      user: user,
      room: room,
      date: _selectedDate,
      timeSlot: _selectedTimeSlot,
    );
    if (validationMessage != null) {
      _errorMessage = validationMessage;
      notifyListeners();
      return null;
    }

    final date = _selectedDate!;
    final timeSlot = _selectedTimeSlot!;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final draft = Booking(
        id: '',
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        roomId: room.id,
        roomName: room.name,
        date: date,
        startTime: timeSlot.startTime,
        endTime: timeSlot.endTime,
        durationHours: BookingRules.durationHours,
        status: 'upcoming',
        createdAt: DateTime.now(),
      );
      final createdBooking = await _apiService.createBooking(draft);
      _bookings = [createdBooking, ..._bookings]
        ..sort((first, second) => first.date.compareTo(second.date));

      await _notificationService.showBookingConfirmation(createdBooking);
      await _notificationService.scheduleBookingReminder(createdBooking);
      return createdBooking;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = 'Booking gagal dibuat. Silakan coba lagi.';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(Booking booking) async {
    if (!canCancel(booking)) {
      _errorMessage = 'Hanya booking mendatang yang dapat dibatalkan.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteBooking(booking.id);
      _bookings = _bookings
          .map(
            (item) => item.id == booking.id
                ? item.copyWith(status: 'cancelled')
                : item,
          )
          .toList();
      await _notificationService.cancelBookingReminder(booking.id);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Booking tidak dapat dibatalkan.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  List<Booking> bookingsForCategory(BookingCategory category) {
    return _bookings.where((booking) {
      switch (category) {
        case BookingCategory.upcoming:
          return booking.status != 'cancelled' &&
              booking.status != 'canceled' &&
              !_dateOnly(booking.date).isBefore(_dateOnly(DateTime.now()));
        case BookingCategory.completed:
          return booking.status == 'completed' ||
              _dateOnly(booking.date).isBefore(_dateOnly(DateTime.now()));
        case BookingCategory.cancelled:
          return booking.status == 'cancelled' || booking.status == 'canceled';
      }
    }).toList();
  }

  bool canCancel(Booking booking) {
    return booking.status != 'cancelled' &&
        booking.status != 'canceled' &&
        _dateOnly(booking.date).isAfter(_dateOnly(DateTime.now()));
  }

  bool _isSlotInsideOperationalHours(BookingTimeSlot timeSlot) {
    final startHour = int.tryParse(timeSlot.startTime.split(':').first) ?? -1;
    final endHour = int.tryParse(timeSlot.endTime.split(':').first) ?? -1;
    return startHour >= BookingRules.openingHour &&
        endHour <= BookingRules.closingHour &&
        endHour - startHour == BookingRules.durationHours;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

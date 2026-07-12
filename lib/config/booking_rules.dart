import '../models/booking.dart';

class BookingRules {
  const BookingRules._();

  static const int openingHour = 9;
  static const int closingHour = 19;
  static const int durationHours = 2;

  static const List<BookingTimeSlot> timeSlots = [
    BookingTimeSlot(startTime: '09:00', endTime: '11:00'),
    BookingTimeSlot(startTime: '11:00', endTime: '13:00'),
    BookingTimeSlot(startTime: '13:00', endTime: '15:00'),
    BookingTimeSlot(startTime: '15:00', endTime: '17:00'),
    BookingTimeSlot(startTime: '17:00', endTime: '19:00'),
  ];

  // Update this local configuration when a new Indonesian holiday calendar is published.
  static const Set<String> nationalHolidayDateKeys = {
    '2026-01-01',
    '2026-01-16',
    '2026-03-19',
    '2026-03-20',
    '2026-03-21',
    '2026-04-03',
    '2026-05-01',
    '2026-05-14',
    '2026-05-27',
    '2026-06-01',
    '2026-06-16',
    '2026-08-17',
    '2026-08-26',
    '2026-12-25',
  };

  static bool isClosedDate(DateTime date) {
    return date.weekday == DateTime.sunday ||
        nationalHolidayDateKeys.contains(dateKey(date));
  }

  static String dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

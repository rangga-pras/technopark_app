import 'package:flutter_test/flutter_test.dart';
import 'package:technopark_app/config/booking_rules.dart';
import 'package:technopark_app/controllers/auth_controller.dart';
import 'package:technopark_app/controllers/booking_controller.dart';
import 'package:technopark_app/models/app_user.dart';
import 'package:technopark_app/models/booking.dart';
import 'package:technopark_app/models/room.dart';
import 'package:technopark_app/services/api_service.dart';
import 'package:technopark_app/services/notification_service.dart';
import 'package:technopark_app/services/secure_storage_service.dart';

void main() {
  const user = AppUser(
    id: 'user-1',
    name: 'Rangga',
    email: 'rangga@student.ac.id',
    password: '123456',
  );
  const room = Room(
    id: 'room-1',
    name: 'Ruang Adi Soemarmo',
    capacity: 4,
    description: 'Ruang diskusi',
    facilities: ['WiFi'],
    isAvailable: true,
    visualVariant: 0,
  );

  group('BookingController validation', () {
    test('rejects a Sunday and a past date', () {
      final controller = BookingController(
        _FakeApiService(),
        _FakeNotificationService(),
      );
      final sunday = _nextSunday();
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      expect(
        controller.validateBooking(
          user: user,
          room: room,
          date: sunday,
          timeSlot: BookingRules.timeSlots.first,
        ),
        contains('Tanggal tidak valid'),
      );
      expect(
        controller.validateBooking(
          user: user,
          room: room,
          date: pastDate,
          timeSlot: BookingRules.timeSlots.first,
        ),
        contains('Tanggal tidak valid'),
      );
    });

    test('prevents a second booking on the same usage date', () async {
      final bookingDate = _nextValidDate();
      final apiService = _FakeApiService(
        bookings: [
          Booking(
            id: 'booking-1',
            userId: user.id,
            userName: user.name,
            userEmail: user.email,
            roomId: room.id,
            roomName: room.name,
            date: bookingDate,
            startTime: '09:00',
            endTime: '11:00',
            durationHours: 2,
            status: 'upcoming',
            createdAt: DateTime.now(),
          ),
        ],
      );
      final controller = BookingController(
        apiService,
        _FakeNotificationService(),
      );

      await controller.fetchUserBookings(user);
      final message = controller.validateBooking(
        user: user,
        room: room,
        date: bookingDate,
        timeSlot: BookingRules.timeSlots[2],
      );

      expect(
        message,
        contains('satu booking untuk tanggal penggunaan yang sama'),
      );
    });
  });

  group('AuthController local session', () {
    test('keeps the demo account and persists the active session', () async {
      final storage = _FakeSecureStorageService();
      final controller = AuthController(storage);

      await controller.initializeSession();
      expect(controller.isAuthenticated, isFalse);

      final isLoggedIn = await controller.login(
        email: 'rangga@student.ac.id',
        password: '123456',
      );
      expect(isLoggedIn, isTrue);
      expect(controller.currentUser?.name, 'Rangga');
      expect(storage.activeUser?.email, 'rangga@student.ac.id');

      await controller.logout();
      expect(controller.isAuthenticated, isFalse);
      expect(storage.activeUser, isNull);
    });
  });
}

DateTime _nextValidDate() {
  var date = DateTime.now().add(const Duration(days: 1));
  while (BookingRules.isClosedDate(date)) {
    date = date.add(const Duration(days: 1));
  }
  return DateTime(date.year, date.month, date.day);
}

DateTime _nextSunday() {
  var date = DateTime.now().add(const Duration(days: 1));
  while (date.weekday != DateTime.sunday) {
    date = date.add(const Duration(days: 1));
  }
  return DateTime(date.year, date.month, date.day);
}

class _FakeApiService extends ApiService {
  _FakeApiService({this.bookings = const []});

  final List<Booking> bookings;

  @override
  Future<List<Booking>> getBookings() async => bookings;
}

class _FakeNotificationService extends NotificationService {
  @override
  Future<void> scheduleBookingReminder(Booking booking) async {}

  @override
  Future<void> showBookingConfirmation(Booking booking) async {}
}

class _FakeSecureStorageService extends SecureStorageService {
  List<AppUser> users = [];
  AppUser? activeUser;

  @override
  Future<void> clearActiveUser() async {
    activeUser = null;
  }

  @override
  Future<List<AppUser>> readAccounts() async => users;

  @override
  Future<AppUser?> readActiveUser() async => activeUser;

  @override
  Future<void> saveAccounts(List<AppUser> accounts) async {
    users = accounts;
  }

  @override
  Future<void> saveActiveUser(AppUser user) async {
    activeUser = user;
  }
}

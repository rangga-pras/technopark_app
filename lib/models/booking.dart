class BookingTimeSlot {
  const BookingTimeSlot({required this.startTime, required this.endTime});

  final String startTime;
  final String endTime;

  String get label => '$startTime - $endTime';
}

class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.roomId,
    required this.roomName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String roomId;
  final String roomName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int durationHours;
  final String status;
  final DateTime createdAt;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userEmail: json['userEmail']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? '',
      roomName: json['roomName']?.toString() ?? 'Ruang TechnoPark',
      date: _toDate(json['date']),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      durationHours: _toInt(json['durationHours']) == 0
          ? 2
          : _toInt(json['durationHours']),
      status: json['status']?.toString().toLowerCase() ?? 'upcoming',
      createdAt: _toDate(json['createdAt']),
    );
  }

  Booking copyWith({String? id, String? status}) {
    return Booking(
      id: id ?? this.id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      roomId: roomId,
      roomName: roomName,
      date: date,
      startTime: startTime,
      endTime: endTime,
      durationHours: durationHours,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'roomId': roomId,
      'roomName': roomName,
      'date': _dateKey(date),
      'startTime': startTime,
      'endTime': endTime,
      'durationHours': durationHours,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static DateTime _toDate(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

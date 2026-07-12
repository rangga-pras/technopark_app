import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/booking.dart';
import '../models/room.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Room>> getRooms() async {
    _ensureConfigured();
    final response = await _client.get(ApiConfig.roomsUri, headers: _headers);
    final data = _decodeList(response, 'ruangan');

    return data
        .whereType<Map<String, dynamic>>()
        .map(Room.fromJson)
        .where((room) => room.id.isNotEmpty)
        .toList();
  }

  Future<List<Booking>> getBookings() async {
    _ensureConfigured();
    final response = await _client.get(
      ApiConfig.bookingsUri,
      headers: _headers,
    );
    final data = _decodeList(response, 'booking');

    return data
        .whereType<Map<String, dynamic>>()
        .map(Booking.fromJson)
        .where((booking) => booking.id.isNotEmpty)
        .toList();
  }

  Future<Booking> createBooking(Booking booking) async {
    _ensureConfigured();
    final response = await _client.post(
      ApiConfig.bookingsUri,
      headers: _headers,
      body: jsonEncode(booking.toJson()..remove('id')),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Gagal membuat booking. Server mengembalikan status ${response.statusCode}.',
      );
    }

    final decoded = _decodeObject(response, 'booking');
    final created = Booking.fromJson(decoded);

    return created.id.isEmpty ? booking : created;
  }

  Future<void> deleteBooking(String bookingId) async {
    _ensureConfigured();
    final response = await _client.delete(
      ApiConfig.bookingUri(bookingId),
      headers: _headers,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Gagal membatalkan booking. Server mengembalikan status ${response.statusCode}.',
      );
    }
  }

  Map<String, String> get _headers => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void _ensureConfigured() {
    if (!ApiConfig.isConfigured) {
      throw const ApiException(ApiConfig.setupMessage);
    }
  }

  List<dynamic> _decodeList(http.Response response, String resourceName) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Gagal memuat $resourceName. Server mengembalikan status ${response.statusCode}.',
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is List<dynamic>) {
        return decoded;
      }
    } on FormatException {
      // The generic message below gives users a useful retry state.
    }

    throw ApiException('Data $resourceName dari server tidak valid.');
  }

  Map<String, dynamic> _decodeObject(
    http.Response response,
    String resourceName,
  ) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } on FormatException {
      // The generic message below gives users a useful retry state.
    }

    throw ApiException('Respons $resourceName dari server tidak valid.');
  }
}

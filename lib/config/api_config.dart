class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'TECHNOPARK_API_BASE_URL',
    defaultValue: '[PASTE_MOCKAPI_BASE_URL_HERE]',
  );

  static bool get isConfigured {
    final uri = Uri.tryParse(normalizedBaseUrl);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static String get normalizedBaseUrl {
    return baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
  }

  static Uri get roomsUri => Uri.parse('$normalizedBaseUrl/rooms');
  static Uri get bookingsUri => Uri.parse('$normalizedBaseUrl/bookings');

  static Uri bookingUri(String bookingId) {
    return Uri.parse('$normalizedBaseUrl/bookings/$bookingId');
  }

  static const String setupMessage =
      'Alamat MockAPI belum dikonfigurasi. Jalankan aplikasi dengan '
      '--dart-define=TECHNOPARK_API_BASE_URL=https://<mockapi-id>.mockapi.io/api/v1.';
}

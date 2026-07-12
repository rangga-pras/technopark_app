import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/app_user.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accountsKey = 'technopark_accounts';
  static const _activeUserKey = 'technopark_active_user';

  final FlutterSecureStorage _storage;

  Future<List<AppUser>> readAccounts() async {
    final rawValue = await _storage.read(key: _accountsKey);
    if (rawValue == null || rawValue.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(AppUser.fromJson)
          .where((user) => user.email.isNotEmpty)
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> saveAccounts(List<AppUser> users) {
    return _storage.write(
      key: _accountsKey,
      value: jsonEncode(users.map((user) => user.toJson()).toList()),
    );
  }

  Future<AppUser?> readActiveUser() async {
    final rawValue = await _storage.read(key: _activeUserKey);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is Map<String, dynamic>) {
        return AppUser.fromJson(decoded);
      }
    } on FormatException {
      return null;
    }

    return null;
  }

  Future<void> saveActiveUser(AppUser user) {
    return _storage.write(
      key: _activeUserKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<void> clearActiveUser() {
    return _storage.delete(key: _activeUserKey);
  }
}

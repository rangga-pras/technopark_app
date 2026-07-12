import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/secure_storage_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._storageService);

  static const _demoUser = AppUser(
    id: 'demo-rangga',
    name: 'Rangga',
    email: 'rangga@student.ac.id',
    password: '123456',
  );

  final SecureStorageService _storageService;

  AppUser? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initializeSession() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _ensureDemoAccount();
      _currentUser = await _storageService.readActiveUser();
    } catch (_) {
      _errorMessage = 'Sesi lokal tidak dapat dibaca. Silakan login kembali.';
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final users = await _loadAccounts();
      final normalizedEmail = email.trim().toLowerCase();
      final user = users.cast<AppUser?>().firstWhere(
        (item) =>
            item?.email.toLowerCase() == normalizedEmail &&
            item?.password == password,
        orElse: () => null,
      );

      if (user == null) {
        _errorMessage = 'Email atau password salah.';
        return false;
      }

      _currentUser = user;
      await _storageService.saveActiveUser(user);
      return true;
    } catch (_) {
      _errorMessage = 'Login gagal. Coba lagi beberapa saat lagi.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final users = await _loadAccounts();
      final normalizedEmail = email.trim().toLowerCase();

      if (users.any((user) => user.email.toLowerCase() == normalizedEmail)) {
        _errorMessage = 'Email sudah terdaftar. Silakan gunakan email lain.';
        return false;
      }

      final user = AppUser(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        email: normalizedEmail,
        password: password,
      );
      await _storageService.saveAccounts([...users, user]);
      return true;
    } catch (_) {
      _errorMessage = 'Registrasi gagal disimpan di perangkat.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _storageService.clearActiveUser();
      _currentUser = null;
    } catch (_) {
      _errorMessage = 'Logout gagal. Silakan coba lagi.';
    } finally {
      _setLoading(false);
    }
  }

  Future<List<AppUser>> _loadAccounts() async {
    final users = await _storageService.readAccounts();
    if (users.isEmpty) {
      await _storageService.saveAccounts([_demoUser]);
      return [_demoUser];
    }
    return users;
  }

  Future<void> _ensureDemoAccount() async {
    final users = await _storageService.readAccounts();
    if (users.any((user) => user.email == _demoUser.email)) {
      return;
    }
    await _storageService.saveAccounts([...users, _demoUser]);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

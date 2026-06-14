import '../models/app_user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final List<AppUser> _users = [
    const AppUser(
      name: 'Rangga',
      email: 'rangga@student.ac.id',
      password: '123456',
    ),
  ];

  AppUser? currentUser;

  bool emailExists(String email) {
    final normalizedEmail = email.trim().toLowerCase();

    for (final user in _users) {
      if (user.email.toLowerCase() == normalizedEmail) {
        return true;
      }
    }

    return false;
  }

  AppUser? login({required String email, required String password}) {
    final normalizedEmail = email.trim().toLowerCase();

    for (final user in _users) {
      final isEmailMatch = user.email.toLowerCase() == normalizedEmail;
      final isPasswordMatch = user.password == password;

      if (isEmailMatch && isPasswordMatch) {
        currentUser = user;
        return user;
      }
    }

    return null;
  }

  bool register({
    required String name,
    required String email,
    required String password,
  }) {
    if (emailExists(email)) {
      return false;
    }

    _users.add(
      AppUser(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
      ),
    );

    return true;
  }
}

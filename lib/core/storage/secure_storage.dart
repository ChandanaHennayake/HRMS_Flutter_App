import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _fullNameKey = 'full_name';
  static const String _roleIdKey = 'role_id';
  static const String _roleKey = 'role';
  static const String _companyIdKey = 'company_id';
  static const String _branchIdKey = 'branch_id';
  static const String _expirationKey = 'token_expiration';

  // NEW
  static const String _rememberMeKey = 'remember_me';

  static Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> saveRememberMe(bool value) async {
    await _storage.write(
      key: _rememberMeKey,
      value: value.toString(),
    );
  }

  static Future<bool> getRememberMe() async {
    final value = await _storage.read(
      key: _rememberMeKey,
    );

    return value == 'true';
  }

  static Future<void> saveUser({
    required int userId,
    required String username,
    required String email,
    required String fullName,
    required int roleId,
    required String role,
    required int companyId,
    required int branchId,
    DateTime? expiration,
  }) async {
    await _storage.write(
      key: _userIdKey,
      value: userId.toString(),
    );

    await _storage.write(
      key: _usernameKey,
      value: username,
    );

    await _storage.write(
      key: _emailKey,
      value: email,
    );

    await _storage.write(
      key: _fullNameKey,
      value: fullName,
    );

    await _storage.write(
      key: _roleIdKey,
      value: roleId.toString(),
    );

    await _storage.write(
      key: _roleKey,
      value: role,
    );

    await _storage.write(
      key: _companyIdKey,
      value: companyId.toString(),
    );

    await _storage.write(
      key: _branchIdKey,
      value: branchId.toString(),
    );

    if (expiration != null) {
      await _storage.write(
        key: _expirationKey,
        value: expiration.toIso8601String(),
      );
    }
  }

  static Future<DateTime?> getTokenExpiration() async {
    final value = await _storage.read(
      key: _expirationKey,
    );

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
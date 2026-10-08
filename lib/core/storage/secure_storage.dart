import 'package:alionhr/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _employeeIdKey = 'employee_id';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _fullNameKey = 'full_name';
  static const String _roleIdKey = 'role_id';
  static const String _roleKey = 'role';
  static const String _companyIdKey = 'company_id';
  static const String _branchIdKey = 'branch_id';
  static const String _expirationKey = 'token_expiration';
  static const String _rememberMeKey = 'remember_me';
  static const String _refreshTokenKey = 'refresh_token';

  // =========================
  // TOKEN
  // =========================

  static Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: _refreshTokenKey,
      value: token,
    );
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  // =========================
  // REMEMBER ME
  // =========================

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

  // =========================
  // USER
  // =========================

  static Future<void> saveUser({
    required int userId,
    required int employeeId,
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
      key: _employeeIdKey,
      value: employeeId.toString(),
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

  // =========================
  // GET USER
  // =========================

  static Future<User?> getUser() async {
    final userId =
        await _storage.read(key: _userIdKey);

    final employeeId =
        await _storage.read(key: _employeeIdKey);

    final username =
        await _storage.read(key: _usernameKey);

    final email =
        await _storage.read(key: _emailKey);

    final fullName =
        await _storage.read(key: _fullNameKey);

    final roleId =
        await _storage.read(key: _roleIdKey);

    final role =
        await _storage.read(key: _roleKey);

    final companyId =
        await _storage.read(key: _companyIdKey);

    final branchId =
        await _storage.read(key: _branchIdKey);

    if (userId == null ||
        employeeId == null ||
        username == null ||
        roleId == null ||
        role == null ||
        companyId == null ||
        branchId == null) {
      return null;
    }

    return User(
      userId: int.tryParse(userId) ?? 0,
      employeeId: int.tryParse(employeeId) ?? 0,
      username: username,
      email: email ?? '',
      fullName: fullName ?? '',
      roleId: int.tryParse(roleId) ?? 0,
      role: role,
      companyId: int.tryParse(companyId) ?? 0,
      branchId: int.tryParse(branchId) ?? 0,
    );
  }

  // =========================
  // USER ID
  // =========================

  static Future<int?> getUserId() async {
    final value = await _storage.read(
      key: _userIdKey,
    );

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  // =========================
  // EMPLOYEE ID
  // =========================

  static Future<int?> getEmployeeId() async {
    final value = await _storage.read(
      key: _employeeIdKey,
    );

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  // =========================
  // TOKEN EXPIRATION
  // =========================

  static Future<DateTime?> getTokenExpiration() async {
    final value = await _storage.read(
      key: _expirationKey,
    );

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  // =========================
  // CLEAR
  // =========================

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
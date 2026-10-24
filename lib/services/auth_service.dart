import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/login_response.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<LoginResponse> login({
  required String username,
  required String password,
  required bool rememberMe,
}) async {
  final response = await _apiClient.post(
    ApiConstants.login,
    requiresAuth: false,
    body: {
      'username': username,
      'password': password,
    },
  );

  if (response.statusCode >= 200 &&
      response.statusCode < 300) {
    final json = jsonDecode(response.body);

    final result = LoginResponse.fromJson(json);

    if (result.success && result.data != null) {
      final data = result.data!;

      await SecureStorage.saveToken(
        data.token,
      );

      if (data.refreshToken != null && data.refreshToken!.isNotEmpty) {
        await SecureStorage.saveRefreshToken(data.refreshToken!);
      }

      await SecureStorage.saveRememberMe(
        rememberMe,
      );

      await SecureStorage.saveUser(
        userId: data.user.userId,
        employeeId: data.user.employeeId,
        username: data.user.username,
        email: data.user.email,
        fullName: data.user.fullName,
        roleId: data.user.roleId,
        role: data.user.role,
        companyId: data.user.companyId,
        branchId: data.user.branchId,
        branchName: data.user.branchName,
        expiration: data.expiration,
      );

    }

    return result;
  }

  String message = 'Login failed.';

  try {
    final json = jsonDecode(response.body);
    message = json['message'] ?? message;
  } catch (_) {
    if (response.statusCode == 401) {
      message = 'Invalid username or password.';
    } else if (response.statusCode >= 500) {
      message = 'Server error. Please try again.';
    }
  }

  return LoginResponse(
    success: false,
    message: message,
  );
}

  Future<bool> refreshToken() async {
    final token = await SecureStorage.getToken();
    final refreshToken = await SecureStorage.getRefreshToken();
    if (token == null || refreshToken == null) return false;

    try {
      final response = await _apiClient.post(
        ApiConstants.refreshToken,
        requiresAuth: false,
        body: {
          'token': token,
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          final newToken = json['data']['token'];
          final newRefreshToken = json['data']['refreshToken'];
          if (newToken != null) await SecureStorage.saveToken(newToken);
          if (newRefreshToken != null) {
            await SecureStorage.saveRefreshToken(newRefreshToken);
          }
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<void> logout() async {
    await SecureStorage.clear();
  }
}
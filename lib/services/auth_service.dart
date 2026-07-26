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

        await SecureStorage.saveToken(data.token);

        await SecureStorage.saveUser(
          userId: data.user.userId,
          username: data.user.username,
          role: data.user.role,
          companyId: data.user.companyId,
          branchId: data.user.branchId,
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

  Future<void> logout() async {
    await SecureStorage.clear();
  }
}
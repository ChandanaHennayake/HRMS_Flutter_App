import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  Future<User?> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty ||
        password.isEmpty) {
      errorMessage = 'Please enter username and password.';
      notifyListeners();

      return null;
    }

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      final response = await _authService.login(
        username: username.trim(),
        password: password,
      );

      if (!response.success || response.data == null) {
        errorMessage = response.message;
        return null;
      }

      return response.data!.user;
    } catch (_) {
      errorMessage =
          'Unable to connect to the server.';

      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
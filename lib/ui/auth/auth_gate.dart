import 'package:flutter/material.dart';

import '../../core/storage/secure_storage.dart';
import '../../models/user.dart';
import '../home/home_view.dart';
import 'login_view.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Check whether user selected Remember Me.
    final rememberMe = await SecureStorage.getRememberMe();

    if (!rememberMe) {
      _goToLogin();
      return;
    }

    // Get saved JWT.
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      _goToLogin();
      return;
    }

    // Check token expiration.
    final expiration =
        await SecureStorage.getTokenExpiration();

    if (expiration == null ||
        DateTime.now().toUtc().isAfter(
          expiration.toUtc(),
        )) {
      await SecureStorage.clear();

      _goToLogin();
      return;
    }

    // Restore logged-in user.
    final user = await SecureStorage.getUser();

    if (user == null) {
      await SecureStorage.clear();

      _goToLogin();
      return;
    }

    _goToHome(user);
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginView(),
      ),
    );
  }

  void _goToHome(User user) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeView(
          user: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B0614),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFA855F7),
        ),
      ),
    );
  }
}
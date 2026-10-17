import 'dart:math';

import 'package:flutter/material.dart';

import 'login_view_model.dart';
import '../home/home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final LoginViewModel viewModel = LoginViewModel();

  bool hidePassword = true;
  bool rememberMe = true;

  static const Color deepDark = Color(0xFF0B0614);
  static const Color midPurple = Color(0xFF260A45);
  static const Color violet = Color(0xFF7C2FCE);
  static const Color brightViolet = Color(0xFFA855F7);
  static const Color textMuted = Color(0xFF8B87A0);

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    viewModel.removeListener(_onViewModelChanged);
    viewModel.dispose();
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN ACTION
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final username = idController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty) {
      _showErrorSnackBar('Please enter your Employee ID or username.');
      return;
    }

    if (password.isEmpty) {
      _showErrorSnackBar('Please enter your password.');
      return;
    }

    final user = await viewModel.login(
      username: username,
      password: password,
      rememberMe: rememberMe,
    );

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeView(user: user),
        ),
      );
      return;
    }

    _showErrorSnackBar(viewModel.errorMessage ?? 'Login failed. Please check credentials.');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              deepDark,
              midPurple,
              Color(0xFF3B0B63),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Ambient glowing background orbs
            Positioned(
              top: -40,
              right: -30,
              child: _ringCircle(140, Colors.white.withValues(alpha: 0.05)),
            ),
            Positioned(
              top: 180,
              left: -50,
              child: _ringCircle(100, brightViolet.withValues(alpha: 0.08)),
            ),

            // Subtle particle dots in background
            Positioned.fill(
              child: CustomPaint(
                painter: _GlobeDotsPainter(),
              ),
            ),

            // Scrollable Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Official Logo Header
                      _buildLogoHeader(),

                      const SizedBox(height: 12),

                      // Login Card
                      _buildLoginCard(),

                      const SizedBox(height: 20),

                      // IT Support & System Version footer
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGO HEADER
  // ============================================================

  Widget _buildLogoHeader() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220, maxHeight: 130),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset(
          'lib/assets/images/alien_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fingerprint, color: Colors.white, size: 48),
                SizedBox(height: 6),
                Text(
                  'AlienHR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN CARD
  // ============================================================

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B2E),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sign in to your AlienHR enterprise workspace',
            style: TextStyle(
              fontSize: 13.5,
              color: textMuted,
            ),
          ),

          const SizedBox(height: 22),

          // Username Field
          const Text(
            'Employee ID / Username',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF2D293D),
            ),
          ),
          const SizedBox(height: 7),
          TextField(
            controller: idController,
            enabled: !viewModel.isLoading,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(fontSize: 14.5, color: Color(0xFF1E1B2E)),
            decoration: _fieldDecoration(
              hint: 'e.g. admin or EMP001',
              icon: Icons.person_outline_rounded,
            ),
          ),

          const SizedBox(height: 16),

          // Password Field
          const Text(
            'Password',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF2D293D),
            ),
          ),
          const SizedBox(height: 7),
          TextField(
            controller: passwordController,
            enabled: !viewModel.isLoading,
            obscureText: hidePassword,
            textInputAction: TextInputAction.done,
            enableSuggestions: false,
            autocorrect: false,
            style: const TextStyle(fontSize: 14.5, color: Color(0xFF1E1B2E)),
            onSubmitted: (_) {
              if (!viewModel.isLoading) {
                _login();
              }
            },
            decoration: _fieldDecoration(
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF7C2FCE),
                  size: 20,
                ),
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Remember Me Row
          InkWell(
            onTap: viewModel.isLoading
                ? null
                : () {
                    setState(() {
                      rememberMe = !rememberMe;
                    });
                  },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: rememberMe,
                      activeColor: violet,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: viewModel.isLoading
                          ? null
                          : (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Text(
                    'Remember me',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B4560),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: viewModel.isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: violet.withValues(alpha: 0.4),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [brightViolet, violet],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: viewModel.isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Signing In...',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 19,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER (SUPPORT & BRAND)
  // ============================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Need help? Contact ',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
              ),
            ),
            const Text(
              'IT Support',
              style: TextStyle(
                color: Color(0xFFC084FC),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.headset_mic_outlined,
              size: 16,
              color: Color(0xFFC084FC),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'AlienHR Enterprise v1.0.0',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 11,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TEXT FIELD DECORATION
  // ============================================================

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 13.5,
      ),
      prefixIcon: Icon(
        icon,
        color: violet,
        size: 20,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF9F7FB),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5DBEC),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5DBEC),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: violet,
          width: 1.8,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
    );
  }

  Widget _ringCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
    );
  }
}

// ================================================================
// BACKGROUND DOTS PAINTER
// ================================================================

class _GlobeDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.22);
    final glowPaint = Paint()..color = const Color(0xFFA855F7).withValues(alpha: 0.45);

    for (int i = 0; i < 35; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;

      final isGlow = i % 5 == 0;

      canvas.drawCircle(
        Offset(dx, dy),
        isGlow ? 1.8 : 1.0,
        isGlow ? glowPaint : dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
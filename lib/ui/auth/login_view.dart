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
  bool rememberMe = false;

  static const Color deepDark = Color(0xFF0B0614);
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
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final user = await viewModel.login(
      username: idController.text,
      password: passwordController.text,
      rememberMe: rememberMe,
    );

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeView(
            user: user,
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ?? 'Login failed.',
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
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
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              deepDark,
              Color(0xFF3B0B63),
              violet,
            ],
            stops: [
              0.0,
              0.55,
              1.0,
            ],
          ),
        ),
        child: Stack(
          children: [
            // ====================================================
            // BACKGROUND DECORATION
            // ====================================================

            Positioned(
              top: 60,
              left: -50,
              child: _ringCircle(
                120,
                Colors.white.withValues(
                  alpha: 0.06,
                ),
              ),
            ),

            Positioned(
              top: 420,
              right: -40,
              child: _ringCircle(
                90,
                Colors.white.withValues(
                  alpha: 0.05,
                ),
              ),
            ),

            // ====================================================
            // CONTENT
            // ====================================================

            SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    _buildLogoHeader(),

                    const SizedBox(height: 10),

                    _buildLoginCard(),

                    const SizedBox(height: 30),

                    _buildGlobeBanner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogoHeader() {
    return Center(
      child: SizedBox(
        width: 270,
        height: 220,
        child: Image.asset(
          'lib/assets/images/alien_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hub_outlined,
                  color: Colors.white,
                  size: 60,
                ),
                SizedBox(height: 10),
                Text(
                  'AlienHR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
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
  // DECORATIVE RING
  // ============================================================

  Widget _ringCircle(
    double size,
    Color color,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN CARD
  // ============================================================

  Widget _buildLoginCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.fromLTRB(
        24,
        28,
        24,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.35,
            ),
            blurRadius: 30,
            offset: const Offset(
              0,
              12,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====================================================
          // TITLE
          // ====================================================

          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B2E),
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Login to your AlienHR account',
            style: TextStyle(
              fontSize: 14,
              color: textMuted,
            ),
          ),

          const SizedBox(height: 24),

          // ====================================================
          // USERNAME
          // ====================================================

          const Text(
            'Employee ID / Username',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: Color(0xFF2D293D),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: idController,
            enabled: !viewModel.isLoading,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            decoration: _fieldDecoration(
              hint: 'Enter your employee ID or username',
              icon: Icons.person_outline,
            ),
          ),

          const SizedBox(height: 18),

          // ====================================================
          // PASSWORD
          // ====================================================

          const Text(
            'Password',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: Color(0xFF2D293D),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: passwordController,
            enabled: !viewModel.isLoading,
            obscureText: hidePassword,
            textInputAction: TextInputAction.done,
            enableSuggestions: false,
            autocorrect: false,
            onSubmitted: (_) {
              if (!viewModel.isLoading) {
                _login();
              }
            },
            decoration: _fieldDecoration(
              hint: 'Enter your password',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey[600],
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

          const SizedBox(height: 16),

          // ====================================================
          // REMEMBER ME
          // ====================================================

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
              padding: const EdgeInsets.symmetric(
                vertical: 4,
              ),
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
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
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

                  const SizedBox(width: 10),

                  const Text(
                    'Remember me',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B4560),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ====================================================
          // LOGIN BUTTON
          // ====================================================

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : _login,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                elevation: 0,
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: viewModel.isLoading
                        ? [
                            const Color(0xFF6B4A88),
                            const Color(0xFF8B5FA8),
                          ]
                        : [
                            const Color(0xFF4C1D95),
                            brightViolet,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: viewModel.isLoading
                      ? const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 21,
                              height: 21,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Signing in...',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ====================================================
          // IT SUPPORT
          // ====================================================

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Need help? Contact ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const Text(
                  'IT Support',
                  style: TextStyle(
                    color: violet,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.headset_mic_outlined,
                  size: 18,
                  color: violet,
                ),
              ],
            ),
          ),
        ],
      ),
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
        color: Colors.grey[400],
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: violet,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFCFBFD),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0D3EA),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0D3EA),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: violet,
          width: 1.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
    );
  }

  // ============================================================
  // GLOBE / NETWORK BANNER
  // ============================================================

  Widget _buildGlobeBanner() {
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: ClipPath(
        clipper: _GlobeClipper(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1.4),
              radius: 1.4,
              colors: [
                Color(0xFF6D28D9),
                Color(0xFF1A0B2E),
                Color(0xFF0B0614),
              ],
              stops: [
                0.0,
                0.55,
                1.0,
              ],
            ),
          ),
          child: CustomPaint(
            size: Size.infinite,
            painter: _GlobeDotsPainter(),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// GLOBE CLIPPER
// ================================================================

class _GlobeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(
      0,
      size.height,
    );

    path.lineTo(
      0,
      size.height * 0.55,
    );

    path.quadraticBezierTo(
      size.width / 2,
      -size.height * 0.55,
      size.width,
      size.height * 0.55,
    );

    path.lineTo(
      size.width,
      size.height,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(
    covariant CustomClipper<Path> oldClipper,
  ) {
    return false;
  }
}

// ================================================================
// GLOBE DOTS PAINTER
// ================================================================

class _GlobeDotsPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final random = Random(42);

    final dotPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.5,
      );

    final glowPaint = Paint()
      ..color = const Color(
        0xFFA855F7,
      ).withValues(
        alpha: 0.8,
      );

    for (int i = 0; i < 45; i++) {
      final dx = random.nextDouble() * size.width;

      final dy =
          size.height * 0.15 +
          random.nextDouble() * size.height * 0.7;

      final isGlow = i % 6 == 0;

      canvas.drawCircle(
        Offset(dx, dy),
        isGlow ? 2.2 : 1.2,
        isGlow
            ? glowPaint
            : dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
import 'package:flutter/material.dart';

import '../../core/storage/secure_storage.dart';
import '../../models/app_version_info.dart';
import '../../services/app_version_service.dart';
import '../auth/login_view.dart';
import '../home/home_view.dart';
import '../update/app_update_required_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _featuresSlide;
  late final Animation<double> _featuresFade;
  late final Animation<double> _progressFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Logo scale + fade in (0% - 40%)
    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    // Feature icons row: slide up + fade (40% - 75%)
    _featuresSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _featuresFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
      ),
    );

    // Progress bar + loading text (65% - 100%)
    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Check version concurrently while splash animation is running
    AppVersionInfo? versionInfo;
    try {
      versionInfo = await AppVersionService.checkVersion();
    } catch (_) {}

    // Give time for full animation sequence
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // If an update is required by the database, block app entry completely!
    if (versionInfo != null && versionInfo.isUpdateRequired) {
      _navigateWithFade(AppUpdateRequiredView(versionInfo: versionInfo));
      return;
    }

    try {
      final rememberMe = await SecureStorage.getRememberMe();
      if (rememberMe) {
        final token = await SecureStorage.getToken();
        final expiration = await SecureStorage.getTokenExpiration();
        if (token != null &&
            token.isNotEmpty &&
            expiration != null &&
            DateTime.now().toUtc().isBefore(expiration.toUtc())) {
          final user = await SecureStorage.getUser();
          if (user != null) {
            _navigateWithFade(HomeView(user: user));
            return;
          }
        }
      }
    } catch (_) {
      // Fall through to login on any storage issue
    }

    _navigateWithFade(const LoginView());
  }

  void _navigateWithFade(Widget destination) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0614),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B0614),
              Color(0xFF240A42),
              Color(0xFF3B0B63),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                children: [
                  const Spacer(flex: 3),

                  // Brand App Logo with ambient purple neon glow
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: _buildLogo(),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Feature icons row
                  SlideTransition(
                    position: _featuresSlide,
                    child: FadeTransition(
                      opacity: _featuresFade,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _FeatureIcon(
                              icon: Icons.badge_outlined,
                              label: 'PEOPLE',
                            ),
                            _FeatureIcon(
                              icon: Icons.how_to_reg_outlined,
                              label: 'ATTENDANCE',
                            ),
                            _FeatureIcon(
                              icon: Icons.event_note_outlined,
                              label: 'LEAVE',
                            ),
                            _FeatureIcon(
                              icon: Icons.payments_outlined,
                              label: 'PAYROLL',
                            ),
                            _FeatureIcon(
                              icon: Icons.share_location_outlined,
                              label: 'GEOFENCE',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Progress bar + loading label
                  FadeTransition(
                    opacity: _progressFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _controller.value,
                              minHeight: 4,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFA855F7),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Loading AlienHR workspace...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ambient soft purple radial glow
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.32),
                blurRadius: 55,
                spreadRadius: 8,
              ),
            ],
          ),
        ),

        // Unclipped, high-resolution official logo
        Image.asset(
          'lib/assets/images/alien_logo.png',
          width: 260,
          height: 220,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Icon(icon, color: const Color(0xFFE9D5FF), size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            color: Colors.white.withValues(alpha: 0.7),
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

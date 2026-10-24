import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../models/app_version_info.dart';
import '../../services/app_version_service.dart';
import '../auth/login_view.dart';

class AppUpdateRequiredView extends StatefulWidget {
  final AppVersionInfo versionInfo;

  const AppUpdateRequiredView({
    super.key,
    required this.versionInfo,
  });

  @override
  State<AppUpdateRequiredView> createState() => _AppUpdateRequiredViewState();
}

class _AppUpdateRequiredViewState extends State<AppUpdateRequiredView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isCheckingAgain = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkAgain() async {
    setState(() => _isCheckingAgain = true);
    final fresh = await AppVersionService.checkVersion();
    setState(() => _isCheckingAgain = false);

    if (!mounted) return;

    if (fresh == null || !fresh.isUpdateRequired) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'AlienHR Enterprise v${fresh.latestVersionOrCurrent} is still required. Please install the latest version.',
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Non-dismissible: user cannot back out or bypass
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F0721),
                Color(0xFF1B0B3B),
                Color(0xFF090314),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const Spacer(),

                  // Pulsing Update Required Badge
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFA855F7),
                            Color(0xFFEC4899),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA855F7).withValues(alpha: 0.45),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.system_update_alt_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Header Title
                  const Text(
                    'Update Required',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Explanation
                  Text(
                    widget.versionInfo.message.isNotEmpty
                        ? widget.versionInfo.message
                        : 'A mandatory application update is required to continue using AlienHR Enterprise.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Version Comparison Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Installed Version',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                'v${ApiConstants.appVersion}',
                                style: const TextStyle(
                                  color: Color(0xFFFCA5A5),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            color: Colors.white12,
                            height: 1,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Required Version',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                'v${widget.versionInfo.latestVersion}',
                                style: const TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.versionInfo.releaseNotes != null &&
                            widget.versionInfo.releaseNotes!.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(
                              color: Colors.white12,
                              height: 1,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'What\'s New:',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.versionInfo.releaseNotes!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Update Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              widget.versionInfo.updateUrl != null &&
                                      widget.versionInfo.updateUrl!.isNotEmpty
                                  ? 'Download URL: ${widget.versionInfo.updateUrl}'
                                  : 'Please contact your administrator or download the latest APK v${widget.versionInfo.latestVersion}.',
                            ),
                            backgroundColor: const Color(0xFF7C2FCE),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9333EA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Download & Update',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Check Again Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isCheckingAgain ? null : _checkAgain,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isCheckingAgain
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'I have updated, check again',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on AppVersionInfo {
  String get latestVersionOrCurrent =>
      latestVersion.isNotEmpty ? latestVersion : minimumVersion;
}

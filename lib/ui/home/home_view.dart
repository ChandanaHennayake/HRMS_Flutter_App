import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../auth/login_view.dart';

class HomeView extends StatefulWidget {
  final User user;

  const HomeView({
    super.key,
    required this.user,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const Color deepDark = Color(0xFF0B0614);
  static const Color violet = Color(0xFF7C2FCE);
  static const Color brightViolet = Color(0xFFA855F7);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  int selectedIndex = 0;

  // Temporary UI values.
  // Later these come from AttendanceService.
  bool isCheckedIn = false;

  String checkInTime = '--:--';
  String checkOutTime = '--:--';
  String workedTime = '00h 00m';
  String overtime = '00h 00m';

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginView(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // TEMPORARY CHECK IN / CHECK OUT
  // ============================================================

  void _attendanceAction() {
    if (!isCheckedIn) {
      final now = TimeOfDay.now();

      setState(() {
        isCheckedIn = true;
        checkInTime = now.format(context);
      });

      _showMessage('Checked in successfully.');

      return;
    }

    final now = TimeOfDay.now();

    setState(() {
      isCheckedIn = false;
      checkOutTime = now.format(context);
    });

    _showMessage('Checked out successfully.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
      backgroundColor: background,

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO:
            // Load today's attendance from API.
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 30,
            ),
            child: Column(
              children: [
                _buildHeader(),

                Transform.translate(
                  offset: const Offset(0, -25),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Column(
                      children: [
                        _buildAttendanceCard(),

                        const SizedBox(height: 18),

                        _buildTodaySummary(),

                        const SizedBox(height: 24),

                        _buildQuickActions(),

                        const SizedBox(height: 24),

                        _buildUpcomingSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final displayName = widget.user.fullName.trim().isNotEmpty
        ? widget.user.fullName
        : widget.user.username;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        55,
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
        ),
      ),
      child: Column(
        children: [
          // Top bar
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.hub_outlined,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'AlienHR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              _headerButton(
                icon: Icons.notifications_none_rounded,
                onTap: () {},
              ),

              const SizedBox(width: 8),

              _headerButton(
                icon: Icons.logout,
                onTap: _logout,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // User
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.15,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: 0.25,
                    ),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials(displayName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          color: Colors.white70,
                          size: 15,
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            widget.user.role,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(
        alpha: 0.12,
      ),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ATTENDANCE CARD
  // ============================================================

  Widget _buildAttendanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 24,
            offset: const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S ATTENDANCE",
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      '8:00 AM - 5:00 PM',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCheckedIn
                      ? const Color(0xFFE8F8EF)
                      : const Color(0xFFF2EDF7),
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isCheckedIn
                            ? Colors.green
                            : textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      isCheckedIn
                          ? 'Working'
                          : 'Not checked in',
                      style: TextStyle(
                        color: isCheckedIn
                            ? Colors.green.shade700
                            : textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          // Main check-in button
          GestureDetector(
            onTap: _attendanceAction,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCheckedIn
                      ? [
                          const Color(0xFFEF4444),
                          const Color(0xFFB91C1C),
                        ]
                      : [
                          violet,
                          brightViolet,
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (
                      isCheckedIn
                          ? Colors.red
                          : violet
                    ).withValues(
                      alpha: 0.25,
                    ),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    isCheckedIn
                        ? Icons.logout_rounded
                        : Icons.fingerprint,
                    color: Colors.white,
                    size: 42,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isCheckedIn
                        ? 'CHECK OUT'
                        : 'CHECK IN',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 0.7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5FB),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: violet,
                  size: 20,
                ),

                SizedBox(width: 9),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Branch location',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        'Location verification required',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.gps_fixed,
                  color: violet,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TODAY SUMMARY
  // ============================================================

  Widget _buildTodaySummary() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Today',
          Icons.today_outlined,
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: const Color(0xFFEEE8F3),
            ),
          ),
          child: Row(
            children: [
              _summaryItem(
                icon: Icons.login_rounded,
                label: 'Check In',
                value: checkInTime,
              ),

              _verticalDivider(),

              _summaryItem(
                icon: Icons.logout_rounded,
                label: 'Check Out',
                value: checkOutTime,
              ),

              _verticalDivider(),

              _summaryItem(
                icon: Icons.schedule_outlined,
                label: 'Worked',
                value: workedTime,
              ),

              _verticalDivider(),

              _summaryItem(
                icon: Icons.more_time_rounded,
                label: 'OT',
                value: overtime,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: violet,
            size: 20,
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              color: textMuted,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 42,
      color: const Color(0xFFEEE8F3),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Quick Actions',
          Icons.grid_view_rounded,
        ),

        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            _quickAction(
              icon: Icons
                  .calendar_month_outlined,
              title: 'Apply Leave',
              subtitle: 'Request time off',
              onTap: () {
                // TODO:
                // Navigate LeaveView
              },
            ),

            _quickAction(
              icon: Icons.history_rounded,
              title: 'Attendance',
              subtitle: 'View history',
              onTap: () {
                // TODO:
                // Navigate AttendanceView
              },
            ),

            _quickAction(
              icon: Icons.celebration_outlined,
              title: 'Holidays',
              subtitle: 'Upcoming holidays',
              onTap: () {},
            ),

            _quickAction(
              icon: Icons.person_outline,
              title: 'My Profile',
              subtitle: 'Personal details',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        16,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          16,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: const Color(0xFFEEE8F3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E8FA),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: violet,
                  size: 22,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // UPCOMING
  // ============================================================

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'Upcoming',
          Icons.event_outlined,
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color: const Color(0xFFEEE8F3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E8FA),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: violet,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No upcoming events',
                      style: TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'Holidays and approved leave will appear here.',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: violet,
        ),

        const SizedBox(width: 7),

        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: selectedIndex,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFF0E4FA),
      elevation: 10,

      onDestinationSelected: (index) {
        setState(() {
          selectedIndex = index;
        });

        // TODO:
        //
        // 0 = Home
        // 1 = Attendance
        // 2 = Leave
        // 3 = Profile
      },

      destinations: const [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
          ),
          selectedIcon: Icon(
            Icons.home,
            color: violet,
          ),
          label: 'Home',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.access_time_outlined,
          ),
          selectedIcon: Icon(
            Icons.access_time_filled,
            color: violet,
          ),
          label: 'Attendance',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.calendar_month_outlined,
          ),
          selectedIcon: Icon(
            Icons.calendar_month,
            color: violet,
          ),
          label: 'Leave',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
          ),
          selectedIcon: Icon(
            Icons.person,
            color: violet,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _initials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where(
          (value) => value.isNotEmpty,
        )
        .toList();

    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'
        .toUpperCase();
  }
}
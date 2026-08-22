import 'package:flutter/material.dart';

import '../../../models/user.dart';
import '../../../services/auth_service.dart';
import '../../auth/login_view.dart';
import '../../leave/manager/manager_leave_page.dart';

class ManagerDashboard extends StatefulWidget {
  final User user;

  const ManagerDashboard({
    super.key,
    required this.user,
  });

  @override
  State<ManagerDashboard> createState() =>
      _ManagerDashboardState();
}

class _ManagerDashboardState
    extends State<ManagerDashboard> {
  static const Color deepDark = Color(0xFF0B0614);
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  int selectedIndex = 0;

  // ============================================================
  // SAMPLE DATA
  // ============================================================

  final int teamTotal = 25;
  final int presentToday = 20;
  final int onLeaveToday = 3;
  final int absentToday = 2;
  final int pendingLeave = 5;

  final List<Map<String, String>> todayLeave = [
    {
      'name': 'Kasun Perera',
      'type': 'Annual Leave',
      'duration': 'Full Day',
    },
    {
      'name': 'Amal Silva',
      'type': 'Medical Leave',
      'duration': 'Full Day',
    },
    {
      'name': 'Nimal Fernando',
      'type': 'Casual Leave',
      'duration': 'Half Day',
    },
  ];

  final List<Map<String, dynamic>> weeklyAttendance = [
    {
      'day': 'Mon',
      'percentage': 0.92,
      'value': '92%',
    },
    {
      'day': 'Tue',
      'percentage': 0.88,
      'value': '88%',
    },
    {
      'day': 'Wed',
      'percentage': 0.94,
      'value': '94%',
    },
    {
      'day': 'Thu',
      'percentage': 0.82,
      'value': '82%',
    },
    {
      'day': 'Fri',
      'percentage': 0.91,
      'value': '91%',
    },
  ];

  // ============================================================
  // LEAVE APPROVAL NAVIGATION
  // ============================================================

  Future<void> _openLeaveApprovals() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManagerLeavePage(
          user: widget.user,
        ),
      ),
    );
  }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 30,
          ),
          child: Column(
            children: [
              _buildHeader(),

              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: Column(
                    children: [
                      _buildTeamSummary(),

                      const SizedBox(height: 18),

                      _buildPendingApproval(),

                      const SizedBox(height: 24),

                      _buildTodayLeave(),

                      const SizedBox(height: 24),

                      _buildWeeklyAttendance(),

                      const SizedBox(height: 24),

                      _buildQuickActions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildNavigation(),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final name =
        widget.user.fullName.trim().isNotEmpty
            ? widget.user.fullName
            : widget.user.username;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
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
          Row(
            children: [
              const Icon(
                Icons.hub_outlined,
                color: Colors.white,
                size: 30,
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
                Icons.notifications_none,
                () {},
              ),

              const SizedBox(width: 8),

              _headerButton(
                Icons.logout,
                _logout,
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor:
                    Colors.white.withValues(
                  alpha: 0.15,
                ),
                child: Text(
                  _initials(name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
                      'Manager Dashboard',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      widget.user.role,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
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

  // ============================================================
  // TEAM SUMMARY
  // ============================================================

  Widget _buildTeamSummary() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S TEAM",
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Attendance Overview',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E8FA),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  '$teamTotal Employees',
                  style: const TextStyle(
                    color: violet,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              _teamMetric(
                'Present',
                presentToday.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
              _teamMetric(
                'Leave',
                onLeaveToday.toString(),
                Icons.event_busy_outlined,
                Colors.orange,
              ),
              _teamMetric(
                'Absent',
                absentToday.toString(),
                Icons.person_off_outlined,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            label,
            style: const TextStyle(
              color: textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PENDING LEAVE APPROVAL
  // ============================================================

  Widget _buildPendingApproval() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: _openLeaveApprovals,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFEADCF5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E6),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.pending_actions_outlined,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Leave Approvals',
                      style: TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Requires your attention',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1E8FA),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  pendingLeave.toString(),
                  style: const TextStyle(
                    color: violet,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 5),

              const Icon(
                Icons.chevron_right,
                color: textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TODAY LEAVE
  // ============================================================

  Widget _buildTodayLeave() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _title(
          "Today's Leave",
          Icons.event_busy_outlined,
        ),

        const SizedBox(height: 12),

        _card(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(
              todayLeave.length,
              (index) {
                final item =
                    todayLeave[index];

                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(
                          0xFFF1E8FA,
                        ),
                        child: Text(
                          _initials(
                            item['name']!,
                          ),
                          style: const TextStyle(
                            color: violet,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        item['name']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        item['type']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: textMuted,
                        ),
                      ),
                      trailing: Text(
                        item['duration']!,
                        style: const TextStyle(
                          color: violet,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),

                    if (index !=
                        todayLeave.length - 1)
                      const Divider(
                        height: 1,
                        indent: 70,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WEEKLY ATTENDANCE
  // ============================================================

  Widget _buildWeeklyAttendance() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _title(
          'Weekly Attendance',
          Icons.bar_chart_rounded,
        ),

        const SizedBox(height: 12),

        _card(
          child: Column(
            children: weeklyAttendance.map(
              (item) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 35,
                        child: Text(
                          item['day'],
                          style: const TextStyle(
                            color: textDark,
                            fontWeight:
                                FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      Expanded(
                        child:
                            LinearProgressIndicator(
                          value:
                              item['percentage'],
                          minHeight: 8,
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                          color: violet,
                          backgroundColor:
                              const Color(
                            0xFFEEE8F3,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      SizedBox(
                        width: 35,
                        child: Text(
                          item['value'],
                          textAlign:
                              TextAlign.right,
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ],
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
        _title(
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
          childAspectRatio: 1.65,
          children: [
            _action(
              Icons.approval_outlined,
              'Approvals',
              onTap: _openLeaveApprovals,
            ),

            _action(
              Icons.groups_outlined,
              'My Team',
            ),

            _action(
              Icons.access_time,
              'Attendance',
            ),

            _action(
              Icons.calendar_month_outlined,
              'Leave Calendar',
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // SHARED
  // ============================================================

  Widget _card({
    required Widget child,
    EdgeInsets padding =
        const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEEE8F3),
        ),
      ),
      child: child,
    );
  }

  Widget _action(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap ??
            () {
              _showMessage(
                '$title will be added next.',
              );
            },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEEE8F3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E8FA),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: violet,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: violet,
          size: 19,
        ),

        const SizedBox(width: 7),

        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _headerButton(
    IconData icon,
    VoidCallback onTap,
  ) {
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
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildNavigation() {
    return NavigationBar(
      selectedIndex: selectedIndex,
      backgroundColor: Colors.white,
      indicatorColor:
          const Color(0xFFF0E4FA),
      onDestinationSelected: (index) {
        setState(() {
          selectedIndex = index;
        });

        // Approvals tab
        if (index == 1) {
          _openLeaveApprovals();
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(
            Icons.dashboard_outlined,
          ),
          selectedIcon: Icon(
            Icons.dashboard,
            color: violet,
          ),
          label: 'Home',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.pending_actions_outlined,
          ),
          selectedIcon: Icon(
            Icons.pending_actions,
            color: violet,
          ),
          label: 'Approvals',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.groups_outlined,
          ),
          selectedIcon: Icon(
            Icons.groups,
            color: violet,
          ),
          label: 'Team',
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
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'
        .toUpperCase();
  }
}
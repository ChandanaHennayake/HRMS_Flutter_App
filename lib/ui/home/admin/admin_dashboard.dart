import 'package:flutter/material.dart';

import '../../../models/user.dart';
import '../../../services/auth_service.dart';
import '../../auth/login_view.dart';

// Leave
import '../../../ui/leave/manager/manager_leave_page.dart';

// Employee
import '../../../ui/employee/employee_list_page.dart';

class AdminDashboard extends StatefulWidget {
  final User user;

  const AdminDashboard({
    super.key,
    required this.user,
  });

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const Color deepDark = Color(0xFF0B0614);
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  int selectedIndex = 0;

  // ============================================================
  // ADMIN DATA
  // ============================================================

  final int totalEmployees = 245;
  final int present = 218;
  final int onLeave = 12;
  final int absent = 15;

  final int pendingLeave = 14;
  final int lateEmployees = 8;
  final int missingCheckOut = 5;

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
  // MESSAGE
  // ============================================================

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // OPEN LEAVE APPROVALS
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

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // OPEN EMPLOYEES
  // ============================================================

 Future<void> _openEmployees() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EmployeeListPage(
        user: widget.user,
      ),
    ),
  );

  if (!mounted) return;

  setState(() {});
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
              _header(),

              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: Column(
                    children: [
                      _organizationSummary(),

                      const SizedBox(height: 24),

                      _attention(),

                      const SizedBox(height: 24),

                      _attendanceOverview(),

                      const SizedBox(height: 24),

                      _quickActions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _navigation(),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
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
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.roleId == 1
                          ? 'Super Admin Dashboard'
                          : 'Admin Dashboard',
                      style: const TextStyle(
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
  // ORGANIZATION
  // ============================================================

  Widget _organizationSummary() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'ORGANIZATION TODAY',
            style: TextStyle(
              color: textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Workforce Overview',
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              _stat(
                'Employees',
                totalEmployees.toString(),
                Icons.groups_outlined,
                violet,
              ),

              const SizedBox(width: 10),

              _stat(
                'Present',
                present.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _stat(
                'On Leave',
                onLeave.toString(),
                Icons.event_busy_outlined,
                Colors.orange,
              ),

              const SizedBox(width: 10),

              _stat(
                'Absent',
                absent.toString(),
                Icons.person_off_outlined,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(
            alpha: 0.07,
          ),
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    label,
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ATTENTION
  // ============================================================

  Widget _attention() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _title(
          'Attention Required',
          Icons.warning_amber_rounded,
        ),

        const SizedBox(height: 12),

        _card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _attentionItem(
                Icons.pending_actions_outlined,
                'Pending Leave Requests',
                pendingLeave,
                Colors.orange,
              ),

              const Divider(height: 1),

              _attentionItem(
                Icons.timer_outlined,
                'Late Employees',
                lateEmployees,
                Colors.red,
              ),

              const Divider(height: 1),

              _attentionItem(
                Icons.logout_outlined,
                'Missing Check-outs',
                missingCheckOut,
                violet,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _attentionItem(
    IconData icon,
    String title,
    int count,
    Color color,
  ) {
    return ListTile(
      onTap: () async {
        if (title == 'Pending Leave Requests') {
          await _openLeaveApprovals();
          return;
        }

        _message(
          '$title details will be added.',
        );
      },

      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(
            alpha: 0.10,
          ),
          borderRadius:
              BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          color: color,
          size: 21,
        ),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),

      trailing: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.bold,
                fontSize: 11,
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
    );
  }

  // ============================================================
  // ATTENDANCE OVERVIEW
  // ============================================================

  Widget _attendanceOverview() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _title(
          'Attendance Today',
          Icons.donut_large_outlined,
        ),

        const SizedBox(height: 12),

        _card(
          child: Column(
            children: [
              _progress(
                'Present',
                0.89,
                '89%',
              ),

              _progress(
                'Late',
                0.04,
                '4%',
              ),

              _progress(
                'Leave',
                0.05,
                '5%',
              ),

              _progress(
                'Absent',
                0.02,
                '2%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progress(
    String label,
    double value,
    String percentage,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style:
                  const TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child:
                LinearProgressIndicator(
              value: value,
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
            width: 32,
            child: Text(
              percentage,
              textAlign:
                  TextAlign.right,
              style:
                  const TextStyle(
                color: textMuted,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _quickActions() {
    final actions =
        <Map<String, dynamic>>[
      {
        'icon':
            Icons.groups_outlined,
        'title': 'Employees',
      },
      {
        'icon':
            Icons.access_time_outlined,
        'title': 'Attendance',
      },
      {
        'icon':
            Icons.event_note_outlined,
        'title': 'Leave',
      },
      {
        'icon':
            Icons.approval_outlined,
        'title': 'Approvals',
      },
      {
        'icon':
            Icons.business_outlined,
        'title': 'Branches',
      },
      {
        'icon':
            Icons.bar_chart_outlined,
        'title': 'Reports',
      },
    ];

    if (widget.user.roleId == 1) {
      actions.addAll([
        {
          'icon':
              Icons.manage_accounts_outlined,
          'title': 'Users',
        },
        {
          'icon':
              Icons.security_outlined,
          'title': 'Roles',
        },
      ]);
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _title(
          'Quick Actions',
          Icons.grid_view_rounded,
        ),

        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount:
              actions.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.75,
          ),
          itemBuilder:
              (context, index) {
            final action =
                actions[index];

            final String title =
                action['title'] as String;

            final IconData icon =
                action['icon'] as IconData;

            return Material(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              child: InkWell(
                onTap: () async {
                  // ==================================================
                  // EMPLOYEES
                  // ==================================================

                  if (title == 'Employees') {
                    await _openEmployees();
                    return;
                  }

                  // ==================================================
                  // LEAVE / APPROVALS
                  // ==================================================

                  if (title == 'Leave' ||
                      title == 'Approvals') {
                    await _openLeaveApprovals();
                    return;
                  }

                  // ==================================================
                  // OTHER EXISTING ACTIONS
                  // ==================================================

                  _message(
                    '$title screen will be added.',
                  );
                },

                borderRadius:
                    BorderRadius.circular(16),

                child: Container(
                  padding:
                      const EdgeInsets.all(14),
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(16),
                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFFEEE8F3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFF1E8FA,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            11,
                          ),
                        ),
                        child:
                            Icon(
                          icon,
                          color:
                              violet,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child:
                            Text(
                          title,
                          style:
                              const TextStyle(
                            fontSize:
                                12,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _card({
    required Widget child,
    EdgeInsets padding =
        const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(
            0xFFEEE8F3,
          ),
        ),
      ),
      child: child,
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

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
          style:
              const TextStyle(
            color: textDark,
            fontWeight:
                FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER BUTTON
  // ============================================================

  Widget _headerButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color:
          Colors.white.withValues(
        alpha: 0.12,
      ),
      borderRadius:
          BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(12),
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
  // NAVIGATION
  // ============================================================

  Widget _navigation() {
    return NavigationBar(
      selectedIndex:
          selectedIndex,

      backgroundColor:
          Colors.white,

      indicatorColor:
          const Color(
        0xFFF0E4FA,
      ),

      onDestinationSelected:
          (index) async {
        // ==================================================
        // EMPLOYEES
        // ==================================================

        if (index == 1) {
          await _openEmployees();

          if (!mounted) return;

          setState(() {
            selectedIndex = 0;
          });

          return;
        }

        // ==================================================
        // EXISTING NAVIGATION
        // ==================================================

        setState(() {
          selectedIndex =
              index;
        });
      },

      destinations:
          const [
        NavigationDestination(
          icon: Icon(
            Icons.dashboard_outlined,
          ),
          selectedIcon:
              Icon(
            Icons.dashboard,
            color: violet,
          ),
          label: 'Home',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.groups_outlined,
          ),
          selectedIcon:
              Icon(
            Icons.groups,
            color: violet,
          ),
          label: 'Employees',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.analytics_outlined,
          ),
          selectedIcon:
              Icon(
            Icons.analytics,
            color: violet,
          ),
          label: 'Reports',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
          ),
          selectedIcon:
              Icon(
            Icons.person,
            color: violet,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _initials(
    String name,
  ) {
    final parts = name
        .trim()
        .split(' ')
        .where(
          (e) => e.isNotEmpty,
        )
        .toList();

    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts[0][0]
          .toUpperCase();
    }

    return '${parts[0][0]}'
            '${parts[1][0]}'
        .toUpperCase();
  }
}
import 'package:flutter/material.dart';

import '../../../models/admin_summary.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';
import '../../../services/dashboard_service.dart';
import '../../auth/login_view.dart';

// Leave
import '../../../ui/leave/manager/manager_leave_page.dart';

// Employee
import '../../../ui/employee/employee_list_page.dart';

// Holiday
import '../../holiday/holidays_page.dart';

// Branch
import '../../branch/branch_list_page.dart';

// Attendance
import '../../attendance/company_attendance_page.dart';

// Profile
import '../../profile/profile_page.dart';
import '../../notification/notification_bell.dart';

// Payroll
import '../../payroll/payroll_management_page.dart';

// Audit Trail
import '../../audit/audit_log_page.dart';

// Reports & Analytics
import '../../report/reports_hub_page.dart';

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
  // ADMIN LIVE DATA & SERVICE
  // ============================================================

  final DashboardService _dashboardService = DashboardService();
  AdminSummary _summary = AdminSummary.empty;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final summary = await _dashboardService.getAdminSummary(
        companyId: widget.user.companyId,
      );
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
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
    _loadSummary();
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
    _loadSummary();
  }

  // ============================================================
  // OPEN BRANCHES
  // ============================================================

  Future<void> _openBranches() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BranchListPage(
          user: widget.user,
        ),
      ),
    );

    if (!mounted) return;
    _loadSummary();
  }

  // ============================================================
  // OPEN ATTENDANCE ROSTER
  // ============================================================

  Future<void> _openCompanyAttendance() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyAttendancePage(
          user: widget.user,
        ),
      ),
    );

    if (!mounted) return;
    _loadSummary();
  }

  // ============================================================
  // OPEN PROFILE
  // ============================================================

  Future<void> _openProfilePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          user: widget.user,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN REPORTS & ANALYTICS
  // ============================================================

  Future<void> _openReportsHub() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReportsHubPage(),
      ),
    );

    if (!mounted) return;
    _loadSummary();
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
          color: violet,
          onRefresh: _loadSummary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        if (_loadError != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Failed to load metrics. Pull down to retry.',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

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

              const NotificationBell(
                isHeaderButton: true,
              ),

              const SizedBox(width: 8),

              _headerButton(
                _isLoading ? Icons.sync : Icons.refresh,
                _loadSummary,
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
              InkWell(
                onTap: _openProfilePage,
                borderRadius: BorderRadius.circular(29),
                child: CircleAvatar(
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
                _summary.totalEmployees.toString(),
                Icons.groups_outlined,
                violet,
              ),

              const SizedBox(width: 10),

              _stat(
                'Present',
                _summary.presentToday.toString(),
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
                _summary.onLeaveToday.toString(),
                Icons.event_busy_outlined,
                Colors.orange,
              ),

              const SizedBox(width: 10),

              _stat(
                'Absent',
                _summary.absentToday.toString(),
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
                _summary.pendingLeaves,
                Colors.orange,
              ),

              const Divider(height: 1),

              _attentionItem(
                Icons.timer_outlined,
                'Late Employees',
                _summary.lateEmployees,
                Colors.red,
              ),

              const Divider(height: 1),

              _attentionItem(
                Icons.logout_outlined,
                'Missing Check-outs',
                _summary.missingCheckOut,
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
    final double presentNorm = (_summary.presentPercentage / 100).clamp(0.0, 1.0);
    final double lateNorm = (_summary.latePercentage / 100).clamp(0.0, 1.0);
    final double leaveNorm = (_summary.leavePercentage / 100).clamp(0.0, 1.0);
    final double absentNorm = (_summary.absentPercentage / 100).clamp(0.0, 1.0);

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
                presentNorm,
                '${_summary.presentPercentage.toStringAsFixed(1)}%',
              ),

              _progress(
                'Late',
                lateNorm,
                '${_summary.latePercentage.toStringAsFixed(1)}%',
              ),

              _progress(
                'Leave',
                leaveNorm,
                '${_summary.leavePercentage.toStringAsFixed(1)}%',
              ),

              _progress(
                'Absent',
                absentNorm,
                '${_summary.absentPercentage.toStringAsFixed(1)}%',
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
      {
        'icon':
            Icons.celebration_outlined,
        'title': 'Holidays',
      },
      {
        'icon':
            Icons.account_balance_wallet_outlined,
        'title': 'Payroll',
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
        {
          'icon':
              Icons.history_edu_outlined,
          'title': 'Audit Trail',
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
                  // HOLIDAYS
                  // ==================================================

                  if (title == 'Holidays') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HolidaysPage(
                          user: widget.user,
                        ),
                      ),
                    );
                    return;
                  }

                  // ==================================================
                  // ATTENDANCE
                  // ==================================================

                  if (title == 'Attendance') {
                    await _openCompanyAttendance();
                    return;
                  }

                  // ==================================================
                  // BRANCHES
                  // ==================================================

                  if (title == 'Branches') {
                    await _openBranches();
                    return;
                  }

                  // ==================================================
                  // PAYROLL
                  // ==================================================

                  if (title == 'Payroll') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PayrollManagementPage(),
                      ),
                    );
                    return;
                  }

                  // ==================================================
                  // AUDIT TRAIL
                  // ==================================================

                  if (title == 'Audit Trail') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AuditLogPage(),
                      ),
                    );
                    return;
                  }

                  // ==================================================
                  // REPORTS
                  // ==================================================

                  if (title == 'Reports') {
                    await _openReportsHub();
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
        // REPORTS
        // ==================================================

        if (index == 2) {
          await _openReportsHub();

          if (!mounted) return;

          setState(() {
            selectedIndex = 0;
          });

          return;
        }

        // ==================================================
        // PROFILE
        // ==================================================

        if (index == 3) {
          await _openProfilePage();

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
import 'package:flutter/material.dart';

import '../../../models/branch.dart';
import '../../../models/manager_summary.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';
import '../../../services/branch_service.dart';
import '../../../services/dashboard_service.dart';
import '../../attendance/company_attendance_page.dart';
import '../../attendance/manager_attendance_corrections_page.dart';
import '../../auth/login_view.dart';
import '../../employee/employee_list_page.dart';
import '../../holiday/holidays_page.dart';
import '../../leave/manager/manager_leave_page.dart';
import '../../notification/notification_bell.dart';
import '../../payroll/payroll_management_page.dart';
import '../../payroll/individual_payroll_page.dart';
import '../../profile/profile_page.dart';
import '../../report/reports_hub_page.dart';
import '../../notice/notice_management_page.dart';

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
  // MANAGER LIVE DATA & SERVICE
  // ============================================================

  final DashboardService _dashboardService = DashboardService();
  final BranchService _branchService = BranchService();
  ManagerSummary _summary = ManagerSummary.empty;
  bool _isLoading = true;
  String? _loadError;

  List<Branch> _assignedBranches = [];
  int _selectedBranchId = 0;
  String _selectedBranchName = '';

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.user.branchId;
    _loadAssignedBranches();
    _loadSummary();
  }

  Future<void> _loadAssignedBranches() async {
    try {
      final branches = await _branchService.getUserBranches(widget.user.userId);
      if (branches.isNotEmpty && mounted) {
        setState(() {
          _assignedBranches = branches;
          if (!_assignedBranches.any((b) => b.branchId == _selectedBranchId)) {
            _selectedBranchId = _assignedBranches.first.branchId;
            _selectedBranchName = _assignedBranches.first.branchName;
          } else {
            _selectedBranchName = _assignedBranches
                .firstWhere((b) => b.branchId == _selectedBranchId)
                .branchName;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _loadSummary() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final branchIdToQuery =
          _selectedBranchId > 0 ? _selectedBranchId : widget.user.branchId;
      final summary = await _dashboardService.getManagerSummary(
        branchIdToQuery,
      );
      if (!mounted) return;
      setState(() {
        _summary = summary;
        if (_selectedBranchName.isEmpty && summary.branchName.isNotEmpty) {
          _selectedBranchName = summary.branchName;
        }
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
  // LEAVE APPROVAL NAVIGATION
  // ============================================================

  Future<void> _openLeaveApprovals() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManagerLeavePage(
          user: widget.user,
          branchId: _selectedBranchId > 0 ? _selectedBranchId : widget.user.branchId,
          branchName: _selectedBranchName,
        ),
      ),
    );

    if (!mounted) return;
    _loadSummary();
  }

  Future<void> _openHolidays() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HolidaysPage(
          user: widget.user,
        ),
      ),
    );
  }

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

  Future<void> _openCompanyAttendance() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyAttendancePage(
          user: widget.user,
          initialBranchId: _selectedBranchId > 0 ? _selectedBranchId : widget.user.branchId,
        ),
      ),
    );

    if (!mounted) return;
    _loadSummary();
  }

  Future<void> _openTeamDirectory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeListPage(
          user: widget.user,
          branchId: _selectedBranchId > 0 ? _selectedBranchId : widget.user.branchId,
          branchName: _selectedBranchName,
        ),
      ),
    );

    if (!mounted) return;
    _loadSummary();
  }

  Future<void> _openAttendanceCorrections() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManagerAttendanceCorrectionsPage(
          user: widget.user,
          branchId: _selectedBranchId > 0 ? _selectedBranchId : widget.user.branchId,
          branchName: _selectedBranchName,
        ),
      ),
    );

    if (!mounted) return;
    _loadSummary();
  }

  Future<void> _openPayrollWorkspace() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PayrollManagementPage(
          branchId: _selectedBranchId > 0 ? _selectedBranchId : widget.user.branchId,
          branchName: _selectedBranchName.isNotEmpty ? _selectedBranchName : _summary.branchName,
        ),
      ),
    );

    if (!mounted) return;
    _loadSummary();
  }

  Future<void> _openIndividualPayroll() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const IndividualPayrollPage(),
      ),
    );

    if (!mounted) return;
    _loadSummary();
  }

  Future<void> _openReportsHub() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportsHubPage(
          initialBranchId: _selectedBranchId > 0 ? _selectedBranchId : widget.user.branchId,
          initialBranchName: _selectedBranchName.isNotEmpty ? _selectedBranchName : _summary.branchName,
        ),
      ),
    );

    if (!mounted) return;
    _loadSummary();
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
                _buildHeader(),

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
                                    'Failed to load team metrics. Pull down to retry.',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

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

          const SizedBox(height: 18),
          _buildBranchSelector(),
        ],
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Branch:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _assignedBranches.length > 1
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedBranchId,
                      dropdownColor: const Color(0xFF1E1035),
                      icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
                      isDense: true,
                      isExpanded: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      items: _assignedBranches.map((b) {
                        return DropdownMenuItem<int>(
                          value: b.branchId,
                          child: Text(
                            b.branchName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (newBranchId) {
                        if (newBranchId != null && newBranchId != _selectedBranchId) {
                          setState(() {
                            _selectedBranchId = newBranchId;
                            final match = _assignedBranches.firstWhere((b) => b.branchId == newBranchId);
                            _selectedBranchName = match.branchName;
                          });
                          _loadSummary();
                        }
                      },
                    ),
                  )
                : Text(
                    _selectedBranchName.isNotEmpty
                        ? _selectedBranchName
                        : (_summary.branchName.isNotEmpty ? _summary.branchName : 'Assigned Branch'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
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
                  '${_summary.teamTotal} Employees',
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
                _summary.presentToday.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
              _teamMetric(
                'Leave',
                _summary.onLeaveToday.toString(),
                Icons.event_busy_outlined,
                Colors.orange,
              ),
              _teamMetric(
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
                  _summary.pendingLeaves.toString(),
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
          child: _summary.todayLeave.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: const [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 36,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No team members on leave today',
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: List.generate(
                    _summary.todayLeave.length,
                    (index) {
                      final item = _summary.todayLeave[index];

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFF1E8FA),
                              child: Text(
                                _initials(item.name),
                                style: const TextStyle(
                                  color: violet,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              item.leaveType,
                              style: const TextStyle(
                                fontSize: 11,
                                color: textMuted,
                              ),
                            ),
                            trailing: Text(
                              item.duration,
                              style: const TextStyle(
                                color: violet,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (index != _summary.todayLeave.length - 1)
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
            children: _summary.weeklyAttendance.map(
              (item) {
                final double normalized = (item.percentage / 100).clamp(0.0, 1.0);

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
                          item.dayName,
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
                          value: normalized,
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
                        width: 42,
                        child: Text(
                          '${item.percentage.toStringAsFixed(1)}%',
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
              Icons.edit_calendar_outlined,
              'Corrections',
              onTap: _openAttendanceCorrections,
            ),

            _action(
              Icons.access_time,
              'Attendance',
              onTap: _openCompanyAttendance,
            ),

            _action(
              Icons.groups_outlined,
              'My Team',
              onTap: _openTeamDirectory,
            ),

            _action(
              Icons.calendar_month_outlined,
              'Leave Calendar',
              onTap: _openHolidays,
            ),

            _action(
              Icons.account_balance_wallet_outlined,
              'Payroll Portal',
              onTap: _openPayrollWorkspace,
            ),

            _action(
              Icons.calculate_outlined,
              'Emp Payroll',
              onTap: _openIndividualPayroll,
            ),

            _action(
              Icons.bar_chart_outlined,
              'Branch Reports',
              onTap: _openReportsHub,
            ),

            _action(
              Icons.campaign_outlined,
              'Notices & Posters',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NoticeManagementPage()),
                );
              },
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
        // Approvals tab
        if (index == 1) {
          _openLeaveApprovals();
          return;
        }

        // Team tab
        if (index == 2) {
          _openCompanyAttendance();
          return;
        }

        // Profile tab
        if (index == 3) {
          _openProfilePage();
          return;
        }

        setState(() {
          selectedIndex = index;
        });
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
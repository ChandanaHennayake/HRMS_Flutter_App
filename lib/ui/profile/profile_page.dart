import 'package:flutter/material.dart';

import '../../models/salary.dart';
import '../../models/user.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/salary_service.dart';
import '../../services/user_service.dart';
import '../auth/login_view.dart';
import '../payroll/my_payslips_page.dart';
import 'change_password_dialog.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color deepDark = Color(0xFF0B0614);
  static const Color violet = Color(0xFF7C2FCE);
  static const Color brightViolet = Color(0xFFA855F7);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  final UserService _userService = UserService();
  final SalaryService _salaryService = SalaryService();

  UserProfile? _profile;
  EmployeeSalary? _salary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _userService.getUserProfile(widget.user.userId);
      EmployeeSalary? salary;
      final empId = (profile.employeeId != null && profile.employeeId! > 0)
          ? profile.employeeId!
          : widget.user.employeeId;

      if (empId > 0) {
        try {
          salary = await _salaryService.getEmployeeSalary(empId);
        } catch (_) {
          // Salary is optional - don't crash profile if salary is unconfigured
        }
      }

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _salary = salary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _openChangePassword() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (_) => ChangePasswordDialog(
        userId: widget.user.userId,
      ),
    );

    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Password updated successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of AlienHR?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await AuthService().logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: RefreshIndicator(
          color: violet,
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final displayName = _profile?.fullName.isNotEmpty == true
        ? _profile!.fullName
        : widget.user.fullName.isNotEmpty
            ? widget.user.fullName
            : widget.user.username;

    final roleName = _profile?.role.isNotEmpty == true
        ? _profile!.role
        : widget.user.role.isNotEmpty
            ? widget.user.role
            : 'Employee';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 52),
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
          // Nav Bar
          Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'My Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Material(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _logout,
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Avatar & Name
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: violet,
              child: Text(
                _initials(displayName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  roleName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (_profile?.employeeCode != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: brightViolet.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _profile!.employeeCode!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT BODY
  // ============================================================

  Widget _buildContent() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(color: violet),
            SizedBox(height: 16),
            Text('Loading profile details...', style: TextStyle(color: textMuted)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: violet,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Account Details Card
        _buildInfoCard(
          title: 'Account Information',
          icon: Icons.person_outline,
          items: [
            _InfoRow(
              icon: Icons.alternate_email,
              label: 'Username',
              value: _profile?.username ?? widget.user.username,
            ),
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email Address',
              value: _profile?.email ?? widget.user.email,
            ),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              value: _profile?.phone?.isNotEmpty == true
                  ? _profile!.phone!
                  : 'Not provided',
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Employment Information Card
        _buildInfoCard(
          title: 'Employment Details',
          icon: Icons.badge_outlined,
          items: [
            _InfoRow(
              icon: Icons.domain_outlined,
              label: 'Department',
              value: _profile?.departmentName ?? 'General Operations',
            ),
            _InfoRow(
              icon: Icons.work_outline,
              label: 'Designation',
              value: _profile?.designationName ?? 'Staff Member',
            ),
            _InfoRow(
              icon: Icons.assignment_ind_outlined,
              label: 'Employment Type',
              value: _profile?.employmentTypeName ?? 'Permanent Full-Time',
            ),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Joined Date',
              value: _profile?.joinedDate != null
                  ? _formatDate(_profile!.joinedDate!)
                  : 'Active since onboarding',
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Branch & Geofence Card
        _buildInfoCard(
          title: 'Assigned Branch & Geofence',
          icon: Icons.location_on_outlined,
          items: [
            _InfoRow(
              icon: Icons.storefront_outlined,
              label: 'Branch Office',
              value: _profile?.branchName ?? 'Headquarters',
            ),
            _InfoRow(
              icon: Icons.gps_fixed_outlined,
              label: 'GPS Coordinates',
              value: (_profile?.branchLatitude != null &&
                      _profile?.branchLongitude != null)
                  ? '${_profile!.branchLatitude!.toStringAsFixed(5)}, ${_profile!.branchLongitude!.toStringAsFixed(5)}'
                  : 'Not configured',
            ),
            _InfoRow(
              icon: Icons.radar_outlined,
              label: 'Geofence Radius',
              value:
                  '${_profile?.geofenceRadiusMeters ?? 100} meters boundary',
            ),
          ],
        ),

        if (_salary != null) ...[
          const SizedBox(height: 18),
          _buildSalaryCard(),
        ],

        const SizedBox(height: 24),

        // Security & Account Actions
        _buildActionCard(),

        const SizedBox(height: 30),
      ],
    );
  }

  // ============================================================
  // SALARY & COMPENSATION CARD
  // ============================================================

  Widget _buildSalaryCard() {
    final calc = _salary?.calculation;
    final netPay = calc?.netSalary ?? _salary?.baseSalary ?? 0.0;
    final base = _salary?.baseSalary ?? 0.0;
    final allowances = calc?.totalAllowances ?? 0.0;
    final gross = calc?.grossEarnings ?? base;
    final employeeEpf = calc?.employeeEpf ?? 0.0;
    final employerEpf = calc?.employerEpf ?? 0.0;
    final employerEtf = calc?.employerEtf ?? 0.0;
    final otherDeductions = calc?.otherDeductions ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEE8F3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.payments_outlined, color: violet, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Salary & Compensation',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E4FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _salary?.structureName ?? 'Monthly',
                  style: const TextStyle(
                    color: violet,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3EFF8)),
          const SizedBox(height: 14),

          // Net Take-Home Highlight Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED NET SALARY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LKR ${netPay.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Core Figures Breakdown
          _salaryRow('Basic Salary', 'LKR ${base.toStringAsFixed(2)}', isBold: true),
          if (allowances > 0)
            _salaryRow('Fixed / Variable Allowances', '+ LKR ${allowances.toStringAsFixed(2)}', textColor: Colors.green.shade700),
          _salaryRow('Gross Earnings', 'LKR ${gross.toStringAsFixed(2)}', isBold: true),

          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF3EFF8)),
          const SizedBox(height: 8),

          // Statutory Contributions (Sri Lanka)
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 14, color: textMuted),
              SizedBox(width: 4),
              Text(
                'Statutory Benefits (Sri Lanka)',
                style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (employeeEpf > 0)
            _salaryRow('Employee EPF (8%)', '- LKR ${employeeEpf.toStringAsFixed(2)}', textColor: Colors.red.shade700),
          if (employerEpf > 0)
            _salaryRow('Employer EPF (12%)', 'LKR ${employerEpf.toStringAsFixed(2)}', isSecondary: true),
          if (employerEtf > 0)
            _salaryRow('Employer ETF (3%)', 'LKR ${employerEtf.toStringAsFixed(2)}', isSecondary: true),

          if (otherDeductions > 0) ...[
            const SizedBox(height: 6),
            _salaryRow('Other Deductions', '- LKR ${otherDeductions.toStringAsFixed(2)}', textColor: Colors.red.shade700),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF3EFF8)),
          const SizedBox(height: 10),

          // Payment details
          Row(
            children: [
              const Icon(Icons.credit_card_outlined, size: 14, color: textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${_salary?.paymentMode ?? "Bank Transfer"}'
                  '${_salary?.bankName != null && _salary!.bankName!.isNotEmpty ? " • ${_salary!.bankName}" : ""}'
                  '${_salary?.bankAccountNo != null && _salary!.bankAccountNo!.isNotEmpty ? " (${_salary!.bankAccountNo})" : ""}',
                  style: const TextStyle(color: textMuted, fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // View All Payslips Action
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPayslipsPage(
                      employeeId: widget.user.employeeId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.receipt_long_rounded, size: 16, color: violet),
              label: const Text(
                'View All Payslips',
                style: TextStyle(
                  color: violet,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD6C2EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _salaryRow(String label, String value, {bool isBold = false, bool isSecondary = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSecondary ? textMuted.withValues(alpha: 0.8) : (isBold ? textDark : textMuted),
              fontSize: isSecondary ? 11 : 12,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor ?? (isBold ? textDark : textDark.withValues(alpha: 0.9)),
              fontSize: isSecondary ? 11 : 12.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD WIDGET
  // ============================================================

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<_InfoRow> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEE8F3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: violet, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3EFF8)),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3FA),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(item.icon, color: textMuted, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.value,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTONS CARD
  // ============================================================

  Widget _buildActionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEE8F3)),
      ),
      child: Column(
        children: [
          // Change Password Tile
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: violet.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.lock_reset_rounded, color: violet),
            ),
            title: const Text(
              'Change Password',
              style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: const Text(
              'Update your account login password',
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: textMuted),
            onTap: _openChangePassword,
          ),

          const Divider(height: 1, color: Color(0xFFF3EFF8)),

          // Sign Out Tile
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.logout_rounded, color: Colors.red.shade700),
            ),
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: const Text(
              'Disconnect session on this device',
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: textMuted),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _initials(String name) {
    final parts =
        name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}

import 'package:flutter/material.dart';

import '../../../models/employee.dart';
import '../../../models/user.dart';
import '../../../services/employee_service.dart';
import '../../../services/user_service.dart';
import 'employee_form_page.dart';

class EmployeeDetailsPage
    extends StatefulWidget {
  final Employee employee;
  final User user;

  const EmployeeDetailsPage({
    super.key,
    required this.employee,
    required this.user,
  });

  @override
  State<EmployeeDetailsPage> createState() =>
      _EmployeeDetailsPageState();
}

class _EmployeeDetailsPageState
    extends State<EmployeeDetailsPage> {
  static const Color violet =
      Color(0xFF7C2FCE);

  static const Color background =
      Color(0xFFF7F5FA);

  static const Color textDark =
      Color(0xFF211B2E);

  static const Color textMuted =
      Color(0xFF8B87A0);

  final EmployeeService _employeeService =
      EmployeeService();
  final UserService _userService =
      UserService();

  late Employee _employee;

  bool _isLoading = false;
  bool _revealPassword = false;

  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
    _loadEmployee();
  }

  // ============================================================
  // LOAD LATEST EMPLOYEE
  // ============================================================

  Future<void> _loadEmployee() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await _employeeService
              .getEmployeeById(
        widget.employee.id,
      );

      if (!mounted) return;

      setState(() {
        _employee = result;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // EDIT
  // ============================================================

  Future<void> _editEmployee() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeFormPage(
          user: widget.user,
          employee: _employee,
        ),
      ),
    );

    if (result == true) {
      await _loadEmployee();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Employee updated successfully.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteEmployee() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Employee',
          ),
          content: Text(
            'Are you sure you want to delete '
            '${_employee.fullName}?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _employeeService
          .deleteEmployee(
        id: _employee.id,
        deletedBy:
            widget.user.userId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Employee deleted successfully.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openChangePasswordDialog() {
    final targetUserId = _employee.userId;
    if (targetUserId == null || targetUserId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No linked user account found for this employee.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscureNew = true;
    bool isSubmitting = false;
    String? dialogError;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: violet.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.vpn_key_rounded, color: violet, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Change Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text('${_employee.firstName} (${_employee.employeeCode})', style: const TextStyle(fontSize: 12.5, color: textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_employee.password != null && _employee.password!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Text('Current: ', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textMuted)),
                            Expanded(
                              child: Text(
                                _employee.password!,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textDark, fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextField(
                      controller: passwordController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'At least 6 characters',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                          onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 10),
                      Text(dialogError!, style: const TextStyle(color: Colors.red, fontSize: 12.5)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final newPass = passwordController.text.trim();
                          final confirmPass = confirmController.text.trim();
                          if (newPass.length < 6) {
                            setDialogState(() => dialogError = 'Password must be at least 6 characters.');
                            return;
                          }
                          if (newPass != confirmPass) {
                            setDialogState(() => dialogError = 'Passwords do not match.');
                            return;
                          }
                          final navigator = Navigator.of(dialogCtx);
                          final messenger = ScaffoldMessenger.of(context);
                          setDialogState(() {
                            isSubmitting = true;
                            dialogError = null;
                          });
                          try {
                            await _userService.adminResetPassword(userId: targetUserId, newPassword: newPass);
                            if (!mounted) return;
                            navigator.pop();
                            await _loadEmployee();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Password updated successfully.'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isSubmitting = false;
                              dialogError = e.toString().replaceAll('Exception:', '').trim();
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: violet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,

        title: const Text(
          'Employee Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: _editEmployee,
            icon: const Icon(
              Icons.edit_outlined,
              color: violet,
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteEmployee();
              }
            },
            itemBuilder:
                (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons
                          .delete_outline,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: violet,
              ),
            )
          : RefreshIndicator(
              color: violet,
              onRefresh: _loadEmployee,
              child: ListView(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  18,
                  20,
                  18,
                  40,
                ),
                children: [
                  _profileHeader(),

                  const SizedBox(
                    height: 18,
                  ),

                  _section(
                    title:
                        'Employee Information',
                    icon:
                        Icons.badge_outlined,
                    children: [
                      _infoRow(
                        'Employee Code',
                        _employee
                            .employeeCode,
                      ),
                      _infoRow(
                        'First Name',
                        _employee
                            .firstName,
                      ),
                      _infoRow(
                        'Last Name',
                        _employee
                                .lastName ??
                            '-',
                      ),
                      _infoRow(
                        'Gender',
                        _employee
                                .gender ??
                            '-',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  _section(
                    title:
                        'Contact Information',
                    icon:
                        Icons
                            .contact_phone_outlined,
                    children: [
                      _infoRow(
                        'Email',
                        _employee
                                .email ??
                            '-',
                      ),
                      _infoRow(
                        'Phone',
                        _employee
                                .phone ??
                            '-',
                      ),
                      _infoRow(
                        'Address Line 1',
                        _employee
                                .addressLine1 ??
                            '-',
                      ),
                      _infoRow(
                        'Address Line 2',
                        _employee
                                .addressLine2 ??
                            '-',
                      ),
                      _infoRow(
                        'City',
                        _employee
                                .city ??
                            '-',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  _section(
                    title:
                        'Employment',
                    icon:
                        Icons
                            .business_center_outlined,
                    children: [
                      _infoRow(
                        'Company ID',
                        _employee
                            .companyId
                            .toString(),
                      ),
                      _infoRow(
                        'Branch ID',
                        _employee
                            .branchId
                            .toString(),
                      ),
                      _infoRow(
                        'Department ID',
                        _employee
                                .departmentId
                                ?.toString() ??
                            '-',
                      ),
                      _infoRow(
                        'Designation ID',
                        _employee
                                .designationId
                                ?.toString() ??
                            '-',
                      ),
                      _infoRow(
                        'Employment Type ID',
                        _employee
                                .employmentTypeId
                                ?.toString() ??
                            '-',
                      ),
                      _infoRow(
                        'Date of Birth',
                        _formatDate(
                          _employee
                              .dateOfBirth,
                        ),
                      ),
                      _infoRow(
                        'Joined Date',
                        _formatDate(
                          _employee
                              .joinedDate,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  _section(
                    title: 'Qualifications & Education',
                    icon: Icons.school_outlined,
                    children: [
                      _infoRow(
                        'Qualification',
                        _employee.qualification ?? '-',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  _section(
                    title: 'Bank Details',
                    icon: Icons.account_balance_outlined,
                    children: [
                      _infoRow(
                        'Bank Name',
                        _employee.bankName ?? '-',
                      ),
                      _infoRow(
                        'Account Number',
                        _employee.bankAccountNo ?? '-',
                      ),
                      _infoRow(
                        'Bank Branch',
                        _employee.bankBranch ?? '-',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  _section(
                    title: 'Login & Security',
                    icon: Icons.lock_outline,
                    children: [
                      _infoRow(
                        'Username',
                        _employee.username ?? _employee.email ?? '-',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Password',
                              style: TextStyle(fontSize: 13, color: textMuted),
                            ),
                            Row(
                              children: [
                                Text(
                                  _revealPassword
                                      ? (_employee.password ?? 'Admin@123')
                                      : '••••••••',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: _revealPassword ? 'monospace' : null,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _revealPassword = !_revealPassword;
                                    });
                                  },
                                  child: Icon(
                                    _revealPassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    size: 18,
                                    color: violet,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (widget.user.roleId == 1 && _employee.userId != null) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _openChangePasswordDialog,
                            icon: const Icon(Icons.lock_reset_rounded, size: 16, color: violet),
                            label: const Text('Change Password', style: TextStyle(color: violet, fontWeight: FontWeight.bold, fontSize: 12.5)),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  _section(
                    title:
                        'Account Status',
                    icon:
                        Icons
                            .manage_accounts_outlined,
                    children: [
                      _infoRow(
                        'Status',
                        _employee
                            .statusText,
                        valueColor:
                            _employee
                                    .isActive
                                ? Colors
                                    .green
                                : Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(
                    height: 52,
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _editEmployee,
                      icon: const Icon(
                        Icons
                            .edit_outlined,
                      ),
                      label: const Text(
                        'Edit Employee',
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            violet,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
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
  // PROFILE HEADER
  // ============================================================

  Widget _profileHeader() {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF0B0614),
            Color(0xFF3B0B63),
            violet,
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor:
                Colors.white
                    .withValues(
              alpha: 0.15,
            ),
            child: Text(
              _initials(
                _employee.fullName,
              ),
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  _employee.fullName,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _employee
                      .employeeCode,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Text(
                    _employee
                        .statusText,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFEEE8F3,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: violet,
                size: 19,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                title,
                style:
                    const TextStyle(
                  color: textDark,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          const Divider(
            height: 1,
          ),

          const SizedBox(
            height: 4,
          ),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style:
                  const TextStyle(
                color: textMuted,
                fontSize: 11,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  TextStyle(
                color:
                    valueColor ??
                        textDark,
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(
    DateTime? date,
  ) {
    if (date == null) {
      return '-';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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

    return '${parts[0][0]}${parts[1][0]}'
        .toUpperCase();
  }
}
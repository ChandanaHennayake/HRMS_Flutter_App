import 'package:flutter/material.dart';

import '../../../models/employee.dart';
import '../../../models/user.dart';
import '../../../services/employee_service.dart';
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

  late Employee _employee;

  bool _isLoading = false;

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
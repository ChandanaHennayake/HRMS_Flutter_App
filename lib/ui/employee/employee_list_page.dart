import 'package:flutter/material.dart';

import '../../../models/employee.dart';
import '../../../models/user.dart';
import '../../../services/employee_service.dart';
import 'employee_details_page.dart';
import 'employee_form_page.dart';

class EmployeeListPage extends StatefulWidget {
  final User user;

  const EmployeeListPage({
    super.key,
    required this.user,
  });

  @override
  State<EmployeeListPage> createState() =>
      _EmployeeListPageState();
}

class _EmployeeListPageState
    extends State<EmployeeListPage> {
  static const Color deepDark =
      Color(0xFF0B0614);

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

  final TextEditingController _searchController =
      TextEditingController();

  List<Employee> _employees = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEmployees();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD EMPLOYEES
  // ============================================================

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _employeeService.getAllEmployees();

      if (!mounted) return;

      setState(() {
        _employees = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                );
      });
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<Employee> get _filteredEmployees {
    final search =
        _searchController.text.trim().toLowerCase();

    if (search.isEmpty) {
      return _employees;
    }

    return _employees.where((employee) {
      final name =
          employee.fullName.toLowerCase();

      final code =
          employee.employeeCode.toLowerCase();

      final email =
          employee.email?.toLowerCase() ?? '';

      final phone =
          employee.phone?.toLowerCase() ?? '';

      final city =
          employee.city?.toLowerCase() ?? '';

      return name.contains(search) ||
          code.contains(search) ||
          email.contains(search) ||
          phone.contains(search) ||
          city.contains(search);
    }).toList();
  }

  // ============================================================
  // OPEN CREATE
  // ============================================================

  Future<void> _openCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeFormPage(
          user: widget.user,
        ),
      ),
    );

    if (result == true) {
      await _loadEmployees();
    }
  }

  // ============================================================
  // OPEN DETAILS
  // ============================================================

  Future<void> _openDetails(
    Employee employee,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeDetailsPage(
          employee: employee,
          user: widget.user,
        ),
      ),
    );

    if (result == true) {
      await _loadEmployees();
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteEmployee(
    Employee employee,
  ) async {
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
            '${employee.fullName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _employeeService.deleteEmployee(
        id: employee.id,
        deletedBy: widget.user.userId,
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

      await _loadEmployees();
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
    final employees =
        _filteredEmployees;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        title: const Text(
          'Employees',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadEmployees,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          _header(),

          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color: violet,
                    ),
                  )
                : _errorMessage != null
                    ? _errorView()
                    : RefreshIndicator(
                        color: violet,
                        onRefresh:
                            _loadEmployees,
                        child:
                            employees.isEmpty
                                ? _emptyView()
                                : ListView.builder(
                                    padding:
                                        const EdgeInsets
                                            .fromLTRB(
                                      18,
                                      8,
                                      18,
                                      100,
                                    ),
                                    itemCount:
                                        employees
                                            .length,
                                    itemBuilder:
                                        (
                                      context,
                                      index,
                                    ) {
                                      return _employeeCard(
                                        employees[index],
                                      );
                                    },
                                  ),
                      ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor: violet,
        foregroundColor: Colors.white,
        onPressed: _openCreate,
        icon: const Icon(
          Icons.person_add_alt_1,
        ),
        label: const Text(
          'Add Employee',
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        18,
      ),
      child: Column(
        children: [
          TextField(
            controller:
                _searchController,
            decoration: InputDecoration(
              hintText:
                  'Search employees...',
              prefixIcon: const Icon(
                Icons.search,
              ),
              suffixIcon:
                  _searchController
                          .text
                          .isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController
                                .clear();
                          },
                          icon:
                              const Icon(
                            Icons.clear,
                          ),
                        )
                      : null,
              filled: true,
              fillColor:
                  background,
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                borderSide:
                    BorderSide.none,
              ),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Row(
            children: [
              _summaryItem(
                'Total',
                _employees.length
                    .toString(),
                violet,
              ),

              const SizedBox(
                width: 10,
              ),

              _summaryItem(
                'Active',
                _employees
                    .where(
                      (e) =>
                          e.isActive,
                    )
                    .length
                    .toString(),
                Colors.green,
              ),

              const SizedBox(
                width: 10,
              ),

              _summaryItem(
                'Inactive',
                _employees
                    .where(
                      (e) =>
                          !e.isActive,
                    )
                    .length
                    .toString(),
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: color.withValues(
            alpha: 0.07,
          ),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              title,
              style:
                  const TextStyle(
                color: textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPLOYEE CARD
  // ============================================================

  Widget _employeeCard(
    Employee employee,
  ) {
    final initials =
        _initials(
      employee.fullName,
    );

    final statusColor =
        employee.isActive
            ? Colors.green
            : Colors.red;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFEEE8F3,
          ),
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        onTap: () {
          _openDetails(
            employee,
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.all(
            14,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor:
                    const Color(
                  0xFFF1E8FA,
                ),
                child: Text(
                  initials,
                  style:
                      const TextStyle(
                    color: violet,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      employee.fullName,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color:
                            textDark,
                        fontSize: 14,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      employee
                          .employeeCode,
                      style:
                          const TextStyle(
                        color:
                            textMuted,
                        fontSize: 11,
                      ),
                    ),

                    if (employee
                            .email !=
                        null) ...[
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        employee.email!,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          color:
                              textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color: statusColor
                          .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                    child: Text(
                      employee
                          .statusText,
                      style:
                          TextStyle(
                        color:
                            statusColor,
                        fontSize: 9,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  const Icon(
                    Icons
                        .chevron_right,
                    color:
                        textMuted,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyView() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(
          height: 100,
        ),
        Icon(
          Icons.groups_outlined,
          size: 65,
          color:
              violet.withValues(
            alpha: 0.35,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        const Center(
          child: Text(
            'No employees found.',
            style: TextStyle(
              color: textDark,
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        const Center(
          child: Text(
            'Add your first employee.',
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorView() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .cloud_off_outlined,
              color: Colors.red,
              size: 55,
            ),

            const SizedBox(
              height: 15,
            ),

            const Text(
              'Unable to load employees',
              style: TextStyle(
                color: textDark,
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              _errorMessage ??
                  'Something went wrong.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: textMuted,
                fontSize: 12,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed:
                  _loadEmployees,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try Again',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    violet,
                foregroundColor:
                    Colors.white,
              ),
            ),
          ],
        ),
      ),
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

    return '${parts[0][0]}${parts[1][0]}'
        .toUpperCase();
  }
}
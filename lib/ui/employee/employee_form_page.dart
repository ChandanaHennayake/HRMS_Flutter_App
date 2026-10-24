import 'package:alionhr/models/employee.dart';
import 'package:flutter/material.dart';

import '../../models/employee_request.dart';
import '../../models/lookup_item.dart';
import '../../models/user.dart';
import '../../services/employee_service.dart';
import '../../services/lookup_service.dart';

class EmployeeFormPage extends StatefulWidget {
  final User user;
  final Employee? employee;

  const EmployeeFormPage({
    super.key,
    required this.user,
    this.employee,
  });

  bool get isEditMode => employee != null;

  @override
  State<EmployeeFormPage> createState() =>
      _EmployeeFormPageState();
}

class _EmployeeFormPageState
    extends State<EmployeeFormPage> {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  final _formKey = GlobalKey<FormState>();

  final EmployeeService _employeeService =
      EmployeeService();

  final LookupService _lookupService =
      LookupService();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController employeeCodeController =
      TextEditingController();

  final TextEditingController firstNameController =
      TextEditingController();

  final TextEditingController lastNameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController dateOfBirthController =
      TextEditingController();

  final TextEditingController joinedDateController =
      TextEditingController();

  final TextEditingController addressLine1Controller =
      TextEditingController();

  final TextEditingController addressLine2Controller =
      TextEditingController();

  final TextEditingController cityController =
      TextEditingController();

  final TextEditingController qualificationController =
      TextEditingController();

  final TextEditingController bankNameController =
      TextEditingController();

  final TextEditingController bankAccountNoController =
      TextEditingController();

  final TextEditingController bankBranchController =
      TextEditingController();

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // ============================================================
  // VALUES
  // ============================================================

  int? employmentTypeId;

  int? departmentId;

  int? branchId;

  int? designationId;

  int? roleId;

  // ============================================================
  // LOOKUPS
  // ============================================================

  EmployeeLookups? lookups;

  bool isLoadingLookups = true;

  String? lookupError;

  int get _companyId =>
      widget.employee?.companyId ??
      widget.user.companyId;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _prefillEmployee();
    _loadLookups();
  }

  void _prefillEmployee() {
    final e = widget.employee;
    if (e == null) return;

    employeeCodeController.text = e.employeeCode;
    firstNameController.text = e.firstName;
    lastNameController.text = e.lastName ?? '';
    emailController.text = e.email ?? '';
    phoneController.text = e.phone ?? '';
    addressLine1Controller.text = e.addressLine1 ?? '';
    addressLine2Controller.text = e.addressLine2 ?? '';
    cityController.text = e.city ?? '';
    qualificationController.text = e.qualification ?? '';
    bankNameController.text = e.bankName ?? '';
    bankAccountNoController.text = e.bankAccountNo ?? '';
    bankBranchController.text = e.bankBranch ?? '';
    if (e.dateOfBirth != null) {
      dateOfBirthController.text = _formatDate(e.dateOfBirth!);
    }
    if (e.joinedDate != null) {
      joinedDateController.text = _formatDate(e.joinedDate!);
    }
    gender = e.gender;
    branchId = e.branchId;
    departmentId = e.departmentId;
    designationId = e.designationId;
    employmentTypeId = e.employmentTypeId;

    if (e.username != null && e.username!.isNotEmpty) {
      usernameController.text = e.username!;
    }
    if (e.password != null && e.password!.isNotEmpty) {
      passwordController.text = e.password!;
    }
  }

  Future<void> _loadLookups() async {
    setState(() {
      isLoadingLookups = true;
      lookupError = null;
    });

    try {
      final result = await _lookupService.getEmployeeLookups(
        companyId: _companyId,
      );

      if (!mounted) return;

      setState(() {
        lookups = result;
        // Drop selections that point to inactive/deleted masters
        // so the dropdown doesn't crash and the user must reselect.
        branchId = _validOrNull(branchId, result.branches);
        departmentId = _validOrNull(departmentId, result.departments);
        designationId = _validOrNull(designationId, result.designations);
        employmentTypeId =
            _validOrNull(employmentTypeId, result.employmentTypes);
        roleId = _validOrNull(roleId, result.roles);
        isLoadingLookups = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        lookupError = e.toString().replaceFirst('Exception: ', '');
        isLoadingLookups = false;
      });
    }
  }

  int? _validOrNull(int? id, List<LookupItem> items) {
    if (id == null) return null;
    return items.any((x) => x.id == id) ? id : null;
  }

  String? gender;

  bool isSaving = false;

  bool obscurePassword = true;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    employeeCodeController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    joinedDateController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    qualificationController.dispose();
    bankNameController.dispose();
    bankAccountNoController.dispose();
    bankBranchController.dispose();
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (isSaving) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      if (widget.isEditMode) {
        await _updateEmployee();
        return;
      }

      final request = CreateEmployeeRequest(
        // ============================================
        // LIVE LOOKUP SELECTIONS
        // ============================================

        companyId: _companyId,
        branchId: branchId!,
        designationId: designationId!,
        roleId: roleId!,

        employmentTypeId: employmentTypeId!,

        // ============================================
        // EMPLOYEE DETAILS
        // ============================================

        employeeCode:
            employeeCodeController.text.trim(),

        firstName:
            firstNameController.text.trim(),

        lastName:
            _nullableText(
          lastNameController.text,
        ),

        email:
            _nullableText(
          emailController.text,
        ),

        phone:
            _nullableText(
          phoneController.text,
        ),

        departmentId:
            departmentId,

        dateOfBirth:
            _nullableText(
          dateOfBirthController.text,
        ),

        joinedDate:
            joinedDateController.text.trim(),

        gender:
            gender,

        addressLine1:
            _nullableText(
          addressLine1Controller.text,
        ),

        addressLine2:
            _nullableText(
          addressLine2Controller.text,
        ),

        city:
            _nullableText(
          cityController.text,
        ),

        bankName:
            _nullableText(
          bankNameController.text,
        ),

        bankAccountNo:
            _nullableText(
          bankAccountNoController.text,
        ),

        bankBranch:
            _nullableText(
          bankBranchController.text,
        ),

        qualification:
            _nullableText(
          qualificationController.text,
        ),

        // ============================================
        // LOGIN
        // ============================================

        createdBy:
            widget.user.userId,

        username:
            usernameController.text.trim(),

        password:
            passwordController.text,
      );

      await _employeeService.createEmployee(
        data: request.toJson(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Employee created successfully.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
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
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> _updateEmployee() async {
    final e = widget.employee!;

    final request = UpdateEmployeeRequest(
      companyId: _companyId,
      branchId: branchId!,
      employeeCode: employeeCodeController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: _nullableText(lastNameController.text),
      email: _nullableText(emailController.text),
      phone: _nullableText(phoneController.text),
      departmentId: departmentId,
      designationId: designationId,
      employmentTypeId: employmentTypeId,
      dateOfBirth: _nullableText(dateOfBirthController.text),
      joinedDate: joinedDateController.text.trim(),
      gender: gender,
      addressLine1: _nullableText(addressLine1Controller.text),
      addressLine2: _nullableText(addressLine2Controller.text),
      city: _nullableText(cityController.text),
      bankName: _nullableText(bankNameController.text),
      bankAccountNo: _nullableText(bankAccountNoController.text),
      bankBranch: _nullableText(bankBranchController.text),
      qualification: _nullableText(qualificationController.text),
      isActive: e.isActive,
      updatedBy: widget.user.userId,
      username: _nullableText(usernameController.text),
      password: _nullableText(passwordController.text),
      roleId: roleId,
    );

    await _employeeService.updateEmployee(
      id: e.id,
      data: request.toJson(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Employee updated successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, true);
  }

  // ============================================================
  // NULLABLE TEXT
  // ============================================================

  String? _nullableText(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate({
    required TextEditingController controller,
    required bool allowFuture,
  }) async {
    final now = DateTime.now();

    final initialDate =
        controller.text.isNotEmpty
            ? DateTime.tryParse(
                controller.text,
              ) ??
                now
            : now;

    final firstDate = allowFuture
        ? DateTime(
            now.year - 100,
            now.month,
            now.day,
          )
        : DateTime(
            now.year - 100,
            now.month,
            now.day,
          );

    final lastDate = allowFuture
        ? DateTime(
            now.year + 1,
            12,
            31,
          )
        : now;

    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          initialDate.isAfter(lastDate)
              ? lastDate
              : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selected == null) {
      return;
    }

    controller.text =
        _formatDate(selected);
  }

  String _formatDate(
    DateTime date,
  ) {
    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    return '${date.year}-$month-$day';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: Text(
          widget.isEditMode
              ? 'Edit Employee'
              : 'Add Employee',
        ),
        backgroundColor:
            Colors.white,
        foregroundColor:
            textDark,
        elevation: 0,
      ),

      body: isLoadingLookups
          ? const Center(
              child: CircularProgressIndicator(color: violet),
            )
          : lookupError != null
              ? _lookupErrorView()
              : _buildForm(),
    );
  }

  Widget _lookupErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: textMuted),
            const SizedBox(height: 12),
            Text(
              lookupError ?? 'Failed to load master data.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: textDark, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadLookups,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: violet,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final data = lookups!;

    return Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                'Organization',
              ),

              const SizedBox(
                height: 12,
              ),

              // ============================================
              // COMPANY
              // ============================================

              _fixedField(
                label: 'Company',
                value: 'Company #$_companyId',
                icon:
                    Icons.business_outlined,
              ),

              const SizedBox(
                height: 12,
              ),

              // ============================================
              // BRANCH
              // ============================================

              _lookupDropdown(
                label: 'Branch',
                icon: Icons.location_city_outlined,
                items: data.branches,
                value: branchId,
                requiredField: true,
                onChanged: (v) => setState(() => branchId = v),
              ),

              const SizedBox(
                height: 12,
              ),

              // ============================================
              // DESIGNATION
              // ============================================

              _lookupDropdown(
                label: 'Designation',
                icon: Icons.badge_outlined,
                items: data.designations,
                value: designationId,
                requiredField: true,
                onChanged: (v) => setState(() => designationId = v),
              ),

              const SizedBox(
                height: 12,
              ),

              // ============================================
              // ROLE (create only - role lives on the login account)
              // ============================================

              if (!widget.isEditMode) ...[
                _lookupDropdown(
                  label: 'Role',
                  icon: Icons.person_outline,
                  items: data.roles,
                  value: roleId,
                  requiredField: true,
                  onChanged: (v) => setState(() => roleId = v),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],

              // ============================================
              // EMPLOYMENT TYPE
              // ============================================

              _lookupDropdown(
                label: 'Employment Type',
                icon: Icons.work_outline,
                items: data.employmentTypes,
                value: employmentTypeId,
                requiredField: true,
                onChanged: (v) => setState(() => employmentTypeId = v),
              ),

              const SizedBox(
                height: 28,
              ),

              // ============================================
              // EMPLOYEE DETAILS
              // ============================================

              _sectionTitle(
                'Employee Details',
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    employeeCodeController,
                label:
                    'Employee Code',
                icon:
                    Icons.badge_outlined,
                requiredField: true,
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    firstNameController,
                label:
                    'First Name',
                icon:
                    Icons.person_outline,
                requiredField: true,
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    lastNameController,
                label:
                    'Last Name',
                icon:
                    Icons.person_outline,
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    emailController,
                label:
                    'Email',
                icon:
                    Icons.email_outlined,
                keyboardType:
                    TextInputType.emailAddress,
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    phoneController,
                label:
                    'Phone',
                icon:
                    Icons.phone_outlined,
                keyboardType:
                    TextInputType.phone,
              ),

              const SizedBox(
                height: 12,
              ),

              _lookupDropdown(
                label: 'Department',
                icon: Icons.account_tree_outlined,
                items: data.departments,
                value: departmentId,
                requiredField: true,
                onChanged: (v) => setState(() => departmentId = v),
              ),

              const SizedBox(
                height: 12,
              ),

              _dateField(
                controller:
                    dateOfBirthController,
                label:
                    'Date of Birth',
                onTap: () {
                  _selectDate(
                    controller:
                        dateOfBirthController,
                    allowFuture:
                        false,
                  );
                },
              ),

              const SizedBox(
                height: 12,
              ),

              _dateField(
                controller:
                    joinedDateController,
                label:
                    'Joined Date',
                requiredField:
                    true,
                onTap: () {
                  _selectDate(
                    controller:
                        joinedDateController,
                    allowFuture:
                        true,
                  );
                },
              ),

              const SizedBox(
                height: 12,
              ),

              _genderDropdown(),

              const SizedBox(
                height: 28,
              ),

              // ============================================
              // ADDRESS
              // ============================================

              _sectionTitle(
                'Address',
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    addressLine1Controller,
                label:
                    'Address Line 1',
                icon:
                    Icons.home_outlined,
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    addressLine2Controller,
                label:
                    'Address Line 2',
                icon:
                    Icons.home_outlined,
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    cityController,
                label:
                    'City',
                icon:
                    Icons.location_on_outlined,
              ),

              const SizedBox(
                height: 28,
              ),

              // ============================================
              // QUALIFICATIONS & EDUCATION
              // ============================================

              _sectionTitle(
                'Qualifications & Education',
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    qualificationController,
                label:
                    'Highest Qualification / Degree / Certifications',
                icon:
                    Icons.school_outlined,
              ),

              const SizedBox(
                height: 28,
              ),

              // ============================================
              // BANK & REMITTANCE DETAILS
              // ============================================

              _sectionTitle(
                'Bank Details',
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    bankNameController,
                label:
                    'Bank Name',
                icon:
                    Icons.account_balance_outlined,
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    bankAccountNoController,
                label:
                    'Account Number',
                icon:
                    Icons.credit_card_outlined,
                keyboardType:
                    TextInputType.number,
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    bankBranchController,
                label:
                    'Bank Branch',
                icon:
                    Icons.storefront_outlined,
              ),

              const SizedBox(
                height: 28,
              ),

              // ============================================
              // LOGIN & CREDENTIALS
              // ============================================

              _sectionTitle(
                widget.isEditMode ? 'User Account & Credentials' : 'Login Details',
              ),

              const SizedBox(
                height: 12,
              ),

              _textField(
                controller:
                    usernameController,
                label:
                    'Username',
                icon:
                    Icons.account_circle_outlined,
                requiredField:
                    !widget.isEditMode,
              ),

              const SizedBox(
                height: 12,
              ),

              _passwordField(isOptional: widget.isEditMode),

              const SizedBox(
                height: 30,
              ),

              // ============================================
              // SAVE
              // ============================================

              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    ElevatedButton(
                  onPressed:
                      isSaving
                          ? null
                          : _saveEmployee,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        violet,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),

                  child: isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.white,
                          ),
                        )
                      : Text(
                          widget.isEditMode
                              ? 'Save Changes'
                              : 'Create Employee',
                          style:
                              TextStyle(
                            fontSize:
                                15,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
    );
  }

  // ============================================================
  // FIXED FIELD
  // ============================================================

  Widget _fixedField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF0EDF3),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color:
              const Color(0xFFE2DDE7),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: violet,
            size: 21,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      const TextStyle(
                    color:
                        textMuted,
                    fontSize:
                        11,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value,
                  style:
                      const TextStyle(
                    color:
                        textDark,
                    fontSize:
                        14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.lock_outline,
            color: textMuted,
            size: 17,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOOKUP DROPDOWN (live master data)
  // ============================================================

  Widget _lookupDropdown({
    required String label,
    required IconData icon,
    required List<LookupItem> items,
    required int? value,
    required ValueChanged<int?> onChanged,
    bool requiredField = false,
  }) {
    final isEmpty = items.isEmpty;

    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,

      decoration: _inputDecoration(
        label: label,
        icon: icon,
      ).copyWith(
        helperText: isEmpty ? 'No active ${label.toLowerCase()} records found.' : null,
      ),

      hint: Text('Select $label'),

      items: items
          .map(
            (item) => DropdownMenuItem<int>(
              value: item.id,
              child: Text(
                item.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),

      onChanged: isSaving || isEmpty ? null : onChanged,

      validator: requiredField
          ? (v) => v == null ? '$label is required.' : null
          : null,
    );
  }

  // ============================================================
  // GENDER
  // ============================================================

  Widget _genderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: gender,

      decoration:
          _inputDecoration(
        label:
            'Gender',
        icon:
            Icons.wc_outlined,
      ),

      hint: const Text(
        'Select Gender',
      ),

      items: const [
        DropdownMenuItem(
          value: 'Male',
          child:
              Text('Male'),
        ),
        DropdownMenuItem(
          value: 'Female',
          child:
              Text('Female'),
        ),
        DropdownMenuItem(
          value: 'Other',
          child:
              Text('Other'),
        ),
      ],

      onChanged: (value) {
        setState(() {
          gender = value;
        });
      },
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    bool requiredField = false,
  }) {
    return TextFormField(
      controller:
          controller,

      readOnly: true,

      onTap: onTap,

      decoration:
          _inputDecoration(
        label: label,
        icon:
            Icons.calendar_today_outlined,
      ),

      validator:
          requiredField
              ? (value) {
                  if (value ==
                          null ||
                      value
                          .trim()
                          .isEmpty) {
                    return '$label is required.';
                  }

                  return null;
                }
              : null,
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool requiredField = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller:
          controller,

      keyboardType:
          keyboardType,

      textInputAction:
          TextInputAction.next,

      decoration:
          _inputDecoration(
        label: label,
        icon: icon,
      ),

      validator:
          requiredField
              ? (value) {
                  if (value ==
                          null ||
                      value
                          .trim()
                          .isEmpty) {
                    return '$label is required.';
                  }

                  return null;
                }
              : null,
    );
  }

  // ============================================================
  // PASSWORD
  // ============================================================

  Widget _passwordField({bool isOptional = false}) {
    return TextFormField(
      controller:
          passwordController,

      obscureText:
          obscurePassword,

      decoration:
          _inputDecoration(
        label:
            widget.isEditMode ? 'Password (leave blank to keep current)' : 'Password',
        icon:
            Icons.lock_outline,
      ).copyWith(
        suffixIcon:
            IconButton(
          onPressed: () {
            setState(() {
              obscurePassword =
                  !obscurePassword;
            });
          },
          icon: Icon(
            obscurePassword
                ? Icons
                    .visibility_outlined
                : Icons
                    .visibility_off_outlined,
          ),
        ),
      ),

      validator: (value) {
        if (isOptional && (value == null || value.trim().isEmpty)) {
          return null;
        }

        if (value ==
                null ||
            value
                .trim()
                .isEmpty) {
          return 'Password is required.';
        }

        if (value.length <
            6) {
          return 'Password must contain at least 6 characters.';
        }

        return null;
      },
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,

      prefixIcon:
          Icon(
        icon,
        color: violet,
        size: 20,
      ),

      filled: true,

      fillColor:
          Colors.white,

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        borderSide:
            const BorderSide(
          color:
              Color(0xFFE2DDE7),
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        borderSide:
            const BorderSide(
          color:
              Color(0xFFE2DDE7),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        borderSide:
            const BorderSide(
          color: violet,
          width: 1.5,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        borderSide:
            const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        borderSide:
            const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
  ) {
    return Text(
      title,
      style:
          const TextStyle(
        color: textDark,
        fontSize: 17,
        fontWeight:
            FontWeight.bold,
      ),
    );
  }
}
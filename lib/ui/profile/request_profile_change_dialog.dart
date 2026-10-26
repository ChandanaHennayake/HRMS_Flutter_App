import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/profile_change_service.dart';

class RequestProfileChangeDialog extends StatefulWidget {
  final UserProfile profile;
  final int employeeId;

  const RequestProfileChangeDialog({
    super.key,
    required this.profile,
    required this.employeeId,
  });

  @override
  State<RequestProfileChangeDialog> createState() => _RequestProfileChangeDialogState();
}

class _RequestProfileChangeDialogState extends State<RequestProfileChangeDialog> {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color deepDark = Color(0xFF0B0614);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  final _formKey = GlobalKey<FormState>();
  final ProfileChangeService _service = ProfileChangeService();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;
  late final TextEditingController _address1Controller;
  late final TextEditingController _address2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _bankAccountNoController;
  late final TextEditingController _bankBranchController;
  late final TextEditingController _reasonController;

  String? _selectedGender;
  bool _isSubmitting = false;

  final List<String> _commonBanks = [
    'Commercial Bank of Ceylon',
    'Bank of Ceylon (BOC)',
    'People\'s Bank',
    'Hatton National Bank (HNB)',
    'Sampath Bank',
    'Nations Trust Bank (NTB)',
    'Seylan Bank',
    'DFCC Bank',
    'National Development Bank (NDB)',
    'Pan Asia Bank',
    'Standard Chartered Bank',
    'HSBC Sri Lanka',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;

    _firstNameController = TextEditingController(text: p.firstName ?? '');
    _lastNameController = TextEditingController(text: p.lastName ?? '');
    _phoneController = TextEditingController(text: p.phone ?? '');
    _dobController = TextEditingController(text: p.dateOfBirth ?? '');
    _address1Controller = TextEditingController(text: p.addressLine1 ?? '');
    _address2Controller = TextEditingController(text: p.addressLine2 ?? '');
    _cityController = TextEditingController(text: p.city ?? '');
    _qualificationController = TextEditingController(text: p.qualification ?? '');
    _bankNameController = TextEditingController(text: p.bankName ?? '');
    _bankAccountNoController = TextEditingController(text: p.bankAccountNo ?? '');
    _bankBranchController = TextEditingController(text: p.bankBranch ?? '');
    _reasonController = TextEditingController();

    _selectedGender = p.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _qualificationController.dispose();
    _bankNameController.dispose();
    _bankAccountNoController.dispose();
    _bankBranchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 25));
    if (_dobController.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_dobController.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: violet,
              onPrimary: Colors.white,
              onSurface: textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final yyyy = picked.year.toString().padLeft(4, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final dd = picked.day.toString().padLeft(2, '0');
      setState(() {
        _dobController.text = '$yyyy-$mm-$dd';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason or note explaining the update.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final requestData = {
        'employeeId': widget.employeeId,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'dateOfBirth': _dobController.text.trim().isEmpty ? null : _dobController.text.trim(),
        'gender': _selectedGender,
        'addressLine1': _address1Controller.text.trim().isEmpty ? null : _address1Controller.text.trim(),
        'addressLine2': _address2Controller.text.trim().isEmpty ? null : _address2Controller.text.trim(),
        'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        'qualification': _qualificationController.text.trim().isEmpty ? null : _qualificationController.text.trim(),
        'bankName': _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
        'bankAccountNo': _bankAccountNoController.text.trim().isEmpty ? null : _bankAccountNoController.text.trim(),
        'bankBranch': _bankBranchController.text.trim().isEmpty ? null : _bankBranchController.text.trim(),
        'reason': _reasonController.text.trim(),
      };

      await _service.submitRequest(requestData);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
            maxWidth: 520,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [deepDark, Color(0xFF1D1435)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: violet.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.manage_accounts_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Details Change',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Updates require Manager or Admin approval',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Banner notice
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD8B4FE)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: violet, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Submit your updated banking and personal details. Once approved by management, your Employee and User login records will automatically be updated.',
                                style: TextStyle(color: Color(0xFF581C87), fontSize: 11.5, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section 1: Bank Account Details
                      _buildSectionHeader('Bank & Salary Account', Icons.account_balance_outlined),
                      const SizedBox(height: 12),
                      _buildBankSelector(),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _bankAccountNoController,
                        label: 'Bank Account Number',
                        hint: 'e.g., 8001234567',
                        icon: Icons.numbers_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _bankBranchController,
                        label: 'Bank Branch Name / Code',
                        hint: 'e.g., Kollupitiya Branch',
                        icon: Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Personal Details
                      _buildSectionHeader('Personal Information', Icons.person_outline),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'First Name *',
                        hint: 'e.g., John',
                        icon: Icons.badge_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? 'First name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        hint: 'e.g., Doe',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Contact Phone Number',
                        hint: 'e.g., 0771234567',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderDropdown(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _selectDateOfBirth,
                              child: IgnorePointer(
                                child: _buildTextField(
                                  controller: _dobController,
                                  label: 'Date of Birth',
                                  hint: 'YYYY-MM-DD',
                                  icon: Icons.cake_outlined,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section 3: Residential Address
                      _buildSectionHeader('Residential Address', Icons.home_outlined),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _address1Controller,
                        label: 'Address Line 1',
                        hint: 'e.g., No. 45, Galle Road',
                        icon: Icons.map_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _address2Controller,
                        label: 'Address Line 2',
                        hint: 'e.g., Apartment 3B',
                        icon: Icons.map_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        hint: 'e.g., Colombo',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _qualificationController,
                        label: 'Highest Educational / Professional Qualification',
                        hint: 'e.g., B.Sc in Information Technology',
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 24),

                      // Section 4: Justification / Reason
                      _buildSectionHeader('Reason for Request *', Icons.comment_outlined),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _reasonController,
                        label: 'Note for Reviewer *',
                        hint: 'e.g., Updated primary salary account for monthly payroll bank transfer.',
                        icon: Icons.edit_note_outlined,
                        maxLines: 3,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please explain why this change is requested' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFC),
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: textDark, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: violet,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Submit for Approval',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                  ),
                                ],
                              ),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: violet),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
      ],
    );
  }

  Widget _buildBankSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _commonBanks.contains(_bankNameController.text) ? _bankNameController.text : null,
          decoration: InputDecoration(
            labelText: 'Bank Name',
            labelStyle: const TextStyle(color: textMuted, fontSize: 13),
            prefixIcon: const Icon(Icons.account_balance, color: violet, size: 20),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: violet, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: _commonBanks.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 12.5)))).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                if (val != 'Other') {
                  _bankNameController.text = val;
                } else {
                  _bankNameController.clear();
                }
              });
            }
          },
        ),
        if (!_commonBanks.contains(_bankNameController.text) && _bankNameController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildTextField(
            controller: _bankNameController,
            label: 'Custom Bank Name',
            hint: 'Enter your bank name',
            icon: Icons.account_balance_outlined,
          ),
        ],
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: const TextStyle(color: textMuted, fontSize: 13),
        prefixIcon: const Icon(Icons.people_outline, color: violet, size: 20),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: violet, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: 'Other', child: Text('Other', style: TextStyle(fontSize: 13))),
      ],
      onChanged: (v) => setState(() => _selectedGender = v),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13.5, color: textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textMuted, fontSize: 13),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12.5),
        prefixIcon: Icon(icon, color: violet, size: 20),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: violet, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: validator,
    );
  }
}

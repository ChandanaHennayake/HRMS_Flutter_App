import 'package:flutter/material.dart';

import '../../core/location/location_service.dart';
import '../../models/branch.dart';
import '../../models/user.dart';
import '../../services/branch_service.dart';

class BranchFormDialog extends StatefulWidget {
  final User? user;
  final Branch? branch; // null for Create, non-null for Edit

  const BranchFormDialog({
    super.key,
    this.user,
    this.branch,
  });

  @override
  State<BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends State<BranchFormDialog> {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  final _formKey = GlobalKey<FormState>();
  final BranchService _branchService = BranchService();

  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _radiusController;

  late bool _isActive;
  bool _isSaving = false;
  bool _isFetchingLocation = false;
  String? _errorMessage;

  bool get isEdit => widget.branch != null;

  @override
  void initState() {
    super.initState();
    final b = widget.branch;
    _nameController = TextEditingController(text: b?.branchName ?? '');
    _codeController = TextEditingController(text: b?.branchCode ?? '');
    _addressController = TextEditingController(text: b?.address ?? '');
    _phoneController = TextEditingController(text: b?.phone ?? '');
    _latController = TextEditingController(
      text: b?.latitude != null ? b!.latitude!.toString() : '',
    );
    _lngController = TextEditingController(
      text: b?.longitude != null ? b!.longitude!.toString() : '',
    );
    _radiusController = TextEditingController(
      text: (b?.geofenceRadiusMeters ?? 100).toString(),
    );
    _isActive = b?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _errorMessage = null;
    });

    try {
      final pos = await LocationService().getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _latController.text = pos.latitude.toStringAsFixed(6);
        _lngController.text = pos.longitude.toStringAsFixed(6);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Captured GPS coordinates successfully.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    double? lat;
    if (_latController.text.trim().isNotEmpty) {
      lat = double.tryParse(_latController.text.trim());
      if (lat == null || lat < -90 || lat > 90) {
        setState(() => _errorMessage = 'Latitude must be between -90 and 90.');
        return;
      }
    }

    double? lng;
    if (_lngController.text.trim().isNotEmpty) {
      lng = double.tryParse(_lngController.text.trim());
      if (lng == null || lng < -180 || lng > 180) {
        setState(() => _errorMessage = 'Longitude must be between -180 and 180.');
        return;
      }
    }

    final radius = int.tryParse(_radiusController.text.trim()) ?? 100;
    if (radius <= 0) {
      setState(() => _errorMessage = 'Geofence radius must be greater than zero.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      if (isEdit) {
        await _branchService.updateBranch(
          branchId: widget.branch!.branchId,
          branchName: _nameController.text.trim(),
          branchCode: _codeController.text.trim().isEmpty
              ? null
              : _codeController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          latitude: lat,
          longitude: lng,
          geofenceRadiusMeters: radius,
          isActive: _isActive,
        );
      } else {
        final companyId = widget.user?.companyId ?? 1;
        await _branchService.createBranch(
          companyId: companyId,
          branchName: _nameController.text.trim(),
          branchCode: _codeController.text.trim().isEmpty
              ? null
              : _codeController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          latitude: lat,
          longitude: lng,
          geofenceRadiusMeters: radius,
          isActive: _isActive,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Branch' : 'Add New Branch',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: textMuted),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Branch Name
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                    'Branch Name *',
                    Icons.business,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Branch name is required'
                      : null,
                ),
                const SizedBox(height: 12),

                // Branch Code
                TextFormField(
                  controller: _codeController,
                  decoration: _inputDecoration(
                    'Branch Code (e.g. CMB-01)',
                    Icons.tag,
                  ),
                ),
                const SizedBox(height: 12),

                // Address
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: _inputDecoration(
                    'Address',
                    Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 12),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(
                    'Phone Number',
                    Icons.phone_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                // GPS Location Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GPS Geofence Coordinates',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isFetchingLocation ? null : _captureLocation,
                      icon: _isFetchingLocation
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: violet,
                              ),
                            )
                          : const Icon(Icons.my_location, size: 16, color: violet),
                      label: const Text(
                        'Use GPS',
                        style: TextStyle(fontSize: 12, color: violet),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: _inputDecoration(
                          'Latitude',
                          Icons.explore_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: _inputDecoration(
                          'Longitude',
                          Icons.explore_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Geofence Radius
                TextFormField(
                  controller: _radiusController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    'Geofence Radius (meters)',
                    Icons.radar_outlined,
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) {
                      return 'Enter radius > 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Active Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active Status',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Switch(
                      value: _isActive,
                      activeThumbColor: violet,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: violet,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEdit ? 'Save Changes' : 'Create Branch',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: textMuted),
      labelStyle: const TextStyle(fontSize: 13, color: textMuted),
      filled: true,
      fillColor: const Color(0xFFF9F8FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: violet, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

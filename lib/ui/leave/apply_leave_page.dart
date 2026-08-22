import 'package:alionhr/models/apply_leave_request.dart';
import 'package:flutter/material.dart';

import '../../models/leave_type.dart';
import '../../models/user.dart';
import '../../services/leave_service.dart';

class ApplyLeavePage extends StatefulWidget {
  final User user;

  const ApplyLeavePage({
    super.key,
    required this.user,
  });

  @override
  State<ApplyLeavePage> createState() => _ApplyLeavePageState();
}

class _ApplyLeavePageState extends State<ApplyLeavePage> {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  final LeaveService _leaveService = LeaveService();

  final TextEditingController _reasonController =
      TextEditingController();

  List<LeaveType> _leaveTypes = [];

  LeaveType? _selectedLeaveType;

  DateTime? _fromDate;
  DateTime? _toDate;

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadLeaveTypes();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD LEAVE TYPES
  // ============================================================

  Future<void> _loadLeaveTypes() async {
    try {
      final types =
          await _leaveService.getLeaveTypes();

      if (!mounted) return;

      final activeTypes = types
          .where((type) => type.isActive)
          .toList();

      setState(() {
        _leaveTypes = activeTypes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(_cleanError(e));
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectFromDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) return;

    setState(() {
      _fromDate = picked;

      if (_toDate != null &&
          _toDate!.isBefore(picked)) {
        _toDate = null;
      }
    });
  }

  Future<void> _selectToDate() async {
    if (_fromDate == null) {
      _showError(
        'Please select the start date first.',
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate!,
      firstDate: _fromDate!,
      lastDate: DateTime(
        _fromDate!.year + 2,
      ),
    );

    if (picked == null) return;

    setState(() {
      _toDate = picked;
    });
  }

  // ============================================================
  // TOTAL DAYS
  // ============================================================

  int get _totalDays {
    if (_fromDate == null || _toDate == null) {
      return 0;
    }

    return _toDate!
            .difference(_fromDate!)
            .inDays +
        1;
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (_selectedLeaveType == null) {
      _showError('Please select a leave type.');
      return;
    }

    if (_fromDate == null) {
      _showError('Please select the start date.');
      return;
    }

    if (_toDate == null) {
      _showError('Please select the end date.');
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      _showError('Please enter a reason.');
      return;
    }

    if (_totalDays <= 0) {
      _showError('Invalid leave dates.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _leaveService.applyLeave(
        employeeId: widget.user.employeeId,
        request: ApplyLeaveRequest(
          leaveTypeId: _selectedLeaveType!.id,
          fromDate: _fromDate!,
          toDate: _toDate!,
          reason: _reasonController.text.trim(),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Leave request submitted successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showError(_cleanError(e));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
        title: const Text(
          'Apply Leave',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: violet,
              ),
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _label('Leave Type'),

          const SizedBox(height: 8),

          DropdownButtonFormField<LeaveType>(
            value: _selectedLeaveType,
            decoration: _inputDecoration(
              'Select leave type',
              Icons.event_note_outlined,
            ),
            items: _leaveTypes.map((type) {
              return DropdownMenuItem<LeaveType>(
                value: type,
                child: Text(type.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLeaveType = value;
              });
            },
          ),

          const SizedBox(height: 20),

          _label('Start Date'),

          const SizedBox(height: 8),

          _dateField(
            date: _fromDate,
            hint: 'Select start date',
            onTap: _selectFromDate,
          ),

          const SizedBox(height: 20),

          _label('End Date'),

          const SizedBox(height: 8),

          _dateField(
            date: _toDate,
            hint: 'Select end date',
            onTap: _selectToDate,
          ),

          if (_totalDays > 0) ...[
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0E4FA),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timelapse_rounded,
                    color: violet,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Total Leave: $_totalDays day(s)',
                    style: const TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          _label('Reason'),

          const SizedBox(height: 8),

          TextField(
            controller: _reasonController,
            maxLines: 5,
            decoration: _inputDecoration(
              'Enter reason for leave',
              Icons.notes_outlined,
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed:
                  _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: violet,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child:
                          CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Submit Leave Request',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: textDark,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _dateField({
    required DateTime? date,
    required String hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _inputDecoration(
          hint,
          Icons.calendar_today_outlined,
        ),
        child: Text(
          date == null
              ? hint
              : _formatDate(date),
          style: TextStyle(
            color:
                date == null ? textMuted : textDark,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: textMuted,
      ),
      prefixIcon: Icon(
        icon,
        color: violet,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFEEE8F3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFEEE8F3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: violet,
          width: 1.5,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
  }
}
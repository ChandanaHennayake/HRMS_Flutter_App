import 'package:flutter/material.dart';

import '../../services/attendance_correction_service.dart';

class AttendanceCorrectionDialog extends StatefulWidget {
  final int employeeId;
  final DateTime? initialDate;

  const AttendanceCorrectionDialog({
    super.key,
    required this.employeeId,
    this.initialDate,
  });

  @override
  State<AttendanceCorrectionDialog> createState() =>
      _AttendanceCorrectionDialogState();
}

class _AttendanceCorrectionDialogState
    extends State<AttendanceCorrectionDialog> {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final AttendanceCorrectionService _service = AttendanceCorrectionService();

  late DateTime _selectedDate;
  TimeOfDay? _selectedCheckInTime;
  TimeOfDay? _selectedCheckOutTime;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
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
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isCheckIn}) async {
    final initial = isCheckIn
        ? (_selectedCheckInTime ?? const TimeOfDay(hour: 8, minute: 30))
        : (_selectedCheckOutTime ?? const TimeOfDay(hour: 17, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
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
      setState(() {
        if (isCheckIn) {
          _selectedCheckInTime = picked;
        } else {
          _selectedCheckOutTime = picked;
        }
      });
    }
  }

  DateTime? _combineDateAndTime(DateTime date, TimeOfDay? time) {
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCheckInTime == null && _selectedCheckOutTime == null) {
      setState(() {
        _errorMessage =
            'Please specify at least requested check-in or check-out time.';
      });
      return;
    }

    final checkIn = _combineDateAndTime(_selectedDate, _selectedCheckInTime);
    final checkOut = _combineDateAndTime(_selectedDate, _selectedCheckOutTime);

    if (checkIn != null && checkOut != null && checkOut.isBefore(checkIn)) {
      setState(() {
        _errorMessage = 'Check-out time must be after check-in time.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      final result = await _service.submitCorrection(
        employeeId: widget.employeeId,
        attendanceDate: dateStr,
        requestedCheckInTime: checkIn,
        requestedCheckOutTime: checkOut,
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: violet.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_calendar, color: violet),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance Correction',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Request missing check-in or check-out',
                            style: TextStyle(fontSize: 12, color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 28),

                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Date Selector
                const Text(
                  'Attendance Date',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E0EE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: violet),
                        const SizedBox(width: 10),
                        Text(
                          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textDark,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time Selectors Row
                Row(
                  children: [
                    // Check-in
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check-In Time',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _pickTime(isCheckIn: true),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: background,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE5E0EE)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.login,
                                      size: 16, color: Color(0xFF10B981)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedCheckInTime != null
                                          ? _selectedCheckInTime!
                                              .format(context)
                                          : 'Select',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _selectedCheckInTime != null
                                            ? textDark
                                            : textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Check-out
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check-Out Time',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _pickTime(isCheckIn: false),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: background,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE5E0EE)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.logout,
                                      size: 16, color: Color(0xFFEF4444)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedCheckOutTime != null
                                          ? _selectedCheckOutTime!
                                              .format(context)
                                          : 'Select',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _selectedCheckOutTime != null
                                            ? textDark
                                            : textMuted,
                                      ),
                                    ),
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
                const SizedBox(height: 16),

                // Reason Field
                const Text(
                  'Reason for Correction *',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please provide a reason.';
                    }
                    if (val.trim().length < 5) {
                      return 'Reason must be at least 5 characters.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Forgot to punch out due to client emergency meeting.',
                    hintStyle: const TextStyle(color: textMuted, fontSize: 13),
                    filled: true,
                    fillColor: background,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E0EE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E0EE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: violet, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: textMuted)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: violet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit Request',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
}

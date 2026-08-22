import 'package:flutter/material.dart';

import '../../../models/leave_request.dart';
import '../../../models/leave_action_request.dart';
import '../../../models/user.dart';
import '../../../services/leave_service.dart';

class ManagerLeaveDetailsPage extends StatefulWidget {
  final LeaveRequest leave;
  final User user;

  const ManagerLeaveDetailsPage({
    super.key,
    required this.leave,
    required this.user,
  });

  @override
  State<ManagerLeaveDetailsPage> createState() =>
      _ManagerLeaveDetailsPageState();
}

class _ManagerLeaveDetailsPageState
    extends State<ManagerLeaveDetailsPage> {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  final LeaveService _leaveService = LeaveService();

  final TextEditingController _remarksController =
      TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Future<void> _approveLeave() async {
    await _processLeave(isApprove: true);
  }

  Future<void> _rejectLeave() async {
    await _processLeave(isApprove: false);
  }

  Future<void> _processLeave({
    required bool isApprove,
  }) async {
    if (_isProcessing) return;

    final action = isApprove ? 'approve' : 'reject';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isApprove ? 'Approve Leave' : 'Reject Leave',
          ),
          content: Text(
            isApprove
                ? 'Are you sure you want to approve this leave request?'
                : 'Are you sure you want to reject this leave request?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isApprove ? Colors.green : Colors.red,
              ),
              child: Text(
                isApprove ? 'Approve' : 'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final request = LeaveActionRequest(
        remarks: _remarksController.text.trim().isEmpty
            ? null
            : _remarksController.text.trim(),
      );

      if (isApprove) {
        await _leaveService.approveLeave(
          leaveRequestId: widget.leave.id,
          approvedBy: widget.user.employeeId,
          request: request,
        );
      } else {
        await _leaveService.rejectLeave(
          leaveRequestId: widget.leave.id,
          rejectedBy: widget.user.employeeId,
          request: request,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApprove
                ? 'Leave approved successfully.'
                : 'Leave rejected successfully.',
          ),
          backgroundColor:
              isApprove ? Colors.green : Colors.red,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leave = widget.leave;
    final statusColor = _statusColor(leave.status);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Leave Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(leave, statusColor),

            const SizedBox(height: 16),

            _buildEmployeeCard(leave),

            const SizedBox(height: 16),

            _buildLeaveInformation(leave),

            const SizedBox(height: 16),

            _buildReason(leave),

            const SizedBox(height: 16),

            _buildRemarks(),

            const SizedBox(height: 24),

            if (leave.status.toLowerCase() == 'pending')
              _buildActionButtons(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    LeaveRequest leave,
    Color statusColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B0B63),
            violet,
            Color(0xFFA855F7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  leave.leaveType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Leave Request #${leave.id}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _statusBadge(
            leave.status,
            statusColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(
    LeaveRequest leave,
  ) {
    return _sectionCard(
      title: 'Employee',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _infoRow(
            'Employee',
            leave.employeeName.isEmpty
                ? 'Employee #${leave.employeeId}'
                : leave.employeeName,
          ),
          _infoRow(
            'Employee ID',
            leave.employeeId.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveInformation(
    LeaveRequest leave,
  ) {
    return _sectionCard(
      title: 'Leave Information',
      icon: Icons.calendar_month_outlined,
      child: Column(
        children: [
          _infoRow(
            'Leave Type',
            leave.leaveType,
          ),
          _infoRow(
            'From Date',
            _formatDate(leave.fromDate),
          ),
          _infoRow(
            'To Date',
            _formatDate(leave.toDate),
          ),
          _infoRow(
            'Total Days',
            '${leave.totalDays} day(s)',
          ),
          _infoRow(
            'Applied Date',
            _formatDate(leave.appliedDate),
          ),
        ],
      ),
    );
  }

  Widget _buildReason(
    LeaveRequest leave,
  ) {
    return _sectionCard(
      title: 'Reason',
      icon: Icons.description_outlined,
      child: Text(
        leave.reason.isEmpty
            ? 'No reason provided.'
            : leave.reason,
        style: const TextStyle(
          color: textDark,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildRemarks() {
    return _sectionCard(
      title: 'Manager Remarks',
      icon: Icons.comment_outlined,
      child: TextField(
        controller: _remarksController,
        maxLines: 4,
        enabled: !_isProcessing,
        decoration: InputDecoration(
          hintText:
              'Enter remarks (optional)',
          filled: true,
          fillColor: const Color(0xFFF9F7FB),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE9E3EF),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: violet,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed:
                  _isProcessing ? null : _rejectLeave,
              icon: const Icon(
                Icons.close_rounded,
              ),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(
                  color: Colors.red,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed:
                  _isProcessing ? null : _approveLeave,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.check_rounded,
                    ),
              label: Text(
                _isProcessing
                    ? 'Processing...'
                    : 'Approve',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEE8F3),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: violet,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: textMuted,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(
    String status,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
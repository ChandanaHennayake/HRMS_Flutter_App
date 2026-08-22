import 'package:flutter/material.dart';

import '../../models/leave_request.dart';
import '../../models/user.dart';
import '../../services/leave_service.dart';

class LeaveDetailsPage extends StatefulWidget {
  final LeaveRequest leave;
  final User user;

  const LeaveDetailsPage({
    super.key,
    required this.leave,
    required this.user,
  });

  @override
  State<LeaveDetailsPage> createState() =>
      _LeaveDetailsPageState();
}

class _LeaveDetailsPageState
    extends State<LeaveDetailsPage> {
  final LeaveService _leaveService =
      LeaveService();

  bool _isCancelling = false;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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

  Future<void> _cancelLeave() async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Cancel Leave'),

          content: const Text(
            'Are you sure you want to cancel '
            'this leave request?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('No'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      await _leaveService.cancelLeave(
        leaveRequestId: widget.leave.id,
        employeeId:
            widget.user.employeeId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Leave request cancelled successfully.',
          ),
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
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leave = widget.leave;

    final statusColor =
        _statusColor(leave.status);

    // Employee can cancel only pending requests.
    final canCancel =
        leave.status.toLowerCase() ==
            'pending';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F5FA),

      appBar: AppBar(
        title: const Text(
          'Leave Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF211B2E),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _statusCard(
              leave.status,
              statusColor,
            ),

            const SizedBox(height: 16),

            _section(
              title: 'Leave Information',
              children: [
                _infoRow(
                  Icons.category_outlined,
                  'Leave Type',
                  leave.leaveType,
                ),

                _infoRow(
                  Icons
                      .calendar_today_outlined,
                  'From Date',
                  _formatDate(
                    leave.fromDate,
                  ),
                ),

                _infoRow(
                  Icons.event_outlined,
                  'To Date',
                  _formatDate(
                    leave.toDate,
                  ),
                ),

                _infoRow(
                  Icons.timelapse,
                  'Total Days',
                  '${leave.totalDays} day(s)',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _section(
              title: 'Reason',
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(14),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF7F5FA,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Text(
                    leave.reason,
                    style:
                        const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _section(
              title: 'Request Information',
              children: [
                _infoRow(
                  Icons.access_time,
                  'Applied Date',
                  _formatDateTime(
                    leave.appliedDate,
                  ),
                ),

                if (leave.remarks != null &&
                    leave.remarks!
                        .trim()
                        .isNotEmpty)
                  _infoRow(
                    Icons.comment_outlined,
                    'Remarks',
                    leave.remarks!,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            if (canCancel)
              SizedBox(
                width: double.infinity,
                height: 50,
                child:
                    FilledButton.icon(
                  onPressed:
                      _isCancelling
                          ? null
                          : _cancelLeave,
                  icon: _isCancelling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons
                              .cancel_outlined,
                        ),
                  label: Text(
                    _isCancelling
                        ? 'Cancelling...'
                        : 'Cancel Leave',
                  ),
                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        Colors.red,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
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

  Widget _statusCard(
    String status,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              color.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 42,
            color: color,
          ),

          const SizedBox(height: 10),

          const Text(
            'Leave Request Status',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            status,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
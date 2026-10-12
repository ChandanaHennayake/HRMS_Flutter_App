import 'package:flutter/material.dart';

import '../../../models/leave_request.dart';
import '../../../models/user.dart';
import '../../../services/leave_service.dart';
import 'manager_leave_details_page.dart';

class ManagerLeavePage extends StatefulWidget {
  final User user;
  final int? branchId;
  final String? branchName;

  const ManagerLeavePage({
    super.key,
    required this.user,
    this.branchId,
    this.branchName,
  });

  @override
  State<ManagerLeavePage> createState() =>
      _ManagerLeavePageState();
}

class _ManagerLeavePageState
    extends State<ManagerLeavePage> {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color background = Color(0xFFF7F5FA);
  static const Color textDark = Color(0xFF211B2E);
  static const Color textMuted = Color(0xFF8B87A0);

  final LeaveService _leaveService = LeaveService();

  List<LeaveRequest> _leaves = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingLeaves();
  }

  // ============================================================
  // LOAD PENDING LEAVES
  // ============================================================

  Future<void> _loadPendingLeaves() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _leaveService.getPendingLeaves(
        branchId: widget.branchId ?? widget.user.branchId,
      );

      if (!mounted) return;

      setState(() {
        _leaves = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  // ============================================================
  // OPEN DETAILS
  // ============================================================

  Future<void> _openDetails(
    LeaveRequest leave,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ManagerLeaveDetailsPage(
          leave: leave,
          user: widget.user,
        ),
      ),
    );

    // Refresh after approve/reject
    if (result == true) {
      await _loadPendingLeaves();
    }
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
          widget.branchName != null
              ? 'Leaves - ${widget.branchName}'
              : 'Leave Requests',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading
                ? null
                : _loadPendingLeaves,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPendingLeaves,
        color: violet,
        child: _buildBody(),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: violet,
        ),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_leaves.isEmpty) {
      return _buildEmpty();
    }

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummary(),

        const SizedBox(height: 20),

        const Text(
          'Pending Requests',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ..._leaves.map(
          (leave) => Padding(
            padding:
                const EdgeInsets.only(bottom: 12),
            child: _buildLeaveCard(leave),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
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
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.pending_actions_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Leave Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_leaves.length} request(s) waiting for approval',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${_leaves.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEAVE CARD
  // ============================================================

  Widget _buildLeaveCard(
    LeaveRequest leave,
  ) {
    return InkWell(
      onTap: () => _openDetails(leave),
      borderRadius:
          BorderRadius.circular(16),
      child: Container(
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
            // ----------------------------------------------------
            // EMPLOYEE + STATUS
            // ----------------------------------------------------

            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color:
                        violet.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: violet,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.employeeName.isEmpty
                            ? 'Employee #${leave.employeeId}'
                            : leave.employeeName,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Employee ID: ${leave.employeeId}',
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                _pendingBadge(),
              ],
            ),

            const SizedBox(height: 16),

            // ----------------------------------------------------
            // LEAVE TYPE
            // ----------------------------------------------------

            Row(
              children: [
                const Icon(
                  Icons.event_note_outlined,
                  color: violet,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    leave.leaveType,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ----------------------------------------------------
            // DATE
            // ----------------------------------------------------

            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: textMuted,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(leave.fromDate)}'
                  ' - '
                  '${_formatDate(leave.toDate)}',
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ----------------------------------------------------
            // TOTAL DAYS
            // ----------------------------------------------------

            Row(
              children: [
                const Icon(
                  Icons.timelapse_rounded,
                  color: textMuted,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${leave.totalDays} day(s)',
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ----------------------------------------------------
            // REASON
            // ----------------------------------------------------

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7FB),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Text(
                leave.reason.isEmpty
                    ? 'No reason provided.'
                    : leave.reason,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ----------------------------------------------------
            // VIEW DETAILS
            // ----------------------------------------------------

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                const Text(
                  'Review Request',
                  style: TextStyle(
                    color: violet,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: violet,
                  size: 13,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PENDING BADGE
  // ============================================================

  Widget _pendingBadge() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pending_rounded,
            color: Colors.orange,
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            'Pending',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 130),
        const Icon(
          Icons.task_alt_rounded,
          color: Colors.green,
          size: 65,
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'No Pending Leave Requests',
            style: TextStyle(
              color: textDark,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 35),
          child: Text(
            'All leave requests have been processed.',
            textAlign: TextAlign.center,
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

  Widget _buildError() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),

        const Icon(
          Icons.error_outline_rounded,
          color: Colors.red,
          size: 60,
        ),

        const SizedBox(height: 15),

        const Center(
          child: Text(
            'Unable to load leave requests',
            style: TextStyle(
              color: textDark,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 25,
          ),
          child: Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textMuted,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: FilledButton(
            onPressed: _loadPendingLeaves,
            style: FilledButton.styleFrom(
              backgroundColor: violet,
            ),
            child: const Text(
              'Try Again',
            ),
          ),
        ),
      ],
    );
  }
}
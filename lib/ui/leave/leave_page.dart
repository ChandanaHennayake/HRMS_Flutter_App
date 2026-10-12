import 'package:flutter/material.dart';

import '../../models/leave_balance.dart';
import '../../models/leave_request.dart';
import '../../models/user.dart';
import '../../services/leave_service.dart';
import 'apply_leave_page.dart';
import 'leave_details_page.dart';
import 'leave_history_page.dart';

class LeavePage extends StatefulWidget {
  final User user;

  const LeavePage({
    super.key,
    required this.user,
  });

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  static const Color violet = Color(0xFF7C2FCE);
  static const Color brightViolet =
      Color(0xFFA855F7);
  static const Color background =
      Color(0xFFF7F5FA);
  static const Color textDark =
      Color(0xFF211B2E);
  static const Color textMuted =
      Color(0xFF8B87A0);

  final LeaveService _leaveService =
      LeaveService();

  List<LeaveRequest> _leaves = [];
  List<LeaveBalance> _balances = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadLeaves() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final leavesFuture = _leaveService.getEmployeeLeaves(
        employeeId: widget.user.employeeId,
      );
      final balancesFuture = _leaveService.getLeaveBalances(
        employeeId: widget.user.employeeId,
      );

      final results = await Future.wait([leavesFuture, balancesFuture]);

      if (!mounted) return;

      setState(() {
        _leaves = results[0] as List<LeaveRequest>;
        _balances = results[1] as List<LeaveBalance>;
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
  // APPLY
  // ============================================================

  Future<void> _openApplyLeave() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplyLeavePage(
          user: widget.user,
        ),
      ),
    );

    if (result == true) {
      await _loadLeaves();
    }
  }

  // ============================================================
  // HISTORY
  // ============================================================

  Future<void> _openHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeaveHistoryPage(
          user: widget.user,
        ),
      ),
    );

    await _loadLeaves();
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
          'Leave',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadLeaves,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: violet,
              ),
            )
          : _error != null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: _loadLeaves,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildContent() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        30,
      ),
      children: [
        _buildHeader(),

        const SizedBox(height: 20),

        if (_balances.isNotEmpty) ...[
          _buildBalanceSection(),
          const SizedBox(height: 20),
        ],

        _buildSummary(),

        const SizedBox(height: 25),

        _buildActions(),

        const SizedBox(height: 25),

        _buildRecentTitle(),

        const SizedBox(height: 12),

        if (_leaves.isEmpty)
          _emptyState()
        else
          ..._recentLeaves(),

        const SizedBox(height: 20),

        if (_leaves.isNotEmpty)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _openHistory,
              child: const Text(
                'View Full Leave History',
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B0B63),
            violet,
            brightViolet,
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
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'My Leave',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your leave requests',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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
  // LEAVE BALANCES
  // ============================================================

  Widget _buildBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Leave Quotas & Balances',
              style: TextStyle(
                color: textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF0E4FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Year ${DateTime.now().year}',
                style: const TextStyle(
                  color: violet,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 146,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _balances.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final b = _balances[index];
              final progress = b.allocatedDays > 0
                  ? ((b.allocatedDays - b.availableDays) / b.allocatedDays).clamp(0.0, 1.0)
                  : 0.0;

              return Container(
                width: 220,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFEEE8F3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            b.leaveTypeName,
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: b.isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            b.isPaid ? 'Paid' : 'Unpaid',
                            style: TextStyle(
                              color: b.isPaid ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          b.availableDays.toStringAsFixed(b.availableDays.truncateToDouble() == b.availableDays ? 0 : 1),
                          style: const TextStyle(
                            color: violet,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ ${b.allocatedDays.toStringAsFixed(b.allocatedDays.truncateToDouble() == b.allocatedDays ? 0 : 1)} days left',
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF0E8F8),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.85 ? Colors.redAccent : violet,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Used: ${b.usedDays.toStringAsFixed(b.usedDays.truncateToDouble() == b.usedDays ? 0 : 1)}',
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Pending: ${b.pendingDays.toStringAsFixed(b.pendingDays.truncateToDouble() == b.pendingDays ? 0 : 1)}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary() {
    final pending =
        _count('pending');

    final approved =
        _count('approved');

    final rejected =
        _count('rejected');

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'Pending',
            pending,
            Colors.orange,
            Icons.hourglass_top_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            'Approved',
            approved,
            Colors.green,
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            'Rejected',
            rejected,
            Colors.red,
            Icons.cancel_outlined,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
    String title,
    int value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              color: textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.add_rounded,
            title: 'Apply Leave',
            onTap: _openApplyLeave,
            filled: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            icon: Icons.history_rounded,
            title: 'History',
            onTap: _openHistory,
            filled: false,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return SizedBox(
      height: 52,
      child: filled
          ? FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(title),
              style: FilledButton.styleFrom(
                backgroundColor: violet,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(
                icon,
                color: violet,
              ),
              label: Text(
                title,
                style: const TextStyle(
                  color: violet,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: violet,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
    );
  }

  // ============================================================
  // RECENT
  // ============================================================

  Widget _buildRecentTitle() {
    return const Row(
      children: [
        Icon(
          Icons.history_rounded,
          color: violet,
          size: 20,
        ),
        SizedBox(width: 7),
        Text(
          'Recent Requests',
          style: TextStyle(
            color: textDark,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _recentLeaves() {
    final recent =
        _leaves.take(3).toList();

    return recent.map((leave) {
      return Padding(
        padding:
            const EdgeInsets.only(
          bottom: 10,
        ),
        child: _leaveCard(leave),
      );
    }).toList();
  }

  Widget _leaveCard(
    LeaveRequest leave,
  ) {
    final color =
        _statusColor(leave.status);

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                LeaveDetailsPage(
              leave: leave,
              user: widget.user,
            ),
          ),
        );

        _loadLeaves();
      },
      borderRadius:
          BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEEE8F3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event_note_outlined,
                color: color,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    leave.leaveType,
                    style: const TextStyle(
                      color: textDark,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(leave.fromDate)} - '
                    '${_formatDate(leave.toDate)}',
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${leave.totalDays} day(s)',
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            _statusBadge(
              leave.status,
              color,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEEE8F3),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            color: violet,
            size: 50,
          ),
          SizedBox(height: 12),
          Text(
            'No Leave Requests',
            style: TextStyle(
              color: textDark,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'You have not submitted a leave request yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _loadLeaves,
              child: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  int _count(String status) {
    return _leaves.where((leave) {
      return leave.status.toLowerCase() ==
          status;
    }).length;
  }

  Widget _statusBadge(
    String status,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
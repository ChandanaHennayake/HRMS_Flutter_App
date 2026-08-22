import 'package:flutter/material.dart';

import '../../models/leave_request.dart';
import '../../models/user.dart';
import '../../services/leave_service.dart';
import 'leave_details_page.dart';

class LeaveHistoryPage extends StatefulWidget {
  final User user;

  const LeaveHistoryPage({
    super.key,
    required this.user,
  });

  @override
  State<LeaveHistoryPage> createState() =>
      _LeaveHistoryPageState();
}

class _LeaveHistoryPageState
    extends State<LeaveHistoryPage> {
  final LeaveService _leaveService = LeaveService();

  List<LeaveRequest> _leaves = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result =
          await _leaveService.getEmployeeLeaves(
        employeeId: widget.user.employeeId,
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
            .replaceFirst('Exception: ', '');
      });
    }
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

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;

      case 'rejected':
        return Icons.cancel;

      case 'cancelled':
        return Icons.remove_circle;

      default:
        return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F5FA),

      appBar: AppBar(
        title: const Text(
          'Leave History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF211B2E),
        elevation: 0,
      ),

      body: RefreshIndicator(
        onRefresh: _loadLeaves,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7C2FCE),
        ),
      );
    }

    if (_error != null) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 140),

          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 55,
          ),

          const SizedBox(height: 15),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 25,
            ),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: FilledButton(
              onPressed: _loadLeaves,
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFF7C2FCE),
              ),
              child:
                  const Text('Try Again'),
            ),
          ),
        ],
      );
    }

    if (_leaves.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 150),

          Icon(
            Icons.event_busy,
            size: 65,
            color: Colors.grey,
          ),

          SizedBox(height: 15),

          Center(
            child: Text(
              'No leave requests found.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _leaves.length,
      itemBuilder: (context, index) {
        final leave = _leaves[index];

        return _buildLeaveCard(leave);
      },
    );
  }

  Widget _buildLeaveCard(
    LeaveRequest leave,
  ) {
    final statusColor =
        _statusColor(leave.status);

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),

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

          await _loadLeaves();
        },

        child: Padding(
          padding:
              const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      leave.leaveType,
                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  _statusBadge(
                    leave.status,
                    statusColor,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(
                    Icons
                        .calendar_today_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    '${_formatDate(leave.fromDate)}'
                    ' - '
                    '${_formatDate(leave.toDate)}',
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.timelapse,
                    size: 18,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    '${leave.totalDays} day(s)',
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                leave.reason,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      color:
                          Theme.of(context)
                              .primaryColor,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 5),

                  Icon(
                    Icons
                        .arrow_forward_ios,
                    size: 13,
                    color:
                        Theme.of(context)
                            .primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
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
        color:
            color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(status),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
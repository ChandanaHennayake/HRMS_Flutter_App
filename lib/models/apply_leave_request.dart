class ApplyLeaveRequest {
  final int leaveTypeId;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;

  ApplyLeaveRequest({
    required this.leaveTypeId,
    required this.fromDate,
    required this.toDate,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'leaveTypeId': leaveTypeId,
      'fromDate': _formatDate(fromDate),
      'toDate': _formatDate(toDate),
      'reason': reason,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
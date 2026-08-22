class LeaveRequest {
  final int id;
  final int employeeId;
  final String employeeName;
  final int leaveTypeId;
  final String leaveType;
  final DateTime fromDate;
  final DateTime toDate;
  final double totalDays;
  final String reason;
  final String status;
  final String? remarks;
  final DateTime appliedDate;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.leaveTypeId,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    this.remarks,
    required this.appliedDate,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: (json['id'] as num).toInt(),

      employeeId:
          (json['employeeId'] as num).toInt(),

      employeeName:
          json['employeeName']?.toString() ?? '',

      leaveTypeId:
          (json['leaveTypeId'] as num).toInt(),

      leaveType:
          json['leaveType']?.toString() ?? '',

      fromDate:
          DateTime.parse(
            json['fromDate'].toString(),
          ),

      toDate:
          DateTime.parse(
            json['toDate'].toString(),
          ),

      totalDays:
          (json['totalDays'] as num).toDouble(),

      reason:
          json['reason']?.toString() ?? '',

      // API returns statusName, not status as String
      status:
          json['statusName']?.toString() ?? 'Pending',

      // API returns managerComment
      remarks:
          json['managerComment']?.toString(),

      // API returns appliedAt
      appliedDate:
          DateTime.parse(
            json['appliedAt'].toString(),
          ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'leaveTypeId': leaveTypeId,
      'leaveType': leaveType,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'totalDays': totalDays,
      'reason': reason,
      'status': status,
      'remarks': remarks,
      'appliedDate': appliedDate.toIso8601String(),
    };
  }
}
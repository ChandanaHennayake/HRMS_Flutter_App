class AttendanceCorrection {
  final int id;
  final int? attendanceId;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final int branchId;
  final String branchName;
  final String attendanceDate;
  final DateTime? originalCheckInTime;
  final DateTime? originalCheckOutTime;
  final DateTime? requestedCheckInTime;
  final DateTime? requestedCheckOutTime;
  final String reason;
  final int status; // 0 = Pending, 1 = Approved, 2 = Rejected, 3 = Cancelled
  final String statusName;
  final int? reviewedBy;
  final String? reviewedByName;
  final DateTime? reviewedAt;
  final String? reviewerComment;
  final DateTime createdAt;

  const AttendanceCorrection({
    required this.id,
    this.attendanceId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.branchId,
    required this.branchName,
    required this.attendanceDate,
    this.originalCheckInTime,
    this.originalCheckOutTime,
    this.requestedCheckInTime,
    this.requestedCheckOutTime,
    required this.reason,
    required this.status,
    required this.statusName,
    this.reviewedBy,
    this.reviewedByName,
    this.reviewedAt,
    this.reviewerComment,
    required this.createdAt,
  });

  factory AttendanceCorrection.fromJson(Map<String, dynamic> json) {
    return AttendanceCorrection(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      attendanceId: json['attendanceId'] as int?,
      employeeId: json['employeeId'] is int
          ? json['employeeId'] as int
          : int.parse(json['employeeId'].toString()),
      employeeName: json['employeeName'] as String? ?? '',
      employeeCode: json['employeeCode'] as String? ?? '',
      branchId: json['branchId'] is int
          ? json['branchId'] as int
          : int.tryParse(json['branchId']?.toString() ?? '0') ?? 0,
      branchName: json['branchName'] as String? ?? '',
      attendanceDate: json['attendanceDate'] as String? ?? '',
      originalCheckInTime: json['originalCheckInTime'] != null
          ? DateTime.tryParse(json['originalCheckInTime'].toString())
          : null,
      originalCheckOutTime: json['originalCheckOutTime'] != null
          ? DateTime.tryParse(json['originalCheckOutTime'].toString())
          : null,
      requestedCheckInTime: json['requestedCheckInTime'] != null
          ? DateTime.tryParse(json['requestedCheckInTime'].toString())
          : null,
      requestedCheckOutTime: json['requestedCheckOutTime'] != null
          ? DateTime.tryParse(json['requestedCheckOutTime'].toString())
          : null,
      reason: json['reason'] as String? ?? '',
      status: json['status'] is int
          ? json['status'] as int
          : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      statusName: json['statusName'] as String? ?? 'Pending',
      reviewedBy: json['reviewedBy'] as int?,
      reviewedByName: json['reviewedByName'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,
      reviewerComment: json['reviewerComment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class BranchDailyAttendance {
  final int employeeId;
  final String employeeCode;
  final String fullName;
  final String? departmentName;
  final String? designationName;
  final int branchId;
  final String? branchName;
  final String attendanceDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int workedMinutes;
  final int status;
  final String statusName;
  final bool isLate;
  final int lateMinutes;
  final bool isEarlyDeparture;
  final int earlyDepartureMinutes;

  BranchDailyAttendance({
    required this.employeeId,
    required this.employeeCode,
    required this.fullName,
    this.departmentName,
    this.designationName,
    required this.branchId,
    this.branchName,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    required this.workedMinutes,
    required this.status,
    required this.statusName,
    required this.isLate,
    required this.lateMinutes,
    required this.isEarlyDeparture,
    required this.earlyDepartureMinutes,
  });

  factory BranchDailyAttendance.fromJson(Map<String, dynamic> json) {
    return BranchDailyAttendance(
      employeeId: json['employeeId'] ?? 0,
      employeeCode: json['employeeCode'] ?? '',
      fullName: json['fullName'] ?? '',
      departmentName: json['departmentName'],
      designationName: json['designationName'],
      branchId: json['branchId'] ?? 0,
      branchName: json['branchName'],
      attendanceDate: json['attendanceDate'] ?? '',
      checkInTime: json['checkInTime'] != null
          ? DateTime.tryParse(json['checkInTime'])
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.tryParse(json['checkOutTime'])
          : null,
      workedMinutes: json['workedMinutes'] ?? 0,
      status: json['status'] ?? 0,
      statusName: json['statusName'] ?? 'Absent',
      isLate: json['isLate'] ?? false,
      lateMinutes: json['lateMinutes'] ?? 0,
      isEarlyDeparture: json['isEarlyDeparture'] ?? false,
      earlyDepartureMinutes: json['earlyDepartureMinutes'] ?? 0,
    );
  }
}

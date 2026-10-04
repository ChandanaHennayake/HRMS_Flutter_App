class AttendanceModel {
  final int id;
  final int employeeId;
  final String attendanceDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double? checkInDistanceMeters;
  final double? checkOutDistanceMeters;
  final int workedMinutes;
  final bool isLate;
  final int lateMinutes;
  final bool isEarlyDeparture;
  final int earlyDepartureMinutes;
  final int otMinutes;
  final int status;

  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInDistanceMeters,
    this.checkOutDistanceMeters,
    required this.workedMinutes,
    required this.isLate,
    required this.lateMinutes,
    required this.isEarlyDeparture,
    required this.earlyDepartureMinutes,
    required this.otMinutes,
    required this.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? 0,
      employeeId: json['employeeId'] ?? 0,
      attendanceDate: json['attendanceDate']?.toString() ?? '',
      checkInTime: json['checkInTime'] != null
          ? DateTime.tryParse(json['checkInTime'].toString())
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.tryParse(json['checkOutTime'].toString())
          : null,
      checkInDistanceMeters: (json['checkInDistanceMeters'] as num?)?.toDouble(),
      checkOutDistanceMeters:
          (json['checkOutDistanceMeters'] as num?)?.toDouble(),
      workedMinutes: json['workedMinutes'] ?? 0,
      isLate: json['isLate'] ?? false,
      lateMinutes: json['lateMinutes'] ?? 0,
      isEarlyDeparture: json['isEarlyDeparture'] ?? false,
      earlyDepartureMinutes: json['earlyDepartureMinutes'] ?? 0,
      otMinutes: json['otMinutes'] ?? 0,
      status: json['status'] ?? 0,
    );
  }
}

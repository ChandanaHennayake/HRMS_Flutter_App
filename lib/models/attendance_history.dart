class AttendanceHistoryModel {
  final int id;
  final int employeeId;
  final DateTime attendanceDate;

  final DateTime? checkInTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkInDistanceMeters;

  final DateTime? checkOutTime;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final double? checkOutDistanceMeters;

  final int workedMinutes;

  final bool isLate;
  final int lateMinutes;

  final bool isEarlyDeparture;
  final int earlyDepartureMinutes;

  final int otMinutes;

  final int status;

  AttendanceHistoryModel({
    required this.id,
    required this.employeeId,
    required this.attendanceDate,
    this.checkInTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInDistanceMeters,
    this.checkOutTime,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutDistanceMeters,
    required this.workedMinutes,
    required this.isLate,
    required this.lateMinutes,
    required this.isEarlyDeparture,
    required this.earlyDepartureMinutes,
    required this.otMinutes,
    required this.status,
  });

  factory AttendanceHistoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AttendanceHistoryModel(
      id: _toInt(json['id']),

      employeeId:
          _toInt(json['employeeId']),

      attendanceDate:
          _parseDate(
        json['attendanceDate'],
      ),

      checkInTime:
          _parseNullableDate(
        json['checkInTime'],
      ),

      checkInLatitude:
          _toDouble(
        json['checkInLatitude'],
      ),

      checkInLongitude:
          _toDouble(
        json['checkInLongitude'],
      ),

      checkInDistanceMeters:
          _toDouble(
        json['checkInDistanceMeters'],
      ),

      checkOutTime:
          _parseNullableDate(
        json['checkOutTime'],
      ),

      checkOutLatitude:
          _toDouble(
        json['checkOutLatitude'],
      ),

      checkOutLongitude:
          _toDouble(
        json['checkOutLongitude'],
      ),

      checkOutDistanceMeters:
          _toDouble(
        json['checkOutDistanceMeters'],
      ),

      workedMinutes:
          _toInt(
        json['workedMinutes'],
      ),

      isLate:
          json['isLate'] == true,

      lateMinutes:
          _toInt(
        json['lateMinutes'],
      ),

      isEarlyDeparture:
          json['isEarlyDeparture'] == true,

      earlyDepartureMinutes:
          _toInt(
        json['earlyDepartureMinutes'],
      ),

      otMinutes:
          _toInt(
        json['otMinutes'],
      ),

      status:
          _toInt(
        json['status'],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static double? _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static DateTime _parseDate(
    dynamic value,
  ) {
    if (value == null) {
      return DateTime.now();
    }

    return DateTime.parse(
      value.toString(),
    );
  }

  static DateTime? _parseNullableDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final text =
        value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(
      text,
    );
  }
}
class LeaveBalance {
  final int leaveTypeId;
  final String leaveTypeName;
  final String leaveTypeCode;
  final bool isPaid;
  final int year;
  final double allocatedDays;
  final double usedDays;
  final double pendingDays;
  final double availableDays;

  LeaveBalance({
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.leaveTypeCode,
    required this.isPaid,
    required this.year,
    required this.allocatedDays,
    required this.usedDays,
    required this.pendingDays,
    required this.availableDays,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      leaveTypeId: json['leaveTypeId'] ?? 0,
      leaveTypeName: json['leaveTypeName'] ?? '',
      leaveTypeCode: json['leaveTypeCode'] ?? '',
      isPaid: json['isPaid'] ?? true,
      year: json['year'] ?? DateTime.now().year,
      allocatedDays: (json['allocatedDays'] as num?)?.toDouble() ?? 0.0,
      usedDays: (json['usedDays'] as num?)?.toDouble() ?? 0.0,
      pendingDays: (json['pendingDays'] as num?)?.toDouble() ?? 0.0,
      availableDays: (json['availableDays'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaveTypeId': leaveTypeId,
      'leaveTypeName': leaveTypeName,
      'leaveTypeCode': leaveTypeCode,
      'isPaid': isPaid,
      'year': year,
      'allocatedDays': allocatedDays,
      'usedDays': usedDays,
      'pendingDays': pendingDays,
      'availableDays': availableDays,
    };
  }
}

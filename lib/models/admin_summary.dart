class AdminSummary {
  final int totalEmployees;
  final int presentToday;
  final int onLeaveToday;
  final int absentToday;
  final int pendingLeaves;
  final int pendingCorrections;
  final int lateEmployees;
  final int missingCheckOut;
  final double presentPercentage;
  final double latePercentage;
  final double leavePercentage;
  final double absentPercentage;

  const AdminSummary({
    required this.totalEmployees,
    required this.presentToday,
    required this.onLeaveToday,
    required this.absentToday,
    required this.pendingLeaves,
    this.pendingCorrections = 0,
    required this.lateEmployees,
    required this.missingCheckOut,
    required this.presentPercentage,
    required this.latePercentage,
    required this.leavePercentage,
    required this.absentPercentage,
  });

  factory AdminSummary.fromJson(Map<String, dynamic> json) {
    return AdminSummary(
      totalEmployees: json['totalEmployees'] is num ? (json['totalEmployees'] as num).toInt() : 0,
      presentToday: json['presentToday'] is num ? (json['presentToday'] as num).toInt() : 0,
      onLeaveToday: json['onLeaveToday'] is num ? (json['onLeaveToday'] as num).toInt() : 0,
      absentToday: json['absentToday'] is num ? (json['absentToday'] as num).toInt() : 0,
      pendingLeaves: json['pendingLeaves'] is num ? (json['pendingLeaves'] as num).toInt() : 0,
      pendingCorrections: json['pendingCorrections'] is num ? (json['pendingCorrections'] as num).toInt() : 0,
      lateEmployees: json['lateEmployees'] is num ? (json['lateEmployees'] as num).toInt() : 0,
      missingCheckOut: json['missingCheckOut'] is num ? (json['missingCheckOut'] as num).toInt() : 0,
      presentPercentage: json['presentPercentage'] is num ? (json['presentPercentage'] as num).toDouble() : 0.0,
      latePercentage: json['latePercentage'] is num ? (json['latePercentage'] as num).toDouble() : 0.0,
      leavePercentage: json['leavePercentage'] is num ? (json['leavePercentage'] as num).toDouble() : 0.0,
      absentPercentage: json['absentPercentage'] is num ? (json['absentPercentage'] as num).toDouble() : 0.0,
    );
  }

  static const AdminSummary empty = AdminSummary(
    totalEmployees: 0,
    presentToday: 0,
    onLeaveToday: 0,
    absentToday: 0,
    pendingLeaves: 0,
    pendingCorrections: 0,
    lateEmployees: 0,
    missingCheckOut: 0,
    presentPercentage: 0.0,
    latePercentage: 0.0,
    leavePercentage: 0.0,
    absentPercentage: 0.0,
  );
}

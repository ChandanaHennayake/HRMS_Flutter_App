class EmployeeOnLeave {
  final int employeeId;
  final String name;
  final String leaveType;
  final String duration;
  final String fromDate;
  final String toDate;

  const EmployeeOnLeave({
    required this.employeeId,
    required this.name,
    required this.leaveType,
    required this.duration,
    required this.fromDate,
    required this.toDate,
  });

  factory EmployeeOnLeave.fromJson(Map<String, dynamic> json) {
    return EmployeeOnLeave(
      employeeId: json['employeeId'] is num ? (json['employeeId'] as num).toInt() : 0,
      name: json['name'] as String? ?? '',
      leaveType: json['leaveType'] as String? ?? 'Leave',
      duration: json['duration'] as String? ?? 'Full Day',
      fromDate: json['fromDate'] as String? ?? '',
      toDate: json['toDate'] as String? ?? '',
    );
  }
}

class WeeklyAttendanceDay {
  final String dayName;
  final String date;
  final double percentage;
  final int presentCount;
  final int totalCount;

  const WeeklyAttendanceDay({
    required this.dayName,
    required this.date,
    required this.percentage,
    required this.presentCount,
    required this.totalCount,
  });

  factory WeeklyAttendanceDay.fromJson(Map<String, dynamic> json) {
    return WeeklyAttendanceDay(
      dayName: json['dayName'] as String? ?? '',
      date: json['date'] as String? ?? '',
      percentage: json['percentage'] is num ? (json['percentage'] as num).toDouble() : 0.0,
      presentCount: json['presentCount'] is num ? (json['presentCount'] as num).toInt() : 0,
      totalCount: json['totalCount'] is num ? (json['totalCount'] as num).toInt() : 0,
    );
  }
}

class ManagerSummary {
  final int branchId;
  final String branchName;
  final int teamTotal;
  final int presentToday;
  final int onLeaveToday;
  final int absentToday;
  final int pendingLeaves;
  final int pendingCorrections;
  final List<EmployeeOnLeave> todayLeave;
  final List<WeeklyAttendanceDay> weeklyAttendance;

  const ManagerSummary({
    required this.branchId,
    required this.branchName,
    required this.teamTotal,
    required this.presentToday,
    required this.onLeaveToday,
    required this.absentToday,
    required this.pendingLeaves,
    this.pendingCorrections = 0,
    required this.todayLeave,
    required this.weeklyAttendance,
  });

  factory ManagerSummary.fromJson(Map<String, dynamic> json) {
    var rawLeave = json['todayLeave'];
    List<EmployeeOnLeave> leaveList = [];
    if (rawLeave is List) {
      leaveList = rawLeave
          .map((item) => EmployeeOnLeave.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    var rawWeekly = json['weeklyAttendance'];
    List<WeeklyAttendanceDay> weeklyList = [];
    if (rawWeekly is List) {
      weeklyList = rawWeekly
          .map((item) => WeeklyAttendanceDay.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ManagerSummary(
      branchId: json['branchId'] is num ? (json['branchId'] as num).toInt() : 0,
      branchName: json['branchName'] as String? ?? 'Branch',
      teamTotal: json['teamTotal'] is num ? (json['teamTotal'] as num).toInt() : 0,
      presentToday: json['presentToday'] is num ? (json['presentToday'] as num).toInt() : 0,
      onLeaveToday: json['onLeaveToday'] is num ? (json['onLeaveToday'] as num).toInt() : 0,
      absentToday: json['absentToday'] is num ? (json['absentToday'] as num).toInt() : 0,
      pendingLeaves: json['pendingLeaves'] is num ? (json['pendingLeaves'] as num).toInt() : 0,
      pendingCorrections: json['pendingCorrections'] is num ? (json['pendingCorrections'] as num).toInt() : 0,
      todayLeave: leaveList,
      weeklyAttendance: weeklyList,
    );
  }

  static const ManagerSummary empty = ManagerSummary(
    branchId: 0,
    branchName: 'Branch',
    teamTotal: 0,
    presentToday: 0,
    onLeaveToday: 0,
    absentToday: 0,
    pendingLeaves: 0,
    pendingCorrections: 0,
    todayLeave: [],
    weeklyAttendance: [],
  );
}

class AttendanceReportSummary {
  final int totalRecords;
  final int presentCount;
  final int lateCount;
  final int absentCount;
  final int earlyDepartureCount;
  final double totalWorkedHours;
  final double totalOvertimeHours;
  final double punctualityRate;

  AttendanceReportSummary({
    required this.totalRecords,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    required this.earlyDepartureCount,
    required this.totalWorkedHours,
    required this.totalOvertimeHours,
    required this.punctualityRate,
  });

  factory AttendanceReportSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceReportSummary(
      totalRecords: json['totalRecords'] as int? ?? 0,
      presentCount: json['presentCount'] as int? ?? 0,
      lateCount: json['lateCount'] as int? ?? 0,
      absentCount: json['absentCount'] as int? ?? 0,
      earlyDepartureCount: json['earlyDepartureCount'] as int? ?? 0,
      totalWorkedHours: (json['totalWorkedHours'] as num?)?.toDouble() ?? 0.0,
      totalOvertimeHours: (json['totalOvertimeHours'] as num?)?.toDouble() ?? 0.0,
      punctualityRate: (json['punctualityRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AttendanceReportItem {
  final DateTime? date;
  final int employeeId;
  final String employeeCode;
  final String employeeName;
  final String branchName;
  final String departmentName;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double workedHours;
  final bool isLate;
  final int lateMinutes;
  final int otMinutes;
  final String status;

  AttendanceReportItem({
    this.date,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.branchName,
    required this.departmentName,
    this.checkInTime,
    this.checkOutTime,
    required this.workedHours,
    required this.isLate,
    required this.lateMinutes,
    required this.otMinutes,
    required this.status,
  });

  factory AttendanceReportItem.fromJson(Map<String, dynamic> json) {
    return AttendanceReportItem(
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      employeeId: json['employeeId'] as int? ?? 0,
      employeeCode: json['employeeCode'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      departmentName: json['departmentName'] as String? ?? '',
      checkInTime: json['checkInTime'] != null ? DateTime.tryParse(json['checkInTime'].toString()) : null,
      checkOutTime: json['checkOutTime'] != null ? DateTime.tryParse(json['checkOutTime'].toString()) : null,
      workedHours: (json['workedHours'] as num?)?.toDouble() ?? 0.0,
      isLate: json['isLate'] as bool? ?? false,
      lateMinutes: json['lateMinutes'] as int? ?? 0,
      otMinutes: json['otMinutes'] as int? ?? 0,
      status: json['status'] as String? ?? 'Present',
    );
  }
}

class AttendanceReportResponse {
  final AttendanceReportSummary summary;
  final List<AttendanceReportItem> items;

  AttendanceReportResponse({
    required this.summary,
    required this.items,
  });

  factory AttendanceReportResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceReportResponse(
      summary: json['summary'] != null
          ? AttendanceReportSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : AttendanceReportSummary(
              totalRecords: 0,
              presentCount: 0,
              lateCount: 0,
              absentCount: 0,
              earlyDepartureCount: 0,
              totalWorkedHours: 0.0,
              totalOvertimeHours: 0.0,
              punctualityRate: 0.0,
            ),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => AttendanceReportItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LeaveReportSummary {
  final int totalRequests;
  final double approvedDays;
  final double pendingDays;
  final double rejectedDays;
  final double paidDays;
  final double unpaidDays;
  final Map<String, double> byTypeBreakdown;

  LeaveReportSummary({
    required this.totalRequests,
    required this.approvedDays,
    required this.pendingDays,
    required this.rejectedDays,
    required this.paidDays,
    required this.unpaidDays,
    required this.byTypeBreakdown,
  });

  factory LeaveReportSummary.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['byTypeBreakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = <String, double>{};
    rawBreakdown.forEach((key, value) {
      breakdown[key] = (value as num?)?.toDouble() ?? 0.0;
    });

    return LeaveReportSummary(
      totalRequests: json['totalRequests'] as int? ?? 0,
      approvedDays: (json['approvedDays'] as num?)?.toDouble() ?? 0.0,
      pendingDays: (json['pendingDays'] as num?)?.toDouble() ?? 0.0,
      rejectedDays: (json['rejectedDays'] as num?)?.toDouble() ?? 0.0,
      paidDays: (json['paidDays'] as num?)?.toDouble() ?? 0.0,
      unpaidDays: (json['unpaidDays'] as num?)?.toDouble() ?? 0.0,
      byTypeBreakdown: breakdown,
    );
  }
}

class LeaveReportItem {
  final int id;
  final int employeeId;
  final String employeeCode;
  final String employeeName;
  final String branchName;
  final String leaveTypeName;
  final DateTime? fromDate;
  final DateTime? toDate;
  final double totalDays;
  final bool isPaid;
  final String status;
  final DateTime? approvedAt;

  LeaveReportItem({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.branchName,
    required this.leaveTypeName,
    this.fromDate,
    this.toDate,
    required this.totalDays,
    required this.isPaid,
    required this.status,
    this.approvedAt,
  });

  factory LeaveReportItem.fromJson(Map<String, dynamic> json) {
    return LeaveReportItem(
      id: json['id'] as int? ?? 0,
      employeeId: json['employeeId'] as int? ?? 0,
      employeeCode: json['employeeCode'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      leaveTypeName: json['leaveTypeName'] as String? ?? '',
      fromDate: json['fromDate'] != null ? DateTime.tryParse(json['fromDate'].toString()) : null,
      toDate: json['toDate'] != null ? DateTime.tryParse(json['toDate'].toString()) : null,
      totalDays: (json['totalDays'] as num?)?.toDouble() ?? 0.0,
      isPaid: json['isPaid'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      approvedAt: json['approvedAt'] != null ? DateTime.tryParse(json['approvedAt'].toString()) : null,
    );
  }
}

class LeaveReportResponse {
  final LeaveReportSummary summary;
  final List<LeaveReportItem> items;

  LeaveReportResponse({
    required this.summary,
    required this.items,
  });

  factory LeaveReportResponse.fromJson(Map<String, dynamic> json) {
    return LeaveReportResponse(
      summary: json['summary'] != null
          ? LeaveReportSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : LeaveReportSummary(
              totalRequests: 0,
              approvedDays: 0.0,
              pendingDays: 0.0,
              rejectedDays: 0.0,
              paidDays: 0.0,
              unpaidDays: 0.0,
              byTypeBreakdown: {},
            ),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => LeaveReportItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PayrollReportSummary {
  final String periodName;
  final int employeeCount;
  final double totalBasicSalary;
  final double totalGrossSalary;
  final double totalDeductions;
  final double totalNetSalary;
  final double totalEPFEmployer;
  final double totalETFEmployer;
  final double totalCompanyCost;

  PayrollReportSummary({
    required this.periodName,
    required this.employeeCount,
    required this.totalBasicSalary,
    required this.totalGrossSalary,
    required this.totalDeductions,
    required this.totalNetSalary,
    required this.totalEPFEmployer,
    required this.totalETFEmployer,
    required this.totalCompanyCost,
  });

  factory PayrollReportSummary.fromJson(Map<String, dynamic> json) {
    return PayrollReportSummary(
      periodName: json['periodName'] as String? ?? '',
      employeeCount: json['employeeCount'] as int? ?? 0,
      totalBasicSalary: (json['totalBasicSalary'] as num?)?.toDouble() ?? 0.0,
      totalGrossSalary: (json['totalGrossSalary'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['totalDeductions'] as num?)?.toDouble() ?? 0.0,
      totalNetSalary: (json['totalNetSalary'] as num?)?.toDouble() ?? 0.0,
      totalEPFEmployer: (json['totalEPFEmployer'] as num?)?.toDouble() ?? 0.0,
      totalETFEmployer: (json['totalETFEmployer'] as num?)?.toDouble() ?? 0.0,
      totalCompanyCost: (json['totalCompanyCost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PayrollReportItem {
  final int payslipId;
  final String employeeCode;
  final String employeeName;
  final String branchName;
  final String departmentName;
  final double baseSalary;
  final double grossEarnings;
  final double totalDeductions;
  final double netSalary;
  final String paymentStatus;

  PayrollReportItem({
    required this.payslipId,
    required this.employeeCode,
    required this.employeeName,
    required this.branchName,
    required this.departmentName,
    required this.baseSalary,
    required this.grossEarnings,
    required this.totalDeductions,
    required this.netSalary,
    required this.paymentStatus,
  });

  factory PayrollReportItem.fromJson(Map<String, dynamic> json) {
    return PayrollReportItem(
      payslipId: json['payslipId'] as int? ?? 0,
      employeeCode: json['employeeCode'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      departmentName: json['departmentName'] as String? ?? '',
      baseSalary: (json['baseSalary'] as num?)?.toDouble() ?? 0.0,
      grossEarnings: (json['grossEarnings'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['totalDeductions'] as num?)?.toDouble() ?? 0.0,
      netSalary: (json['netSalary'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] as String? ?? 'Paid',
    );
  }
}

class PayrollReportResponse {
  final PayrollReportSummary summary;
  final List<PayrollReportItem> items;

  PayrollReportResponse({
    required this.summary,
    required this.items,
  });

  factory PayrollReportResponse.fromJson(Map<String, dynamic> json) {
    return PayrollReportResponse(
      summary: json['summary'] != null
          ? PayrollReportSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : PayrollReportSummary(
              periodName: '',
              employeeCount: 0,
              totalBasicSalary: 0.0,
              totalGrossSalary: 0.0,
              totalDeductions: 0.0,
              totalNetSalary: 0.0,
              totalEPFEmployer: 0.0,
              totalETFEmployer: 0.0,
              totalCompanyCost: 0.0,
            ),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => PayrollReportItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DistributionItem {
  final String name;
  final int count;
  final double percentage;

  DistributionItem({
    required this.name,
    required this.count,
    required this.percentage,
  });

  factory DistributionItem.fromJson(Map<String, dynamic> json) {
    return DistributionItem(
      name: json['name'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class HeadcountReport {
  final int totalEmployees;
  final int activeEmployees;
  final int inactiveEmployees;
  final List<DistributionItem> branchDistribution;
  final List<DistributionItem> departmentDistribution;
  final List<DistributionItem> designationDistribution;
  final List<DistributionItem> employmentTypeDistribution;

  HeadcountReport({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.inactiveEmployees,
    required this.branchDistribution,
    required this.departmentDistribution,
    required this.designationDistribution,
    required this.employmentTypeDistribution,
  });

  factory HeadcountReport.fromJson(Map<String, dynamic> json) {
    return HeadcountReport(
      totalEmployees: json['totalEmployees'] as int? ?? 0,
      activeEmployees: json['activeEmployees'] as int? ?? 0,
      inactiveEmployees: json['inactiveEmployees'] as int? ?? 0,
      branchDistribution: (json['branchDistribution'] as List<dynamic>? ?? [])
          .map((e) => DistributionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      departmentDistribution: (json['departmentDistribution'] as List<dynamic>? ?? [])
          .map((e) => DistributionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      designationDistribution: (json['designationDistribution'] as List<dynamic>? ?? [])
          .map((e) => DistributionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      employmentTypeDistribution: (json['employmentTypeDistribution'] as List<dynamic>? ?? [])
          .map((e) => DistributionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

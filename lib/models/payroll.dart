class PayrollPeriod {
  final int id;
  final int companyId;
  final int year;
  final int month;
  final String name;
  final String startDate;
  final String endDate;
  final bool isClosed;

  PayrollPeriod({
    required this.id,
    required this.companyId,
    required this.year,
    required this.month,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isClosed,
  });

  factory PayrollPeriod.fromJson(Map<String, dynamic> json) {
    return PayrollPeriod(
      id: (json['id'] as num?)?.toInt() ?? 0,
      companyId: (json['companyId'] as num?)?.toInt() ?? 0,
      year: (json['year'] as num?)?.toInt() ?? 0,
      month: (json['month'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      isClosed: json['isClosed'] as bool? ?? false,
    );
  }
}

class PayrollRun {
  final int id;
  final int companyId;
  final int? branchId;
  final String? branchName;
  final int payrollPeriodId;
  final String periodName;
  final int status; // 0=Draft, 1=UnderReview, 2=Approved, 3=Published
  final String statusName;
  final double totalGross;
  final double totalNet;
  final double totalEmployerCost;
  final int processedCount;
  final int processedBy;
  final String processedAt;
  final int? approvedBy;
  final String? approvedAt;
  final String? comments;
  final List<PayslipSummary> payslips;

  PayrollRun({
    required this.id,
    required this.companyId,
    this.branchId,
    this.branchName,
    required this.payrollPeriodId,
    required this.periodName,
    required this.status,
    required this.statusName,
    required this.totalGross,
    required this.totalNet,
    required this.totalEmployerCost,
    required this.processedCount,
    required this.processedBy,
    required this.processedAt,
    this.approvedBy,
    this.approvedAt,
    this.comments,
    this.payslips = const [],
  });

  factory PayrollRun.fromJson(Map<String, dynamic> json) {
    var rawPayslips = json['payslips'] as List<dynamic>?;
    List<PayslipSummary> parsedPayslips = rawPayslips != null
        ? rawPayslips.map((p) => PayslipSummary.fromJson(p)).toList()
        : [];

    return PayrollRun(
      id: (json['id'] as num?)?.toInt() ?? 0,
      companyId: (json['companyId'] as num?)?.toInt() ?? 0,
      branchId: (json['branchId'] as num?)?.toInt(),
      branchName: json['branchName']?.toString(),
      payrollPeriodId: (json['payrollPeriodId'] as num?)?.toInt() ?? 0,
      periodName: json['periodName']?.toString() ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      statusName: json['statusName']?.toString() ?? 'Draft',
      totalGross: (json['totalGross'] as num?)?.toDouble() ?? 0.0,
      totalNet: (json['totalNet'] as num?)?.toDouble() ?? 0.0,
      totalEmployerCost: (json['totalEmployerCost'] as num?)?.toDouble() ?? 0.0,
      processedCount: (json['processedCount'] as num?)?.toInt() ?? 0,
      processedBy: (json['processedBy'] as num?)?.toInt() ?? 0,
      processedAt: json['processedAt']?.toString() ?? '',
      approvedBy: (json['approvedBy'] as num?)?.toInt(),
      approvedAt: json['approvedAt']?.toString(),
      comments: json['comments']?.toString(),
      payslips: parsedPayslips,
    );
  }
}

class PayslipSummary {
  final int id;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String? departmentName;
  final String? designationName;
  final double baseSalary;
  final double grossEarnings;
  final double totalDeductions;
  final double netSalary;
  final String paymentStatus;

  PayslipSummary({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    this.departmentName,
    this.designationName,
    required this.baseSalary,
    required this.grossEarnings,
    required this.totalDeductions,
    required this.netSalary,
    required this.paymentStatus,
  });

  factory PayslipSummary.fromJson(Map<String, dynamic> json) {
    return PayslipSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      employeeName: json['employeeName']?.toString() ?? '',
      employeeCode: json['employeeCode']?.toString() ?? '',
      departmentName: json['departmentName']?.toString(),
      designationName: json['designationName']?.toString(),
      baseSalary: (json['baseSalary'] as num?)?.toDouble() ?? 0.0,
      grossEarnings: (json['grossEarnings'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['totalDeductions'] as num?)?.toDouble() ?? 0.0,
      netSalary: (json['netSalary'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus']?.toString() ?? 'Unpaid',
    );
  }
}

class Payslip {
  final int id;
  final int payrollRunId;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String? departmentName;
  final String? designationName;
  final String? branchName;
  final String? bankName;
  final String? bankAccountNo;
  final String paymentMode;

  final int periodId;
  final String periodName;
  final String periodStartDate;
  final String periodEndDate;

  final double baseSalary;
  final double totalAllowances;
  final double overtimeHours;
  final double overtimePay;
  final double grossEarnings;

  final double noPayDays;
  final double noPayDeduction;
  final double grossEpfSalary;
  final double employeeEpf;
  final double employerEpf;
  final double employerEtf;
  final double apitTax;
  final double otherDeductions;
  final double totalDeductions;

  final double netSalary;
  final String paymentStatus;
  final String? paymentDate;

  final List<PayslipItem> earnings;
  final List<PayslipItem> deductions;

  Payslip({
    required this.id,
    required this.payrollRunId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    this.departmentName,
    this.designationName,
    this.branchName,
    this.bankName,
    this.bankAccountNo,
    required this.paymentMode,
    required this.periodId,
    required this.periodName,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.baseSalary,
    required this.totalAllowances,
    required this.overtimeHours,
    required this.overtimePay,
    required this.grossEarnings,
    required this.noPayDays,
    required this.noPayDeduction,
    required this.grossEpfSalary,
    required this.employeeEpf,
    required this.employerEpf,
    required this.employerEtf,
    required this.apitTax,
    required this.otherDeductions,
    required this.totalDeductions,
    required this.netSalary,
    required this.paymentStatus,
    this.paymentDate,
    this.earnings = const [],
    this.deductions = const [],
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    var rawEarnings = json['earnings'] as List<dynamic>?;
    List<PayslipItem> parsedEarnings = rawEarnings != null
        ? rawEarnings.map((e) => PayslipItem.fromJson(e)).toList()
        : [];

    var rawDeductions = json['deductions'] as List<dynamic>?;
    List<PayslipItem> parsedDeductions = rawDeductions != null
        ? rawDeductions.map((d) => PayslipItem.fromJson(d)).toList()
        : [];

    return Payslip(
      id: (json['id'] as num?)?.toInt() ?? 0,
      payrollRunId: (json['payrollRunId'] as num?)?.toInt() ?? 0,
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      employeeName: json['employeeName']?.toString() ?? '',
      employeeCode: json['employeeCode']?.toString() ?? '',
      departmentName: json['departmentName']?.toString(),
      designationName: json['designationName']?.toString(),
      branchName: json['branchName']?.toString(),
      bankName: json['bankName']?.toString(),
      bankAccountNo: json['bankAccountNo']?.toString(),
      paymentMode: json['paymentMode']?.toString() ?? 'Bank Transfer',
      periodId: (json['periodId'] as num?)?.toInt() ?? 0,
      periodName: json['periodName']?.toString() ?? '',
      periodStartDate: json['periodStartDate']?.toString() ?? '',
      periodEndDate: json['periodEndDate']?.toString() ?? '',
      baseSalary: (json['baseSalary'] as num?)?.toDouble() ?? 0.0,
      totalAllowances: (json['totalAllowances'] as num?)?.toDouble() ?? 0.0,
      overtimeHours: (json['overtimeHours'] as num?)?.toDouble() ?? 0.0,
      overtimePay: (json['overtimePay'] as num?)?.toDouble() ?? 0.0,
      grossEarnings: (json['grossEarnings'] as num?)?.toDouble() ?? 0.0,
      noPayDays: (json['noPayDays'] as num?)?.toDouble() ?? 0.0,
      noPayDeduction: (json['noPayDeduction'] as num?)?.toDouble() ?? 0.0,
      grossEpfSalary: (json['grossEpfSalary'] as num?)?.toDouble() ?? 0.0,
      employeeEpf: (json['employeeEpf'] as num?)?.toDouble() ?? 0.0,
      employerEpf: (json['employerEpf'] as num?)?.toDouble() ?? 0.0,
      employerEtf: (json['employerEtf'] as num?)?.toDouble() ?? 0.0,
      apitTax: (json['apitTax'] as num?)?.toDouble() ?? 0.0,
      otherDeductions: (json['otherDeductions'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['totalDeductions'] as num?)?.toDouble() ?? 0.0,
      netSalary: (json['netSalary'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus']?.toString() ?? 'Unpaid',
      paymentDate: json['paymentDate']?.toString(),
      earnings: parsedEarnings,
      deductions: parsedDeductions,
    );
  }
}

class PayslipItem {
  final int id;
  final String name;
  final String code;
  final int itemType; // 1 = Earning, 2 = Deduction
  final double amount;
  final bool isEpfApplicable;
  final bool isTaxable;

  PayslipItem({
    required this.id,
    required this.name,
    required this.code,
    required this.itemType,
    required this.amount,
    required this.isEpfApplicable,
    required this.isTaxable,
  });

  factory PayslipItem.fromJson(Map<String, dynamic> json) {
    return PayslipItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      itemType: (json['itemType'] as num?)?.toInt() ?? 1,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isEpfApplicable: json['isEpfApplicable'] as bool? ?? false,
      isTaxable: json['isTaxable'] as bool? ?? false,
    );
  }
}

class PayrollManualItem {
  String name;
  double amount;
  bool isEpfApplicable;

  PayrollManualItem({
    required this.name,
    required this.amount,
    this.isEpfApplicable = false,
  });

  factory PayrollManualItem.fromJson(Map<String, dynamic> json) {
    return PayrollManualItem(
      name: json['name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isEpfApplicable: json['isEpfApplicable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'isEpfApplicable': isEpfApplicable,
    };
  }
}

class EmployeePayrollPreview {
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String? departmentName;
  final String? designationName;
  final String? branchName;
  final String? bankName;
  final String? bankAccountNo;
  final double baseSalary;
  final String startDate;
  final String endDate;
  final int totalCalendarDays;
  final int workedDays;
  final int holidaysCount;
  final int sundaysCount;
  final double workingDaysDivisor;
  final double suggestedDailyRate;
  final double detectedAbsentDays;
  final double suggestedNoPayDeduction;
  final double otHours;
  final double hourlyOtRate;
  final double suggestedOtPay;
  final List<PayrollManualItem> standardAllowances;
  final List<PayrollManualItem> standardDeductions;

  EmployeePayrollPreview({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    this.departmentName,
    this.designationName,
    this.branchName,
    this.bankName,
    this.bankAccountNo,
    required this.baseSalary,
    this.startDate = '',
    this.endDate = '',
    this.totalCalendarDays = 0,
    this.workedDays = 0,
    this.holidaysCount = 0,
    this.sundaysCount = 0,
    required this.workingDaysDivisor,
    required this.suggestedDailyRate,
    required this.detectedAbsentDays,
    required this.suggestedNoPayDeduction,
    this.otHours = 0.0,
    this.hourlyOtRate = 0.0,
    this.suggestedOtPay = 0.0,
    this.standardAllowances = const [],
    this.standardDeductions = const [],
  });

  factory EmployeePayrollPreview.fromJson(Map<String, dynamic> json) {
    var rawAllowances = json['standardAllowances'] as List<dynamic>?;
    List<PayrollManualItem> parsedAllowances = rawAllowances != null
        ? rawAllowances.map((a) => PayrollManualItem.fromJson(a)).toList()
        : [];

    var rawDeductions = json['standardDeductions'] as List<dynamic>?;
    List<PayrollManualItem> parsedDeductions = rawDeductions != null
        ? rawDeductions.map((d) => PayrollManualItem.fromJson(d)).toList()
        : [];

    return EmployeePayrollPreview(
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      employeeName: json['employeeName']?.toString() ?? '',
      employeeCode: json['employeeCode']?.toString() ?? '',
      departmentName: json['departmentName']?.toString(),
      designationName: json['designationName']?.toString(),
      branchName: json['branchName']?.toString(),
      bankName: json['bankName']?.toString(),
      bankAccountNo: json['bankAccountNo']?.toString(),
      baseSalary: (json['baseSalary'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      totalCalendarDays: (json['totalCalendarDays'] as num?)?.toInt() ?? 0,
      workedDays: (json['workedDays'] as num?)?.toInt() ?? 0,
      holidaysCount: (json['holidaysCount'] as num?)?.toInt() ?? 0,
      sundaysCount: (json['sundaysCount'] as num?)?.toInt() ?? 0,
      workingDaysDivisor: (json['workingDaysDivisor'] as num?)?.toDouble() ?? 26.0,
      suggestedDailyRate: (json['suggestedDailyRate'] as num?)?.toDouble() ?? 0.0,
      detectedAbsentDays: (json['detectedAbsentDays'] as num?)?.toDouble() ?? 0.0,
      suggestedNoPayDeduction: (json['suggestedNoPayDeduction'] as num?)?.toDouble() ?? 0.0,
      otHours: (json['otHours'] as num?)?.toDouble() ?? 0.0,
      hourlyOtRate: (json['hourlyOtRate'] as num?)?.toDouble() ?? 0.0,
      suggestedOtPay: (json['suggestedOtPay'] as num?)?.toDouble() ?? 0.0,
      standardAllowances: parsedAllowances,
      standardDeductions: parsedDeductions,
    );
  }
}

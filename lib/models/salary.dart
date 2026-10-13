class SalaryCalculation {
  final double baseSalary;
  final double totalAllowances;
  final double overtimePay;
  final double grossEarnings;
  final double noPayDeduction;
  final double otherDeductions;
  final double grossEpfSalary;
  final double employeeEpf;
  final double employerEpf;
  final double employerEtf;
  final double apitTax;
  final double totalDeductions;
  final double netSalary;
  final double totalEmployerCost;

  SalaryCalculation({
    required this.baseSalary,
    required this.totalAllowances,
    required this.overtimePay,
    required this.grossEarnings,
    required this.noPayDeduction,
    required this.otherDeductions,
    required this.grossEpfSalary,
    required this.employeeEpf,
    required this.employerEpf,
    required this.employerEtf,
    required this.apitTax,
    required this.totalDeductions,
    required this.netSalary,
    required this.totalEmployerCost,
  });

  factory SalaryCalculation.fromJson(Map<String, dynamic> json) {
    return SalaryCalculation(
      baseSalary: (json['baseSalary'] as num?)?.toDouble() ?? 0.0,
      totalAllowances: (json['totalAllowances'] as num?)?.toDouble() ?? 0.0,
      overtimePay: (json['overtimePay'] as num?)?.toDouble() ?? 0.0,
      grossEarnings: (json['grossEarnings'] as num?)?.toDouble() ?? 0.0,
      noPayDeduction: (json['noPayDeduction'] as num?)?.toDouble() ?? 0.0,
      otherDeductions: (json['otherDeductions'] as num?)?.toDouble() ?? 0.0,
      grossEpfSalary: (json['grossEpfSalary'] as num?)?.toDouble() ?? 0.0,
      employeeEpf: (json['employeeEpf'] as num?)?.toDouble() ?? 0.0,
      employerEpf: (json['employerEpf'] as num?)?.toDouble() ?? 0.0,
      employerEtf: (json['employerEtf'] as num?)?.toDouble() ?? 0.0,
      apitTax: (json['apitTax'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['totalDeductions'] as num?)?.toDouble() ?? 0.0,
      netSalary: (json['netSalary'] as num?)?.toDouble() ?? 0.0,
      totalEmployerCost: (json['totalEmployerCost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SalaryItem {
  final String name;
  final String code;
  final double amount;
  final bool isEpfApplicable;
  final bool isTaxable;

  SalaryItem({
    required this.name,
    required this.code,
    required this.amount,
    required this.isEpfApplicable,
    required this.isTaxable,
  });

  factory SalaryItem.fromJson(Map<String, dynamic> json) {
    return SalaryItem(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isEpfApplicable: json['isEpfApplicable'] ?? false,
      isTaxable: json['isTaxable'] ?? true,
    );
  }
}

class EmployeeSalary {
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final int? salaryStructureId;
  final String? structureName;
  final double baseSalary;
  final String effectiveFrom;
  final String paymentMode;
  final String? bankName;
  final String? bankAccountNo;
  final List<SalaryItem> earnings;
  final List<SalaryItem> deductions;
  final SalaryCalculation? calculation;

  EmployeeSalary({
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    this.salaryStructureId,
    this.structureName,
    required this.baseSalary,
    required this.effectiveFrom,
    required this.paymentMode,
    this.bankName,
    this.bankAccountNo,
    required this.earnings,
    required this.deductions,
    this.calculation,
  });

  factory EmployeeSalary.fromJson(Map<String, dynamic> json) {
    return EmployeeSalary(
      employeeId: json['employeeId'] ?? 0,
      employeeName: json['employeeName'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      salaryStructureId: json['salaryStructureId'],
      structureName: json['structureName'],
      baseSalary: (json['baseSalary'] as num?)?.toDouble() ?? 0.0,
      effectiveFrom: json['effectiveFrom']?.toString() ?? '',
      paymentMode: json['paymentMode'] ?? 'Bank Transfer',
      bankName: json['bankName'],
      bankAccountNo: json['bankAccountNo'],
      earnings: (json['earnings'] as List<dynamic>?)
              ?.map((e) => SalaryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      deductions: (json['deductions'] as List<dynamic>?)
              ?.map((e) => SalaryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      calculation: json['calculation'] != null
          ? SalaryCalculation.fromJson(json['calculation'] as Map<String, dynamic>)
          : null,
    );
  }
}

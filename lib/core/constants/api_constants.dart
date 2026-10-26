class ApiConstants {
  static const String baseUrl = 'https://hrms-api-u0mt.onrender.com';

  // Application Version Configuration
  static const String appVersion = '1.0.3';
  static const String appVersionCheck = '/api/AppVersion/check';

  static const String login = '/api/Authentication/login';

    static const String checkIn =
      '/api/Attendance/check-in';

  static const String checkOut =
      '/api/Attendance/check-out';

  static const String attendanceHistory =
      '/api/Attendance/history';

  static const String todayAttendance =
      '/api/Attendance/today';

  static String branchDailyAttendance({int? branchId, String? date}) {
    final params = <String>[];
    if (branchId != null && branchId > 0) params.add('branchId=$branchId');
    if (date != null && date.isNotEmpty) params.add('date=$date');
    if (params.isEmpty) return '/api/Attendance/branch-daily';
    return '/api/Attendance/branch-daily?${params.join('&')}';
  }




static const String leaveTypes = '/api/LeaveType';

static const String applyLeave = '/api/Leave/apply';

static const String leaveEmployee = '/api/Leave/employee';

static const String pendingLeaves = '/api/Leave/pending';

static String approveLeave(int id) =>
    '/api/Leave/$id/approve';

static String rejectLeave(int id) =>
    '/api/Leave/$id/reject';

static String cancelLeave(int id) =>
    '/api/Leave/$id/cancel';

static String leaveBalances(int employeeId, {int? year}) {
  if (year != null) {
    return '/api/Leave/employee/$employeeId/balance?year=$year';
  }
  return '/api/Leave/employee/$employeeId/balance';
}

  // ============================================================
  // SALARY & PAYROLL
  // ============================================================

  static String employeeSalary(int employeeId) =>
      '/api/Salary/employee/$employeeId';

  static const String calculateSalary = '/api/Salary/calculate';

  static String salaryComponents({int companyId = 1}) =>
      '/api/Salary/components?companyId=$companyId';


      // ============================================================
  // EMPLOYEE
  // ============================================================

  static const String employees =
      '/api/Employee';

  // ============================================================
  // MASTER LOOKUPS
  // ============================================================

  static const String lookupDepartments = '/api/Lookup/departments';
  static const String lookupDesignations = '/api/Lookup/designations';
  static const String lookupEmploymentTypes = '/api/Lookup/employment-types';
  static const String lookupRoles = '/api/Lookup/roles';
  static const String lookupBranches = '/api/Lookup/branches';

  // ============================================================
  // DASHBOARD
  // ============================================================

  static const String adminDashboardSummary = '/api/Dashboard/admin-summary';
  static String managerDashboardSummary(int branchId) =>
      '/api/Dashboard/manager-summary?branchId=$branchId';

  // ============================================================
  // HOLIDAY
  // ============================================================

  static const String holidays = '/api/Holiday';
  static const String upcomingHoliday = '/api/Holiday/upcoming';

  // ============================================================
  // AUTH
  // ============================================================

  static const String refreshToken = '/api/Authentication/refresh-token';

  // ============================================================
  // BRANCH
  // ============================================================

  static const String branches = '/api/Branch';
  static String branchManagers(int branchId) => '/api/Branch/managers/$branchId';
  static String userBranches(int userId) => '/api/Branch/user-branches/$userId';
  static const String assignBranchManager = '/api/Branch/assign-manager';
  static String removeBranchManager(int userId, int branchId) =>
      '/api/Branch/remove-manager?userId=$userId&branchId=$branchId';

  // ============================================================
  // USER & PROFILE
  // ============================================================

  static String userProfile(int userId) => '/api/User/profile/$userId';
  static const String changePassword = '/api/User/change-password';

  // ============================================================
  // ATTENDANCE CORRECTION
  // ============================================================

  static String attendanceCorrectionRequest(int employeeId) =>
      '/api/AttendanceCorrection/request?employeeId=$employeeId';
  static String myAttendanceCorrections(int employeeId) =>
      '/api/AttendanceCorrection/my?employeeId=$employeeId';
  static String pendingAttendanceCorrections({int? branchId}) {
    if (branchId != null && branchId > 0) {
      return '/api/AttendanceCorrection/pending?branchId=$branchId';
    }
    return '/api/AttendanceCorrection/pending';
  }
  static String reviewAttendanceCorrection(int id, int reviewerId) =>
      '/api/AttendanceCorrection/$id/review?reviewerId=$reviewerId';
  static String cancelAttendanceCorrection(int id, int employeeId) =>
      '/api/AttendanceCorrection/$id/cancel?employeeId=$employeeId';

  // ============================================================
  // PAYROLL & PAYSLIPS
  // ============================================================

  static String payrollPeriods({int companyId = 1, int? year}) {
    if (year != null) {
      return '/api/Payroll/periods?companyId=$companyId&year=$year';
    }
    return '/api/Payroll/periods?companyId=$companyId';
  }

  static const String processPayroll = '/api/Payroll/process';

  static String payrollRuns({int companyId = 1, int? branchId}) {
    if (branchId != null && branchId > 0) {
      return '/api/Payroll/runs?companyId=$companyId&branchId=$branchId';
    }
    return '/api/Payroll/runs?companyId=$companyId';
  }

  static String payrollRunDetails(int id) => '/api/Payroll/run/$id';

  static String updatePayrollStatus(int id, {int reviewerId = 1}) =>
      '/api/Payroll/run/$id/status?reviewerId=$reviewerId';

  static String employeePayslips(int employeeId) =>
      '/api/Payroll/employee/$employeeId/payslips';

  static String payslipDetails(int id) => '/api/Payroll/payslip/$id';

  static String employeePayrollPreview(int employeeId, {int? year, int? month, String? startDate, String? endDate}) {
    final params = <String>[];
    if (year != null) params.add('year=$year');
    if (month != null) params.add('month=$month');
    if (startDate != null && startDate.isNotEmpty) params.add('startDate=$startDate');
    if (endDate != null && endDate.isNotEmpty) params.add('endDate=$endDate');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '/api/Payroll/employee/$employeeId/preview$query';
  }

  static const String individualPayroll = '/api/Payroll/individual';
  static String deletePayslip(int id) => '/api/Payroll/payslip/$id';

  // ============================================================
  // SYSTEM NOTICES / POSTERS
  // ============================================================

  static const String activeNotice = '/api/Notice/active';
  static const String notices = '/api/Notice';
  static String toggleNotice(int id) => '/api/Notice/$id/toggle';
  static String deleteNotice(int id) => '/api/Notice/$id';

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  static String myNotifications({int? userId, int limit = 50}) {
    if (userId != null && userId > 0) {
      return '/api/Notification/my?userId=$userId&limit=$limit';
    }
    return '/api/Notification/my?limit=$limit';
  }

  static String notificationSummary({int? userId}) {
    if (userId != null && userId > 0) {
      return '/api/Notification/summary?userId=$userId';
    }
    return '/api/Notification/summary';
  }

  static String markNotificationRead(int id) => '/api/Notification/$id/read';

  static String markAllNotificationsRead({int? userId}) {
    if (userId != null && userId > 0) {
      return '/api/Notification/read-all?userId=$userId';
    }
    return '/api/Notification/read-all';
  }

  // ============================================================
  // AUDIT LOGS
  // ============================================================

  static String auditLogs({
    int page = 1,
    int pageSize = 30,
    String? action,
    String? entityName,
    String? severity,
    String? search,
  }) {
    final query = <String>[];
    query.add('page=$page');
    query.add('pageSize=$pageSize');
    if (action != null && action.isNotEmpty && action != 'All') {
      query.add('action=${Uri.encodeComponent(action)}');
    }
    if (entityName != null && entityName.isNotEmpty && entityName != 'All') {
      query.add('entityName=${Uri.encodeComponent(entityName)}');
    }
    if (severity != null && severity.isNotEmpty && severity != 'All') {
      query.add('severity=${Uri.encodeComponent(severity)}');
    }
    if (search != null && search.trim().isNotEmpty) {
      query.add('search=${Uri.encodeComponent(search.trim())}');
    }
    return '/api/AuditLog?${query.join('&')}';
  }

  static const String auditStats = '/api/AuditLog/stats';
  static const String auditActions = '/api/AuditLog/actions';
  static const String auditEntities = '/api/AuditLog/entities';
  static String auditLogDetails(int id) => '/api/AuditLog/$id';

  // ============================================================
  // REPORTS & ANALYTICS
  // ============================================================

  static String attendanceReport({
    String? startDate,
    String? endDate,
    int? branchId,
    int? departmentId,
  }) {
    final query = <String>[];
    if (startDate != null) query.add('startDate=$startDate');
    if (endDate != null) query.add('endDate=$endDate');
    if (branchId != null && branchId > 0) query.add('branchId=$branchId');
    if (departmentId != null && departmentId > 0) query.add('departmentId=$departmentId');
    return query.isEmpty ? '/api/Report/attendance' : '/api/Report/attendance?${query.join('&')}';
  }

  static String exportAttendanceCsv({
    String? startDate,
    String? endDate,
    int? branchId,
    int? departmentId,
  }) {
    final query = <String>[];
    if (startDate != null) query.add('startDate=$startDate');
    if (endDate != null) query.add('endDate=$endDate');
    if (branchId != null && branchId > 0) query.add('branchId=$branchId');
    if (departmentId != null && departmentId > 0) query.add('departmentId=$departmentId');
    return query.isEmpty ? '/api/Report/attendance/export-csv' : '/api/Report/attendance/export-csv?${query.join('&')}';
  }

  static String leaveReport({
    String? startDate,
    String? endDate,
    int? branchId,
    int? departmentId,
    int? leaveTypeId,
    int? status,
  }) {
    final query = <String>[];
    if (startDate != null) query.add('startDate=$startDate');
    if (endDate != null) query.add('endDate=$endDate');
    if (branchId != null && branchId > 0) query.add('branchId=$branchId');
    if (departmentId != null && departmentId > 0) query.add('departmentId=$departmentId');
    if (leaveTypeId != null && leaveTypeId > 0) query.add('leaveTypeId=$leaveTypeId');
    if (status != null) query.add('status=$status');
    return query.isEmpty ? '/api/Report/leave' : '/api/Report/leave?${query.join('&')}';
  }

  static String exportLeaveCsv({
    String? startDate,
    String? endDate,
    int? branchId,
    int? departmentId,
  }) {
    final query = <String>[];
    if (startDate != null) query.add('startDate=$startDate');
    if (endDate != null) query.add('endDate=$endDate');
    if (branchId != null && branchId > 0) query.add('branchId=$branchId');
    if (departmentId != null && departmentId > 0) query.add('departmentId=$departmentId');
    return query.isEmpty ? '/api/Report/leave/export-csv' : '/api/Report/leave/export-csv?${query.join('&')}';
  }

  static String payrollReport({
    int? periodId,
    int companyId = 1,
    int? branchId,
    int? year,
    int? month,
  }) {
    final query = <String>[];
    if (periodId != null && periodId > 0) query.add('periodId=$periodId');
    query.add('companyId=$companyId');
    if (branchId != null && branchId > 0) query.add('branchId=$branchId');
    if (year != null && year > 0) query.add('year=$year');
    if (month != null && month > 0) query.add('month=$month');
    return '/api/Report/payroll?${query.join('&')}';
  }

  static String exportPayrollCsv({
    int? periodId,
    int companyId = 1,
    int? branchId,
    int? year,
    int? month,
  }) {
    final query = <String>[];
    if (periodId != null && periodId > 0) query.add('periodId=$periodId');
    query.add('companyId=$companyId');
    if (branchId != null && branchId > 0) query.add('branchId=$branchId');
    if (year != null && year > 0) query.add('year=$year');
    if (month != null && month > 0) query.add('month=$month');
    return '/api/Report/payroll/export-csv?${query.join('&')}';
  }

  static String headcountReport({int? branchId}) {
    if (branchId != null && branchId > 0) {
      return '/api/Report/headcount?branchId=$branchId';
    }
    return '/api/Report/headcount';
  }

  // ============================================================
  // PROFILE CHANGE REQUESTS
  // ============================================================

  static const String profileChange = '/api/ProfileChange';
  static String myProfileChanges(int employeeId) => '/api/ProfileChange/my?employeeId=$employeeId';
  static String profileChangeById(int id) => '/api/ProfileChange/$id';
  static String approveProfileChange(int id) => '/api/ProfileChange/$id/approve';
  static String rejectProfileChange(int id) => '/api/ProfileChange/$id/reject';
  static String cancelProfileChange(int id) => '/api/ProfileChange/$id/cancel';

  // ============================================================
  // SYSTEM HEALTH
  // ============================================================

  static const String healthCheck = '/health';
}
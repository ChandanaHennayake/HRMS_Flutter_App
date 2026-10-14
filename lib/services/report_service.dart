import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/report.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient();

  /// Attendance summary and records
  Future<AttendanceReportResponse> getAttendanceReport({
    String? startDate,
    String? endDate,
    int? branchId,
    int? departmentId,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.attendanceReport(
        startDate: startDate,
        endDate: endDate,
        branchId: branchId,
        departmentId: departmentId,
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return AttendanceReportResponse.fromJson(json['data'] as Map<String, dynamic>);
    }

    throw Exception(_extractError(response.body, 'Failed to load attendance report.'));
  }

  /// Leave summary and itemized records
  Future<LeaveReportResponse> getLeaveReport({
    String? startDate,
    String? endDate,
    int? branchId,
    int? departmentId,
    int? leaveTypeId,
    int? status,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.leaveReport(
        startDate: startDate,
        endDate: endDate,
        branchId: branchId,
        departmentId: departmentId,
        leaveTypeId: leaveTypeId,
        status: status,
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return LeaveReportResponse.fromJson(json['data'] as Map<String, dynamic>);
    }

    throw Exception(_extractError(response.body, 'Failed to load leave report.'));
  }

  /// Payroll summary and itemized payslip breakdown
  Future<PayrollReportResponse> getPayrollReport({
    int? periodId,
    int companyId = 1,
    int? branchId,
    int? year,
    int? month,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.payrollReport(
        periodId: periodId,
        companyId: companyId,
        branchId: branchId,
        year: year,
        month: month,
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return PayrollReportResponse.fromJson(json['data'] as Map<String, dynamic>);
    }

    throw Exception(_extractError(response.body, 'Failed to load payroll report.'));
  }

  /// Headcount and workforce distribution breakdown
  Future<HeadcountReport> getHeadcountReport({int? branchId}) async {
    final response = await _apiClient.get(
      ApiConstants.headcountReport(branchId: branchId),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return HeadcountReport.fromJson(json['data'] as Map<String, dynamic>);
    }

    throw Exception(_extractError(response.body, 'Failed to load headcount report.'));
  }

  /// Export Attendance Report as CSV text
  Future<String> exportAttendanceCsv({
    String? startDate,
    String? endDate,
    int? branchId,
    int? departmentId,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.exportAttendanceCsv(
        startDate: startDate,
        endDate: endDate,
        branchId: branchId,
        departmentId: departmentId,
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }

    throw Exception(_extractError(response.body, 'Failed to export attendance CSV.'));
  }

  /// Export Leave Report as CSV text
  Future<String> exportLeaveCsv({
    String? startDate,
    String? endDate,
    int? branchId,
    int? departmentId,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.exportLeaveCsv(
        startDate: startDate,
        endDate: endDate,
        branchId: branchId,
        departmentId: departmentId,
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }

    throw Exception(_extractError(response.body, 'Failed to export leave CSV.'));
  }

  /// Export Payroll Report as CSV text
  Future<String> exportPayrollCsv({
    int? periodId,
    int companyId = 1,
    int? branchId,
    int? year,
    int? month,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.exportPayrollCsv(
        periodId: periodId,
        companyId: companyId,
        branchId: branchId,
        year: year,
        month: month,
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }

    throw Exception(_extractError(response.body, 'Failed to export payroll CSV.'));
  }

  String _extractError(String body, String fallback) {
    try {
      final json = jsonDecode(body);
      return json['message'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}

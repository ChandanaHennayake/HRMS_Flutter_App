import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/payroll.dart';

class PayrollService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch payroll periods
  Future<List<PayrollPeriod>> getPayrollPeriods({int companyId = 1, int? year}) async {
    final response = await _apiClient.get(
      ApiConstants.payrollPeriods(companyId: companyId, year: year),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final list = json['data'] as List<dynamic>? ?? [];
      return list.map((item) => PayrollPeriod.fromJson(item)).toList();
    }

    throw Exception(_extractError(response.body));
  }

  /// Trigger batch payroll process
  Future<PayrollRun> processPayroll(Map<String, dynamic> request, {int processedBy = 1}) async {
    final response = await _apiClient.post(
      '${ApiConstants.processPayroll}?processedBy=$processedBy',
      body: request,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return PayrollRun.fromJson(json['data']);
    }

    throw Exception(_extractError(response.body));
  }

  /// Fetch list of payroll runs
  Future<List<PayrollRun>> getPayrollRuns({int companyId = 1, int? branchId}) async {
    final response = await _apiClient.get(
      ApiConstants.payrollRuns(companyId: companyId, branchId: branchId),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final list = json['data'] as List<dynamic>? ?? [];
      return list.map((item) => PayrollRun.fromJson(item)).toList();
    }

    throw Exception(_extractError(response.body));
  }

  /// Fetch payroll run details including employee payslip summaries
  Future<PayrollRun?> getPayrollRunDetails(int id) async {
    final response = await _apiClient.get(
      ApiConstants.payrollRunDetails(id),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      if (json['data'] != null) {
        return PayrollRun.fromJson(json['data']);
      }
      return null;
    }

    if (response.statusCode == 404) return null;

    throw Exception(_extractError(response.body));
  }

  /// Update payroll run status (Draft -> UnderReview -> Approved -> Published)
  Future<PayrollRun> updatePayrollStatus(
    int id,
    int status, {
    int reviewerId = 1,
    String? comments,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.updatePayrollStatus(id, reviewerId: reviewerId),
      body: {
        'status': status,
        'comments': comments,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return PayrollRun.fromJson(json['data']);
    }

    throw Exception(_extractError(response.body));
  }

  /// Fetch payslips for a specific employee
  Future<List<PayslipSummary>> getEmployeePayslips(int employeeId) async {
    final response = await _apiClient.get(
      ApiConstants.employeePayslips(employeeId),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final list = json['data'] as List<dynamic>? ?? [];
      return list.map((item) => PayslipSummary.fromJson(item)).toList();
    }

    throw Exception(_extractError(response.body));
  }

  /// Fetch full itemized payslip breakdown
  Future<Payslip?> getPayslipDetails(int id) async {
    final response = await _apiClient.get(
      ApiConstants.payslipDetails(id),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      if (json['data'] != null) {
        return Payslip.fromJson(json['data']);
      }
      return null;
    }

    if (response.statusCode == 404) return null;

    throw Exception(_extractError(response.body));
  }

  String _extractError(String body) {
    if (body.trim().isEmpty) {
      return 'Payroll request failed.';
    }

    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['title']?.toString() ??
            'Payroll request failed.';
      }
    } catch (_) {}

    return body;
  }
}

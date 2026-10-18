import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/salary.dart';

class SalaryService {
  final ApiClient _apiClient = ApiClient();

  /// Get employee salary profile and live calculation
  Future<EmployeeSalary?> getEmployeeSalary(int employeeId) async {
    if (employeeId <= 0) return null;

    final response = await _apiClient.get(
      ApiConstants.employeeSalary(employeeId),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      if (json['data'] != null) {
        return EmployeeSalary.fromJson(json['data']);
      }
      return null;
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception(_extractError(response.body));
  }

  /// Run custom salary calculation
  Future<SalaryCalculation> calculateSalary(Map<String, dynamic> request) async {
    final response = await _apiClient.post(
      ApiConstants.calculateSalary,
      body: request,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return SalaryCalculation.fromJson(json['data']);
    }

    throw Exception(_extractError(response.body));
  }

  String _extractError(String body) {
    if (body.trim().isEmpty) {
      return 'Salary request failed.';
    }

    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['title']?.toString() ??
            'Salary request failed.';
      }
    } catch (_) {}

    return body;
  }
}

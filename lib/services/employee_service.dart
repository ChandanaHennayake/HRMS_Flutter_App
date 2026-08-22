import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/employee.dart';

class EmployeeService {
  final ApiClient _apiClient = ApiClient();

  // ============================================================
  // GET ALL EMPLOYEES
  // GET: api/Employee
  // ============================================================

  Future<List<Employee>> getAllEmployees() async {
    final response = await _apiClient.get(
      ApiConstants.employees,
      requiresAuth: true,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json = jsonDecode(response.body);

      if (json is! List) {
        throw Exception(
          'Invalid employee response from server.',
        );
      }

      return json
          .map(
            (item) => Employee.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw _handleError(response);
  }

  // ============================================================
  // GET EMPLOYEE BY ID
  // GET: api/Employee/{id}
  // ============================================================

  Future<Employee> getEmployeeById(
    int id,
  ) async {
    final response = await _apiClient.get(
      '${ApiConstants.employees}/$id',
      requiresAuth: true,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return Employee.fromJson(
        json as Map<String, dynamic>,
      );
    }

    throw _handleError(response);
  }

  // ============================================================
  // CREATE EMPLOYEE
  // POST: api/Employee
  // ============================================================

  Future<Employee> createEmployee({
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.employees,
      requiresAuth: true,
      body: data,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return Employee.fromJson(
        json as Map<String, dynamic>,
      );
    }

    throw _handleError(response);
  }

  // ============================================================
  // UPDATE EMPLOYEE
  // PUT: api/Employee/{id}
  // ============================================================

  Future<Employee> updateEmployee({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final response = await _apiClient.put(
      '${ApiConstants.employees}/$id',
      requiresAuth: true,
      body: data,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json = jsonDecode(response.body);

      return Employee.fromJson(
        json as Map<String, dynamic>,
      );
    }

    throw _handleError(response);
  }

  // ============================================================
  // DELETE EMPLOYEE
  // DELETE: api/Employee/{id}?deletedBy=1
  // ============================================================

  Future<bool> deleteEmployee({
    required int id,
    int? deletedBy,
  }) async {
    String endpoint =
        '${ApiConstants.employees}/$id';

    if (deletedBy != null) {
      endpoint += '?deletedBy=$deletedBy';
    }

    final response = await _apiClient.delete(
      endpoint,
      requiresAuth: true,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return true;
    }

    throw _handleError(response);
  }

  // ============================================================
  // ERROR HANDLER
  // ============================================================

  Exception _handleError(
    dynamic response,
  ) {
    String message =
        'Something went wrong.';

    try {
      final json =
          jsonDecode(response.body);

      if (json is Map<String, dynamic>) {
        if (json['message'] != null) {
          message =
              json['message'].toString();
        } else if (json['title'] != null) {
          message =
              json['title'].toString();
        }
      }
    } catch (_) {
      if (response.body != null &&
          response.body.toString().isNotEmpty) {
        message =
            response.body.toString();
      }
    }

    switch (response.statusCode) {
      case 400:
        return Exception(message);

      case 401:
        return Exception(
          'Unauthorized. Please login again.',
        );

      case 403:
        return Exception(
          'You do not have permission to manage employees.',
        );

      case 404:
        return Exception(
          message == 'Something went wrong.'
              ? 'Employee not found.'
              : message,
        );

      case 500:
        return Exception(
          'Server error. Please try again later.',
        );

      default:
        return Exception(message);
    }
  }
}
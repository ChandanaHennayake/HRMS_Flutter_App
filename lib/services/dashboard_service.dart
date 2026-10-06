import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/admin_summary.dart';
import '../models/manager_summary.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  // ============================================================
  // GET ADMIN DASHBOARD SUMMARY
  // GET: /api/Dashboard/admin-summary
  // ============================================================

  Future<AdminSummary> getAdminSummary({int? companyId}) async {
    String url = ApiConstants.adminDashboardSummary;
    if (companyId != null && companyId > 0) {
      url += '?companyId=$companyId';
    }

    final response = await _apiClient.get(
      url,
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        return AdminSummary.fromJson(
          decoded['data'] as Map<String, dynamic>,
        );
      }
      return AdminSummary.fromJson(
        decoded as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to load admin dashboard: ${response.statusCode}',
    );
  }

  // ============================================================
  // GET MANAGER DASHBOARD SUMMARY
  // GET: /api/Dashboard/manager-summary?branchId={id}
  // ============================================================

  Future<ManagerSummary> getManagerSummary(int branchId) async {
    final response = await _apiClient.get(
      ApiConstants.managerDashboardSummary(branchId),
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        return ManagerSummary.fromJson(
          decoded['data'] as Map<String, dynamic>,
        );
      }
      return ManagerSummary.fromJson(
        decoded as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to load manager dashboard: ${response.statusCode}',
    );
  }
}

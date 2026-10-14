import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/audit_log.dart';

class AuditService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch paged audit logs with optional filters
  Future<PagedAuditResult> getAuditLogs({
    int page = 1,
    int pageSize = 30,
    String? action,
    String? entityName,
    String? severity,
    String? search,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.auditLogs(
        page: page,
        pageSize: pageSize,
        action: action,
        entityName: entityName,
        severity: severity,
        search: search,
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return PagedAuditResult.fromJson(json['data'] as Map<String, dynamic>);
    }

    throw Exception(_extractError(response.body));
  }

  /// Fetch overall audit log statistics
  Future<AuditStats> getAuditStats() async {
    final response = await _apiClient.get(ApiConstants.auditStats);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return AuditStats.fromJson(json['data'] as Map<String, dynamic>);
    }

    throw Exception(_extractError(response.body));
  }

  /// Fetch distinct actions for filter dropdowns
  Future<List<String>> getDistinctActions() async {
    final response = await _apiClient.get(ApiConstants.auditActions);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final list = json['data'] as List<dynamic>? ?? [];
      return list.map((e) => e.toString()).toList();
    }

    return [];
  }

  /// Fetch distinct entities for filter dropdowns
  Future<List<String>> getDistinctEntities() async {
    final response = await _apiClient.get(ApiConstants.auditEntities);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final list = json['data'] as List<dynamic>? ?? [];
      return list.map((e) => e.toString()).toList();
    }

    return [];
  }

  /// Fetch details of a specific audit log entry
  Future<AuditLogItem?> getAuditLogDetails(int id) async {
    final response = await _apiClient.get(ApiConstants.auditLogDetails(id));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return AuditLogItem.fromJson(json['data'] as Map<String, dynamic>);
    }

    return null;
  }

  String _extractError(String body) {
    try {
      final json = jsonDecode(body);
      return json['message'] as String? ?? 'Failed to load audit logs.';
    } catch (_) {
      return 'An unexpected error occurred.';
    }
  }
}

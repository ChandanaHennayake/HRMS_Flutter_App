import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/lookup_item.dart';

/// Fetches master lookup data from /api/Lookup.
class LookupService {
  final ApiClient _apiClient = ApiClient();

  Future<List<LookupItem>> getDepartments({int? companyId}) =>
      _getList(ApiConstants.lookupDepartments, companyId: companyId);

  Future<List<LookupItem>> getDesignations({int? companyId}) =>
      _getList(ApiConstants.lookupDesignations, companyId: companyId);

  Future<List<LookupItem>> getEmploymentTypes() =>
      _getList(ApiConstants.lookupEmploymentTypes);

  Future<List<LookupItem>> getRoles({int? companyId}) =>
      _getList(ApiConstants.lookupRoles, companyId: companyId);

  Future<List<LookupItem>> getBranches({int? companyId}) =>
      _getList(ApiConstants.lookupBranches, companyId: companyId);

  /// Loads every list required by the employee form concurrently.
  Future<EmployeeLookups> getEmployeeLookups({int? companyId}) async {
    final results = await Future.wait([
      getDepartments(companyId: companyId),
      getDesignations(companyId: companyId),
      getEmploymentTypes(),
      getRoles(companyId: companyId),
      getBranches(companyId: companyId),
    ]);

    return EmployeeLookups(
      departments: results[0],
      designations: results[1],
      employmentTypes: results[2],
      roles: results[3],
      branches: results[4],
    );
  }

  Future<List<LookupItem>> _getList(
    String endpoint, {
    int? companyId,
  }) async {
    final url = (companyId != null && companyId > 0)
        ? '$endpoint?companyId=$companyId'
        : endpoint;

    final response = await _apiClient.get(url, requiresAuth: true);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      if (json is! List) {
        throw Exception('Invalid lookup response from server.');
      }
      return json
          .map((e) => LookupItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw _handleError(response);
  }

  Exception _handleError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        return Exception('Unauthorized. Please login again.');
      case 403:
        return Exception('You do not have permission to view master data.');
      case 404:
        return Exception('Lookup endpoint not found.');
      case 500:
        return Exception('Server error. Please try again later.');
      default:
        String message = 'Failed to load master data.';
        try {
          final json = jsonDecode(response.body);
          if (json is Map<String, dynamic> && json['message'] != null) {
            message = json['message'].toString();
          }
        } catch (_) {}
        return Exception(message);
    }
  }
}

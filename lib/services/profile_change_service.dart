import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/profile_change_request.dart';

class ProfileChangeService {
  final ApiClient _apiClient = ApiClient();

  /// Submit a new profile change request (Personal & Bank details)
  Future<ProfileChangeRequest> submitRequest(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.profileChange,
      body: data,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return ProfileChangeRequest.fromJson(json['data']);
    }

    throw Exception(_extractError(response.body));
  }

  /// Get profile change requests for the logged in employee
  Future<List<ProfileChangeRequest>> getMyRequests(int employeeId) async {
    final response = await _apiClient.get(
      ApiConstants.myProfileChanges(employeeId),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final rawList = json['data'] as List<dynamic>? ?? [];
      return rawList.map((e) => ProfileChangeRequest.fromJson(e)).toList();
    }

    throw Exception(_extractError(response.body));
  }

  /// Get all profile change requests for Admin / Manager review
  Future<List<ProfileChangeRequest>> getAllRequests({
    int? branchId,
    int? status,
  }) async {
    final params = <String>[];
    if (branchId != null && branchId > 0) params.add('branchId=$branchId');
    if (status != null) params.add('status=$status');

    final endpoint = params.isEmpty
        ? ApiConstants.profileChange
        : '${ApiConstants.profileChange}?${params.join('&')}';

    final response = await _apiClient.get(endpoint);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final rawList = json['data'] as List<dynamic>? ?? [];
      return rawList.map((e) => ProfileChangeRequest.fromJson(e)).toList();
    }

    throw Exception(_extractError(response.body));
  }

  /// Get single profile change request details
  Future<ProfileChangeRequest?> getById(int id) async {
    final response = await _apiClient.get(
      ApiConstants.profileChangeById(id),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return ProfileChangeRequest.fromJson(json['data']);
    }

    return null;
  }

  /// Approve a profile change request (Applies changes to Employee & User tables)
  Future<ProfileChangeRequest> approveRequest(
    int id, {
    int? reviewerUserId,
    String? comment,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.approveProfileChange(id),
      body: {
        'reviewerUserId': reviewerUserId,
        'comment': comment,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return ProfileChangeRequest.fromJson(json['data']);
    }

    throw Exception(_extractError(response.body));
  }

  /// Reject a profile change request with reason
  Future<ProfileChangeRequest> rejectRequest(
    int id, {
    int? reviewerUserId,
    String? comment,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.rejectProfileChange(id),
      body: {
        'reviewerUserId': reviewerUserId,
        'comment': comment,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return ProfileChangeRequest.fromJson(json['data']);
    }

    throw Exception(_extractError(response.body));
  }

  /// Cancel a pending profile change request
  Future<bool> cancelRequest(int id) async {
    final response = await _apiClient.post(
      ApiConstants.cancelProfileChange(id),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw Exception(_extractError(response.body));
  }

  String _extractError(String body) {
    if (body.trim().isEmpty) {
      return 'Request failed.';
    }

    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['title']?.toString() ??
            'Request failed.';
      }
    } catch (_) {}

    return 'Network request failed: $body';
  }
}

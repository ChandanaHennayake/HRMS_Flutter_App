import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/apply_leave_request.dart';
import '../models/leave_action_request.dart';
import '../models/leave_request.dart';
import '../models/leave_type.dart';

class LeaveService {
  final ApiClient _apiClient = ApiClient();

  /// Get Leave Types
  Future<List<LeaveType>> getLeaveTypes() async {
    final response = await _apiClient.get(
      ApiConstants.leaveTypes,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json = jsonDecode(response.body);

      final List data = json['data'];

      return data
          .map((e) => LeaveType.fromJson(e))
          .toList();
    }

    throw Exception(_extractError(response.body));
  }

  /// Employee Leave History
  Future<List<LeaveRequest>> getEmployeeLeaves({
    required int employeeId,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.leaveEmployee}/$employeeId',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json = jsonDecode(response.body);

      final List data = json['data'];

      return data
          .map((e) => LeaveRequest.fromJson(e))
          .toList();
    }

    throw Exception(_extractError(response.body));
  }

  /// Apply Leave
  Future<void> applyLeave({
    required int employeeId,
    required ApplyLeaveRequest request,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.applyLeave}?employeeId=$employeeId',
      body: request.toJson(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(_extractError(response.body));
    }
  }

  /// Cancel Leave
  Future<void> cancelLeave({
    required int leaveRequestId,
    required int employeeId,
  }) async {
    final response = await _apiClient.put(
      '${ApiConstants.cancelLeave(leaveRequestId)}?employeeId=$employeeId',
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(_extractError(response.body));
    }
  }

  /// Pending Leaves (Manager/Admin)
  Future<List<LeaveRequest>> getPendingLeaves() async {
    final response = await _apiClient.get(
      ApiConstants.pendingLeaves,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final json = jsonDecode(response.body);

      final List data = json['data'];

      return data
          .map((e) => LeaveRequest.fromJson(e))
          .toList();
    }

    throw Exception(_extractError(response.body));
  }

  /// Approve Leave
  Future<void> approveLeave({
    required int leaveRequestId,
    required int approvedBy,
    required LeaveActionRequest request,
  }) async {
    final response = await _apiClient.put(
      '${ApiConstants.approveLeave(leaveRequestId)}?approvedBy=$approvedBy',
      body: request.toJson(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(_extractError(response.body));
    }
  }

  /// Reject Leave
  Future<void> rejectLeave({
    required int leaveRequestId,
    required int rejectedBy,
    required LeaveActionRequest request,
  }) async {
    final response = await _apiClient.put(
      '${ApiConstants.rejectLeave(leaveRequestId)}?rejectedBy=$rejectedBy',
      body: request.toJson(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(_extractError(response.body));
    }
  }

  String _extractError(String body) {
    if (body.trim().isEmpty) {
      return 'Leave request failed.';
    }

    try {
      final data = jsonDecode(body);

      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['title']?.toString() ??
            'Leave request failed.';
      }
    } catch (_) {}

    return body;
  }
}
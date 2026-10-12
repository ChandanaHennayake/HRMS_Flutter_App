import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/attendance_correction.dart';

class AttendanceCorrectionService {
  final ApiClient _apiClient = ApiClient();

  Future<AttendanceCorrection> submitCorrection({
    required int employeeId,
    required String attendanceDate,
    DateTime? requestedCheckInTime,
    DateTime? requestedCheckOutTime,
    required String reason,
  }) async {
    final body = <String, dynamic>{
      'attendanceDate': attendanceDate,
      'reason': reason,
      if (requestedCheckInTime != null)
        'requestedCheckInTime': requestedCheckInTime.toIso8601String(),
      if (requestedCheckOutTime != null)
        'requestedCheckOutTime': requestedCheckOutTime.toIso8601String(),
    };

    final response = await _apiClient.post(
      ApiConstants.attendanceCorrectionRequest(employeeId),
      body: body,
      requiresAuth: true,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      return AttendanceCorrection.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        data['message'] ?? 'Failed to submit attendance correction.',
      );
    }
  }

  Future<List<AttendanceCorrection>> getMyCorrections(int employeeId) async {
    final response = await _apiClient.get(
      ApiConstants.myAttendanceCorrections(employeeId),
      requiresAuth: true,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map(
            (item) => AttendanceCorrection.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } else {
      throw Exception(
        data['message'] ?? 'Failed to load attendance corrections.',
      );
    }
  }

  Future<List<AttendanceCorrection>> getPendingCorrections({
    int? branchId,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.pendingAttendanceCorrections(branchId: branchId),
      requiresAuth: true,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list
          .map(
            (item) => AttendanceCorrection.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } else {
      throw Exception(
        data['message'] ?? 'Failed to load pending corrections.',
      );
    }
  }

  Future<AttendanceCorrection> reviewCorrection({
    required int id,
    required int reviewerId,
    required int status,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      'status': status,
      'reviewerComment': comment,
    };

    final response = await _apiClient.put(
      ApiConstants.reviewAttendanceCorrection(id, reviewerId),
      body: body,
      requiresAuth: true,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      return AttendanceCorrection.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        data['message'] ?? 'Failed to review attendance correction.',
      );
    }
  }

  Future<bool> cancelCorrection({
    required int id,
    required int employeeId,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.cancelAttendanceCorrection(id, employeeId),
      requiresAuth: true,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      return true;
    } else {
      throw Exception(
        data['message'] ?? 'Failed to cancel correction request.',
      );
    }
  }
}

import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/attendance.dart';
import '../models/attendance_history.dart';
import '../models/branch_daily_attendance.dart';

class AttendanceService {
  final ApiClient _apiClient = ApiClient();

  // =========================================================
  // GET TODAY ATTENDANCE
  // =========================================================

  Future<AttendanceModel?> getTodayAttendance({
    required int employeeId,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.todayAttendance}?employeeId=$employeeId',
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return null;
      final json = jsonDecode(response.body);
      if (json is Map<String, dynamic> && json['data'] != null) {
        return AttendanceModel.fromJson(
          Map<String, dynamic>.from(json['data']),
        );
      }
      return null;
    }

    throw Exception(_extractError(response.body));
  }

  // =========================================================
  // CHECK IN
  // =========================================================

  Future<void> checkIn({
    required int employeeId,
    required double latitude,
    required double longitude,
    DateTime? deviceTime,
  }) async {
    final now = deviceTime ?? DateTime.now();
    final response = await _apiClient.post(
      '${ApiConstants.checkIn}?employeeId=$employeeId',
      body: {
        'latitude': latitude,
        'longitude': longitude,
        'deviceTime': now.toIso8601String(),
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _extractError(response.body),
      );
    }
  }

  // =========================================================
  // CHECK OUT
  // =========================================================

  Future<void> checkOut({
    required int employeeId,
    required double latitude,
    required double longitude,
    DateTime? deviceTime,
  }) async {
    final now = deviceTime ?? DateTime.now();
    final response = await _apiClient.post(
      '${ApiConstants.checkOut}?employeeId=$employeeId',
      body: {
        'latitude': latitude,
        'longitude': longitude,
        'deviceTime': now.toIso8601String(),
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _extractError(response.body),
      );
    }
  }

  // =========================================================
  // ATTENDANCE HISTORY
  // =========================================================

  Future<List<AttendanceHistoryModel>>
      getAttendanceHistory({
    required int employeeId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParameters =
        <String, String>{
      'employeeId':
          employeeId.toString(),
    };

    if (fromDate != null) {
      queryParameters['fromDate'] =
          _formatDate(fromDate);
    }

    if (toDate != null) {
      queryParameters['toDate'] =
          _formatDate(toDate);
    }

    final uri = Uri.parse(
      ApiConstants.attendanceHistory,
    ).replace(
      queryParameters:
          queryParameters,
    );

    final response =
        await _apiClient.get(
      uri.toString(),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _extractError(response.body),
      );
    }

    if (response.body.trim().isEmpty) {
      return [];
    }

    final decoded =
        jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid attendance history response.',
      );
    }

    return decoded
        .map(
          (item) =>
              AttendanceHistoryModel.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
        .toList();
  }

  // =========================================================
  // DATE FORMAT
  // =========================================================

  String _formatDate(
    DateTime date,
  ) {
    final year =
        date.year
            .toString()
            .padLeft(4, '0');

    final month =
        date.month
            .toString()
            .padLeft(2, '0');

    final day =
        date.day
            .toString()
            .padLeft(2, '0');

    return '$year-$month-$day';
  }

  // =========================================================
  // ERROR
  // =========================================================

  String _extractError(
    String body,
  ) {
    if (body.trim().isEmpty) {
      return 'Attendance request failed.';
    }

    try {
      final data =
          jsonDecode(body);

      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['title']?.toString() ??
            'Attendance request failed.';
      }
    } catch (_) {
      // Response wasn't JSON.
    }

    return body;
  }

  // =========================================================
  // BRANCH / COMPANY DAILY ATTENDANCE ROSTER
  // =========================================================

  Future<List<BranchDailyAttendance>> getBranchDailyAttendance({
    int? branchId,
    DateTime? date,
  }) async {
    final dateStr = date != null ? _formatDate(date) : null;
    final url = ApiConstants.branchDailyAttendance(
      branchId: branchId,
      date: dateStr,
    );

    final response = await _apiClient.get(url, requiresAuth: true);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      dynamic data = decoded;
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        data = decoded['data'];
      }
      if (data is List) {
        return data
            .map((item) => BranchDailyAttendance.fromJson(
                  item as Map<String, dynamic>,
                ))
            .toList();
      }
      return [];
    }

    throw Exception(_extractError(response.body));
  }
}
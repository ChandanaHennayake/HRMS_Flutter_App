import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class AttendanceService {
  final ApiClient _apiClient = ApiClient();

  Future<void> checkIn({
    required int employeeId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.checkIn}?employeeId=$employeeId',
      body: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _extractError(response.body),
      );
    }
  }

  Future<void> checkOut({
    required int employeeId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.checkOut}?employeeId=$employeeId',
      body: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        _extractError(response.body),
      );
    }
  }

  String _extractError(String body) {
    if (body.trim().isEmpty) {
      return 'Attendance request failed.';
    }

    try {
      final data = jsonDecode(body);

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
}
import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/holiday.dart';

class HolidayService {
  final ApiClient _apiClient = ApiClient();

  // ============================================================
  // GET ALL HOLIDAYS
  // GET: /api/Holiday?companyId={id}&year={yyyy}
  // ============================================================

  Future<List<Holiday>> getHolidays({
    int? companyId,
    int? year,
  }) async {
    String url = ApiConstants.holidays;
    final queryParams = <String>[];

    if (companyId != null && companyId > 0) {
      queryParams.add('companyId=$companyId');
    }
    if (year != null && year > 0) {
      queryParams.add('year=$year');
    }

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await _apiClient.get(
      url,
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      dynamic listData = decoded;
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        listData = decoded['data'];
      }

      if (listData is List) {
        return listData
            .map(
              (item) => Holiday.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }
      return [];
    }

    throw Exception(
      'Failed to load holidays: ${response.statusCode}',
    );
  }

  // ============================================================
  // GET UPCOMING HOLIDAY
  // GET: /api/Holiday/upcoming?companyId={id}
  // ============================================================

  Future<Holiday?> getUpcomingHoliday({int? companyId}) async {
    String url = ApiConstants.upcomingHoliday;
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
        return Holiday.fromJson(
          decoded['data'] as Map<String, dynamic>,
        );
      }
      return null;
    }

    return null;
  }
}

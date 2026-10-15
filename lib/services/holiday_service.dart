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

  // ============================================================
  // CREATE HOLIDAY
  // POST: /api/Holiday
  // ============================================================

  Future<Holiday> createHoliday(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.holidays,
      body: data,
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final itemData = decoded is Map<String, dynamic> && decoded['data'] != null
          ? decoded['data']
          : decoded;
      return Holiday.fromJson(itemData as Map<String, dynamic>);
    }

    throw Exception(_extractError(response.body));
  }

  // ============================================================
  // UPDATE HOLIDAY
  // PUT: /api/Holiday/{id}
  // ============================================================

  Future<Holiday> updateHoliday(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${ApiConstants.holidays}/$id',
      body: data,
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final itemData = decoded is Map<String, dynamic> && decoded['data'] != null
          ? decoded['data']
          : decoded;
      return Holiday.fromJson(itemData as Map<String, dynamic>);
    }

    throw Exception(_extractError(response.body));
  }

  // ============================================================
  // DELETE HOLIDAY
  // DELETE: /api/Holiday/{id}
  // ============================================================

  Future<bool> deleteHoliday(int id, {int? deletedBy}) async {
    String url = '${ApiConstants.holidays}/$id';
    if (deletedBy != null && deletedBy > 0) {
      url += '?deletedBy=$deletedBy';
    }

    final response = await _apiClient.delete(
      url,
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw Exception(_extractError(response.body));
  }

  String _extractError(String body) {
    if (body.trim().isEmpty) return 'Holiday operation failed.';
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['title']?.toString() ??
            'Holiday operation failed.';
      }
    } catch (_) {}
    return body;
  }
}

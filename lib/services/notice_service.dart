import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/notice.dart';

class NoticeService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch currently active notice for users popup
  Future<SystemNotice?> getActiveNotice([String? role]) async {
    try {
      final endpoint = role != null && role.isNotEmpty && role != 'All'
          ? '${ApiConstants.activeNotice}?role=$role'
          : ApiConstants.activeNotice;
      final response = await _apiClient.get(endpoint);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        if (json['data'] != null) {
          return SystemNotice.fromJson(json['data']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get all notices (for Admin management)
  Future<List<SystemNotice>> getAllNotices() async {
    final response = await _apiClient.get(ApiConstants.notices);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final list = json['data'] as List<dynamic>? ?? [];
      return list.map((item) => SystemNotice.fromJson(item)).toList();
    }
    throw Exception(_extractError(response.body));
  }

  /// Create a new notice / poster
  Future<SystemNotice> createNotice({
    required String title,
    required String message,
    String? imageUrl,
    String? targetAudience,
    String? validUntil,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.notices,
      body: {
        'title': title,
        'message': message,
        'imageUrl': imageUrl,
        'targetRole': targetAudience ?? 'All',
        'targetAudience': targetAudience ?? 'All',
        'isActive': true,
        'validUntil': validUntil,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return SystemNotice.fromJson(json['data']);
    }

    throw Exception(_extractError(response.body));
  }

  /// Toggle active/inactive status
  Future<bool> toggleNotice(int id) async {
    final response = await _apiClient.put(ApiConstants.toggleNotice(id));
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Delete notice
  Future<bool> deleteNotice(int id) async {
    final response = await _apiClient.delete(ApiConstants.deleteNotice(id));
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  String _extractError(String body) {
    if (body.trim().isEmpty) return 'Notice request failed.';
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ?? 'Notice request failed.';
      }
    } catch (_) {}
    return body;
  }
}

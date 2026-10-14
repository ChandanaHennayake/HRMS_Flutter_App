import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/notification.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch user notifications
  Future<List<AppNotification>> getMyNotifications({int? userId, int limit = 50}) async {
    final response = await _apiClient.get(
      ApiConstants.myNotifications(userId: userId, limit: limit),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final list = json['data'] as List<dynamic>? ?? [];
      return list.map((item) => AppNotification.fromJson(item as Map<String, dynamic>)).toList();
    }

    throw Exception(_extractError(response.body));
  }

  /// Get notification summary (unread count & total count)
  Future<NotificationSummary> getSummary({int? userId}) async {
    final response = await _apiClient.get(
      ApiConstants.notificationSummary(userId: userId),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return NotificationSummary.fromJson(json['data'] as Map<String, dynamic>);
    }

    return NotificationSummary(unreadCount: 0, totalCount: 0);
  }

  /// Mark single notification as read
  Future<bool> markAsRead(int notificationId) async {
    final response = await _apiClient.put(
      ApiConstants.markNotificationRead(notificationId),
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead({int? userId}) async {
    final response = await _apiClient.put(
      ApiConstants.markAllNotificationsRead(userId: userId),
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  String _extractError(String body) {
    try {
      final json = jsonDecode(body);
      return json['message'] as String? ?? 'Failed to process notification request.';
    } catch (_) {
      return 'An unexpected error occurred.';
    }
  }
}

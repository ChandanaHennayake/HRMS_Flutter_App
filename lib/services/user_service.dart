import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/admin_user.dart';
import '../models/user_profile.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  // ============================================================
  // GET USER PROFILE
  // GET: /api/User/profile/{userId}
  // ============================================================

  Future<UserProfile> getUserProfile(int userId) async {
    final response = await _apiClient.get(
      ApiConstants.userProfile(userId),
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final data =
          (decoded is Map<String, dynamic> && decoded.containsKey('data'))
              ? decoded['data']
              : decoded;

      if (data is Map<String, dynamic>) {
        return UserProfile.fromJson(data);
      }
      throw Exception('Invalid profile response format');
    }

    try {
      final decoded = jsonDecode(response.body);
      final message = decoded is Map && decoded['message'] != null
          ? decoded['message']
          : 'Failed to load user profile';
      throw Exception(message);
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) {
        rethrow;
      }
      throw Exception('Failed to load user profile (${response.statusCode})');
    }
  }

  // ============================================================
  // CHANGE PASSWORD
  // PUT: /api/User/change-password
  // ============================================================

  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.changePassword,
      body: {
        'userId': userId,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    try {
      final decoded = jsonDecode(response.body);
      final message = decoded is Map && decoded['message'] != null
          ? decoded['message']
          : 'Failed to change password (${response.statusCode})';
      throw Exception(message);
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) {
        rethrow;
      }
      throw Exception('Failed to change password (${response.statusCode})');
    }
  }

  // ============================================================
  // GET ALL USERS (ADMIN)
  // GET: /api/User
  // ============================================================

  Future<List<AdminUserItem>> getAllUsers() async {
    final response = await _apiClient.get(
      '/api/User',
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      dynamic data = decoded;
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        data = decoded['data'];
      }
      if (data is List) {
        return data.map((e) => AdminUserItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await _apiClient.get(
      '/api/User',
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      dynamic data = decoded;
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        data = decoded['data'];
      }
      if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
    }
    return [];
  }

  // ============================================================
  // CREATE USER (ADMIN)
  // POST: /api/User
  // ============================================================

  Future<void> createUser({
    required int companyId,
    required int? branchId,
    required int roleId,
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    int? employeeId,
  }) async {
    final response = await _apiClient.post(
      '/api/User',
      body: {
        'companyId': companyId,
        'branchId': branchId,
        'roleId': roleId,
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'employeeId': employeeId,
      },
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    try {
      final decoded = jsonDecode(response.body);
      final message = decoded is Map && decoded['message'] != null
          ? decoded['message']
          : 'Failed to create user (${response.statusCode})';
      throw Exception(message);
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) {
        rethrow;
      }
      throw Exception('Failed to create user (${response.statusCode})');
    }
  }

  // ============================================================
  // DELETE USER (ADMIN)
  // DELETE: /api/User/{id}
  // ============================================================

  Future<void> deleteUser(int userId) async {
    final response = await _apiClient.delete(
      '/api/User/$userId',
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception('Failed to delete user (${response.statusCode})');
  }
}

import 'dart:convert';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/branch.dart';

class BranchService {
  final ApiClient _apiClient = ApiClient();

  // ============================================================
  // GET ALL BRANCHES
  // GET: /api/Branch
  // ============================================================

  Future<List<Branch>> getBranches() async {
    final response = await _apiClient.get(
      ApiConstants.branches,
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
            .map((item) => Branch.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    throw Exception('Failed to load branches: ${response.statusCode}');
  }

  // ============================================================
  // GET BRANCH BY ID
  // GET: /api/Branch/{id}
  // ============================================================

  Future<Branch?> getBranchById(int id) async {
    final response = await _apiClient.get(
      '${ApiConstants.branches}/$id',
      requiresAuth: true,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        return Branch.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      return null;
    }

    return null;
  }

  // ============================================================
  // CREATE BRANCH
  // POST: /api/Branch
  // ============================================================

  Future<Branch> createBranch({
    required int companyId,
    String? branchCode,
    required String branchName,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
    int geofenceRadiusMeters = 100,
    bool isActive = true,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.branches,
      requiresAuth: true,
      body: {
        'companyId': companyId,
        'branchCode': branchCode,
        'branchName': branchName,
        'address': address,
        'phone': phone,
        'latitude': latitude,
        'longitude': longitude,
        'geofenceRadiusMeters': geofenceRadiusMeters,
        'isActive': isActive,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        return Branch.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      throw Exception('Branch created but invalid response payload.');
    }

    final decoded = jsonDecode(response.body);
    final errorMsg = decoded is Map<String, dynamic>
        ? (decoded['message'] ?? 'Failed to create branch')
        : 'Failed to create branch';
    throw Exception(errorMsg);
  }

  // ============================================================
  // UPDATE BRANCH
  // PUT: /api/Branch/{id}
  // ============================================================

  Future<Branch> updateBranch({
    required int branchId,
    String? branchCode,
    required String branchName,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
    int geofenceRadiusMeters = 100,
    bool isActive = true,
  }) async {
    final response = await _apiClient.put(
      '${ApiConstants.branches}/$branchId',
      requiresAuth: true,
      body: {
        'branchCode': branchCode,
        'branchName': branchName,
        'address': address,
        'phone': phone,
        'latitude': latitude,
        'longitude': longitude,
        'geofenceRadiusMeters': geofenceRadiusMeters,
        'isActive': isActive,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        return Branch.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      throw Exception('Branch updated but invalid response payload.');
    }

    final decoded = jsonDecode(response.body);
    final errorMsg = decoded is Map<String, dynamic>
        ? (decoded['message'] ?? 'Failed to update branch')
        : 'Failed to update branch';
    throw Exception(errorMsg);
  }

  // ============================================================
  // DELETE / DEACTIVATE BRANCH
  // DELETE: /api/Branch/{id}
  // ============================================================

  Future<void> deleteBranch(int id) async {
    final response = await _apiClient.delete(
      '${ApiConstants.branches}/$id',
      requiresAuth: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded is Map<String, dynamic>
          ? (decoded['message'] ?? 'Failed to delete branch')
          : 'Failed to delete branch';
      throw Exception(errorMsg);
    }
  }

  // ============================================================
  // GET BRANCH MANAGERS
  // GET: /api/Branch/managers/{branchId}
  // ============================================================

  Future<List<BranchManager>> getBranchManagers(int branchId) async {
    final response = await _apiClient.get(
      ApiConstants.branchManagers(branchId),
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
            .map((item) => BranchManager.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    return [];
  }

  // ============================================================
  // ASSIGN MANAGER
  // POST: /api/Branch/assign-manager
  // ============================================================

  Future<void> assignManager({
    required int userId,
    required int branchId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.assignBranchManager,
      requiresAuth: true,
      body: {
        'userId': userId,
        'branchId': branchId,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded is Map<String, dynamic>
          ? (decoded['message'] ?? 'Failed to assign manager')
          : 'Failed to assign manager';
      throw Exception(errorMsg);
    }
  }

  // ============================================================
  // REMOVE MANAGER
  // DELETE: /api/Branch/remove-manager?userId={userId}&branchId={branchId}
  // ============================================================

  Future<void> removeManager({
    required int userId,
    required int branchId,
  }) async {
    final response = await _apiClient.delete(
      ApiConstants.removeBranchManager(userId, branchId),
      requiresAuth: true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded is Map<String, dynamic>
          ? (decoded['message'] ?? 'Failed to remove manager assignment')
          : 'Failed to remove manager assignment';
      throw Exception(errorMsg);
    }
  }

  // ============================================================
  // GET BRANCHES ASSIGNED TO A MANAGER / USER
  // GET: /api/Branch/user-branches/{userId}
  // ============================================================

  Future<List<Branch>> getUserBranches(int userId) async {
    final response = await _apiClient.get(
      ApiConstants.userBranches(userId),
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
            .map((item) => Branch.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    return [];
  }
}

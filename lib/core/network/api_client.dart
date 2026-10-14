import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../ui/auth/login_view.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static void Function()? onUnauthorized;

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final headers = await _buildHeaders(
      requiresAuth: requiresAuth,
    );

    final response = await http
        .post(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: headers,
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 30));

    await _handleResponse(response, requiresAuth);
    return response;
  }

  Future<http.Response> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final headers = await _buildHeaders(
      requiresAuth: requiresAuth,
    );

    final response = await http
        .get(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 30));

    await _handleResponse(response, requiresAuth);
    return response;
  }

  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final headers = await _buildHeaders(
      requiresAuth: requiresAuth,
    );

    final response = await http
        .delete(
          Uri.parse(
            '${ApiConstants.baseUrl}$endpoint',
          ),
          headers: headers,
        )
        .timeout(const Duration(seconds: 30));

    await _handleResponse(response, requiresAuth);
    return response;
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final headers = await _buildHeaders(
      requiresAuth: requiresAuth,
    );

    final response = await http
        .put(
          Uri.parse('${ApiConstants.baseUrl}$endpoint'),
          headers: headers,
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 30));

    await _handleResponse(response, requiresAuth);
    return response;
  }


  Future<void> _handleResponse(
    http.Response response,
    bool requiresAuth,
  ) async {
    if (requiresAuth && response.statusCode == 401) {
      await SecureStorage.clear();
      if (onUnauthorized != null) {
        onUnauthorized!();
      } else if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      }
    }
  }

  Future<Map<String, String>> _buildHeaders({
    required bool requiresAuth,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await SecureStorage.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }
}
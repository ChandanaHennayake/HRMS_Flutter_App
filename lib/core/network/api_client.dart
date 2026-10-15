import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../ui/auth/login_view.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'connectivity_service.dart';

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

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: headers,
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 30));

      await _handleResponse(response, requiresAuth);
      return response;
    } on SocketException {
      ConnectivityService.showOfflineAlert();
      throw Exception('You are offline. Please check your internet connection.');
    } on TimeoutException {
      ConnectivityService.showOfflineAlert();
      throw Exception('Connection timed out. Please check your network connection.');
    } on http.ClientException {
      ConnectivityService.showOfflineAlert();
      throw Exception('You are offline. Unable to reach server.');
    }
  }

  Future<http.Response> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final headers = await _buildHeaders(
      requiresAuth: requiresAuth,
    );

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      await _handleResponse(response, requiresAuth);
      return response;
    } on SocketException {
      ConnectivityService.showOfflineAlert();
      throw Exception('You are offline. Please check your internet connection.');
    } on TimeoutException {
      ConnectivityService.showOfflineAlert();
      throw Exception('Connection timed out. Please check your network connection.');
    } on http.ClientException {
      ConnectivityService.showOfflineAlert();
      throw Exception('You are offline. Unable to reach server.');
    }
  }

  Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final headers = await _buildHeaders(
      requiresAuth: requiresAuth,
    );

    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      await _handleResponse(response, requiresAuth);
      return response;
    } on SocketException {
      ConnectivityService.showOfflineAlert();
      throw Exception('You are offline. Please check your internet connection.');
    } on TimeoutException {
      ConnectivityService.showOfflineAlert();
      throw Exception('Connection timed out. Please check your network connection.');
    } on http.ClientException {
      ConnectivityService.showOfflineAlert();
      throw Exception('You are offline. Unable to reach server.');
    }
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final headers = await _buildHeaders(
      requiresAuth: requiresAuth,
    );

    try {
      final response = await http
          .put(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: headers,
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 30));

      await _handleResponse(response, requiresAuth);
      return response;
    } on SocketException {
      ConnectivityService.showOfflineAlert();
      throw Exception('You are offline. Please check your internet connection.');
    } on TimeoutException {
      ConnectivityService.showOfflineAlert();
      throw Exception('Connection timed out. Please check your network connection.');
    } on http.ClientException {
      ConnectivityService.showOfflineAlert();
      throw Exception('You are offline. Unable to reach server.');
    }
  }

  Future<void> _handleResponse(
    http.Response response,
    bool requiresAuth,
  ) async {
    if (requiresAuth && response.statusCode == 401) {
      await SecureStorage.clear();

      final messenger = ConnectivityService.messengerKey.currentState;
      if (messenger != null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: Color(0xFFDC2626),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

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
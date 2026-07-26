import 'user.dart';

class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  LoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? LoginData.fromJson(json['data'])
          : null,
    );
  }
}

class LoginData {
  final User user;
  final String token;
  final DateTime? expiration;

  LoginData({
    required this.user,
    required this.token,
    this.expiration,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: User.fromJson(json),
      token: json['token'] ?? '',
      expiration: DateTime.tryParse(
        json['expiration'] ?? '',
      ),
    );
  }
}
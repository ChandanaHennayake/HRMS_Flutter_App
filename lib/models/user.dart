class User {
  final int userId;
  final int employeeId;
  final String username;
  final String email;
  final String fullName;
  final int roleId;
  final String role;
  final int companyId;
  final int branchId;
  final String? branchName;

  User({
    required this.userId,
    required this.employeeId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.roleId,
    required this.role,
    required this.companyId,
    required this.branchId,
    this.branchName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? 0,
      employeeId: json['employeeId'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      roleId: json['roleId'] ?? 0,
      role: json['role'] ?? '',
      companyId: json['companyId'] ?? 0,
      branchId: json['branchId'] ?? 0,
      branchName: json['branchName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'employeeId': employeeId,
      'username': username,
      'email': email,
      'fullName': fullName,
      'roleId': roleId,
      'role': role,
      'companyId': companyId,
      'branchId': branchId,
      'branchName': branchName,
    };
  }
}
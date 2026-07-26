class User {
  final int userId;
  final String username;
  final String email;
  final String fullName;
  final int roleId;
  final String role;
  final int companyId;
  final int branchId;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.roleId,
    required this.role,
    required this.companyId,
    required this.branchId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      roleId: json['roleId'] ?? 0,
      role: json['role'] ?? '',
      companyId: json['companyId'] ?? 0,
      branchId: json['branchId'] ?? 0,
    );
  }
}
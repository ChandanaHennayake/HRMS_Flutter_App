class AdminUserItem {
  final int userId;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;

  AdminUserItem({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      userId: json['userId'] ?? json['UserId'] ?? 0,
      username: json['username'] ?? json['Username'] ?? '',
      email: json['email'] ?? json['Email'] ?? '',
      fullName: json['fullName'] ?? json['FullName'] ?? '',
      role: json['role'] ?? json['Role'] ?? '',
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
    );
  }
}

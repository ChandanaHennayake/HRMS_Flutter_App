class AdminUserItem {
  final int userId;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final int? roleId;
  final int? employeeId;
  final bool isActive;
  final bool isDeleted;
  final String? clearPassword;

  AdminUserItem({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.roleId,
    this.employeeId,
    required this.isActive,
    this.isDeleted = false,
    this.clearPassword,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    final rId = json['roleId'] ?? json['RoleId'];
    String roleStr = (json['role'] ?? json['Role'] ?? '').toString().trim();
    if (roleStr.isEmpty) {
      if (rId == 1) {
        roleStr = 'Admin';
      } else if (rId == 2) {
        roleStr = 'Manager';
      } else if (rId == 3) {
        roleStr = 'HR';
      } else {
        roleStr = 'Employee';
      }
    }

    return AdminUserItem(
      userId: json['userId'] ?? json['UserId'] ?? 0,
      username: json['username'] ?? json['Username'] ?? '',
      email: json['email'] ?? json['Email'] ?? '',
      fullName: json['fullName'] ?? json['FullName'] ?? '',
      role: roleStr,
      roleId: rId is num ? rId.toInt() : null,
      employeeId: json['employeeId'] ?? json['EmployeeId'],
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
      isDeleted: json['isDeleted'] ?? json['IsDeleted'] ?? false,
      clearPassword: json['clearPassword'] ?? json['ClearPassword'] ?? json['password'] ?? json['passwordSalt'],
    );
  }
}

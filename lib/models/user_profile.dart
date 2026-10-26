class UserProfile {
  final int userId;
  final int? employeeId;
  final String username;
  final String fullName;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String role;
  final int roleId;

  final String? employeeCode;
  final String? departmentName;
  final String? designationName;
  final String? employmentTypeName;
  final String? joinedDate;
  final String? dateOfBirth;
  final String? gender;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? qualification;

  // Bank Details
  final String? bankName;
  final String? bankAccountNo;
  final String? bankBranch;

  // Change Request Flag
  final bool hasPendingChangeRequest;

  final int? branchId;
  final String? branchName;
  final double? branchLatitude;
  final double? branchLongitude;
  final int? geofenceRadiusMeters;

  const UserProfile({
    required this.userId,
    this.employeeId,
    required this.username,
    required this.fullName,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    required this.role,
    required this.roleId,
    this.employeeCode,
    this.departmentName,
    this.designationName,
    this.employmentTypeName,
    this.joinedDate,
    this.dateOfBirth,
    this.gender,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.qualification,
    this.bankName,
    this.bankAccountNo,
    this.bankBranch,
    this.hasPendingChangeRequest = false,
    this.branchId,
    this.branchName,
    this.branchLatitude,
    this.branchLongitude,
    this.geofenceRadiusMeters,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] is num ? (json['userId'] as num).toInt() : 0,
      employeeId:
          json['employeeId'] is num ? (json['employeeId'] as num).toInt() : null,
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? '',
      roleId: json['roleId'] is num ? (json['roleId'] as num).toInt() : 0,
      employeeCode: json['employeeCode'] as String?,
      departmentName: json['departmentName'] as String?,
      designationName: json['designationName'] as String?,
      employmentTypeName: json['employmentTypeName'] as String?,
      joinedDate: json['joinedDate'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      qualification: json['qualification'] as String?,
      bankName: json['bankName'] as String?,
      bankAccountNo: json['bankAccountNo'] as String?,
      bankBranch: json['bankBranch'] as String?,
      hasPendingChangeRequest: json['hasPendingChangeRequest'] as bool? ?? false,
      branchId:
          json['branchId'] is num ? (json['branchId'] as num).toInt() : null,
      branchName: json['branchName'] as String?,
      branchLatitude: json['branchLatitude'] is num
          ? (json['branchLatitude'] as num).toDouble()
          : null,
      branchLongitude: json['branchLongitude'] is num
          ? (json['branchLongitude'] as num).toDouble()
          : null,
      geofenceRadiusMeters: json['geofenceRadiusMeters'] is num
          ? (json['geofenceRadiusMeters'] as num).toInt()
          : null,
    );
  }
}

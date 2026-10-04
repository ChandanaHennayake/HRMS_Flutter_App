class CreateEmployeeRequest {
  final int companyId;
  final int branchId;
  final int designationId;
  final int roleId;

  final int employmentTypeId;

  final String employeeCode;
  final String firstName;
  final String? lastName;

  final String? email;
  final String? phone;

  final int? departmentId;

  final String? dateOfBirth;
  final String joinedDate;

  final String? gender;

  final String? addressLine1;
  final String? addressLine2;
  final String? city;

  final int? createdBy;

  final String username;
  final String password;

  // All master IDs are required and come from live lookups
  // (no hardcoded defaults).
  const CreateEmployeeRequest({
    required this.companyId,
    required this.branchId,
    required this.designationId,
    required this.roleId,
    required this.employmentTypeId,
    required this.employeeCode,
    required this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.departmentId,
    this.dateOfBirth,
    required this.joinedDate,
    this.gender,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.createdBy,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'branchId': branchId,
      'designationId': designationId,
      'roleId': roleId,

      'employmentTypeId': employmentTypeId,

      'employeeCode': employeeCode,
      'firstName': firstName,
      'lastName': lastName,

      'email': email,
      'phone': phone,

      'departmentId': departmentId,

      'dateOfBirth': dateOfBirth,
      'joinedDate': joinedDate,

      'gender': gender,

      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,

      'createdBy': createdBy,

      'username': username,
      'password': password,
    };
  }
}

/// Payload for PUT /api/Employee/{id} (matches UpdateEmployeeDto).
class UpdateEmployeeRequest {
  final int companyId;
  final int branchId;
  final String employeeCode;
  final String firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final int? departmentId;
  final int? designationId;
  final int? employmentTypeId;
  final String? dateOfBirth;
  final String joinedDate;
  final String? gender;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final bool isActive;
  final int? updatedBy;

  const UpdateEmployeeRequest({
    required this.companyId,
    required this.branchId,
    required this.employeeCode,
    required this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.departmentId,
    this.designationId,
    this.employmentTypeId,
    this.dateOfBirth,
    required this.joinedDate,
    this.gender,
    this.addressLine1,
    this.addressLine2,
    this.city,
    required this.isActive,
    this.updatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'branchId': branchId,
      'employeeCode': employeeCode,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'departmentId': departmentId,
      'designationId': designationId,
      'employmentTypeId': employmentTypeId,
      'dateOfBirth': dateOfBirth,
      'joinedDate': joinedDate,
      'gender': gender,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'isActive': isActive,
      'updatedBy': updatedBy,
    };
  }
}
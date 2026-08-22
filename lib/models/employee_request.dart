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

  const CreateEmployeeRequest({
    this.companyId = 1,
    this.branchId = 1,
    this.designationId = 1,
    this.roleId = 4,
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
      'companyId': 1,
      'branchId': 1,
      'designationId': 1,
      'roleId': 4,

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
class Employee {
  final int id;

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

  final DateTime? dateOfBirth;
  final DateTime? joinedDate;

  final String? gender;

  final String? addressLine1;
  final String? addressLine2;
  final String? city;

  final String? bankName;
  final String? bankAccountNo;
  final String? bankBranch;
  final String? qualification;

  final bool isActive;

  final int? userId;
  final String? username;
  final String? password;

  Employee({
    required this.id,
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
    this.joinedDate,
    this.gender,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.bankName,
    this.bankAccountNo,
    this.bankBranch,
    this.qualification,
    required this.isActive,
    this.userId,
    this.username,
    this.password,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory Employee.fromJson(
    Map<String, dynamic> json,
  ) {
    return Employee(
      id: _toInt(json['id']) ?? 0,

      companyId:
          _toInt(json['companyId']) ?? 0,

      branchId:
          _toInt(json['branchId']) ?? 0,

      employeeCode:
          json['employeeCode']?.toString() ?? '',

      firstName:
          json['firstName']?.toString() ?? '',

      lastName:
          json['lastName']?.toString(),

      email:
          json['email']?.toString(),

      phone:
          json['phone']?.toString(),

      departmentId:
          _toInt(json['departmentId']),

      designationId:
          _toInt(json['designationId']),

      employmentTypeId:
          _toInt(json['employmentTypeId']),

      dateOfBirth:
          _parseDate(json['dateOfBirth']),

      joinedDate:
          _parseDate(json['joinedDate']),

      gender:
          json['gender']?.toString(),

      addressLine1:
          json['addressLine1']?.toString(),

      addressLine2:
          json['addressLine2']?.toString(),

      city:
          json['city']?.toString(),

      bankName:
          json['bankName']?.toString(),

      bankAccountNo:
          json['bankAccountNo']?.toString(),

      bankBranch:
          json['bankBranch']?.toString(),

      qualification:
          json['qualification']?.toString(),

      isActive:
          _toBool(json['isActive']),
      userId:
          _toInt(json['userId'] ?? json['UserId']),
      username:
          json['username']?.toString() ?? json['Username']?.toString(),
      password:
          json['password']?.toString() ?? json['Password']?.toString() ?? json['clearPassword']?.toString(),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,

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

      'dateOfBirth':
          _formatDate(dateOfBirth),

      'joinedDate':
          _formatDate(joinedDate),

      'gender': gender,

      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,

      'bankName': bankName,
      'bankAccountNo': bankAccountNo,
      'bankBranch': bankBranch,
      'qualification': qualification,

      'isActive': isActive,
      'userId': userId,
      'username': username,
      'password': password,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  Employee copyWith({
    int? id,
    int? companyId,
    int? branchId,
    String? employeeCode,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    int? departmentId,
    int? designationId,
    int? employmentTypeId,
    DateTime? dateOfBirth,
    DateTime? joinedDate,
    String? gender,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? bankName,
    String? bankAccountNo,
    String? bankBranch,
    String? qualification,
    bool? isActive,
    int? userId,
    String? username,
    String? password,
  }) {
    return Employee(
      id: id ?? this.id,

      companyId:
          companyId ?? this.companyId,

      branchId:
          branchId ?? this.branchId,

      employeeCode:
          employeeCode ?? this.employeeCode,

      firstName:
          firstName ?? this.firstName,

      lastName:
          lastName ?? this.lastName,

      email:
          email ?? this.email,

      phone:
          phone ?? this.phone,

      departmentId:
          departmentId ?? this.departmentId,

      designationId:
          designationId ?? this.designationId,

      employmentTypeId:
          employmentTypeId ??
              this.employmentTypeId,

      dateOfBirth:
          dateOfBirth ?? this.dateOfBirth,

      joinedDate:
          joinedDate ?? this.joinedDate,

      gender:
          gender ?? this.gender,

      addressLine1:
          addressLine1 ?? this.addressLine1,

      addressLine2:
          addressLine2 ?? this.addressLine2,

      city:
          city ?? this.city,

      bankName:
          bankName ?? this.bankName,

      bankAccountNo:
          bankAccountNo ?? this.bankAccountNo,

      bankBranch:
          bankBranch ?? this.bankBranch,

      qualification:
          qualification ?? this.qualification,

      isActive:
          isActive ?? this.isActive,
      userId:
          userId ?? this.userId,
      username:
          username ?? this.username,
      password:
          password ?? this.password,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value == null) {
      return false;
    }

    return value.toString().toLowerCase() ==
        'true';
  }

  static DateTime? _parseDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }

  static String? _formatDate(
    DateTime? value,
  ) {
    if (value == null) {
      return null;
    }

    final year =
        value.year.toString().padLeft(4, '0');

    final month =
        value.month.toString().padLeft(2, '0');

    final day =
        value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // ============================================================
  // DISPLAY NAME
  // ============================================================

  String get fullName {
    final first =
        firstName.trim();

    final last =
        lastName?.trim() ?? '';

    if (last.isEmpty) {
      return first;
    }

    return '$first $last';
  }

  // ============================================================
  // DISPLAY STATUS
  // ============================================================

  String get statusText {
    return isActive
        ? 'Active'
        : 'Inactive';
  }
}
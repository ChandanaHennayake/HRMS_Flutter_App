class ProfileChangeRequest {
  final int id;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String? departmentName;
  final String? designationName;
  final int? userId;
  final int companyId;
  final int? branchId;
  final String? branchName;

  // Proposed Values
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? qualification;
  final String? bankName;
  final String? bankAccountNo;
  final String? bankBranch;

  // Current Values Snapshot
  final String? currentFirstName;
  final String? currentLastName;
  final String? currentPhone;
  final String? currentDateOfBirth;
  final String? currentGender;
  final String? currentAddressLine1;
  final String? currentAddressLine2;
  final String? currentCity;
  final String? currentQualification;
  final String? currentBankName;
  final String? currentBankAccountNo;
  final String? currentBankBranch;

  final int status; // 0 = Pending, 1 = Approved, 2 = Rejected, 3 = Cancelled
  final String statusText;
  final String? reason;
  final int? reviewedBy;
  final String? reviewerName;
  final String? reviewedAt;
  final String? reviewerComment;
  final String createdAt;
  final String? updatedAt;

  const ProfileChangeRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    this.departmentName,
    this.designationName,
    this.userId,
    required this.companyId,
    this.branchId,
    this.branchName,
    this.firstName,
    this.lastName,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.qualification,
    this.bankName,
    this.bankAccountNo,
    this.bankBranch,
    this.currentFirstName,
    this.currentLastName,
    this.currentPhone,
    this.currentDateOfBirth,
    this.currentGender,
    this.currentAddressLine1,
    this.currentAddressLine2,
    this.currentCity,
    this.currentQualification,
    this.currentBankName,
    this.currentBankAccountNo,
    this.currentBankBranch,
    required this.status,
    required this.statusText,
    this.reason,
    this.reviewedBy,
    this.reviewerName,
    this.reviewedAt,
    this.reviewerComment,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == 0;
  bool get isApproved => status == 1;
  bool get isRejected => status == 2;
  bool get isCancelled => status == 3;

  factory ProfileChangeRequest.fromJson(Map<String, dynamic> json) {
    return ProfileChangeRequest(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      employeeId: json['employeeId'] is num ? (json['employeeId'] as num).toInt() : 0,
      employeeName: json['employeeName'] as String? ?? '',
      employeeCode: json['employeeCode'] as String? ?? '',
      departmentName: json['departmentName'] as String?,
      designationName: json['designationName'] as String?,
      userId: json['userId'] is num ? (json['userId'] as num).toInt() : null,
      companyId: json['companyId'] is num ? (json['companyId'] as num).toInt() : 1,
      branchId: json['branchId'] is num ? (json['branchId'] as num).toInt() : null,
      branchName: json['branchName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      qualification: json['qualification'] as String?,
      bankName: json['bankName'] as String?,
      bankAccountNo: json['bankAccountNo'] as String?,
      bankBranch: json['bankBranch'] as String?,
      currentFirstName: json['currentFirstName'] as String?,
      currentLastName: json['currentLastName'] as String?,
      currentPhone: json['currentPhone'] as String?,
      currentDateOfBirth: json['currentDateOfBirth'] as String?,
      currentGender: json['currentGender'] as String?,
      currentAddressLine1: json['currentAddressLine1'] as String?,
      currentAddressLine2: json['currentAddressLine2'] as String?,
      currentCity: json['currentCity'] as String?,
      currentQualification: json['currentQualification'] as String?,
      currentBankName: json['currentBankName'] as String?,
      currentBankAccountNo: json['currentBankAccountNo'] as String?,
      currentBankBranch: json['currentBankBranch'] as String?,
      status: json['status'] is num ? (json['status'] as num).toInt() : 0,
      statusText: json['statusText'] as String? ?? 'Pending',
      reason: json['reason'] as String?,
      reviewedBy: json['reviewedBy'] is num ? (json['reviewedBy'] as num).toInt() : null,
      reviewerName: json['reviewerName'] as String?,
      reviewedAt: json['reviewedAt'] as String?,
      reviewerComment: json['reviewerComment'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

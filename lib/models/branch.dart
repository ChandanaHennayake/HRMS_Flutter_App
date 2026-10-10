class Branch {
  final int branchId;
  final int companyId;
  final String? branchCode;
  final String branchName;
  final String? address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final int geofenceRadiusMeters;
  final bool isActive;
  final DateTime? createdDate;

  Branch({
    required this.branchId,
    required this.companyId,
    this.branchCode,
    required this.branchName,
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
    required this.geofenceRadiusMeters,
    required this.isActive,
    this.createdDate,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchId: json['branchId'] ?? json['branchid'] ?? 0,
      companyId: json['companyId'] ?? json['companyid'] ?? 0,
      branchCode: json['branchCode'] ?? json['branchcode'],
      branchName: json['branchName'] ?? json['branchname'] ?? '',
      address: json['address'],
      phone: json['phone'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      geofenceRadiusMeters:
          json['geofenceRadiusMeters'] ?? json['geofenceRadius'] ?? 100,
      isActive: json['isActive'] ?? json['isactive'] ?? true,
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'companyId': companyId,
      'branchCode': branchCode,
      'branchName': branchName,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'geofenceRadiusMeters': geofenceRadiusMeters,
      'isActive': isActive,
    };
  }
}

class BranchManager {
  final int userBranchId;
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final int branchId;
  final String branchName;

  BranchManager({
    required this.userBranchId,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    required this.branchId,
    required this.branchName,
  });

  factory BranchManager.fromJson(Map<String, dynamic> json) {
    return BranchManager(
      userBranchId: json['userBranchId'] ?? 0,
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      branchId: json['branchId'] ?? 0,
      branchName: json['branchName'] ?? '',
    );
  }
}

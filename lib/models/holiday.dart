class Holiday {
  final int id;
  final int companyId;
  final String holidayDate; // "2026-11-12"
  final String holidayName;
  final String? description;
  final bool isActive;

  const Holiday({
    required this.id,
    required this.companyId,
    required this.holidayDate,
    required this.holidayName,
    this.description,
    required this.isActive,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      companyId:
          json['companyId'] is num ? (json['companyId'] as num).toInt() : 0,
      holidayDate: json['holidayDate'] as String? ?? '',
      holidayName: json['holidayName'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  DateTime? get parsedDate {
    try {
      return DateTime.parse(holidayDate);
    } catch (_) {
      return null;
    }
  }
}

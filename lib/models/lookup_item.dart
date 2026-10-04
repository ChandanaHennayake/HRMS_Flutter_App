/// Generic master lookup item returned by /api/Lookup/*.
class LookupItem {
  final int id;
  final String name;
  final String? code;
  final int? companyId;

  const LookupItem({
    required this.id,
    required this.name,
    this.code,
    this.companyId,
  });

  factory LookupItem.fromJson(Map<String, dynamic> json) {
    return LookupItem(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      companyId: _toInt(json['companyId']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'companyId': companyId,
      };

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
}

/// Aggregated lookup data needed by the employee form.
class EmployeeLookups {
  final List<LookupItem> departments;
  final List<LookupItem> designations;
  final List<LookupItem> employmentTypes;
  final List<LookupItem> roles;
  final List<LookupItem> branches;

  const EmployeeLookups({
    required this.departments,
    required this.designations,
    required this.employmentTypes,
    required this.roles,
    required this.branches,
  });
}

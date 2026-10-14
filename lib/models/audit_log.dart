class AuditLogItem {
  final int id;
  final int? userId;
  final String? userName;
  final String action;
  final String entityName;
  final String? entityId;
  final String? description;
  final String? oldValues;
  final String? newValues;
  final String? ipAddress;
  final String? userAgent;
  final String severity;
  final DateTime createdAt;

  AuditLogItem({
    required this.id,
    this.userId,
    this.userName,
    required this.action,
    required this.entityName,
    this.entityId,
    this.description,
    this.oldValues,
    this.newValues,
    this.ipAddress,
    this.userAgent,
    required this.severity,
    required this.createdAt,
  });

  factory AuditLogItem.fromJson(Map<String, dynamic> json) {
    return AuditLogItem(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int?,
      userName: json['userName'] as String?,
      action: json['action'] as String? ?? '',
      entityName: json['entityName'] as String? ?? '',
      entityId: json['entityId'] as String?,
      description: json['description'] as String?,
      oldValues: json['oldValues'] as String?,
      newValues: json['newValues'] as String?,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      severity: json['severity'] as String? ?? 'Info',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class PagedAuditResult {
  final List<AuditLogItem> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  PagedAuditResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedAuditResult.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List<dynamic>? ?? [];
    return PagedAuditResult(
      items: list.map((x) => AuditLogItem.fromJson(x as Map<String, dynamic>)).toList(),
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 30,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class AuditStats {
  final int totalLogs;
  final int securityCount;
  final int warningCount;
  final int criticalCount;
  final int infoCount;
  final Map<String, int> topActions;

  AuditStats({
    required this.totalLogs,
    required this.securityCount,
    required this.warningCount,
    required this.criticalCount,
    required this.infoCount,
    required this.topActions,
  });

  factory AuditStats.fromJson(Map<String, dynamic> json) {
    final actionsMap = <String, int>{};
    if (json['topActions'] != null && json['topActions'] is Map) {
      (json['topActions'] as Map).forEach((k, v) {
        actionsMap[k.toString()] = (v as num).toInt();
      });
    }

    return AuditStats(
      totalLogs: json['totalLogs'] as int? ?? 0,
      securityCount: json['securityCount'] as int? ?? 0,
      warningCount: json['warningCount'] as int? ?? 0,
      criticalCount: json['criticalCount'] as int? ?? 0,
      infoCount: json['infoCount'] as int? ?? 0,
      topActions: actionsMap,
    );
  }
}

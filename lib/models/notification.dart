class AppNotification {
  final int id;
  final int userId;
  final int? employeeId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? referenceType;
  final int? referenceId;

  AppNotification({
    required this.id,
    required this.userId,
    this.employeeId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.referenceType,
    this.referenceId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      employeeId: json['employeeId'] != null ? (json['employeeId'] as num).toInt() : null,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'Info',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] != null ? (json['referenceId'] as num).toInt() : null,
    );
  }

  AppNotification copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      userId: userId,
      employeeId: employeeId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      referenceType: referenceType,
      referenceId: referenceId,
    );
  }
}

class NotificationSummary {
  final int unreadCount;
  final int totalCount;

  NotificationSummary({
    required this.unreadCount,
    required this.totalCount,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      unreadCount: json['unreadCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }
}

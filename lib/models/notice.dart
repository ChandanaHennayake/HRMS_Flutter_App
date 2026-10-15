class SystemNotice {
  final int id;
  final String title;
  final String message;
  final String? imageUrl;
  final bool isActive;
  final String? targetAudience;
  final String? validUntil;
  final String createdAt;

  SystemNotice({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.isActive,
    this.targetAudience,
    this.validUntil,
    required this.createdAt,
  });

  factory SystemNotice.fromJson(Map<String, dynamic> json) {
    return SystemNotice(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      targetAudience: json['targetAudience']?.toString(),
      validUntil: json['validUntil']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'targetAudience': targetAudience,
      'validUntil': validUntil,
    };
  }
}

import '../../domain/entities/notification_item.dart';

/// Data model for notification API responses
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? data;
  final String? priority;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
    this.priority,
  });

  /// Convert from domain entity
  factory NotificationModel.fromEntity(NotificationItem entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      message: entity.message,
      type: entity.type.value,
      isRead: entity.isRead,
      createdAt: entity.createdAt.toIso8601String(),
      data: entity.data,
      priority: entity.priority.value,
    );
  }

  /// Convert to domain entity
  NotificationItem toEntity() {
    return NotificationItem(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: NotificationType.fromString(type),
      isRead: isRead,
      createdAt: DateTime.parse(createdAt),
      data: data,
      priority: priority != null
          ? NotificationPriority.fromString(priority!)
          : NotificationPriority.medium,
    );
  }

  /// Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'Info',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      data: json['data'],
      priority: json['priority'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt,
      'data': data,
      'priority': priority,
    };
  }
}

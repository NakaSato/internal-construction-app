import '../application/notification_bloc.dart' as bloc;
import '../domain/entities/notification.dart';
import '../domain/repositories/notification_repository.dart';

/// Adapts the domain NotificationRepository to the bloc NotificationRepository interface
class NotificationRepositoryAdapter implements bloc.NotificationRepository {
  final NotificationRepository _repository;

  NotificationRepositoryAdapter(this._repository);

  @override
  Future<List<AppNotification>> getNotifications() async {
    final result = await _repository.getNotifications();
    return result.fold((failure) => throw Exception(failure.message), (response) => response.items);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);
    result.fold((failure) => throw Exception(failure.message), (notification) => null);
  }

  @override
  Future<void> markAllAsRead() async {
    final result = await _repository.markAllAsRead();
    result.fold((failure) => throw Exception(failure.message), (bulkResult) => null);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final result = await _repository.deleteNotification(notificationId);
    result.fold((failure) => throw Exception(failure.message), (bulkResult) => null);
  }

  @override
  Future<int> getUnreadCount() async {
    final result = await _repository.getNotificationStatistics();
    return result.fold((failure) => throw Exception(failure.message), (stats) => stats.unreadCount);
  }
}

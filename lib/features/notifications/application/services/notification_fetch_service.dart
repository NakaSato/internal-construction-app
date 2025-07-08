import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notifications_response.dart';
import '../../domain/repositories/notification_repository.dart';
import '../utils/notification_helper.dart';

/// Manages notification fetch operations
class NotificationFetchService {
  final NotificationRepository _repository;
  final NotificationHelper _helper;

  NotificationFetchService(this._repository, this._helper);

  /// Fetch notifications with optional filtering and pagination
  Future<Either<Failure, NotificationsResponse>> fetchNotifications({
    NotificationsQuery? query,
    bool refreshCache = false,
  }) async {
    // Use default query if none provided
    final notificationsQuery = query ?? const NotificationsQuery(includeSummary: true);
    return await _repository.getNotifications(query: notificationsQuery);
  }

  /// Fetch notification statistics
  Future<Either<Failure, NotificationCountStatistics>> fetchStatistics() async {
    return await _repository.getNotificationStatistics();
  }

  /// Fetch a single notification by ID
  Future<Either<Failure, AppNotification>> fetchNotificationById(String id) async {
    return await _repository.getNotificationById(id);
  }

  /// Fetch notifications by category
  Future<Either<Failure, NotificationsResponse>> fetchByCategory(String category, {int page = 1}) async {
    final query = NotificationsQuery(category: category, pageNumber: page, pageSize: 20);
    return await fetchNotifications(query: query);
  }

  /// Fetch unread notifications
  Future<Either<Failure, NotificationsResponse>> fetchUnreadNotifications({int page = 1}) async {
    final query = NotificationsQuery(isRead: false, pageNumber: page, pageSize: 20, includeSummary: true);
    return await fetchNotifications(query: query);
  }

  /// Fetch high priority notifications
  Future<Either<Failure, NotificationsResponse>> fetchHighPriorityNotifications({int page = 1}) async {
    final query = NotificationsQuery(priority: NotificationPriority.high, pageNumber: page, pageSize: 10);
    return await fetchNotifications(query: query);
  }

  /// Fetch critical notifications
  Future<Either<Failure, NotificationsResponse>> fetchCriticalNotifications() async {
    final query = NotificationsQuery(
      priority: NotificationPriority.critical,
      pageSize: 100, // Get all critical notifications
      includeSummary: false,
    );
    return await fetchNotifications(query: query);
  }
}

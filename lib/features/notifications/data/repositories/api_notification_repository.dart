import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/notifications_response.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

/// Base API repository for notifications without real-time capabilities
@Injectable()
class ApiNotificationRepository implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  
  ApiNotificationRepository(this._remoteDataSource);

  @override
  Future<Either<Failure, NotificationsResponse>> getNotifications({
    NotificationsQuery query = const NotificationsQuery(),
  }) async {
    try {
      final response = await _remoteDataSource.getNotifications(query: query);
      return Right(response);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppNotification>> getNotificationById(String notificationId) async {
    try {
      final notification = await _remoteDataSource.getNotificationById(notificationId);
      return Right(notification);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppNotification>> markAsRead(String notificationId) async {
    try {
      final notification = await _remoteDataSource.markAsRead(notificationId);
      return Right(notification);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> markMultipleAsRead(List<String> notificationIds) async {
    try {
      final result = await _remoteDataSource.markMultipleAsRead(notificationIds);
      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> markAllAsRead() async {
    try {
      final result = await _remoteDataSource.markAllAsRead();
      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      await _remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> deleteMultipleNotifications(List<String> notificationIds) async {
    try {
      final result = await _remoteDataSource.deleteMultipleNotifications(notificationIds);
      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationCountStatistics>> getNotificationStatistics() async {
    try {
      final stats = await _remoteDataSource.getNotificationStatistics();
      return Right(stats);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, NotificationSettings>> getNotificationSettings() async {
    try {
      final settings = await _remoteDataSource.getNotificationSettings();
      return Right(settings);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, NotificationSettings>> updateNotificationSettings(
    NotificationSettings settings,
  ) async {
    try {
      final updatedSettings = await _remoteDataSource.updateNotificationSettings(settings);
      return Right(updatedSettings);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Stream<AppNotification> getNotificationStream() {
    // Not implemented in the base repository
    throw UnimplementedError('Real-time notifications not available in base repository');
  }
  
  @override
  Stream<int> getUnreadCountStream() {
    // Not implemented in the base repository
    throw UnimplementedError('Real-time unread count not available in base repository');
  }
}

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/mixins/realtime_api_mixin.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/realtime_notification_update.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/notifications_response.dart';
import '../../domain/repositories/notification_repository.dart';

/// Implementation of NotificationRepository with real-time capabilities
@Injectable(env: [Environment.test]) // Only use in test environment
class NotificationRepositoryImpl with RealtimeApiMixin implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  final StreamController<AppNotification> _notificationStreamController = StreamController<AppNotification>.broadcast();

  final StreamController<int> _unreadCountStreamController = StreamController<int>.broadcast();

  NotificationRepositoryImpl(this._remoteDataSource) {
    // Start listening to real-time notification updates
    _initializeRealTimeUpdates();
  }

  @override
  String get endpointName => 'notifications';

  void _initializeRealTimeUpdates() {
    startRealtimeUpdates<RealtimeNotificationUpdate>(
      onUpdate: _handleRealtimeUpdate,
      onError: (error) {
        // Log error but don't propagate - streams should be resilient
        print('❌ Notification real-time error: $error');
      },
    );

    // Request initial unread count
    requestInitialData();
  }

  void _handleRealtimeUpdate(RealtimeNotificationUpdate update) {
    switch (update.updateType) {
      case RealtimeNotificationUpdateType.added:
      case RealtimeNotificationUpdateType.updated:
        if (update.notification != null) {
          _notificationStreamController.add(update.notification!);
        }
        break;
      case RealtimeNotificationUpdateType.countChanged:
        if (update.unreadCount != null) {
          _unreadCountStreamController.add(update.unreadCount!);
        }
        break;
      case RealtimeNotificationUpdateType.read:
        // We don't need to handle this directly as it will be followed by a countChanged update
        break;
      case RealtimeNotificationUpdateType.deleted:
        // The backend will handle this and send appropriate updates
        break;
    }
  }

  @override
  Future<Either<Failure, NotificationsResponse>> getNotifications({
    NotificationsQuery query = const NotificationsQuery(),
  }) async {
    try {
      final response = await _remoteDataSource.getNotifications(query: query);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppNotification>> getNotificationById(String notificationId) async {
    try {
      final notification = await _remoteDataSource.getNotificationById(notificationId);
      return Right(notification);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppNotification>> markAsRead(String notificationId) async {
    try {
      final notification = await _remoteDataSource.markAsRead(notificationId);
      return Right(notification);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> markMultipleAsRead(List<String> notificationIds) async {
    try {
      final result = await _remoteDataSource.markMultipleAsRead(notificationIds);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> markAllAsRead() async {
    try {
      final result = await _remoteDataSource.markAllAsRead();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      await _remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> deleteMultipleNotifications(List<String> notificationIds) async {
    try {
      final result = await _remoteDataSource.deleteMultipleNotifications(notificationIds);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationCountStatistics>> getNotificationStatistics() async {
    try {
      final statistics = await _remoteDataSource.getNotificationStatistics();
      // Always send updated unread count to stream
      _unreadCountStreamController.add(statistics.unreadCount);
      return Right(statistics);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationSettings>> getNotificationSettings() async {
    try {
      final settings = await _remoteDataSource.getNotificationSettings();
      return Right(settings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationSettings>> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final updatedSettings = await _remoteDataSource.updateNotificationSettings(settings);
      return Right(updatedSettings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<AppNotification> getNotificationStream() {
    return _notificationStreamController.stream;
  }

  @override
  Stream<int> getUnreadCountStream() {
    return _unreadCountStreamController.stream;
  }

  void dispose() {
    // Clean up resources
    disposeRealtime();
    _notificationStreamController.close();
    _unreadCountStreamController.close();
  }
}

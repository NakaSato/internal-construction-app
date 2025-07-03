import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/entities/notification_statistics.dart';
import '../../domain/entities/notification_pagination.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

/// Implementation of notification repository
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, NotificationListResult>> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? unreadOnly,
    NotificationType? type,
  }) async {
    try {
      final response = await remoteDataSource.getNotifications(
        page: page,
        pageSize: pageSize,
        unreadOnly: unreadOnly,
        type: type?.value,
      );

      final notifications = response.data
          .map((model) => model.toEntity())
          .toList();

      NotificationPagination? pagination;
      if (response.pagination != null) {
        final paginationModel = response.pagination!;
        pagination = NotificationPagination(
          page: paginationModel.page,
          pageSize: paginationModel.pageSize,
          totalCount: paginationModel.totalCount,
          totalPages: paginationModel.totalPages,
        );
      }

      return Right(
        NotificationListResult(
          notifications: notifications,
          pagination: pagination,
        ),
      );
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationCount>> getNotificationCount() async {
    try {
      final model = await remoteDataSource.getNotificationCount();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationStatistics>>
  getNotificationStatistics() async {
    try {
      final model = await remoteDataSource.getNotificationStatistics();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(
    String notificationId,
  ) async {
    try {
      await remoteDataSource.markNotificationAsRead(notificationId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllNotificationsAsRead() async {
    try {
      await remoteDataSource.markAllNotificationsAsRead();
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendTestNotification({
    required String message,
    NotificationType type = NotificationType.info,
  }) async {
    try {
      await remoteDataSource.sendTestNotification(
        message: message,
        type: type.value,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendAnnouncement({
    required String message,
    NotificationPriority priority = NotificationPriority.medium,
    String targetAudience = 'All',
  }) async {
    try {
      await remoteDataSource.sendAnnouncement(
        message: message,
        priority: priority.value,
        targetAudience: targetAudience,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> testSignalR({
    required String message,
    String? targetUserId,
  }) async {
    try {
      await remoteDataSource.testSignalR(
        message: message,
        targetUserId: targetUserId,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SignalRConnectionInfo>> getConnectionInfo() async {
    try {
      final model = await remoteDataSource.getConnectionInfo();
      return Right(
        SignalRConnectionInfo(
          hubUrl: model.hubUrl,
          isEnabled: model.isEnabled,
          activeConnections: model.activeConnections,
          availableGroups: model.availableGroups,
        ),
      );
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationItem>> getNotificationById(
    String notificationId,
  ) async {
    try {
      final model = await remoteDataSource.getNotificationById(notificationId);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}

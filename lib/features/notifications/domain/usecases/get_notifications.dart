import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_item.dart';
import '../repositories/notification_repository.dart';

/// Use case for getting paginated notifications
class GetNotificationsUseCase
    implements UseCase<NotificationListResult, GetNotificationsParams> {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationListResult>> call(
    GetNotificationsParams params,
  ) async {
    return await repository.getNotifications(
      page: params.page,
      pageSize: params.pageSize,
      unreadOnly: params.unreadOnly,
      type: params.type,
    );
  }
}

/// Parameters for getting notifications
class GetNotificationsParams {
  final int page;
  final int pageSize;
  final bool? unreadOnly;
  final NotificationType? type;

  const GetNotificationsParams({
    this.page = 1,
    this.pageSize = 20,
    this.unreadOnly,
    this.type,
  });
}

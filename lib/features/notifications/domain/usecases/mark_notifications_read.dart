import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

/// Use case for marking a notification as read
class MarkNotificationAsReadUseCase implements UseCase<void, String> {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.markNotificationAsRead(notificationId);
  }
}

/// Use case for marking all notifications as read
class MarkAllNotificationsAsReadUseCase implements UseCase<void, NoParams> {
  final NotificationRepository repository;

  MarkAllNotificationsAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.markAllNotificationsAsRead();
  }
}

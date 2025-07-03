import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_statistics.dart';
import '../repositories/notification_repository.dart';

/// Use case for getting notification count
class GetNotificationCountUseCase
    implements UseCase<NotificationCount, NoParams> {
  final NotificationRepository repository;

  GetNotificationCountUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationCount>> call(NoParams params) async {
    return await repository.getNotificationCount();
  }
}

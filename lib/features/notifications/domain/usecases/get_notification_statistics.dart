import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_statistics.dart';
import '../repositories/notification_repository.dart';

/// Use case for getting detailed notification statistics
class GetNotificationStatisticsUseCase
    implements UseCase<NotificationStatistics, NoParams> {
  final NotificationRepository repository;

  GetNotificationStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationStatistics>> call(NoParams params) async {
    return await repository.getNotificationStatistics();
  }
}

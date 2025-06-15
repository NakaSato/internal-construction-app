import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/work_request.dart';
import '../../domain/usecases/get_pending_approvals_usecase.dart';

// States
abstract class PendingApprovalsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PendingApprovalsInitial extends PendingApprovalsState {}

class PendingApprovalsLoading extends PendingApprovalsState {}

class PendingApprovalsLoaded extends PendingApprovalsState {
  PendingApprovalsLoaded(this.requests);

  final List<WorkRequest> requests;

  @override
  List<Object> get props => [requests];
}

class PendingApprovalsError extends PendingApprovalsState {
  PendingApprovalsError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

// Cubit
class PendingApprovalsCubit extends Cubit<PendingApprovalsState> {
  PendingApprovalsCubit(this._getPendingApprovalsUseCase)
    : super(PendingApprovalsInitial());

  final GetPendingApprovalsUseCase _getPendingApprovalsUseCase;

  Future<void> loadPendingApprovals() async {
    emit(PendingApprovalsLoading());

    final result = await _getPendingApprovalsUseCase();

    result.fold(
      (failure) => emit(PendingApprovalsError(failure.message)),
      (requests) => emit(PendingApprovalsLoaded(requests)),
    );
  }

  Future<void> refreshApprovals() async {
    await loadPendingApprovals();
  }
}

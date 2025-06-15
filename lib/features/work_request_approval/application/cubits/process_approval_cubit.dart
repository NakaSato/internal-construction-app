import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/approval_requests.dart';
import '../../domain/usecases/process_approval_usecase.dart';

// States
abstract class ProcessApprovalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProcessApprovalInitial extends ProcessApprovalState {}

class ProcessApprovalLoading extends ProcessApprovalState {}

class ProcessApprovalSuccess extends ProcessApprovalState {}

class ProcessApprovalError extends ProcessApprovalState {
  ProcessApprovalError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

// Cubit
class ProcessApprovalCubit extends Cubit<ProcessApprovalState> {
  ProcessApprovalCubit(this._processApprovalUseCase)
    : super(ProcessApprovalInitial());

  final ProcessApprovalUseCase _processApprovalUseCase;

  Future<void> processApproval(
    String requestId,
    ApprovalAction action, {
    String? comments,
    String? rejectionReason,
  }) async {
    emit(ProcessApprovalLoading());

    final request = ProcessApprovalRequest(
      action: action,
      comments: comments,
      rejectionReason: rejectionReason,
    );

    final result = await _processApprovalUseCase(requestId, request);

    result.fold(
      (failure) => emit(ProcessApprovalError(failure.message)),
      (_) => emit(ProcessApprovalSuccess()),
    );
  }

  void reset() {
    emit(ProcessApprovalInitial());
  }
}

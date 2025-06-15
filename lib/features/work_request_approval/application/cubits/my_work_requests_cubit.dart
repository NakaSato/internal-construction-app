import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/work_request.dart';
import '../../domain/usecases/get_my_work_requests_usecase.dart';

// States
abstract class MyWorkRequestsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MyWorkRequestsInitial extends MyWorkRequestsState {}

class MyWorkRequestsLoading extends MyWorkRequestsState {}

class MyWorkRequestsLoaded extends MyWorkRequestsState {
  MyWorkRequestsLoaded(this.requests);

  final List<WorkRequest> requests;

  @override
  List<Object> get props => [requests];
}

class MyWorkRequestsError extends MyWorkRequestsState {
  MyWorkRequestsError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

// Cubit
class MyWorkRequestsCubit extends Cubit<MyWorkRequestsState> {
  MyWorkRequestsCubit(this._getMyWorkRequestsUseCase)
    : super(MyWorkRequestsInitial());

  final GetMyWorkRequestsUseCase _getMyWorkRequestsUseCase;

  Future<void> loadMyWorkRequests() async {
    emit(MyWorkRequestsLoading());

    final result = await _getMyWorkRequestsUseCase();

    result.fold(
      (failure) => emit(MyWorkRequestsError(failure.message)),
      (requests) => emit(MyWorkRequestsLoaded(requests)),
    );
  }

  Future<void> refreshRequests() async {
    await loadMyWorkRequests();
  }
}

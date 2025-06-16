import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/project_detail.dart';
import '../../domain/usecases/get_project_detail.dart';

part 'project_detail_state.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  ProjectDetailCubit(this._getProjectDetail) : super(ProjectDetailInitial());

  final GetProjectDetail _getProjectDetail;

  Future<void> loadProjectDetail(String projectId) async {
    emit(ProjectDetailLoading());

    final result = await _getProjectDetail(
      GetProjectDetailParams(projectId: projectId),
    );

    result.fold(
      (failure) => emit(ProjectDetailError(failure.message)),
      (projectDetail) => emit(ProjectDetailLoaded(projectDetail)),
    );
  }

  void resetState() {
    emit(ProjectDetailInitial());
  }
}

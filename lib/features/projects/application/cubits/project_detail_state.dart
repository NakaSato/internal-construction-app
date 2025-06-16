part of 'project_detail_cubit.dart';

abstract class ProjectDetailState extends Equatable {
  const ProjectDetailState();

  @override
  List<Object?> get props => [];
}

class ProjectDetailInitial extends ProjectDetailState {}

class ProjectDetailLoading extends ProjectDetailState {}

class ProjectDetailLoaded extends ProjectDetailState {
  const ProjectDetailLoaded(this.projectDetail);

  final ProjectDetail projectDetail;

  @override
  List<Object?> get props => [projectDetail];
}

class ProjectDetailError extends ProjectDetailState {
  const ProjectDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

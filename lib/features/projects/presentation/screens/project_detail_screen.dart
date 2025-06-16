import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../application/cubits/project_detail_cubit.dart';
import '../widgets/project_detail_content.dart';
import '../widgets/project_detail_loading.dart';
import '../widgets/project_detail_error.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<ProjectDetailCubit>()..loadProjectDetail(projectId),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
          builder: (context, state) {
            if (state is ProjectDetailLoading) {
              return const ProjectDetailLoading();
            } else if (state is ProjectDetailLoaded) {
              return ProjectDetailContent(projectDetail: state.projectDetail);
            } else if (state is ProjectDetailError) {
              return ProjectDetailError(
                message: state.message,
                onRetry: () => context
                    .read<ProjectDetailCubit>()
                    .loadProjectDetail(projectId),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton:
            BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
              builder: (context, state) {
                if (state is ProjectDetailLoaded) {
                  return FloatingActionButton.extended(
                    onPressed: () {
                      // Add new task or report
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
      ),
    );
  }
}

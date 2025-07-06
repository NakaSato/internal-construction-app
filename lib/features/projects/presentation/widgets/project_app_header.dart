import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_header.dart';
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../application/project_bloc.dart';

/// Specialized app header for the project list screen
class ProjectAppHeader extends StatelessWidget {
  const ProjectAppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;

        if (user == null) {
          return Container(
            height: 120,
            color: Theme.of(context).colorScheme.primary,
            child: const Center(
              child: Text('Please log in to continue', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          );
        }

        return BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, projectState) {
            String subtitle = 'Manage solar installation projects';
            if (projectState is ProjectsLoaded) {
              final count = projectState.projectsResponse.totalCount;
              subtitle = 'Manage solar installation projects • $count project${count != 1 ? 's' : ''}';
            }
            return AppHeader(title: 'Project Management', subtitle: subtitle, user: user);
          },
        );
      },
    );
  }
}

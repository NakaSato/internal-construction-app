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
            int projectCount = 0;

            if (projectState is ProjectsLoaded) {
              projectCount = projectState.projectsResponse.totalCount;
              subtitle = 'Manage solar installation projects';
            }

            return Stack(
              children: [
                // Base AppHeader
                AppHeader(title: 'Project Management', subtitle: subtitle, user: user),

                // Project count badge overlay
                if (projectState is ProjectsLoaded)
                  Positioned(
                    top: 54,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bar_chart_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            '$projectCount Total Project${projectCount != 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';

/// Floating action button for creating new projects
/// Only visible to users with appropriate permissions
class ProjectFloatingActionButton extends StatelessWidget {
  const ProjectFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final canCreateProject = user?.roleName == 'Admin' || user?.roleName == 'Project Manager';

        if (!canCreateProject) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => context.push('/projects/create'),
          icon: const Icon(Icons.add),
          label: const Text('New Project'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        );
      },
    );
  }
}

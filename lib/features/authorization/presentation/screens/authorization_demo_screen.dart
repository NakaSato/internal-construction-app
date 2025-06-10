import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/authorization_bloc.dart';
import '../../application/authorization_event.dart';
import '../../application/authorization_state.dart';
import '../widgets/authorization_widgets.dart';
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';

/// Demo screen showcasing authorization features
class AuthorizationDemoScreen extends StatelessWidget {
  const AuthorizationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authorization Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(
              child: Text('Please log in to see authorization features'),
            );
          }

          final user = authState.user;

          return BlocListener<AuthorizationBloc, AuthorizationState>(
            listener: (context, state) {
              if (state is AuthorizationLoaded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Authorization data loaded successfully'),
                  ),
                );
              } else if (state is AuthorizationFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Authorization error: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoCard(user),
                  const SizedBox(height: 20),
                  _buildAuthorizationControls(context, user),
                  const SizedBox(height: 20),
                  _buildRoleBasedWidgets(context, user),
                  const SizedBox(height: 20),
                  _buildPermissionBasedWidgets(context, user),
                  const SizedBox(height: 20),
                  _buildAdvancedAuthorizationWidgets(context, user),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoCard(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Name: ${user.fullName}'),
            Text('Email: ${user.email}'),
            Text('Role: ${user.roleName}'),
            Text('Status: ${user.isActive ? "Active" : "Inactive"}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizationControls(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authorization Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AuthorizationBloc>().add(
                  AuthorizationLoadRequested(user: user),
                );
              },
              child: const Text('Load User Authorization'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.read<AuthorizationBloc>().add(
                  AuthorizationPermissionCheckRequested(
                    user: user,
                    resource: 'user',
                    action: 'view',
                  ),
                );
              },
              child: const Text('Check User Read Permission'),
            ),
            const SizedBox(height: 8),
            BlocBuilder<AuthorizationBloc, AuthorizationState>(
              builder: (context, state) {
                if (state is AuthorizationLoading) {
                  return const CircularProgressIndicator();
                } else if (state is AuthorizationPermissionChecked) {
                  return Text(
                    'Authorization Status: ${state.hasPermission ? "Authorized" : "Not Authorized"}',
                    style: TextStyle(
                      color: state.hasPermission ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else if (state is AuthorizationFailure) {
                  return Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBasedWidgets(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Role-Based Widgets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AdminOnlyWidget(
              user: user,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Admin Only Content'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ManagerOnlyWidget(
              user: user,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.manage_accounts, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Manager Only Content'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedAccessWidget(
              user: user,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Elevated Access Content (Admin/Manager)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionBasedWidgets(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permission-Based Widgets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PermissionGate(
              user: user,
              resource: 'calendar',
              action: 'edit',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_calendar, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Calendar Write Access'),
                  ],
                ),
              ),
              fallback: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.block, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('No Calendar Write Access'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            PermissionBuilder(
              user: user,
              resource: 'image',
              action: 'upload',
              builder: (context, hasPermission) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasPermission
                        ? Colors.purple.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasPermission ? Icons.upload : Icons.block,
                        color: hasPermission ? Colors.purple : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasPermission
                            ? 'Image Upload Available'
                            : 'No Upload Permission',
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedAuthorizationWidgets(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Authorization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ConditionalWidget(
              user: user,
              resource: 'system',
              action: 'admin',
              enabledChild: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user, color: Colors.cyan),
                    SizedBox(width: 8),
                    Text('Complex Condition: Active Admin'),
                  ],
                ),
              ),
              disabledChild: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.block, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Not Admin or Inactive'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'User Role Information:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Role: ${user.roleName}'),
            Text('Display Name: ${_formatRoleName(user.roleName)}'),
            Text(
              'Is Technician: ${user.roleName.toLowerCase() == 'technician'}',
            ),
            Text('Is Active: ${user.isActive}'),
          ],
        ),
      ),
    );
  }

  String _formatRoleName(String roleName) {
    return roleName
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}

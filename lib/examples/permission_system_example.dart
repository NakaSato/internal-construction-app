import 'package:flutter/material.dart';
import '../core/permissions/domain/entities/permission.dart';
import '../core/permissions/domain/services/permission_service.dart';
import '../core/permissions/infrastructure/repositories/mock_permission_repository.dart';
import '../core/permissions/presentation/widgets/permission_widgets.dart';

/// Example demonstration of the permission system usage
/// This shows how to integrate permission checks throughout your app
class PermissionSystemExample extends StatefulWidget {
  const PermissionSystemExample({super.key});

  @override
  State<PermissionSystemExample> createState() => _PermissionSystemExampleState();
}

class _PermissionSystemExampleState extends State<PermissionSystemExample> {
  late final PermissionService _permissionService;
  UserPermissionContext? _userContext;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _permissionService = PermissionService(MockPermissionRepository());
    _loadUserPermissions();
  }

  Future<void> _loadUserPermissions() async {
    try {
      final context = await _permissionService.getUserPermissionContext();
      setState(() {
        _userContext = context;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading permissions: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userContext == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load user permissions')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission System Demo'),
        subtitle: Text('Role: ${_userContext!.role.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoCard(),
            const SizedBox(height: 16),
            _buildPermissionExamples(),
            const SizedBox(height: 16),
            _buildConditionalWidgets(),
          ],
        ),
      ),
      floatingActionButton: PermissionFloatingActionButton(
        permission: const PermissionCheck(resource: 'project', action: 'create'),
        onPressed: () => _showCreateDialog('Project'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    final user = _userContext!.user;
    final role = _userContext!.role;
    final permissions = _userContext!.permissions;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Name: ${user.displayName}'),
            Text('Email: ${user.email}'),
            Text('Role: ${role.name}'),
            Text('Permissions: ${permissions.length}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: permissions.map((permission) {
                return Chip(
                  label: Text(
                    '${permission.resource}:${permission.action}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permission Examples',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Project permissions
            _buildPermissionSection('Project Management', [
              PermissionCheck(resource: 'project', action: 'view'),
              PermissionCheck(resource: 'project', action: 'create'),
              PermissionCheck(resource: 'project', action: 'update'),
              PermissionCheck(resource: 'project', action: 'delete'),
            ]),
            
            const SizedBox(height: 12),
            
            // Report permissions
            _buildPermissionSection('Report Management', [
              PermissionCheck(resource: 'report', action: 'view'),
              PermissionCheck(resource: 'report', action: 'create'),
              PermissionCheck(resource: 'report', action: 'approve'),
              PermissionCheck(resource: 'report', action: 'delete'),
            ]),
            
            const SizedBox(height: 12),
            
            // User permissions
            _buildPermissionSection('User Management', [
              PermissionCheck(resource: 'user', action: 'view'),
              PermissionCheck(resource: 'user', action: 'create'),
              PermissionCheck(resource: 'user', action: 'update'),
              PermissionCheck(resource: 'user', action: 'manage'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection(String title, List<PermissionCheck> permissions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: permissions.map((permission) {
            return PermissionBuilder(
              permission: permission,
              builder: (context, hasPermission) {
                return Chip(
                  label: Text(permission.action),
                  backgroundColor: hasPermission 
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: hasPermission ? Colors.green : Colors.red,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConditionalWidgets() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conditional UI Elements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Permission-aware buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PermissionButton(
                  permission: const PermissionCheck(resource: 'project', action: 'create'),
                  onPressed: () => _showCreateDialog('Project'),
                  child: const Text('Create Project'),
                ),
                PermissionButton(
                  permission: const PermissionCheck(resource: 'report', action: 'create'),
                  onPressed: () => _showCreateDialog('Report'),
                  child: const Text('Create Report'),
                ),
                PermissionButton(
                  permission: const PermissionCheck(resource: 'user', action: 'manage'),
                  onPressed: () => _showCreateDialog('User'),
                  child: const Text('Manage Users'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Permission-aware list items
            PermissionListTile(
              permission: const PermissionCheck(resource: 'report', action: 'approve'),
              leading: const Icon(Icons.approval),
              title: const Text('Approve Reports'),
              subtitle: const Text('Review and approve submitted reports'),
              onTap: () => _showDialog('Report Approval'),
            ),
            
            PermissionListTile(
              permission: const PermissionCheck(resource: 'user', action: 'view'),
              leading: const Icon(Icons.people),
              title: const Text('View Users'),
              subtitle: const Text('Browse system users'),
              onTap: () => _showDialog('User List'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create $type'),
        content: Text('This would open the create $type form.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('This would open the $title interface.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Example of how to use the permission system in your own widgets
class MyCustomWidget extends StatelessWidget {
  const MyCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Show widget only if user has permission
        PermissionWidget(
          permission: const PermissionCheck(resource: 'project', action: 'view'),
          child: const Card(
            child: ListTile(
              title: Text('Project Information'),
              subtitle: Text('View project details and status'),
            ),
          ),
        ),
        
        // Alternative widget when permission is denied
        PermissionWidget(
          permission: const PermissionCheck(resource: 'admin', action: 'access'),
          child: const Card(
            child: ListTile(
              title: Text('Admin Panel'),
              subtitle: Text('Administrative functions'),
            ),
          ),
          fallback: const Card(
            child: ListTile(
              title: Text('Access Denied'),
              subtitle: Text('You don\'t have admin permissions'),
              leading: Icon(Icons.lock),
            ),
          ),
        ),
      ],
    );
  }
}

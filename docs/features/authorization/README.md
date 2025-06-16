# Authorization Feature

## Overview
The authorization feature handles role-based access control, permissions, and authorization policies for different user types within the application.

## Architecture Components

### Domain Layer
- **Entities**: Permission, Role, UserRole
- **Repositories**: AuthorizationRepository
- **Use Cases**: CheckPermissionUseCase, GetUserRolesUseCase

### Application Layer
- **State Management**: AuthorizationBloc/Cubit
- **Events/States**: AuthorizationEvent, AuthorizationState

### Infrastructure Layer
- **Data Sources**: AuthorizationRemoteDataSource, AuthorizationLocalDataSource
- **Models**: PermissionModel, RoleModel, UserRoleModel
- **Repository Implementation**: AuthorizationRepositoryImpl

### Presentation Layer
- **Screens**: RoleManagementScreen
- **Widgets**: PermissionControlWidget, RoleAssignmentDialog
- **Pages**: AuthorizationSettingsPage

## Usage Examples

```dart
// Example: Check if a user has a specific permission
final hasPermission = await checkPermissionUseCase(
  CheckPermissionParams(
    userId: currentUser.id,
    permission: Permission.manageProjects,
  ),
);

if (hasPermission) {
  // Allow user to perform action
} else {
  // Show unauthorized message
}
```

## API Integration

The authorization feature integrates with the following endpoints:
- `GET /api/users/{id}/roles` - Get user's roles
- `GET /api/permissions` - Get available permissions
- `POST /api/users/{id}/roles` - Assign role to user

## Related Features
- [Authentication](/docs/features/authentication/README.md)
- [Profile](/docs/features/profile/README.md)

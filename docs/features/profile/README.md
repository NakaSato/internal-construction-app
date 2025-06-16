# Profile Feature

## Overview
The profile feature manages user profile information, settings, and preferences. It allows users to view and update their personal information, change their password, and configure application settings.

## Architecture Components

### Domain Layer
- **Entities**: UserProfile, ProfileSettings, UserPreference
- **Repositories**: ProfileRepository
- **Use Cases**: GetUserProfileUseCase, UpdateProfileUseCase, ChangePasswordUseCase, UpdatePreferencesUseCase

### Application Layer
- **State Management**: ProfileBloc/Cubit
- **Events/States**: ProfileEvent, ProfileState

### Infrastructure Layer
- **Data Sources**: ProfileRemoteDataSource, ProfileLocalDataSource
- **Models**: UserProfileModel, ProfileSettingsModel
- **Repository Implementation**: ProfileRepositoryImpl

### Presentation Layer
- **Screens**: ProfileScreen, EditProfileScreen, SettingsScreen
- **Widgets**: ProfileHeader, AvatarPicker, PreferenceToggle, SettingsSection
- **Pages**: ProfilePage, SettingsPage

## Usage Examples

```dart
// Example: Update user profile information
final result = await updateProfileUseCase(
  UpdateProfileParams(
    userProfile: UserProfile(
      displayName: 'Jane Smith',
      email: 'jane.smith@example.com',
      jobTitle: 'Senior Engineer',
      avatarUrl: 'https://example.com/avatar.jpg',
      phone: '+1 234 567 8901',
    ),
  ),
);

result.fold(
  (failure) => handleFailure(failure),
  (updatedProfile) => showSuccessMessage('Profile updated successfully'),
);
```

## API Integration

The profile feature integrates with the following endpoints:
- `GET /api/users/{id}/profile` - Get user profile
- `PUT /api/users/{id}/profile` - Update user profile
- `PUT /api/users/{id}/password` - Change password
- `GET /api/users/{id}/preferences` - Get user preferences
- `PUT /api/users/{id}/preferences` - Update user preferences

## Related Features
- [Authentication](/docs/features/authentication/README.md)
- [Authorization](/docs/features/authorization/README.md)

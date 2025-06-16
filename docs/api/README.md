# API Documentation

This section documents the API integration and usage in the Flutter Architecture App.

## API Overview

The app interacts with several RESTful API endpoints for authentication, project management, calendar management, and other features.

## Base Configuration

API base URL and configuration settings are managed in:

```
lib/core/api/api_client.dart
```

## Authentication

### Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/login` | POST | User login |
| `/auth/register` | POST | User registration |
| `/auth/refresh` | POST | Token refresh |
| `/auth/logout` | POST | User logout |

### Authentication Flow

1. User submits credentials
2. Server returns JWT token
3. Token is stored in `flutter_secure_storage`
4. Token is attached to subsequent API requests

## Error Handling

API errors are handled using a consistent pattern:

1. Network errors are caught and transformed to `NetworkFailure`
2. Authentication errors trigger token refresh or logout
3. Other errors are mapped to specific failure types

## Data Models

Data transfer objects (DTOs) follow a consistent pattern:

```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? name,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

## API Client

The app uses `dio` for HTTP requests, with interceptors for:
- Authentication
- Logging
- Error handling

## Implementation Guidelines

When adding new API integrations:
1. Add endpoint constants to appropriate service
2. Create data models with proper serialization
3. Implement repository interfaces
4. Handle errors consistently

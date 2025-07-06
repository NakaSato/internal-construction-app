# API Documentation

This section documents the comprehensive REST API integration and usage in the Flutter Architecture App.

## API Overview

The app implements a feature-rich solar construction management platform with the following REST APIs:
- **Authentication & Authorization** - User management and role-based access
- **Project Management** - Solar project tracking and management  
- **Calendar Management** - Advanced calendar and event scheduling
- **Work Calendar** - Construction-specific calendar functionality
- **Task Management** - Task assignment and tracking
- **Daily Reports** - Daily activity logging and reporting
- **Work Request Approval** - Approval workflow management

## Base Configuration

API base URL and configuration settings are managed in:
```
lib/core/api/api_client.dart
```

**Base URL**: `/api/v1`
**Environment**: Configurable via `.env` file
**Authentication**: Bearer token (JWT)

---

## Quick Start

### 🔐 Authentication First
All API endpoints require authentication. Start here:
- **[Authentication & User Management](./authentication.md)** - Login, user registration, and role-based access

### 📋 Core APIs

---

## 🔐 Authentication API

### Endpoints

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/api/v1/auth/login` | POST | User login with credentials | No |
| `/api/v1/auth/register` | POST | User registration | No |
| `/api/v1/auth/refresh` | POST | Refresh authentication token | No |

### Login Request
```json
{
  "username": "user@example.com",
  "password": "securePassword123"
}
```

### Login Response
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_here",
    "user": {
      "userId": "usr_123456789",
      "username": "johndoe",
      "email": "john.doe@example.com",
      "fullName": "John Doe",
      "roleName": "Project Manager",
      "isActive": true,
      "profileImageUrl": "https://example.com/avatar.jpg",
      "phoneNumber": "+1234567890",
      "isEmailVerified": true,
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-06-15T14:20:00Z"
    }
  },
  "errors": []
}
```

### Registration Request
```json
{
  "username": "johndoe",
  "email": "john.doe@example.com",
  "password": "securePassword123",
  "fullName": "John Doe",
  "roleId": 3
}
```

### Registration Response
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "userId": "usr_123456789",
    "username": "johndoe",
    "email": "john.doe@example.com",
    "fullName": "John Doe",
    "roleName": "User",
    "isActive": true,
    "isEmailVerified": false,
    "createdAt": "2024-06-17T10:30:00Z"
  },
  "errors": []
}
```

---

## 🏗️ Project Management API

### Endpoints

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/api/v1/projects` | GET | Get all projects with pagination | Yes |
| `/api/v1/projects/{id}` | GET | Get project by ID | Yes |

### Query Parameters for Project List
- `pageNumber` (int): Page number (default: 1)
- `pageSize` (int): Items per page (default: 10)  
- `managerId` (string): Filter by project manager ID

### Project List Response
```json
{
  "success": true,
  "message": "Projects retrieved successfully",
  "data": {
    "items": [
      {
        "projectId": "proj_123456789",
        "projectName": "Residential Solar Installation - Smith House",
        "address": "123 Main St, Anytown, ST 12345",
        "clientInfo": "John Smith - (555) 123-4567",
        "status": "In Progress",
        "startDate": "2024-06-01T00:00:00Z",
        "estimatedEndDate": "2024-08-15T00:00:00Z",
        "actualEndDate": null,
        "projectManager": {
          "userId": "usr_987654321",
          "username": "manager1",
          "email": "manager@company.com",
          "fullName": "Project Manager",
          "roleName": "Project Manager"
        },
        "taskCount": 15,
        "completedTaskCount": 8
      }
    ],
    "totalCount": 42,
    "pageNumber": 1,
    "pageSize": 10,
    "totalPages": 5
  },
  "errors": []
}
```

### Single Project Response
```json
{
  "success": true,
  "message": "Project retrieved successfully", 
  "data": {
    "items": [
      {
        "projectId": "proj_123456789",
        "projectName": "Commercial Solar Array - Office Building",
        "address": "456 Business Park Dr, Corporate City, ST 54321",
        "clientInfo": "ABC Corporation - Contact: Jane Wilson (555) 987-6543",
        "status": "Planning",
        "startDate": "2024-07-01T00:00:00Z",
        "estimatedEndDate": "2024-12-31T00:00:00Z",
        "actualEndDate": null,
        "projectManager": {
          "userId": "usr_987654321",
          "username": "manager1", 
          "email": "manager@company.com",
          "fullName": "Senior Project Manager",
          "roleName": "Project Manager",
          "isActive": true,
          "phoneNumber": "+1234567890"
        },
        "taskCount": 25,
        "completedTaskCount": 3
      }
    ]
  }
}
```

---

## 📅 Calendar Management API

### Endpoints

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/api/v1/calendar` | GET | Get all calendar events with filtering | Yes |
| `/api/v1/calendar/{eventId}` | GET | Get calendar event by ID | Yes |
| `/api/v1/calendar` | POST | Create new calendar event | Yes |
| `/api/v1/calendar/{eventId}` | PUT | Update calendar event | Yes |
| `/api/v1/calendar/{eventId}` | DELETE | Delete calendar event | Yes |
| `/api/v1/calendar/project/{projectId}` | GET | Get events by project | Yes |
| `/api/v1/calendar/task/{taskId}` | GET | Get events by task | Yes |
| `/api/v1/calendar/user/{userId}` | GET | Get events by user | Yes |
| `/api/v1/calendar/upcoming` | GET | Get upcoming events | Yes |
| `/api/v1/calendar/conflicts` | POST | Check for scheduling conflicts | Yes |

### Calendar Event Query Parameters
- `startDate` (string): Filter events from date (ISO 8601)
- `endDate` (string): Filter events to date (ISO 8601)
- `eventType` (string): Event type filter (meeting, deadline, installation, maintenance, training, other)
- `status` (string): Status filter (scheduled, inprogress, completed, cancelled, postponed)
- `priority` (string): Priority filter (low, medium, high, critical)
- `isAllDay` (boolean): Filter all-day events
- `isRecurring` (boolean): Filter recurring events
- `projectId` (string): Filter by project ID
- `taskId` (string): Filter by task ID
- `createdByUserId` (string): Filter by creator
- `assignedToUserId` (string): Filter by assignee
- `pageNumber` (int): Page number for pagination
- `pageSize` (int): Items per page

### Calendar Event Types
1. **Meeting** (1) - Team meetings, client calls
2. **Deadline** (2) - Project milestones, deliverables  
3. **Installation** (3) - On-site work, commissioning
4. **Maintenance** (4) - Routine maintenance, repairs
5. **Training** (5) - Training sessions, certification
6. **Other** (6) - General events

### Calendar Event Status
1. **Scheduled** (1) - Event is planned
2. **In Progress** (2) - Event is currently happening
3. **Completed** (3) - Event finished successfully
4. **Cancelled** (4) - Event was cancelled
5. **Postponed** (5) - Event was postponed

### Calendar Event Priority
1. **Low** (1) - Low priority
2. **Medium** (2) - Normal priority  
3. **High** (3) - High priority
4. **Critical** (4) - Critical priority

### Calendar Events List Response
```json
{
  "success": true,
  "message": "Calendar events retrieved successfully",
  "data": {
    "events": [
      {
        "id": "evt_123456789",
        "title": "Solar Panel Installation - Phase 1",
        "description": "Installation of 20 solar panels on main roof section",
        "startDateTime": "2024-06-18T08:00:00Z",
        "endDateTime": "2024-06-18T17:00:00Z",
        "isAllDay": false,
        "eventType": 3,
        "eventTypeName": "Installation",
        "status": 1,
        "statusName": "Scheduled",
        "priority": 3,
        "priorityName": "High",
        "location": "123 Main St, Residential Site",
        "projectId": "proj_123456789",
        "projectName": "Smith House Solar Project",
        "taskId": "task_987654321",
        "taskName": "Panel Installation",
        "createdByUserId": "usr_111111111",
        "createdByUserName": "Project Manager",
        "assignedToUserId": "usr_222222222", 
        "assignedToUserName": "Lead Technician",
        "isRecurring": false,
        "recurrencePattern": null,
        "recurrenceEndDate": null,
        "reminderMinutes": 60,
        "isPrivate": false,
        "meetingUrl": null,
        "attendees": ["tech1@company.com", "tech2@company.com"],
        "notes": "Ensure safety equipment is ready. Weather forecast is clear.",
        "color": "#FF6B35",
        "createdAt": "2024-06-15T10:30:00Z",
        "updatedAt": "2024-06-16T14:20:00Z"
      }
    ],
    "totalCount": 125,
    "page": 1,
    "pageSize": 10,
    "totalPages": 13,
    "hasPreviousPage": false,
    "hasNextPage": true
  },
  "errors": []
}
```

### Create Calendar Event Request
```json
{
  "title": "Client Meeting - Project Review",
  "description": "Review installation progress with client",
  "startDateTime": "2024-06-20T14:00:00Z",
  "endDateTime": "2024-06-20T15:00:00Z",
  "eventType": "meeting",
  "status": "scheduled",
  "priority": "medium",
  "location": "Client Office",
  "isAllDay": false,
  "isRecurring": false,
  "notes": "Bring progress photos and timeline update",
  "reminderMinutes": 30,
  "projectId": "proj_123456789",
  "assignedToUserId": "usr_987654321",
  "color": "#4285F4",
  "isPrivate": false,
  "attendees": ["client@email.com", "manager@company.com"]
}
```

### Update Calendar Event Request
```json
{
  "title": "Updated Event Title",
  "status": "completed",
  "notes": "Event completed successfully with positive outcome",
  "reminderMinutes": 15
}
```

### Conflict Check Request
```json
{
  "startDateTime": "2024-06-20T14:00:00Z",
  "endDateTime": "2024-06-20T15:00:00Z", 
  "userId": "usr_987654321",
  "excludeEventId": "evt_123456789"
}
```

### Conflict Check Response
```json
{
  "success": true,
  "message": "Conflict check completed",
  "data": {
    "hasConflicts": true,
    "conflictingEvents": [
      {
        "id": "evt_conflict_123",
        "title": "Existing Meeting",
        "startDateTime": "2024-06-20T13:30:00Z",
        "endDateTime": "2024-06-20T14:30:00Z"
      }
    ]
  }
}
```

---

## 🔒 Authorization API

### Endpoints

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/auth/roles` | GET | Get all available roles | Yes |
| `/auth/permissions` | GET | Get all permissions | Yes |
| `/auth/users/{userId}/role` | GET | Get user's role | Yes |
| `/auth/check-permission` | POST | Check user permission | Yes |
| `/auth/check-resource-permission` | POST | Check resource permission | Yes |
| `/auth/users/{userId}/assign-role` | POST | Assign role to user | Yes |
| `/auth/users/{userId}/revoke-role` | POST | Revoke role from user | Yes |

### Roles List Response
```json
{
  "success": true,
  "message": "Roles retrieved successfully",
  "data": [
    {
      "id": "role_1",
      "name": "Administrator",
      "description": "Full system access and user management",
      "permissions": ["read", "write", "delete", "admin"]
    },
    {
      "id": "role_2", 
      "name": "Project Manager",
      "description": "Manage projects and team members",
      "permissions": ["read", "write", "manage_projects"]
    },
    {
      "id": "role_3",
      "name": "User",
      "description": "Basic user access",
      "permissions": ["read"]
    }
  ]
}
```

### Permission Check Request
```json
{
  "userId": "usr_123456789",
  "permission": "manage_projects"
}
```

### Permission Check Response
```json
{
  "success": true,
  "message": "Permission check completed",
  "data": {
    "hasPermission": true,
    "permission": "manage_projects",
    "userId": "usr_123456789"
  }
}
```

---

## 🗓️ Work Calendar API

### Endpoints

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/api/calendar/events` | GET | Get work events in date range | Yes |
| `/api/calendar/events/date` | GET | Get events for specific date | Yes |
| `/api/calendar/events/{id}` | GET | Get work event by ID | Yes |
| `/api/calendar/events` | POST | Create new work event | Yes |
| `/api/calendar/events/{id}` | PUT | Update work event | Yes |
| `/api/calendar/events/{id}` | DELETE | Delete work event | Yes |
| `/api/calendar/events/search` | GET | Search events | Yes |
| `/api/calendar/events/upcoming` | GET | Get upcoming events | Yes |
| `/api/calendar/events/type/{type}` | GET | Get events by type | Yes |
| `/api/calendar/events/today` | GET | Get today's events | Yes |
| `/api/calendar/events/export` | POST | Export events | Yes |

### Work Event Response
```json
{
  "events": [
    {
      "id": "work_evt_123",
      "title": "Morning Safety Briefing",
      "startTime": "2024-06-18T07:30:00Z",
      "endTime": "2024-06-18T08:00:00Z",
      "description": "Daily safety briefing before work begins",
      "location": "Job Site Trailer",
      "color": "#4CAF50",
      "isAllDay": false,
      "eventType": "meeting",
      "attendees": ["foreman@company.com", "tech1@company.com"]
    }
  ]
}
```

---

## 📊 Task Management API

*Note: API endpoints for task management are planned but not yet implemented in the current codebase.*

### Planned Endpoints
- `GET /api/v1/tasks` - Get tasks with filtering
- `POST /api/v1/tasks` - Create new task
- `PUT /api/v1/tasks/{id}` - Update task
- `DELETE /api/v1/tasks/{id}` - Delete task
- `GET /api/v1/tasks/project/{projectId}` - Get tasks by project

---

## 📋 Daily Reports API

*Note: API endpoints for daily reports are planned but not yet implemented in the current codebase.*

### Planned Endpoints
- `GET /api/v1/reports/daily` - Get daily reports
- `POST /api/v1/reports/daily` - Submit daily report
- `PUT /api/v1/reports/daily/{id}` - Update daily report
- `GET /api/v1/reports/daily/project/{projectId}` - Get reports by project

---

## Error Handling

### Standard Error Response Format
```json
{
  "success": false,
  "message": "Error description",
  "data": null,
  "errors": [
    "Detailed error message 1",
    "Detailed error message 2"
  ]
}
```

### HTTP Status Codes
- **200** - Success
- **400** - Bad Request (validation errors)
- **401** - Unauthorized (invalid token)
- **403** - Forbidden (insufficient permissions)
- **404** - Not Found
- **409** - Conflict (duplicate resource)
- **422** - Unprocessable Entity (validation failed)
- **500** - Internal Server Error

### Error Types
1. **Network errors** → `NetworkFailure`
2. **Authentication errors** → Token refresh or logout
3. **Validation errors** → User-friendly validation messages
4. **Permission errors** → Access denied with clear messaging

---

## Data Models Architecture

### Consistent Model Pattern
```dart
@freezed
class ExampleModel with _$ExampleModel {
  const factory ExampleModel({
    required String id,
    required String name,
    DateTime? createdAt,
  }) = _ExampleModel;

  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);
}
```

### Model Features
- **Freezed** for immutability and JSON serialization
- **Nullable safety** with proper typing
- **Entity conversion** methods for clean architecture
- **Validation** with required fields and constraints

---

## API Client Configuration

### Dio HTTP Client Setup
```dart
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio() {
    final dio = Dio();
    
    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
    
    return dio;
  }
}
```

### Features
- **Authentication** - Automatic Bearer token injection
- **Logging** - Request/response logging in debug mode
- **Error handling** - Standardized error transformation
- **Retry logic** - Automatic token refresh on 401 errors
- **Timeout configuration** - Configurable connection timeouts

---

## Implementation Guidelines

### Adding New API Integration
1. **Define endpoints** in `@RestApi` service class
2. **Create data models** with Freezed and JSON serialization
3. **Implement repository** following clean architecture
4. **Add error handling** with proper exception mapping
5. **Write tests** for all endpoints and error scenarios
6. **Update documentation** with examples and response formats

### Best Practices
- Use **dependency injection** for testability
- Implement **proper error handling** with meaningful messages
- Follow **consistent naming** conventions across APIs
- Add **comprehensive logging** for debugging
- Write **integration tests** for critical flows
- Document **all query parameters** and response formats

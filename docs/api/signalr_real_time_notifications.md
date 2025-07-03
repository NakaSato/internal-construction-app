# Real-Time Notifications with SignalR

This document provides comprehensive information about the real-time notification system implemented using ASP.NET Core SignalR in the Solar Project Management API.

## Overview

The API implements a real-time notification system using SignalR to provide:
- Live project updates
- Real-time collaboration on daily reports  
- Instant notifications for work requests, approvals, and status changes
- Real-time progress tracking
- Live user presence indicators

## SignalR Hub Endpoint

**Hub URL:** `/notificationHub`

**Authentication:** Required (JWT Bearer token)

## Client Connection

### JavaScript/TypeScript Example
```javascript
import * as signalR from "@microsoft/signalr";

const connection = new signalR.HubConnectionBuilder()
    .withUrl("/notificationHub", {
        accessTokenFactory: () => {
            return localStorage.getItem("jwt-token"); // Your JWT token
        }
    })
    .withAutomaticReconnect()
    .build();

// Start connection
await connection.start();
console.log("SignalR Connected");
```

### C# Client Example
```csharp
var connection = new HubConnectionBuilder()
    .WithUrl("https://your-api-url/notificationHub", options =>
    {
        options.AccessTokenProvider = () => Task.FromResult(yourJwtToken);
    })
    .WithAutomaticReconnect()
    .Build();

await connection.StartAsync();
```

## Available Hub Methods

### Project Management

#### Join Project Group
Join a project-specific group to receive real-time updates for that project.

```javascript
await connection.invoke("JoinProjectGroup", "project-id-here");
```

#### Leave Project Group  
Leave a project-specific group.

```javascript
await connection.invoke("LeaveProjectGroup", "project-id-here");
```

#### Send Project Message
Send a message to all users in a project group.

```javascript
await connection.invoke("SendProjectMessage", "project-id", "Hello team!");
```

### Daily Report Collaboration

#### Join Daily Report Session
Join a collaborative editing session for a specific daily report.

```javascript
await connection.invoke("JoinDailyReportSession", "daily-report-id");
```

#### Leave Daily Report Session
Leave a daily report editing session.

```javascript
await connection.invoke("LeaveDailyReportSession", "daily-report-id");  
```

#### Update Report Field
Notify others when editing a specific field in a daily report.

```javascript
await connection.invoke("UpdateReportField", "daily-report-id", "fieldName", "new-value");
```

#### Start/Stop Typing Indicator
Show typing indicators during collaborative editing.

```javascript
// Start typing
await connection.invoke("StartTyping", "daily-report-id", "fieldName");

// Stop typing  
await connection.invoke("StopTyping", "daily-report-id", "fieldName");
```

### User Presence

#### Update User Status
Update your online status.

```javascript
await connection.invoke("UpdateUserStatus", "online"); // "online", "away", "busy"
```

## Event Listeners

### Project Events

```javascript
// User joined project
connection.on("UserJoinedProject", (data) => {
    console.log(`${data.UserName} joined project ${data.ProjectId}`);
});

// User left project
connection.on("UserLeftProject", (data) => {
    console.log(`${data.UserName} left project ${data.ProjectId}`);
});

// Project message received
connection.on("ProjectMessageReceived", (data) => {
    console.log(`Message from ${data.SenderName}: ${data.Message}`);
});
```

### Daily Report Events

```javascript
// Someone joined report session
connection.on("UserJoinedReportSession", (data) => {
    console.log(`${data.UserName} started editing report ${data.ReportId}`);
});

// Report field updated
connection.on("ReportFieldUpdated", (data) => {
    console.log(`Field ${data.FieldName} updated to: ${data.NewValue}`);
    // Update your UI accordingly
});

// Typing indicators  
connection.on("UserStartedTyping", (data) => {
    showTypingIndicator(data.UserName, data.FieldName);
});

connection.on("UserStoppedTyping", (data) => {
    hideTypingIndicator(data.UserName, data.FieldName);
});
```

### Notification Events

```javascript
// General notification
connection.on("ReceiveNotification", (notification) => {
    showNotification(notification.Message, notification.Type);
});

// Work request notifications
connection.on("WorkRequestCreated", (data) => {
    console.log("New work request created:", data);
});

connection.on("WorkRequestStatusChanged", (data) => {
    console.log(`Work request ${data.WorkRequestId} status: ${data.NewStatus}`);
});

// Daily report notifications
connection.on("DailyReportCreated", (data) => {
    console.log("New daily report created:", data);
});

connection.on("DailyReportApprovalStatusChanged", (data) => {
    console.log(`Daily report ${data.ReportId} approval: ${data.ApprovalStatus}`);
});

// Progress updates
connection.on("RealTimeProgressUpdate", (data) => {
    updateProgressBar(data.ProjectId, data.CompletionPercentage);
});

// System announcements
connection.on("SystemAnnouncement", (data) => {
    showSystemMessage(data.Message, data.Priority);
});
```

### User Presence Events

```javascript
connection.on("UserStatusChanged", (data) => {
    updateUserStatus(data.UserId, data.Status);
});
```

## Server-Side Service Integration

### Using INotificationService

The `SignalRNotificationService` implements `INotificationService` and provides methods for sending notifications:

```csharp
public class YourController : ControllerBase
{
    private readonly INotificationService _notificationService;
    
    public YourController(INotificationService notificationService)
    {
        _notificationService = notificationService;
    }
    
    [HttpPost("create-work-request")]
    public async Task<IActionResult> CreateWorkRequest(CreateWorkRequestDto dto)
    {
        // Create work request logic...
        
        // Send real-time notification
        await _notificationService.SendWorkRequestCreatedNotificationAsync(workRequest);
        
        return Ok(workRequest);
    }
}
```

### Available Notification Methods

- `SendNotificationAsync(message, userId)` - Send basic notification
- `SendWorkRequestCreatedNotificationAsync(workRequest)` - Work request created
- `SendWorkRequestStatusChangedNotificationAsync(workRequest, oldStatus)` - Status change
- `SendDailyReportCreatedNotificationAsync(dailyReport)` - Daily report created
- `SendDailyReportApprovalStatusChangeAsync(dailyReport, oldStatus)` - Approval change
- `SendRealTimeProgressUpdateAsync(projectId, completionPercentage, updatedBy)` - Progress update
- `SendSystemAnnouncementAsync(message, priority, targetAudience)` - System messages

## Testing SignalR Integration

### Notification API Endpoints

The API provides comprehensive endpoints for notification management and SignalR testing:

#### Get Notifications
```bash
# Get all notifications for the authenticated user
GET /api/v1/notifications

# Get unread notification count
GET /api/v1/notifications/count

# Get notification statistics
GET /api/v1/notifications/statistics
```

#### Manage Notifications
```bash
# Mark specific notification as read
POST /api/v1/notifications/{notificationId}/read

# Mark all notifications as read
POST /api/v1/notifications/read-all
```

#### Testing Endpoints
```bash
# Send test notification
POST /api/v1/notifications/test
{
    "message": "Test notification",
    "type": "Info"
}

# Send announcement to all users
POST /api/v1/notifications/announcement
{
    "message": "System maintenance scheduled",
    "priority": "Medium",
    "targetAudience": "All"
}

# Send system announcement via SignalR
POST /api/v1/notifications/system-announcement
{
    "message": "System maintenance in 30 minutes",
    "priority": "High",
    "targetAudience": "All"
}

# Test SignalR connection
POST /api/v1/notifications/test-signalr
{
    "message": "SignalR test message",
    "targetUserId": "optional-user-id"
}

# Get SignalR connection info
GET /api/v1/notifications/connection-info
```

### API Response Examples

#### Get Notifications Response
```json
{
  "success": true,
  "data": [
    {
      "id": "notification-id-1",
      "userId": "user-id",
      "title": "New Project Assignment",
      "message": "You have been assigned to Solar Farm Project Alpha",
      "type": "ProjectAssignment",
      "isRead": false,
      "createdAt": "2025-07-04T10:30:00Z",
      "data": {
        "projectId": "project-123",
        "projectName": "Solar Farm Alpha"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalCount": 50,
    "totalPages": 3
  }
}
```

#### Get Notification Count Response
```json
{
  "success": true,
  "data": {
    "unreadCount": 5,
    "totalCount": 25
  }
}
```

#### Get Notification Statistics Response
```json
{
  "success": true,
  "data": {
    "unreadCount": 5,
    "readCount": 20,
    "totalCount": 25,
    "typeBreakdown": {
      "ProjectAssignment": 8,
      "DailyReportApproval": 6,
      "WorkRequestCreated": 4,
      "SystemAnnouncement": 7
    },
    "recentActivity": {
      "last24Hours": 3,
      "lastWeek": 12,
      "lastMonth": 25
    }
  }
}
```

### Flutter API Integration

#### Notification Service Implementation
```dart
import 'package:dio/dio.dart';

class NotificationApiService {
  final Dio _dio;
  final String _baseUrl;

  NotificationApiService(this._dio, this._baseUrl);

  Future<NotificationResponse> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? unreadOnly,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/api/v1/notifications',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (unreadOnly != null) 'unreadOnly': unreadOnly,
      },
    );
    return NotificationResponse.fromJson(response.data);
  }

  Future<NotificationCount> getNotificationCount() async {
    final response = await _dio.get('$_baseUrl/api/v1/notifications/count');
    return NotificationCount.fromJson(response.data['data']);
  }

  Future<NotificationStatistics> getNotificationStatistics() async {
    final response = await _dio.get('$_baseUrl/api/v1/notifications/statistics');
    return NotificationStatistics.fromJson(response.data['data']);
  }

  Future<void> markAsRead(String notificationId) async {
    await _dio.post('$_baseUrl/api/v1/notifications/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.post('$_baseUrl/api/v1/notifications/read-all');
  }

  Future<void> sendTestNotification({
    required String message,
    String type = 'Info',
  }) async {
    await _dio.post(
      '$_baseUrl/api/v1/notifications/test',
      data: {
        'message': message,
        'type': type,
      },
    );
  }

  Future<void> sendAnnouncement({
    required String message,
    String priority = 'Medium',
    String targetAudience = 'All',
  }) async {
    await _dio.post(
      '$_baseUrl/api/v1/notifications/announcement',
      data: {
        'message': message,
        'priority': priority,
        'targetAudience': targetAudience,
      },
    );
  }

  Future<void> testSignalR({
    required String message,
    String? targetUserId,
  }) async {
    await _dio.post(
      '$_baseUrl/api/v1/notifications/test-signalr',
      data: {
        'message': message,
        if (targetUserId != null) 'targetUserId': targetUserId,
      },
    );
  }

  Future<SignalRConnectionInfo> getConnectionInfo() async {
    final response = await _dio.get('$_baseUrl/api/v1/notifications/connection-info');
    return SignalRConnectionInfo.fromJson(response.data['data']);
  }
}
```

#### Data Models
```dart
class NotificationResponse {
  final bool success;
  final List<NotificationItem> data;
  final Pagination? pagination;

  NotificationResponse({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)
          ?.map((item) => NotificationItem.fromJson(item))
          .toList() ?? [],
      pagination: json['pagination'] != null 
          ? Pagination.fromJson(json['pagination']) 
          : null,
    );
  }
}

class NotificationItem {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      data: json['data'],
    );
  }
}

class NotificationCount {
  final int unreadCount;
  final int totalCount;

  NotificationCount({
    required this.unreadCount,
    required this.totalCount,
  });

  factory NotificationCount.fromJson(Map<String, dynamic> json) {
    return NotificationCount(
      unreadCount: json['unreadCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

class NotificationStatistics {
  final int unreadCount;
  final int readCount;
  final int totalCount;
  final Map<String, int> typeBreakdown;
  final RecentActivity recentActivity;

  NotificationStatistics({
    required this.unreadCount,
    required this.readCount,
    required this.totalCount,
    required this.typeBreakdown,
    required this.recentActivity,
  });

  factory NotificationStatistics.fromJson(Map<String, dynamic> json) {
    return NotificationStatistics(
      unreadCount: json['unreadCount'] ?? 0,
      readCount: json['readCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      typeBreakdown: Map<String, int>.from(json['typeBreakdown'] ?? {}),
      recentActivity: RecentActivity.fromJson(json['recentActivity'] ?? {}),
    );
  }
}

class RecentActivity {
  final int last24Hours;
  final int lastWeek;
  final int lastMonth;

  RecentActivity({
    required this.last24Hours,
    required this.lastWeek,
    required this.lastMonth,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      last24Hours: json['last24Hours'] ?? 0,
      lastWeek: json['lastWeek'] ?? 0,
      lastMonth: json['lastMonth'] ?? 0,
    );
  }
}

class Pagination {
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class SignalRConnectionInfo {
  final String hubUrl;
  final bool isEnabled;
  final int activeConnections;
  final List<String> availableGroups;

  SignalRConnectionInfo({
    required this.hubUrl,
    required this.isEnabled,
    required this.activeConnections,
    required this.availableGroups,
  });

  factory SignalRConnectionInfo.fromJson(Map<String, dynamic> json) {
    return SignalRConnectionInfo(
      hubUrl: json['hubUrl'] ?? '',
      isEnabled: json['isEnabled'] ?? false,
      activeConnections: json['activeConnections'] ?? 0,
      availableGroups: List<String>.from(json['availableGroups'] ?? []),
    );
  }
}
```

#### Notification BLoC Integration
```dart
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationApiService _apiService;
  final SignalRService _signalRService;

  NotificationBloc(this._apiService, this._signalRService) 
      : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadNotificationCount>(_onLoadNotificationCount);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<NotificationReceived>(_onNotificationReceived);
    
    // Listen to SignalR notifications
    _signalRService.onNotificationReceived = (notification) {
      add(NotificationReceived(notification));
    };
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationLoading());
      final response = await _apiService.getNotifications(
        page: event.page,
        pageSize: event.pageSize,
        unreadOnly: event.unreadOnly,
      );
      emit(NotificationLoaded(response.data, response.pagination));
    } catch (error) {
      emit(NotificationError(error.toString()));
    }
  }

  Future<void> _onLoadNotificationCount(
    LoadNotificationCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final count = await _apiService.getNotificationCount();
      emit(NotificationCountLoaded(count));
    } catch (error) {
      emit(NotificationError(error.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _apiService.markAsRead(event.notificationId);
      // Reload notifications
      add(LoadNotifications());
    } catch (error) {
      emit(NotificationError(error.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _apiService.markAllAsRead();
      // Reload notifications
      add(LoadNotifications());
    } catch (error) {
      emit(NotificationError(error.toString()));
    }
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    // Update state with new notification
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updatedNotifications = [event.notification, ...currentState.notifications];
      emit(NotificationLoaded(updatedNotifications, currentState.pagination));
    }
  }
}
```

## Configuration

### SignalR Configuration in Program.cs

```csharp
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = builder.Environment.IsDevelopment();
    options.ClientTimeoutInterval = TimeSpan.FromMinutes(5);
    options.KeepAliveInterval = TimeSpan.FromMinutes(2);
    options.MaximumReceiveMessageSize = 1024 * 1024; // 1MB
});
```

### CORS Configuration for SignalR

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("SignalRCorsPolicy", policy =>
    {
        policy.WithOrigins(allowedOrigins)
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials(); // Important for SignalR
    });
});
```

## Error Handling

### Connection Errors

```javascript
connection.onclose(async () => {
    console.log("SignalR connection closed");
    // Implement reconnection logic if needed
});

connection.onreconnecting((error) => {
    console.log("SignalR reconnecting:", error);
});

connection.onreconnected((connectionId) => {
    console.log("SignalR reconnected:", connectionId);
    // Re-join groups if needed
});
```

### Hub Method Errors

```javascript
try {
    await connection.invoke("JoinProjectGroup", projectId);
} catch (error) {
    console.error("Error joining project group:", error);
}
```

## Best Practices

### Client-Side

1. **Handle Connection State**: Always check connection state before invoking methods
2. **Implement Reconnection**: Use automatic reconnection and handle reconnection events
3. **Manage Groups**: Re-join groups after reconnection
4. **Error Handling**: Wrap hub method calls in try-catch blocks
5. **Memory Management**: Remove event listeners when components unmount

```javascript
// Check connection state
if (connection.state === signalR.HubConnectionState.Connected) {
    await connection.invoke("JoinProjectGroup", projectId);
}

// Clean up on component unmount
useEffect(() => {
    return () => {
        connection.off("ReceiveNotification");
        connection.stop();
    };
}, []);
```

### Server-Side

1. **Use Groups Efficiently**: Leverage SignalR groups for targeted messaging
2. **Handle Exceptions**: Wrap hub methods in try-catch blocks
3. **Validate Parameters**: Always validate input parameters in hub methods
4. **Use Background Services**: For heavy operations, use background services instead of hub methods
5. **Monitor Performance**: Log connection metrics and monitor hub performance

## Security Considerations

1. **Authentication Required**: All hub connections require JWT authentication
2. **Authorization**: Hub methods verify user permissions before executing
3. **Input Validation**: All hub method parameters are validated
4. **Rate Limiting**: Consider implementing rate limiting for hub methods
5. **Group Access Control**: Users can only join groups they have permission to access

## Monitoring and Logging

The system includes comprehensive logging for SignalR operations:

- Connection/disconnection events
- Group join/leave operations  
- Message sending/receiving
- Error conditions
- Performance metrics

Logs are available in the application logs with the category `dotnet_rest_api.Hubs.NotificationHub`.

## Scaling Considerations

For production deployments with multiple server instances:

1. **Azure SignalR Service**: Use Azure SignalR Service for cloud deployments
2. **Redis Backplane**: Configure Redis backplane for on-premises scaling
3. **Connection Limits**: Monitor and plan for connection limits
4. **Load Balancing**: Ensure sticky sessions if not using backplane

```csharp
// Azure SignalR Service
builder.Services.AddSignalR().AddAzureSignalR(connectionString);

// Redis backplane  
builder.Services.AddSignalR().AddStackExchangeRedis(connectionString);
```

## Common Integration Patterns

### React/Next.js Integration

```typescript
// hooks/useSignalR.ts
import { useEffect, useState } from 'react';
import * as signalR from '@microsoft/signalr';

export const useSignalR = (token: string) => {
    const [connection, setConnection] = useState<signalR.HubConnection | null>(null);
    const [isConnected, setIsConnected] = useState(false);

    useEffect(() => {
        const newConnection = new signalR.HubConnectionBuilder()
            .withUrl('/notificationHub', {
                accessTokenFactory: () => token
            })
            .withAutomaticReconnect()
            .build();

        setConnection(newConnection);

        newConnection.start()
            .then(() => setIsConnected(true))
            .catch(err => console.error('SignalR connection error:', err));

        return () => {
            newConnection.stop();
        };
    }, [token]);

    return { connection, isConnected };
};
```

### Vue.js Integration

```typescript
// composables/useSignalR.ts
import { ref, onUnmounted } from 'vue';
import * as signalR from '@microsoft/signalr';

export function useSignalR(token: string) {
    const connection = ref<signalR.HubConnection | null>(null);
    const isConnected = ref(false);

    const connect = async () => {
        connection.value = new signalR.HubConnectionBuilder()
            .withUrl('/notificationHub', {
                accessTokenFactory: () => token
            })
            .withAutomaticReconnect()
            .build();

        try {
            await connection.value.start();
            isConnected.value = true;
        } catch (error) {
            console.error('SignalR connection error:', error);
        }
    };

    onUnmounted(() => {
        connection.value?.stop();
    });

    return { connection, isConnected, connect };
}
```

### cURL Testing Examples

Here are practical cURL examples for testing all notification endpoints:

#### Authentication Setup
```bash
# Set your JWT token (replace with actual token)
export JWT_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
export API_BASE="http://localhost:5001"
```

#### Get Notifications
```bash
# Get all notifications
curl -X GET "$API_BASE/api/v1/notifications" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json"

# Get notifications with pagination
curl -X GET "$API_BASE/api/v1/notifications?page=1&pageSize=10&unreadOnly=true" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json"

# Get unread count
curl -X GET "$API_BASE/api/v1/notifications/count" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json"

# Get notification statistics
curl -X GET "$API_BASE/api/v1/notifications/statistics" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json"
```

#### Mark Notifications as Read
```bash
# Mark specific notification as read (replace notification-id with actual ID)
curl -X POST "$API_BASE/api/v1/notifications/notification-id/read" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json"

# Mark all notifications as read
curl -X POST "$API_BASE/api/v1/notifications/read-all" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json"
```

#### Send Test Notifications
```bash
# Send basic test notification
curl -X POST "$API_BASE/api/v1/notifications/test" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "This is a test notification",
    "type": "Info"
  }'

# Send announcement
curl -X POST "$API_BASE/api/v1/notifications/announcement" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "System maintenance scheduled for tonight",
    "priority": "High",
    "targetAudience": "All"
  }'

# Send system announcement via SignalR
curl -X POST "$API_BASE/api/v1/notifications/system-announcement" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Emergency maintenance in 30 minutes",
    "priority": "Critical",
    "targetAudience": "All"
  }'

# Test SignalR functionality
curl -X POST "$API_BASE/api/v1/notifications/test-signalr" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "SignalR test message",
    "targetUserId": "optional-user-id"
  }'
```

#### Get SignalR Connection Info
```bash
# Get SignalR connection information
curl -X GET "$API_BASE/api/v1/notifications/connection-info" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json"
```

#### Advanced Testing Scenarios
```bash
# Test notification types
curl -X POST "$API_BASE/api/v1/notifications/test" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Project assignment notification",
    "type": "ProjectAssignment"
  }'

curl -X POST "$API_BASE/api/v1/notifications/test" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Daily report needs approval",
    "type": "DailyReportApproval"
  }'

curl -X POST "$API_BASE/api/v1/notifications/test" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "New work request created",
    "type": "WorkRequestCreated"
  }'

# Test different priority levels
curl -X POST "$API_BASE/api/v1/notifications/announcement" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Low priority system update",
    "priority": "Low",
    "targetAudience": "All"
  }'

curl -X POST "$API_BASE/api/v1/notifications/announcement" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Critical system alert",
    "priority": "Critical",
    "targetAudience": "Admins"
  }'
```

#### Batch Testing Script
```bash
#!/bin/bash
# notification_test.sh - Comprehensive notification testing

API_BASE="http://localhost:5001"
JWT_TOKEN="your-jwt-token-here"

echo "🧪 Starting Notification API Tests..."

# Test 1: Get initial notification count
echo "📊 Getting initial notification count..."
curl -s -X GET "$API_BASE/api/v1/notifications/count" \
  -H "Authorization: Bearer $JWT_TOKEN" | jq '.'

# Test 2: Send test notifications
echo "📤 Sending test notifications..."
for i in {1..3}; do
  curl -s -X POST "$API_BASE/api/v1/notifications/test" \
    -H "Authorization: Bearer $JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"message\": \"Test notification #$i\", \"type\": \"Info\"}"
  echo "Sent notification #$i"
done

# Test 3: Get updated notification count
echo "📊 Getting updated notification count..."
curl -s -X GET "$API_BASE/api/v1/notifications/count" \
  -H "Authorization: Bearer $JWT_TOKEN" | jq '.'

# Test 4: Get notifications list
echo "📋 Getting notifications list..."
curl -s -X GET "$API_BASE/api/v1/notifications?pageSize=5" \
  -H "Authorization: Bearer $JWT_TOKEN" | jq '.'

# Test 5: Send SignalR test
echo "📡 Testing SignalR..."
curl -s -X POST "$API_BASE/api/v1/notifications/test-signalr" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message": "SignalR test from script"}'

# Test 6: Send system announcement
echo "📢 Sending system announcement..."
curl -s -X POST "$API_BASE/api/v1/notifications/system-announcement" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"message": "Test system announcement", "priority": "Medium"}'

# Test 7: Get connection info
echo "🔗 Getting SignalR connection info..."
curl -s -X GET "$API_BASE/api/v1/notifications/connection-info" \
  -H "Authorization: Bearer $JWT_TOKEN" | jq '.'

# Test 8: Mark all as read
echo "✅ Marking all notifications as read..."
curl -s -X POST "$API_BASE/api/v1/notifications/read-all" \
  -H "Authorization: Bearer $JWT_TOKEN"

# Test 9: Get final notification count
echo "📊 Getting final notification count..."
curl -s -X GET "$API_BASE/api/v1/notifications/count" \
  -H "Authorization: Bearer $JWT_TOKEN" | jq '.'

echo "✅ Notification API tests completed!"
```

#### Error Handling Examples
```bash
# Test with invalid token
curl -X GET "$API_BASE/api/v1/notifications" \
  -H "Authorization: Bearer invalid-token" \
  -H "Content-Type: application/json"

# Test with missing required fields
curl -X POST "$API_BASE/api/v1/notifications/test" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}'

# Test with invalid notification ID
curl -X POST "$API_BASE/api/v1/notifications/invalid-id/read" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json"
```

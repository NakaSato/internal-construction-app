# Project Refresh & Account Switch Fix

## Summary
This document details the implementation of fixes for issues related to project data not refreshing properly after switching accounts or when the app regains focus.

## Problem
When users switched accounts or the app returned from the background (e.g., after switching to another app and back), project data was not automatically refreshing. This led to:

1. Stale data being displayed
2. Confusion when switching between accounts
3. Inconsistent UI state between app and server

## Implementation

### App Focus Detection
We implemented a comprehensive app focus detection system that:

1. Detects when the app regains focus using Flutter's `AppLifecycleState`
2. Broadcasts these focus change events via a dedicated stream
3. Allows components across the app to respond to focus changes

### Stream-based Refresh System
Created a unified approach to handle app focus events:

```dart
// In RealtimeApiStreams
final StreamController<bool> _appFocusStreamController = StreamController<bool>.broadcast();
      
Stream<bool> get appFocusStream => _appFocusStreamController.stream;

void notifyAppFocusReturned() {
  debugPrint('📱 RealtimeApiStreams: Notifying app focus returned');
  _appFocusStreamController.add(true);
}
```

### Integration with Key Components

#### Project List Screen
The `ProjectListScreen` now:
1. Subscribes to app focus events
2. Refreshes project data when focus returns
3. Clears cache to ensure fresh data

```dart
void _initializeAppFocusListener() {
  _appFocusSubscription = _realtimeApiStreams.appFocusStream.listen((hasFocus) {
    if (!mounted) return;
    
    debugPrint('📱 Project List: App focus returned, refreshing projects data');
    _forceRefreshWithCacheClear();
  });
}
```

#### Notification Cubit
The `NotificationCubit` now:
1. Listens for app focus events
2. Refreshes notification data when focus returns

```dart
void _setupAppFocusListener() {
  _appFocusSubscription = realtimeStreams.appFocusStream.listen((hasFocus) {
    debugPrint('📱 NotificationCubit: App focus returned, refreshing notifications');
    loadAllNotifications();
  });
}
```

### Authentication Integration
When app focus returns, we also:
1. Verify authentication status
2. Ensure user sessions are still valid
3. Trigger re-authentication if needed

## Benefits

1. **Improved User Experience**: Data always reflects current account
2. **Data Consistency**: App state stays in sync with server state
3. **Robust Error Handling**: Proper authentication verification on focus return
4. **Performance Optimization**: Cache clearing prevents stale data issues

## Testing Scenarios

To verify the fix works correctly, test the following scenarios:

1. Switch between multiple accounts
2. Switch to another app and return to this app
3. Lock and unlock the device
4. Put the app in background and bring it back to foreground
5. Switch network conditions while app is in background

In all cases, the project list and notifications should refresh with current data when the app regains focus.

## Related Components

- `RealtimeApiStreams`: Central event broadcasting
- `ProjectListScreen`: Handles project-specific refresh logic
- `NotificationCubit`: Handles notification-specific refresh logic
- `app.dart`: Core app focus detection

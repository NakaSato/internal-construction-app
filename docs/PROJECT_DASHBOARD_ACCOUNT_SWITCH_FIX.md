# Project Dashboard Refresh Fix During Account Switch

## Problem
When switching between accounts in the Solar Mana app, the project dashboard would not properly refresh, leaving users with either stale data or no data at all. This issue primarily occurred when:

1. The user switched accounts
2. The app lost and regained focus during the account switching process
3. The app lifecycle transitions were not properly handled

## Solution

### Enhanced Focus Change Handling

We've implemented a more robust focus change handling system that:

1. Detects when the app loses focus (potentially for account switching)
2. Marks the dashboard for refresh when focus is lost
3. Triggers a comprehensive refresh when focus returns
4. Forces a project data reload with the latest account information

```dart
void _handleFocusChange(bool hasFocus) {
  if (!hasFocus) {
    // Mark dashboard as needing refresh when focus returns
    _markDashboardForRefresh();
  } else {
    // When focus returns to the app, trigger a comprehensive refresh
    Future.delayed(const Duration(milliseconds: 500), () {
      // Notify all listeners that app focus has returned
      getIt<RealtimeApiStreams>().notifyAppFocusReturned();
      
      // Check auth state and refresh dashboard
      context.read<AuthBloc>().add(const AuthCheckRequested());
      _forceRefreshDashboard();
    });
  }
}
```

### App Lifecycle Integration

We've also enhanced the app lifecycle handling to better support account switching:

1. When the app resumes from background state, it triggers a dashboard refresh
2. This ensures data is properly refreshed even during complex account switching scenarios
3. The app broadcasts focus return events to all listening components

```dart
void _onAppResumed() {
  // Validate session and then refresh dashboard
  _validateSessionOnResume();
  
  Future.delayed(const Duration(milliseconds: 800), () {
    _markDashboardForRefresh();
    _forceRefreshDashboard();
    getIt<RealtimeApiStreams>().notifyAppFocusReturned();
  });
}
```

### Project Data Refresh

The project data refresh process now uses the `LoadProjectsRequested` event with the `forceRefresh` flag set to true, which ensures:

1. Cache is properly cleared
2. Fresh data is always fetched from the server
3. The latest account context is used for data requests

## Benefits

- **Smoother Account Switching**: Project dashboard now properly refreshes after account changes
- **More Reliable Data**: Users always see data associated with their current account
- **Improved User Experience**: No more blank or stale project dashboards after switching accounts
- **System Integration**: Better coordination between app focus events and data refresh

## Testing

This fix has been tested under various account switching scenarios:

1. Direct account switching within the app
2. Switching to another app and returning during the account switch process
3. Background/foreground transitions during account switching
4. Multiple rapid account switches

In all cases, the project dashboard now properly refreshes and displays the correct data for the current account.

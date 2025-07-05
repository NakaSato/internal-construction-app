# Real-time API Updates Implementation Guide

## Overview

This guide documents the implementation of a comprehensive real-time update system for all API endpoints in the Flutter application, inspired by the Medium article on efficient real-time data handling without Firebase.

## Architecture

The implementation follows Clean Architecture principles with Feature-First organization and includes:

### Core Components

1. **UnifiedRealtimeApiService** - WebSocket connection manager
2. **RealtimeApiStreams** - Typed streams for each endpoint
3. **RealtimeRepositoryEnhancer** - Helper for adding real-time to repositories
4. **RealtimeBlocEnhancer** - Helper for adding real-time to BLoCs
5. **RealtimeApiMixin** - Mixin for easy real-time integration

### Supported Endpoints

- `projects` - Project management
- `tasks` - Task management  
- `daily-reports` - Daily reports
- `calendar` - Calendar events
- `work-calendar` - Work calendar
- `wbs` - Work breakdown structure
- `authorization` - Authorization/permissions
- `auth` - Authentication
- `calendar-management` - Calendar management

## WebSocket Communication Protocol

### Message Format

```json
{
  "type": "update|create|delete|bulk_update|heartbeat",
  "endpoint": "projects|tasks|daily-reports|...",
  "payload": {
    // Endpoint-specific data
  },
  "timestamp": "2025-07-06T12:00:00Z"
}
```

### Connection Features

- **Auto-reconnection** with exponential backoff
- **Heartbeat** for connection monitoring
- **Authentication** via token
- **Error handling** and recovery
- **BSON support** for efficient binary data (optional)

## Implementation Examples

### 1. Enhanced Repository with Real-time

```dart
@Injectable()
class RealtimeProjectRepositoryWrapper 
    with RealtimeEnhancedRepositoryMixin<RealtimeProjectUpdate> 
    implements EnhancedProjectRepository {
  
  final ApiProjectRepository _baseRepository;
  
  RealtimeProjectRepositoryWrapper(this._baseRepository);

  @override
  String get realtimeEndpointName => 'projects';

  Future<void> initializeRealtimeCapabilities() async {
    await initializeRealtime();
    
    startRealtimeUpdates(
      onUpdate: (update) => _handleProjectUpdate(update),
      onCreate: (update) => _handleProjectCreate(update),
      onDelete: (update) => _handleProjectDelete(update),
      onError: (error) => _handleError(error),
    );
  }

  // All repository methods delegate to base repository
  // with real-time notification flags added
  @override
  Future<EnhancedProject> createProject(Map<String, dynamic> data) async {
    final enhancedData = Map<String, dynamic>.from(data);
    enhancedData['_realtime'] = 'true';
    enhancedData['_notifyClients'] = 'true';
    
    return await _baseRepository.createProject(enhancedData);
  }
}
```

### 2. Enhanced BLoC with Real-time

```dart
@injectable
class EnhancedProjectBloc extends Bloc<EnhancedProjectEvent, EnhancedProjectState> {
  // Real-time subscription
  StreamSubscription<RealtimeProjectUpdate>? _realtimeApiSubscription;

  EnhancedProjectBloc() : super(const EnhancedProjectInitial()) {
    // Register event handlers
    on<StartProjectRealtimeUpdates>(_onStartProjectRealtimeUpdates);
    on<StopProjectRealtimeUpdates>(_onStopProjectRealtimeUpdates);
    on<ProjectRealtimeUpdateReceived>(_onProjectRealtimeUpdateReceived);
  }

  Future<void> _onStartProjectRealtimeUpdates(
    StartProjectRealtimeUpdates event, 
    Emitter<EnhancedProjectState> emit
  ) async {
    final realtimeStreams = getIt<RealtimeApiStreams>();
    await realtimeStreams.initialize();
    
    _realtimeApiSubscription = realtimeStreams.projectsStream.listen(
      (update) => add(ProjectRealtimeUpdateReceived(update: update)),
    );
  }

  Future<void> _onProjectRealtimeUpdateReceived(
    ProjectRealtimeUpdateReceived event, 
    Emitter<EnhancedProjectState> emit
  ) async {
    // Handle different update types
    switch (event.update.type) {
      case 'update':
        // Update existing project in current state
        break;
      case 'create':
        // Add new project to current state
        break;
      case 'delete':
        // Remove project from current state
        break;
    }
  }
}
```

### 3. UI Integration

```dart
class ProjectDetailsScreen extends StatefulWidget {
  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  StreamSubscription<RealtimeProjectUpdate>? _realtimeSubscription;
  bool _isRealtimeConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeRealtime();
  }

  void _initializeRealtime() async {
    final realtimeStreams = getIt<RealtimeApiStreams>();
    await realtimeStreams.initialize();
    
    setState(() {
      _isRealtimeConnected = realtimeStreams.isConnected;
    });

    // Start real-time updates through BLoC
    context.read<EnhancedProjectBloc>().add(const StartProjectRealtimeUpdates());

    // Subscribe for UI feedback
    _realtimeSubscription = realtimeStreams.projectsStream.listen(
      (update) => _showRealtimeUpdateFeedback(update),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
        actions: [
          // Real-time connection indicator
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(
                  _isRealtimeConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isRealtimeConnected ? Colors.green : Colors.grey,
                ),
                Text(_isRealtimeConnected ? 'Live' : 'Offline'),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<EnhancedProjectBloc, EnhancedProjectState>(
        builder: (context, state) {
          // Build UI based on state
          // Real-time updates automatically handled by BLoC
        },
      ),
    );
  }
}
```

## Integration Steps for New Endpoints

### 1. Add Endpoint to Core Services

Update `UnifiedRealtimeApiService`:

```dart
// Add endpoint constant
static const String newEndpoint = 'new-endpoint';

// Add to subscription list
Future<void> _subscribeToAllEndpoints() async {
  final subscriptionMessage = {
    'type': 'subscribe',
    'endpoints': [
      // ...existing endpoints
      newEndpoint,
    ],
  };
}
```

### 2. Add Typed Stream to RealtimeApiStreams

```dart
// Add new update model
class RealtimeNewEndpointUpdate extends RealtimeUpdate {
  // Define endpoint-specific fields
}

// Add stream property
Stream<RealtimeNewEndpointUpdate> get newEndpointStream => _unifiedService
    .getEndpointStream(UnifiedRealtimeApiService.newEndpoint)
    .map((data) => RealtimeNewEndpointUpdate.fromJson(data));
```

### 3. Update Repository Enhancer

Add endpoint case to `RealtimeRepositoryEnhancer._getStreamForEndpoint()`:

```dart
case 'new-endpoint':
  return _realtimeStreams.newEndpointStream as Stream<T>;
```

### 4. Create Real-time Repository Wrapper

```dart
@Injectable()
class RealtimeNewEndpointRepositoryWrapper 
    with RealtimeEnhancedRepositoryMixin<RealtimeNewEndpointUpdate> {
  
  @override
  String get realtimeEndpointName => 'new-endpoint';
  
  // Implement wrapper methods
}
```

### 5. Enhance BLoC with Real-time

Add real-time events and handlers to the BLoC:

```dart
// Events
class StartNewEndpointRealtimeUpdates extends NewEndpointEvent {}
class NewEndpointRealtimeUpdateReceived extends NewEndpointEvent {
  final RealtimeNewEndpointUpdate update;
}

// Handlers in BLoC constructor
on<StartNewEndpointRealtimeUpdates>(_onStartRealtimeUpdates);
on<NewEndpointRealtimeUpdateReceived>(_onRealtimeUpdateReceived);
```

### 6. Update UI Components

Add real-time indicators and initialize real-time updates in screens.

## Configuration

### Environment Configuration

Add WebSocket URL to environment config:

```dart
class EnvironmentConfig {
  static String get websocketUrl {
    switch (environment) {
      case Environment.development:
        return 'ws://localhost:8080';
      case Environment.staging:
        return 'wss://api-staging.example.com';
      case Environment.production:
        return 'wss://api.example.com';
    }
  }
}
```

### Dependency Injection

Register services in `injection.dart`:

```dart
@LazySingleton()
UnifiedRealtimeApiService get unifiedRealtimeApiService => UnifiedRealtimeApiService(get());

@LazySingleton()
RealtimeApiStreams get realtimeApiStreams => RealtimeApiStreams(get());
```

## Error Handling

### Connection Recovery

- **Automatic reconnection** with exponential backoff
- **Maximum retry attempts** configuration
- **Graceful degradation** when WebSocket fails
- **Fallback to HTTP polling** (optional)

### Error States in UI

- **Connection status indicators**
- **Retry buttons** for failed connections
- **Offline mode** messaging
- **Error boundaries** for real-time failures

## Performance Considerations

### Optimization Strategies

1. **Selective subscriptions** - Subscribe only to needed endpoints
2. **Filter updates** - Server-side filtering by user/project
3. **Batch updates** - Group multiple changes
4. **Debouncing** - Prevent UI thrashing from rapid updates
5. **Memory management** - Proper disposal of subscriptions

### BSON Support (Optional)

For high-frequency updates, BSON can be enabled:

```dart
// Handle binary messages in UnifiedRealtimeApiService
void _onMessage(dynamic message) {
  Map<String, dynamic> data;
  
  if (message is String) {
    data = json.decode(message);
  } else if (message is Uint8List) {
    // BSON decoding
    data = BsonCodec.deserialize(BsonBinary.from(message));
  }
  
  _processMessage(data);
}
```

## Testing

### Unit Tests

```dart
group('RealtimeRepositoryEnhancer', () {
  test('should handle real-time updates', () async {
    final enhancer = RealtimeRepositoryEnhancer<RealtimeProjectUpdate>(
      endpointName: 'projects',
    );
    
    // Test initialization, updates, disposal
  });
});
```

### Integration Tests

Test complete real-time flows with mock WebSocket server.

### Widget Tests

Test UI components with real-time state changes.

## Monitoring and Analytics

### Real-time Metrics

- Connection uptime
- Message throughput
- Error rates
- Reconnection frequency
- User engagement with real-time features

### Logging

- Connection events
- Message processing
- Error conditions
- Performance metrics

## Security Considerations

### Authentication

- **Token-based auth** for WebSocket connections
- **Token refresh** handling
- **Unauthorized connection** handling

### Data Validation

- **Message validation** on client side
- **Schema verification** for real-time updates
- **Permission checks** for sensitive updates

## Future Enhancements

### Planned Features

1. **Push notifications** integration
2. **Offline support** with sync on reconnect
3. **Real-time collaboration** features
4. **Advanced filtering** and subscriptions
5. **Analytics dashboard** for real-time metrics

### Migration Path

The current implementation provides a foundation for these enhancements while maintaining backward compatibility with existing HTTP-based APIs.

## Conclusion

This real-time implementation provides:

- **Scalable architecture** for adding real-time to any endpoint
- **Type-safe** real-time updates
- **Performance optimized** with minimal UI impact
- **Error resilient** with graceful degradation
- **Easy integration** with existing code

The system enables real-time collaboration features while maintaining the clean architecture principles and ensuring excellent user experience.

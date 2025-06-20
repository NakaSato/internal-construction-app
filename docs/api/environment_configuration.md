# API Environment Configuration

## Overview
The Flutter app now supports multiple API environments (development, staging, production, local) with easy switching capabilities.

## Environment Configuration

### 1. Environment Setup in `.env`
```properties
# Set the default environment
API_ENVIRONMENT=production

# Override specific URLs if needed
API_BASE_URL=https://solar-projects-api.azurewebsites.net
```

### 2. Available Environments

| Environment | Description | Default URL |
|-------------|-------------|-------------|
| **Production** | Live production API | `https://solar-projects-api.azurewebsites.net` |
| **Staging** | Pre-production testing | `https://staging-solar-projects-api.azurewebsites.net` |
| **Development** | Development API | `https://dev-solar-projects-api.azurewebsites.net` |
| **Local** | Local development server | `http://localhost:3000` |

## Usage

### 1. Programmatic Environment Selection
```dart
import '../core/api/api_config.dart';

// Set environment programmatically
ApiConfig.setEnvironment(ApiEnvironment.development);

// Check current environment
if (ApiConfig.isDevelopment) {
  print('Running in development mode');
}

// Get current URL
String apiUrl = ApiConfig.configuredBaseUrl;
```

### 2. Environment Selector Widget
```dart
import '../core/widgets/api_environment_selector.dart';

// In your settings screen or debug panel
ApiEnvironmentSelector(
  onEnvironmentChanged: (environment) {
    print('Environment changed to: ${environment}');
    // Optionally restart API services or show confirmation
  },
)
```

### 3. Environment Indicator
```dart
import '../core/widgets/api_environment_selector.dart';

// Show current environment in app bar (non-production only)
AppBar(
  title: Text('My App'),
  actions: [
    ApiEnvironmentIndicator(),
  ],
)
```

## Configuration Priority

The API base URL is determined in this order:
1. **Environment Variable**: `API_BASE_URL` from `.env` file
2. **Selected Environment**: Current environment setting
3. **Production Fallback**: Default production URL

## Environment-Specific Features

### Development Mode
- Environment selector widget is visible
- Debug information is displayed
- Additional logging may be enabled

### Production Mode
- Environment selector is hidden by default
- Only production URLs are used
- Debug features are disabled

## Example Implementation

### Settings Screen with Environment Selector
```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          ApiEnvironmentIndicator(),
        ],
      ),
      body: Column(
        children: [
          // Only show in debug mode
          if (kDebugMode)
            ApiEnvironmentSelector(
              onEnvironmentChanged: (env) {
                // Handle environment change
                _restartApiServices();
              },
            ),
          
          // Other settings...
        ],
      ),
    );
  }
}
```

### Debug Panel Integration
```dart
class DebugPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('API Configuration'),
      children: [
        // Environment selector
        ApiEnvironmentSelector(),
        
        // Current config display
        ListTile(
          title: Text('Current Environment'),
          subtitle: Text(ApiConfig.environmentName),
          trailing: Icon(_getEnvironmentIcon()),
        ),
        
        ListTile(
          title: Text('Base URL'),
          subtitle: Text(ApiConfig.configuredBaseUrl),
        ),
      ],
    );
  }
}
```

## Security Notes

- **Production builds** should disable environment switching
- **Sensitive URLs** should not be exposed in client code
- **Environment indicators** help developers identify current context
- **Default to production** to prevent accidental dev API usage

## Testing Different Environments

```dart
// Test with different environments
void testEnvironments() {
  for (final env in ApiEnvironment.values) {
    ApiConfig.setEnvironment(env);
    print('${env.name}: ${ApiConfig.configuredBaseUrl}');
  }
}
```

## Best Practices

1. **Default to Production**: Always fallback to production environment
2. **Hide in Production**: Don't show environment selector in production builds
3. **Visual Indicators**: Use clear visual indicators for non-production environments
4. **Configuration Validation**: Validate URLs before making API calls
5. **Environment Persistence**: Consider persisting environment selection in debug mode

# Running Flutter with Environment Configuration

## 🚀 Quick Start

Your Flutter app is now configured with environment support. Here are the ways to run it:

### 1. **VS Code Task (Recommended)**
```bash
# Use VS Code Command Palette: 
# Ctrl/Cmd + Shift + P → "Tasks: Run Task" → "Run Flutter App"
```

### 2. **Environment Switcher Script**
```bash
# Run with current environment
./scripts/run_with_env.sh

# Switch to development
./scripts/run_with_env.sh dev

# Switch to staging  
./scripts/run_with_env.sh staging

# Switch to production
./scripts/run_with_env.sh production

# Switch to local development
./scripts/run_with_env.sh local
```

### 3. **Manual Flutter Commands**
```bash
# Standard Flutter run (uses .env configuration)
flutter run

# Clean and run
flutter clean && flutter pub get && flutter run

# Run in debug mode
flutter run --debug

# Run in profile mode
flutter run --profile

# Run in release mode
flutter run --release
```

## 🔧 Environment Configuration

### Current Configuration
```properties
API_ENVIRONMENT=production
API_BASE_URL=https://solar-projects-api.azurewebsites.net
```

### Available Environments

| Environment | Command | URL |
|-------------|---------|-----|
| **Production** | `./scripts/run_with_env.sh production` | `https://solar-projects-api.azurewebsites.net` |
| **Development** | `./scripts/run_with_env.sh dev` | `https://dev-solar-projects-api.azurewebsites.net` |
| **Staging** | `./scripts/run_with_env.sh staging` | `https://staging-solar-projects-api.azurewebsites.net` |
| **Local** | `./scripts/run_with_env.sh local` | `http://localhost:3000` |

## 📱 In-App Environment Management

### Environment Selector Widget
The app includes a built-in environment selector (visible in debug mode):

```dart
// Add to your settings screen
ApiEnvironmentSelector(
  onEnvironmentChanged: (environment) {
    print('Environment changed to: ${environment.name}');
  },
)
```

### Environment Indicator
Show current environment in your app bar:

```dart
AppBar(
  title: Text('Solar Projects'),
  actions: [
    ApiEnvironmentIndicator(), // Shows current environment badge
  ],
)
```

## 🧪 Testing Environment Configuration

### Run Tests
```bash
# Test environment configuration
flutter test test/core/api/api_config_test.dart

# Run all tests
flutter test
```

### Manual Testing
```dart
import 'package:your_app/core/api/api_config.dart';

// Check current environment
print('Environment: ${ApiConfig.environmentName}');
print('Base URL: ${ApiConfig.configuredBaseUrl}');

// Switch environments programmatically
ApiConfig.setEnvironment(ApiEnvironment.development);
print('New URL: ${ApiConfig.configuredBaseUrl}');
```

## 🛠️ Development Workflow

### 1. **Local Development**
```bash
# Start your local API server (if applicable)
# Then switch to local environment
./scripts/run_with_env.sh local
```

### 2. **Testing Against Development API**
```bash
./scripts/run_with_env.sh dev
```

### 3. **Staging Testing**
```bash
./scripts/run_with_env.sh staging
```

### 4. **Production Testing**
```bash
./scripts/run_with_env.sh production
```

## 🔒 Security Features

- **Production Default**: Always defaults to production environment
- **Debug Mode Only**: Environment selector only visible in debug builds
- **Safe Fallbacks**: Falls back to production URL if configuration fails
- **Visual Indicators**: Clear environment identification in debug mode

## 📝 Configuration Priority

The API base URL is determined in this order:
1. **Environment Variable**: `API_BASE_URL` from `.env` file
2. **Selected Environment**: Current programmatically selected environment  
3. **Production Fallback**: Default production URL

## 🎯 Production Deployment

For production builds:
```bash
# Ensure production environment
echo "API_ENVIRONMENT=production" > .env
echo "API_BASE_URL=https://solar-projects-api.azurewebsites.net" >> .env

# Build for production
flutter build apk --release
flutter build ios --release
```

## 🚨 Troubleshooting

### Environment Not Switching
```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Check .env file
cat .env

# Verify environment in app
# Look for ApiEnvironmentIndicator in debug mode
```

### API Connection Issues
```bash
# Test API endpoint manually
curl -I https://solar-projects-api.azurewebsites.net/api/v1/auth/login

# Check network connectivity
ping solar-projects-api.azurewebsites.net
```

### Debug Information
The app provides debug information in development:
- Environment indicator in app bar
- API configuration summary in debug panel
- Network request logging (if enabled)

## 🎉 Success! 

Your Flutter app is now running with full environment configuration support:

✅ **Multi-environment support** (dev, staging, production, local)
✅ **Easy environment switching** via script or in-app selector  
✅ **Production-safe defaults** with secure fallbacks
✅ **Visual environment indicators** for development
✅ **Comprehensive testing** with automated test suite

The app will now use the configured API environment and provide clear visual feedback about which environment is active during development.

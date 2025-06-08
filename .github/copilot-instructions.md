<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Flutter Architecture App - Copilot Instructions

## Project Overview
This is a medium-sized Flutter application following Feature-First architecture with Clean Architecture principles. The app includes authentication, image upload, location tracking, and work calendar features.

## Architecture Guidelines
- Follow Feature-First organization: each feature should be in its own directory under `lib/features/`
- Use internal layering within features: `presentation/`, `application/`, `domain/`, `infrastructure/`
- Keep widgets "dumb" - move business logic to BLoCs, Cubits, or ViewModels
- Use dependency injection for loose coupling
- Prefer immutable data structures
- Apply proper separation of concerns

## State Management
- Primary: BLoC/Cubit pattern for complex state management
- Alternative: Riverpod for modern, flexible state management
- Avoid Provider for complex scenarios due to BuildContext limitations

## Code Quality Standards
- Use flutter_lints for code quality
- Follow Dart naming conventions (UpperCamelCase for classes, lowerCamelCase for variables)
- Write comprehensive tests (unit, widget, integration)
- Use meaningful, descriptive names for classes and methods
- Handle errors gracefully with try-catch blocks
- Use environment variables for sensitive configuration

## Key Dependencies
- State Management: flutter_bloc or riverpod
- Image Handling: image_picker, flutter_image_compress
- Location Services: location, geolocator
- Calendar UI: syncfusion_flutter_calendar
- Authentication: firebase_auth or auth0_flutter
- Secure Storage: flutter_secure_storage
- Network: dio or http
- Routing: go_router

## Testing Strategy
- Mirror lib/ structure in test/ directory
- Use mocks and fakes for external dependencies
- Focus on business logic in unit tests
- Test widget behavior and user interactions
- Write integration tests for critical user flows

## Security Considerations
- Store sensitive data in flutter_secure_storage
- Use environment variables for API keys and secrets
- Implement proper authentication flows
- Handle permissions gracefully for location and camera access

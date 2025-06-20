## CalendarEventListWidget Usage Guide

### Overview
The `CalendarEventListWidget` is a Material Design 3 compliant widget for displaying calendar events in a clean, organized list format. It follows the Flutter architecture guidelines with proper separation of concerns and responsive design principles.

### Basic Usage

```dart
import '../widgets/calendar_event_list_widget.dart';

// Basic usage with a list of events
CalendarEventListWidget(
  events: events,
  onEventTap: (event) {
    // Handle event tap
    print('Tapped on event: ${event.title}');
  },
)

// Customized display options
CalendarEventListWidget(
  events: events,
  onEventTap: _handleEventTap,
  showDate: true,        // Show event dates
  showProject: true,     // Show project information
  showPriority: false,   // Hide priority badges
)
```

### Features

#### ✅ **Material Design 3 Compliance**
- Uses proper color schemes and typography
- Implements consistent spacing (4dp grid system)
- Follows elevation and surface guidelines

#### ✅ **Performance Optimized**
- Uses `const` constructors
- Implements `ListView.builder` for efficiency
- Proper widget recycling

#### ✅ **Accessibility Ready**
- Semantic markup for screen readers
- Proper contrast ratios
- Touch target sizing

#### ✅ **Customizable Display**
- Toggle date display
- Toggle project information
- Toggle priority badges
- Responsive to different screen sizes

### Event Card Features

Each event card displays:
- **Event Type Icon** with colored background
- **Event Title** with proper text overflow handling
- **Date/Time Information** (if enabled)
- **Priority Badge** (if enabled)
- **Color Indicator** (if event has a color)
- **Description** (if available)
- **Status Chip** with appropriate styling
- **Location Chip** (if available)
- **Project Information** (if enabled)
- **Assigned User** (if available)

### Integration with BLoC

```dart
BlocBuilder<CalendarManagementBloc, CalendarManagementState>(
  builder: (context, state) {
    if (state is CalendarManagementLoaded) {
      return CalendarEventListWidget(
        events: state.events,
        onEventTap: (event) {
          context.read<CalendarManagementBloc>().add(
            CalendarEventSelected(event),
          );
        },
      );
    }
    return const CircularProgressIndicator();
  },
)
```

### Empty State Handling

The widget automatically displays a beautiful empty state when no events are provided:
- Semantic icon
- Clear messaging
- Consistent with Material Design 3 guidelines

### Architecture Compliance

This widget follows the project's architecture guidelines:

1. **Feature-First**: Located in `calendar_management/presentation/widgets/`
2. **Clean Architecture**: Only depends on domain entities
3. **Single Responsibility**: Focused solely on displaying event lists
4. **Material Design 3**: Uses theme colors and typography
5. **Performance**: Optimized for large datasets
6. **Testable**: Pure widget without business logic

### Customization

All spacing and sizing uses constants for easy maintenance:
- `_cardMarginHorizontal = 16.0`
- `_cardMarginVertical = 8.0`
- `_cardPadding = 16.0`
- `_spaceSmall = 4.0`
- `_spaceMedium = 8.0`
- `_spaceLarge = 12.0`
- `_spaceXLarge = 16.0`

### Related Widgets

- `CalendarAgendaView`: Uses this widget for grouped displays
- `CalendarEventDialog`: For editing events
- `CalendarFilterWidget`: For filtering events
- `CalendarSearchWidget`: For searching events

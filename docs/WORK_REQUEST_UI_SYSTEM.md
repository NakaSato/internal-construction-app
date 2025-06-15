# Work Request Approval UI System

A comprehensive, reusable widget system for the work request approval feature, designed following Material Design 3 principles and Flutter best practices.

## Overview

The UI system provides a set of composable, consistent, and reusable widgets that ensure visual and functional consistency across the work request approval feature.

## Core Components

### 1. Status Management

#### `WorkRequestStatusChip`
A versatile status indicator showing work request current state.

**Features:**
- 5 status states: draft, pending approval, approved, rejected, escalated
- 3 sizes: small, medium, large
- Consistent color scheme following Material Design 3
- Icon + text display
- Optional icon display

**Usage:**
```dart
WorkRequestStatusChip(
  status: WorkRequestStatus.pendingApproval,
  size: WorkRequestStatusChipSize.medium,
  showIcon: true,
)
```

#### `WorkRequestPriorityIndicator`
Multi-style priority indicator for visual priority communication.

**Features:**
- 4 priority levels: low, medium, high, critical
- 3 display styles: chip, badge, indicator
- 3 sizes: small, medium, large
- Color-coded priority system

**Usage:**
```dart
WorkRequestPriorityIndicator(
  priority: WorkRequestPriority.high,
  style: WorkRequestPriorityStyle.chip,
  size: WorkRequestPrioritySize.medium,
)
```

### 2. Action System

#### `WorkRequestActionButton`
Standardized button component for all work request actions.

**Features:**
- 4 styles: primary, secondary, destructive, text
- 3 sizes: small, medium, large
- Loading state support
- Icon + label support
- Consistent spacing and typography

**Usage:**
```dart
WorkRequestActionButton(
  label: 'Approve Request',
  icon: Icons.check,
  onPressed: () => _handleApproval(),
  style: WorkRequestActionButtonStyle.primary,
  size: WorkRequestActionButtonSize.medium,
  isLoading: false,
)
```

### 3. Card System

#### `WorkRequestCardContainer`
Base container for all work request cards with consistent styling.

**Features:**
- Material Design 3 elevation
- Configurable padding and margin
- Optional tap handling
- Ripple effect control
- Rounded corners

#### `WorkRequestCardHeader`
Standardized header component for cards.

**Features:**
- Title and subtitle display
- Optional trailing widget
- Text overflow handling
- Consistent typography

#### `WorkRequestCardContent`
Container for card content with automatic spacing.

**Features:**
- Automatic spacing between children
- Configurable spacing values
- Column-based layout

#### `WorkRequestInfoRow`
Key-value display component for structured information.

**Features:**
- Icon + label + value layout
- Customizable icon colors
- Consistent spacing
- Right-aligned values

#### `WorkRequestCardFooter`
Action container for card bottom actions.

**Features:**
- Flexible action layout
- Configurable alignment
- Automatic spacing between actions

**Usage:**
```dart
WorkRequestCardContainer(
  child: WorkRequestCardContent(
    children: [
      WorkRequestCardHeader(
        title: 'Request Title',
        subtitle: 'Project Name',
        trailing: WorkRequestStatusChip(...),
      ),
      WorkRequestInfoRow(
        icon: Icons.person,
        label: 'Assigned to',
        value: 'John Doe',
      ),
      WorkRequestCardFooter(
        actions: [
          WorkRequestActionButton(...),
          WorkRequestActionButton(...),
        ],
      ),
    ],
  ),
)
```

### 4. State Management

#### `WorkRequestEmptyState`
Consistent empty state display across the application.

**Features:**
- Icon or illustration support
- Title and description
- Optional action button
- Centered layout
- Consistent typography

#### `WorkRequestErrorState`
Standardized error state with retry functionality.

**Features:**
- Error icon display
- Title and description
- Optional retry button
- Consistent error styling

#### `WorkRequestLoadingState`
Loading indicator with optional message.

**Features:**
- Circular progress indicator
- Customizable loading message
- Centered layout
- Theme-aware colors

#### `WorkRequestCardShimmer`
Animated loading placeholder for card lists.

**Features:**
- Configurable item count
- Smooth animation
- Card-shaped placeholders
- Theme-aware colors

**Usage:**
```dart
// Empty State
WorkRequestEmptyState(
  title: 'No requests found',
  description: 'Your requests will appear here',
  icon: Icons.inbox,
  action: WorkRequestActionButton(...),
)

// Error State
WorkRequestErrorState(
  title: 'Something went wrong',
  description: 'Failed to load requests',
  onRetry: () => _retryLoad(),
)

// Loading State
WorkRequestLoadingState(
  message: 'Loading requests...',
)

// Shimmer Loading
WorkRequestCardShimmer(itemCount: 3)
```

## Design System Principles

### 1. Consistency
- All components follow the same design language
- Consistent spacing, typography, and colors
- Standardized component APIs

### 2. Flexibility
- Multiple size variants for different contexts
- Style variations for different use cases
- Configurable properties for customization

### 3. Accessibility
- Semantic color usage (error, success, warning)
- Proper contrast ratios
- Screen reader friendly

### 4. Performance
- Optimized widget builds
- Efficient animations
- Minimal rebuilds

### 5. Material Design 3
- Color scheme compliance
- Elevation system
- Typography scale
- Interactive states

## Implementation Benefits

### For Developers
- **Reduced Development Time**: Pre-built, tested components
- **Consistency**: Automatic design system compliance
- **Maintainability**: Centralized component logic
- **Reusability**: Components work across different screens

### For Users
- **Consistent Experience**: Familiar interaction patterns
- **Better Performance**: Optimized components
- **Accessibility**: Built-in accessibility features
- **Modern UI**: Material Design 3 compliance

### For the Codebase
- **Cleaner Code**: Simplified screen implementations
- **Easier Testing**: Isolated, testable components
- **Better Architecture**: Clear separation of concerns
- **Scalability**: Easy to extend and modify

## Usage Examples

### Simple Card Implementation
```dart
class MyWorkRequestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WorkRequestCardContainer(
      child: WorkRequestCardContent(
        children: [
          WorkRequestCardHeader(
            title: workRequest.title,
            subtitle: workRequest.projectName,
            trailing: WorkRequestStatusChip(
              status: workRequest.currentStatus,
            ),
          ),
          WorkRequestInfoRow(
            icon: Icons.calendar_today,
            label: 'Due date',
            value: formatDate(workRequest.dueDate),
          ),
          WorkRequestCardFooter(
            actions: [
              WorkRequestActionButton(
                label: 'View Details',
                onPressed: () => _viewDetails(),
                style: WorkRequestActionButtonStyle.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Screen State Management
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkRequestCubit, WorkRequestState>(
      builder: (context, state) {
        if (state is WorkRequestLoading) {
          return const WorkRequestLoadingState();
        }
        
        if (state is WorkRequestError) {
          return WorkRequestErrorState(
            title: 'Failed to load',
            description: state.message,
            onRetry: () => context.read<WorkRequestCubit>().reload(),
          );
        }
        
        if (state is WorkRequestLoaded && state.requests.isEmpty) {
          return WorkRequestEmptyState(
            title: 'No requests',
            description: 'Create your first request',
            icon: Icons.add_task,
            action: WorkRequestActionButton(
              label: 'Create Request',
              onPressed: () => _createRequest(),
            ),
          );
        }
        
        return _buildRequestsList(state.requests);
      },
    );
  }
}
```

## File Structure

```
lib/features/work_request_approval/presentation/widgets/ui_system/
├── ui_system.dart                           # Main export file
├── work_request_status_chip.dart           # Status indicators
├── work_request_priority_indicator.dart    # Priority indicators
├── work_request_action_button.dart         # Action buttons
├── work_request_card_components.dart       # Card building blocks
└── work_request_state_widgets.dart         # State management widgets
```

## Future Enhancements

1. **Animation System**: Consistent animations across components
2. **Theme Variants**: Dark mode and custom theme support
3. **Responsive Design**: Adaptive layouts for different screen sizes
4. **Internationalization**: Multi-language support
5. **Advanced Components**: Charts, graphs, and data visualization
6. **Form System**: Standardized form components
7. **Navigation System**: Consistent navigation patterns
8. **Notification System**: Toast, snackbar, and dialog components

This UI system provides a solid foundation for building consistent, maintainable, and user-friendly interfaces across the work request approval feature while following Flutter and Material Design best practices.

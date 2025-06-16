# Common Directory

This directory contains shared resources that are used across multiple features in the application. Unlike the `core` directory which focuses on infrastructure and foundational setup, the `common` directory contains concrete, reusable code that prevents duplication between features.

## Structure

```
common/
├── constants/                    # Application-wide constants
│   └── app_constants.dart        # String keys, numeric values, etc.
├── utils/                        # Shared utility functions and extensions
│   └── app_utils.dart            # Helper functions, formatters, extensions
├── widgets/                      # Reusable UI components
│   └── app_widgets.dart          # Generic widgets used by multiple features
└── models/                       # Data models shared by multiple features
```

## Usage Guidelines

### Constants
- Place values that are used in multiple features
- Avoid feature-specific constants (those should stay in the feature)
- Examples: API endpoints, animation durations, common strings

### Utils
- Utility functions that don't belong to any specific feature
- Extension methods that enhance built-in Dart/Flutter classes
- Formatters for dates, currencies, file sizes, etc.

### Widgets
- UI components that are truly generic and reusable
- Should not contain business logic specific to any feature
- Examples: loading indicators, error states, common buttons

### Models
- **Use with caution** - only for data models genuinely shared across features
- Consider if the model truly needs to be shared or if it's creating unnecessary coupling
- Prefer feature-specific models when possible

## Best Practices

1. **Avoid Business Logic**: The common directory should not contain business logic specific to any feature
2. **Minimize Coupling**: Be careful not to create unnecessary dependencies between features
3. **Keep it Generic**: Code here should be generic enough to be useful across multiple contexts
4. **Document Usage**: When adding shared components, document their intended use cases

## When NOT to Use Common

- Feature-specific utilities
- Business logic
- Models that are only used by one feature
- UI components that are specific to a particular feature's design

## Migration from Core

If you find utilities or widgets in the `core` directory that are not infrastructure-related, consider moving them here to maintain the proper separation of concerns.

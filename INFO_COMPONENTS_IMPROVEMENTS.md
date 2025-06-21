# Info Components - Code Quality Improvements & Documentation

## Overview
The `info_components.dart` file has been significantly improved with enhanced code quality, reduced duplication, better performance, and additional specialized components for common use cases.

## Key Improvements Made

### 1. **Eliminated Code Duplication**
- **Created `InfoFormatters` utility class** to centralize all formatting logic
- **Removed duplicate formatting methods** from individual components
- **Consolidated empty value handling** across all components
- **Unified theming and styling** approaches

### 2. **Enhanced Code Quality**
- **Added proper imports** for clipboard functionality (`flutter/services.dart`)
- **Implemented async/await** for clipboard operations with error handling
- **Added context.mounted checks** to prevent memory leaks
- **Improved widget organization** with private helper methods
- **Enhanced documentation** with comprehensive dartdocs

### 3. **Performance Optimizations**
- **Extracted helper methods** to reduce widget rebuild overhead
- **Used const constructors** where applicable
- **Optimized conditional rendering** logic
- **Reduced memory allocations** in formatting operations

### 4. **Added New Specialized Components**
- **PercentageInfoRow**: For displaying percentages with optional progress bars
- **StatusInfoRow**: For status display with color-coded badges
- **ContactInfoRow**: For contact information with interaction support
- **Enhanced utility methods**: Large numbers, durations, file sizes, etc.

## Components Overview

### Core Components

#### 1. **InfoCard**
```dart
InfoCard(
  title: 'Project Details',
  icon: Icons.info_outline,
  children: [
    InfoRow(label: 'Name', value: 'Construction Project'),
    CurrencyInfoRow(label: 'Budget', amount: 150000.0),
    DateInfoRow(label: 'Start Date', date: DateTime.now()),
  ],
)
```

**Features:**
- Material Design 3 styling with proper elevation
- Optional icon integration
- Customizable background colors
- Responsive dividers and spacing
- Clean header organization

#### 2. **InfoRow** (Base Component)
```dart
InfoRow(
  label: 'Project Manager',
  value: 'John Doe',
  icon: Icons.person_outline,
  copyable: true,
  onTap: () => print('Tapped'),
)
```

**Features:**
- Flexible label-value layout
- Optional icons and interactions
- Copy-to-clipboard with error handling
- Consistent theming and spacing
- Empty value handling

### Specialized Components

#### 3. **CurrencyInfoRow**
```dart
CurrencyInfoRow(
  label: 'Total Cost',
  amount: 125000.50,
  currency: '\$',
  icon: Icons.attach_money,
)
```

**Output:** `$125,000.50` (with green color for monetary values)

#### 4. **DateInfoRow**
```dart
DateInfoRow(
  label: 'Deadline',
  date: DateTime(2024, 12, 31, 14, 30),
  showTime: true,
  icon: Icons.calendar_today,
)
```

**Output:** `Dec 31, 2024 at 14:30`

#### 5. **PercentageInfoRow**
```dart
PercentageInfoRow(
  label: 'Completion',
  percentage: 75.5,
  showProgressBar: true,
  colorCoded: true,
  precision: 1,
)
```

**Features:**
- Color-coded based on percentage ranges
- Optional progress bar visualization
- Configurable decimal precision

#### 6. **StatusInfoRow**
```dart
StatusInfoRow(
  label: 'Status',
  status: 'Active',
  showBadge: true,
  icon: Icons.info_outline,
)
```

**Features:**
- Color-coded status badges
- Predefined status color schemes
- Custom color support

#### 7. **ContactInfoRow**
```dart
ContactInfoRow(
  label: 'Email',
  contact: 'john.doe@example.com',
  contactType: ContactType.email,
)
```

**Features:**
- Contact type-specific icons
- Copy-to-clipboard functionality
- Tap interactions for contact actions

#### 8. **SpecInfoRow**
```dart
SpecInfoRow(
  label: 'Area',
  value: 1250.75,
  unit: 'sq ft',
  precision: 2,
)
```

**Output:** `1250.75 sq ft`

## InfoFormatters Utility Class

### Available Methods

#### Currency Formatting
```dart
InfoFormatters.formatCurrency(150000.50, '\$')
// Output: $150,000.50
```

#### Date Formatting
```dart
InfoFormatters.formatDate(DateTime.now(), includeTime: true)
// Output: Jun 21, 2025 at 14:30
```

#### Large Numbers
```dart
InfoFormatters.formatLargeNumber(1500000)
// Output: 1.5M
```

#### Duration Formatting
```dart
InfoFormatters.formatDuration(Duration(days: 2, hours: 5, minutes: 30))
// Output: 2d 5h
```

#### File Size Formatting
```dart
InfoFormatters.formatFileSize(1048576)
// Output: 1.0 MB
```

#### Text Utilities
```dart
InfoFormatters.truncateText('Very long text...', 20)
InfoFormatters.capitalizeWords('hello world')
InfoFormatters.handleEmptyValue(null) // Returns: "Not Set"
```

## Usage Examples

### Basic Information Card
```dart
InfoCard(
  title: 'Project Information',
  icon: Icons.construction,
  children: [
    InfoRow(
      label: 'Project Name',
      value: 'Office Building Construction',
    ),
    StatusInfoRow(
      label: 'Status',
      status: 'In Progress',
      showBadge: true,
    ),
    PercentageInfoRow(
      label: 'Progress',
      percentage: 68.5,
      showProgressBar: true,
    ),
    CurrencyInfoRow(
      label: 'Budget',
      amount: 2500000.00,
      currency: '\$',
    ),
    DateInfoRow(
      label: 'Start Date',
      date: DateTime(2024, 1, 15),
    ),
    DateInfoRow(
      label: 'Expected Completion',
      date: DateTime(2024, 12, 30),
      showTime: true,
    ),
  ],
)
```

### Contact Information Card
```dart
InfoCard(
  title: 'Contact Information',
  icon: Icons.contacts,
  children: [
    ContactInfoRow(
      label: 'Project Manager',
      contact: 'pm@construction.com',
      contactType: ContactType.email,
    ),
    ContactInfoRow(
      label: 'Phone',
      contact: '+1-555-0123',
      contactType: ContactType.phone,
    ),
    ContactInfoRow(
      label: 'Website',
      contact: 'https://construction.com',
      contactType: ContactType.website,
    ),
  ],
)
```

### Technical Specifications Card
```dart
InfoCard(
  title: 'Technical Specifications',
  icon: Icons.engineering,
  children: [
    SpecInfoRow(
      label: 'Total Area',
      value: 15000.0,
      unit: 'sq ft',
      precision: 1,
    ),
    SpecInfoRow(
      label: 'Height',
      value: 45.5,
      unit: 'm',
      precision: 1,
    ),
    InfoRow(
      label: 'Floors',
      value: '12',
    ),
  ],
)
```

## Best Practices

### 1. **Component Selection**
- Use **InfoRow** for simple label-value pairs
- Use **CurrencyInfoRow** for monetary values
- Use **DateInfoRow** for dates and timestamps
- Use **PercentageInfoRow** for progress and completion rates
- Use **StatusInfoRow** for status indicators with visual emphasis
- Use **ContactInfoRow** for clickable contact information
- Use **SpecInfoRow** for technical measurements with units

### 2. **Performance Considerations**
- **Prefer specialized components** over custom InfoRow implementations
- **Use const constructors** when values are known at compile time
- **Leverage InfoFormatters** for consistent formatting across the app
- **Minimize widget rebuilds** by extracting static content

### 3. **Accessibility**
- **Include semantic icons** for better screen reader support
- **Use appropriate color contrasts** for status indicators
- **Provide tooltips** for interactive elements
- **Test with screen readers** to ensure proper navigation

### 4. **Theming**
- **Respect Material Design 3** color schemes
- **Use theme colors** instead of hardcoded values
- **Maintain consistency** across similar UI elements
- **Support dark mode** automatically through theming

## Migration Guide

### From Old InfoRow Usage
```dart
// OLD: Manual formatting
InfoRow(
  label: 'Amount',
  value: '\$${amount.toStringAsFixed(2)}',
)

// NEW: Use specialized component
CurrencyInfoRow(
  label: 'Amount',
  amount: amount,
  currency: '\$',
)
```

### From Custom Formatting
```dart
// OLD: Inline formatting
InfoRow(
  label: 'Date',
  value: '${date.day}/${date.month}/${date.year}',
)

// NEW: Use formatter utility
DateInfoRow(
  label: 'Date',
  date: date,
)
```

## Testing Recommendations

### Unit Tests
```dart
group('InfoFormatters', () {
  test('formatCurrency should format correctly', () {
    expect(
      InfoFormatters.formatCurrency(1234.56, '\$'),
      equals('\$1,234.56'),
    );
  });

  test('formatDate should include time when requested', () {
    final date = DateTime(2024, 6, 21, 14, 30);
    expect(
      InfoFormatters.formatDate(date, includeTime: true),
      equals('Jun 21, 2024 at 14:30'),
    );
  });
});
```

### Widget Tests
```dart
testWidgets('CurrencyInfoRow displays formatted amount', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CurrencyInfoRow(
          label: 'Test',
          amount: 1234.56,
        ),
      ),
    ),
  );

  expect(find.text('฿1,234.56'), findsOneWidget);
});
```

## Future Enhancements

### Potential Improvements
1. **Internationalization support** for date and number formatting
2. **Animation support** for value changes
3. **Theme customization** for component-specific styling
4. **Accessibility improvements** with better semantic markup
5. **Performance monitoring** for large lists with many info components

### Architecture Benefits
- **Maintainability**: Single source of truth for formatting logic
- **Consistency**: Unified styling and behavior across components
- **Extensibility**: Easy to add new specialized components
- **Performance**: Optimized rendering and minimal rebuilds
- **Developer Experience**: Clear APIs with comprehensive documentation

The improved info components provide a robust, scalable foundation for displaying structured information throughout the Flutter application while maintaining excellent code quality and performance.

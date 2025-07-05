# Solar UI System Documentation

## Overview

The Solar UI System is a comprehensive component library for the Solar Project Management app, built on Flutter with Material Design 3 principles and solar-specific theming.

## Table of Contents

- [Installation](#installation)
- [Design Tokens](#design-tokens)
- [Components](#components)
  - [Buttons](#buttons)
  - [Cards](#cards)
  - [Inputs](#inputs)
  - [Chips & Badges](#chips--badges)
  - [Navigation](#navigation)
  - [Layout](#layout)
- [Theming](#theming)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)

## Installation

Import the Solar UI library in your Dart files:

```dart
import 'package:your_app/core/ui/components/solar_ui.dart';
```

## Design Tokens

The Solar UI system uses design tokens to ensure consistency across all components.

### Spacing

```dart
// Available spacing tokens
AppDesignTokens.spacingXxs  // 4dp
AppDesignTokens.spacingXs   // 8dp
AppDesignTokens.spacingSm   // 12dp
AppDesignTokens.spacingMd   // 16dp (standard)
AppDesignTokens.spacingLg   // 24dp
AppDesignTokens.spacingXl   // 32dp
AppDesignTokens.spacingXxl  // 48dp
AppDesignTokens.spacingXxxl // 64dp
```

### Colors

```dart
// Primary colors
AppColorTokens.primary600    // Main brand blue
AppColorTokens.secondary600  // Solar orange
AppColorTokens.success600    // Solar green

// Semantic colors
AppColorTokens.energyHigh     // High energy production
AppColorTokens.energyMedium   // Medium energy production
AppColorTokens.energyLow      // Low energy production
AppColorTokens.energyOptimal  // Optimal conditions

// Status colors
AppColorTokens.statusActive     // Active projects
AppColorTokens.statusPending    // Pending projects
AppColorTokens.statusCompleted  // Completed projects
```

### Border Radius

```dart
AppDesignTokens.radiusSm   // 6dp
AppDesignTokens.radiusMd   // 8dp
AppDesignTokens.radiusLg   // 12dp
AppDesignTokens.radiusXl   // 16dp
AppDesignTokens.radiusMax  // 24dp
```

### Elevation

```dart
AppDesignTokens.elevationNone  // 0dp
AppDesignTokens.elevationXs    // 1dp
AppDesignTokens.elevationSm    // 2dp
AppDesignTokens.elevationMd    // 4dp
AppDesignTokens.elevationLg    // 8dp
```

## Components

### Buttons

The Solar UI system provides multiple button variants for different use cases.

#### SolarButton (Base Component)

```dart
SolarButton(
  onPressed: () {},
  variant: SolarButtonVariant.primary,
  size: SolarButtonSize.medium,
  child: Text('Click Me'),
)
```

**Variants:**
- `SolarButtonVariant.primary` - Main action button
- `SolarButtonVariant.secondary` - Secondary action button
- `SolarButtonVariant.outlined` - Outlined button
- `SolarButtonVariant.text` - Text-only button
- `SolarButtonVariant.elevated` - Elevated button

**Sizes:**
- `SolarButtonSize.small` - 32dp height
- `SolarButtonSize.medium` - 40dp height (default)
- `SolarButtonSize.large` - 48dp height
- `SolarButtonSize.extraLarge` - 56dp height

#### Specialized Button Components

```dart
// Primary action button
SolarPrimaryButton(
  onPressed: () {},
  leadingIcon: Icon(Icons.add),
  child: Text('Create Project'),
)

// Secondary action button
SolarSecondaryButton(
  onPressed: () {},
  child: Text('Cancel'),
)

// Outlined button
SolarOutlinedButton(
  onPressed: () {},
  child: Text('Learn More'),
)

// Text button
SolarTextButton(
  onPressed: () {},
  child: Text('Skip'),
)
```

#### Button States

```dart
// Loading state
SolarPrimaryButton(
  onPressed: () {},
  isLoading: true,
  child: Text('Processing...'),
)

// Disabled state
SolarPrimaryButton(
  onPressed: null, // or isDisabled: true
  child: Text('Disabled'),
)

// Full width button
SolarPrimaryButton(
  onPressed: () {},
  fullWidth: true,
  child: Text('Full Width'),
)
```

### Cards

Cards provide containers for related content with consistent styling.

#### SolarCard (Base Component)

```dart
SolarCard(
  variant: SolarCardVariant.elevated,
  size: SolarCardSize.medium,
  onTap: () {},
  child: YourContent(),
)
```

**Variants:**
- `SolarCardVariant.elevated` - Elevated with shadow
- `SolarCardVariant.outlined` - Outlined border
- `SolarCardVariant.filled` - Filled background
- `SolarCardVariant.surface` - Surface level
- `SolarCardVariant.glass` - Semi-transparent overlay

#### Specialized Card Components

```dart
// Project card with active state
SolarProjectCard(
  isActive: true,
  onTap: () {},
  child: ProjectContent(),
)

// Energy metrics card
SolarEnergyCard(
  energyLevel: EnergyLevel.high,
  child: EnergyMetrics(),
)

// Status card
SolarStatusCard(
  status: ProjectStatus.active,
  child: StatusContent(),
)

// Glass overlay card
SolarGlassCard(
  opacity: 0.8,
  child: OverlayContent(),
)
```

#### Card Grid Layout

```dart
SolarCardGrid(
  maxCrossAxisExtent: 320.0,
  mainAxisSpacing: 16.0,
  crossAxisSpacing: 16.0,
  children: [
    SolarCard(child: Content1()),
    SolarCard(child: Content2()),
    SolarCard(child: Content3()),
  ],
)
```

### Inputs

Form controls with consistent styling and validation support.

#### SolarTextField

```dart
SolarTextField(
  labelText: 'Project Name',
  hintText: 'Enter project name',
  helperText: 'This will be used as the display name',
  isRequired: true,
  prefixIcon: Icon(Icons.solar_power),
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'This field is required';
    }
    return null;
  },
  onChanged: (value) {
    // Handle value changes
  },
)
```

**Variants:**
- `SolarInputVariant.outlined` - Outlined border (default)
- `SolarInputVariant.filled` - Filled background
- `SolarInputVariant.underlined` - Underlined border

**Sizes:**
- `SolarInputSize.small` - Compact input
- `SolarInputSize.medium` - Standard input (default)
- `SolarInputSize.large` - Large input

#### SolarDropdownField

```dart
SolarDropdownField<String>(
  labelText: 'Project Type',
  hintText: 'Select project type',
  isRequired: true,
  items: [
    DropdownMenuItem(value: 'residential', child: Text('Residential')),
    DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
    DropdownMenuItem(value: 'industrial', child: Text('Industrial')),
  ],
  onChanged: (value) {
    // Handle selection
  },
)
```

#### SolarSearchField

```dart
SolarSearchField(
  hintText: 'Search projects...',
  onChanged: (value) {
    // Handle search
  },
  onClear: () {
    // Handle clear
  },
)
```

### Chips & Badges

Status indicators and selectable options.

#### SolarChip (Base Component)

```dart
SolarChip(
  label: 'Filter Option',
  variant: SolarChipVariant.filter,
  isSelected: isSelected,
  onTap: () {
    // Handle tap
  },
)
```

**Variants:**
- `SolarChipVariant.filled` - Filled background
- `SolarChipVariant.outlined` - Outlined border
- `SolarChipVariant.elevated` - Elevated with shadow
- `SolarChipVariant.input` - Input chip with delete
- `SolarChipVariant.filter` - Filter chip (selectable)
- `SolarChipVariant.action` - Action chip

#### Specialized Chip Components

```dart
// Status indicator chip
SolarStatusChip(
  status: ProjectStatus.active,
  label: 'Active',
  size: SolarChipSize.small,
)

// Energy level chip
SolarEnergyChip(
  energyLevel: EnergyLevel.high,
  label: 'High Output',
)
```

#### Badge Components

```dart
// Notification badge
SolarNotificationBadge(
  count: 5,
  child: IconButton(
    icon: Icon(Icons.notifications),
    onPressed: () {},
  ),
)

// Priority badge
SolarPriorityBadge(
  priority: Priority.high,
  child: Icon(Icons.flag),
)

// Custom badge
SolarBadge(
  label: 'New',
  backgroundColor: Colors.red,
  child: YourWidget(),
)
```

### Navigation

Navigation components for app structure.

#### SolarAppBar

```dart
SolarAppBar(
  title: Text('Solar Projects'),
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
  ],
  bottom: SolarTabBar(
    tabs: [
      Tab(text: 'All'),
      Tab(text: 'Active'),
      Tab(text: 'Completed'),
    ],
  ),
)
```

#### SolarBottomNavigationBar

```dart
SolarBottomNavigationBar(
  currentIndex: selectedIndex,
  onTap: (index) {
    setState(() => selectedIndex = index);
  },
  items: [
    SolarBottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    SolarBottomNavigationBarItem(
      icon: Icon(Icons.solar_power),
      label: 'Projects',
    ),
    SolarBottomNavigationBarItem(
      icon: Icon(Icons.analytics),
      label: 'Analytics',
    ),
  ],
)
```

#### SolarDrawer

```dart
SolarDrawer(
  header: DrawerHeader(
    child: YourHeaderContent(),
  ),
  currentRoute: '/projects',
  items: [
    SolarDrawerItem(
      title: 'Dashboard',
      icon: Icon(Icons.dashboard),
      route: '/dashboard',
    ),
    SolarDrawerItem(
      title: 'Projects',
      icon: Icon(Icons.solar_power),
      route: '/projects',
    ),
    SolarDrawerItem.divider(),
    SolarDrawerItem(
      title: 'Settings',
      icon: Icon(Icons.settings),
      route: '/settings',
    ),
  ],
  onItemTap: (item) {
    Navigator.pushNamed(context, item.route!);
  },
)
```

### Layout

Layout components for consistent page structure.

#### SolarPageLayout

```dart
SolarPageLayout(
  header: SolarAppBar(title: Text('Page Title')),
  sidebar: NavigationContent(),
  body: MainContent(),
  footer: FooterContent(),
  showSidebar: true,
  sidebarWidth: 280.0,
)
```

#### SolarSection

```dart
SolarSection(
  title: 'Project Statistics',
  subtitle: 'Overview of your solar projects',
  actions: [
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
  children: [
    StatisticsWidget(),
    ChartWidget(),
  ],
)
```

#### SolarResponsiveLayout

```dart
SolarResponsiveLayout(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

#### SolarStackLayout

```dart
// Vertical stack with consistent spacing
SolarStackLayout(
  spacing: AppDesignTokens.spacingMd,
  children: [
    Widget1(),
    Widget2(),
    Widget3(),
  ],
)

// Horizontal stack
SolarStackLayout(
  direction: Axis.horizontal,
  spacing: AppDesignTokens.spacingMd,
  children: [
    Widget1(),
    Widget2(),
  ],
)
```

#### SolarSpacer

```dart
// Predefined spacers
SolarSpacer.xs    // 8dp spacing
SolarSpacer.sm    // 12dp spacing
SolarSpacer.md    // 16dp spacing
SolarSpacer.lg    // 24dp spacing
SolarSpacer.xl    // 32dp spacing

// Custom spacing
SolarSpacer.custom(20.0)
SolarSpacer.horizontal(16.0)
SolarSpacer.vertical(24.0)
```

## Theming

The Solar UI system integrates with Flutter's Material Design 3 theming system.

### Accessing Theme Values

```dart
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;
final textTheme = theme.textTheme;

// Use theme colors
Container(
  color: colorScheme.primary,
  child: Text(
    'Themed Content',
    style: textTheme.headlineSmall,
  ),
)
```

### Custom Solar Colors

```dart
// Access solar-specific colors
Container(
  color: AppColorTokens.energyHigh,
  child: Text('High Energy Production'),
)
```

## Usage Examples

### Project Dashboard Card

```dart
SolarProjectCard(
  isActive: true,
  onTap: () => Navigator.push(...),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Solar Installation Project',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SolarStatusChip(
            status: ProjectStatus.active,
            label: 'Active',
            size: SolarChipSize.small,
          ),
        ],
      ),
      SolarSpacer.sm,
      Text(
        'Commercial rooftop installation with 200kW capacity',
        style: TextStyle(color: Colors.grey[600]),
      ),
      SolarSpacer.md,
      Row(
        children: [
          Icon(Icons.location_on, size: 16),
          SolarSpacer.xs,
          Text('San Francisco, CA'),
          SolarSpacer.lg,
          Icon(Icons.calendar_today, size: 16),
          SolarSpacer.xs,
          Text('Due: Dec 15, 2024'),
        ],
      ),
      SolarSpacer.md,
      LinearProgressIndicator(value: 0.65),
      SolarSpacer.xs,
      Text('65% Complete'),
    ],
  ),
)
```

### Energy Metrics Dashboard

```dart
SolarEnergyCard(
  energyLevel: EnergyLevel.high,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Energy Production',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SolarEnergyChip(
            energyLevel: EnergyLevel.high,
            label: 'High Output',
            size: SolarChipSize.small,
          ),
        ],
      ),
      SolarSpacer.md,
      Row(
        children: [
          Icon(Icons.flash_on, color: Colors.orange),
          SolarSpacer.xs,
          Text(
            '145.2 kW',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
      Text('Current Output'),
      SolarSpacer.lg,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMetric('Today', '1,234 kWh'),
          _buildMetric('This Month', '35,678 kWh'),
        ],
      ),
    ],
  ),
)
```

### Project Creation Form

```dart
Form(
  child: SolarStackLayout(
    children: [
      SolarTextField(
        labelText: 'Project Name',
        hintText: 'Enter project name',
        isRequired: true,
        prefixIcon: Icon(Icons.solar_power),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Project name is required';
          }
          return null;
        },
      ),
      
      SolarDropdownField<String>(
        labelText: 'Project Type',
        hintText: 'Select project type',
        isRequired: true,
        items: [
          DropdownMenuItem(value: 'residential', child: Text('Residential')),
          DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
          DropdownMenuItem(value: 'industrial', child: Text('Industrial')),
        ],
        onChanged: (value) {
          // Handle selection
        },
      ),
      
      SolarTextField(
        labelText: 'Description',
        hintText: 'Enter project description',
        maxLines: 3,
        variant: SolarInputVariant.outlined,
      ),
      
      SolarTextField(
        labelText: 'Budget',
        hintText: '0.00',
        keyboardType: TextInputType.number,
        prefixText: '\$',
        variant: SolarInputVariant.filled,
      ),
      
      SolarStackLayout(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: SolarOutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ),
          SolarSpacer.md,
          Expanded(
            child: SolarPrimaryButton(
              onPressed: () {
                // Submit form
              },
              child: Text('Create Project'),
            ),
          ),
        ],
      ),
    ],
  ),
)
```

## Best Practices

### 1. Use Design Tokens

Always use design tokens for consistent spacing, colors, and sizing:

```dart
// ✅ Good
Container(
  padding: EdgeInsets.all(AppDesignTokens.spacingMd),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
  ),
)

// ❌ Avoid
Container(
  padding: EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.0),
  ),
)
```

### 2. Choose Appropriate Component Variants

Use the right variant for the context:

```dart
// ✅ Primary action
SolarPrimaryButton(
  onPressed: submitForm,
  child: Text('Create Project'),
)

// ✅ Secondary action
SolarSecondaryButton(
  onPressed: saveDraft,
  child: Text('Save Draft'),
)

// ✅ Destructive action
SolarOutlinedButton(
  onPressed: deleteProject,
  child: Text('Delete'),
)
```

### 3. Provide Proper Feedback

Use loading states and validation:

```dart
// ✅ Loading state
SolarPrimaryButton(
  onPressed: isLoading ? null : submit,
  isLoading: isLoading,
  child: Text('Submit'),
)

// ✅ Form validation
SolarTextField(
  labelText: 'Email',
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!isValidEmail(value!)) {
      return 'Please enter a valid email';
    }
    return null;
  },
)
```

### 4. Use Semantic Components

Choose components that match the content semantics:

```dart
// ✅ Use specialized components
SolarProjectCard(
  isActive: project.isActive,
  child: ProjectContent(),
)

SolarEnergyCard(
  energyLevel: metrics.level,
  child: EnergyMetrics(),
)

// ✅ Use appropriate status indicators
SolarStatusChip(
  status: project.status,
  label: project.statusLabel,
)
```

### 5. Responsive Design

Consider different screen sizes:

```dart
// ✅ Responsive layout
SolarResponsiveLayout(
  mobile: SingleColumnLayout(),
  tablet: TwoColumnLayout(),
  desktop: ThreeColumnLayout(),
)

// ✅ Responsive grid
SolarGridLayout(
  maxCrossAxisExtent: 320.0, // Adapts to screen size
  children: cards,
)
```

### 6. Accessibility

Ensure components are accessible:

```dart
// ✅ Semantic labels
SolarButton(
  onPressed: delete,
  child: Text('Delete Project'),
  // Automatically handles accessibility
)

// ✅ Form labels
SolarTextField(
  labelText: 'Project Name', // Provides semantic label
  hintText: 'Enter project name',
)
```

### 7. Consistent Spacing

Use SolarStackLayout and SolarSpacer for consistent spacing:

```dart
// ✅ Consistent spacing
SolarStackLayout(
  spacing: AppDesignTokens.spacingMd,
  children: widgets,
)

// ✅ Semantic spacing
Column(
  children: [
    Widget1(),
    SolarSpacer.md,
    Widget2(),
    SolarSpacer.lg,
    Widget3(),
  ],
)
```

This completes the comprehensive Solar UI System documentation. The system provides a complete set of components for building consistent, accessible, and beautiful solar project management interfaces.

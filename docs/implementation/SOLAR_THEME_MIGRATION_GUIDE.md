# Solar Theme Migration Guide

## Quick Reference for Updating Components to New Solar Theme

### **1. Import Changes**
```dart
// OLD
import '../config/app_theme.dart';

// NEW  
import '../theme/solar_app_theme.dart';
```

### **2. Spacing Updates**
```dart
// OLD
AppTheme.spacingXS  // 4.0
AppTheme.spacingS   // 8.0  
AppTheme.spacingM   // 16.0
AppTheme.spacingL   // 24.0
AppTheme.spacingXL  // 32.0

// NEW
SolarSpacing.xs     // 4.0
SolarSpacing.sm     // 8.0
SolarSpacing.md     // 16.0
SolarSpacing.lg     // 24.0
SolarSpacing.xl     // 32.0
SolarSpacing.xxl    // 48.0
SolarSpacing.xxxl   // 64.0
```

### **3. Border Radius Updates**
```dart
// OLD
AppTheme.radiusS    // 8.0
AppTheme.radiusM    // 12.0
AppTheme.radiusL    // 16.0
AppTheme.radiusXL   // 20.0

// NEW
SolarBorderRadius.sm    // 8.0
SolarBorderRadius.md    // 12.0
SolarBorderRadius.lg    // 16.0
SolarBorderRadius.xl    // 20.0
SolarBorderRadius.xxl   // 28.0
SolarBorderRadius.round // 50.0
```

### **4. Color Access**
```dart
// OLD
AppTheme.primaryColor
AppTheme.successColor
AppTheme.warningColor
AppTheme.errorColor

// NEW - via BuildContext extension
context.colorScheme.primary
context.colorScheme.energyHigh     // success
context.colorScheme.energyMedium   // warning  
context.colorScheme.error

// NEW - Solar specific colors
context.colorScheme.solarBlue
context.colorScheme.solarOrange
context.colorScheme.solarGreen
context.colorScheme.solarGold
```

### **5. Text Styles**
```dart
// OLD
Theme.of(context).textTheme.headline6
Theme.of(context).textTheme.bodyText1

// NEW - via extension
context.textTheme.cardTitle
context.textTheme.body
context.textTheme.displayHeading
context.textTheme.statusBadge
context.textTheme.metricValue
```

### **6. Decorations**
```dart
// OLD
AppTheme.createCardDecoration(
  color: Colors.white,
  elevation: 2,
  borderRadius: AppTheme.radiusM,
)

// NEW
SolarDecorations.createCardDecoration(
  color: Colors.white,
  elevation: 2,
  borderRadius: SolarBorderRadius.md,
)

// OLD
AppTheme.createGradientDecoration(
  colors: [color1, color2],
  borderRadius: AppTheme.radiusL,
)

// NEW
SolarDecorations.createGradientDecoration(
  colors: [color1, color2],
  borderRadius: SolarBorderRadius.lg,
)
```

### **7. Elevation/Shadows**
```dart
// OLD
AppTheme.elevation1
AppTheme.elevation2

// NEW
SolarDecorations.createElevationShadow(SolarElevation.sm)
SolarDecorations.createElevationShadow(SolarElevation.md)
```

### **8. Status Colors**
```dart
// OLD
AppTheme.successColor
AppTheme.warningColor
AppTheme.errorColor

// NEW - Energy focused
context.colorScheme.energyHigh      // Green - optimal performance
context.colorScheme.energyMedium    // Orange - medium performance  
context.colorScheme.energyLow       // Red - low performance/issues
context.colorScheme.energyOptimal   // Purple - optimal state

// NEW - Project status
context.colorScheme.statusActive
context.colorScheme.statusPending
context.colorScheme.statusCompleted
context.colorScheme.statusCancelled
```

### **9. App Theme Configuration**
```dart
// OLD
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
)

// NEW
MaterialApp(
  theme: SolarAppTheme.themeData,
  themeMode: ThemeMode.light,
)
```

### **10. Complete Example Migration**

**Before:**
```dart
Container(
  margin: EdgeInsets.all(AppTheme.spacingM),
  decoration: AppTheme.createCardDecoration(
    color: Colors.white,
    elevation: 2,
    borderRadius: AppTheme.radiusL,
  ),
  child: Text(
    'Solar Panel Status',
    style: Theme.of(context).textTheme.headline6,
  ),
)
```

**After:**
```dart
Container(
  margin: EdgeInsets.all(SolarSpacing.md),
  decoration: SolarDecorations.createCardDecoration(
    color: context.colorScheme.surface,
    elevation: SolarElevation.md,
    borderRadius: SolarBorderRadius.lg,
  ),
  child: Text(
    'Solar Panel Status',
    style: context.textTheme.cardTitle,
  ),
)
```

### **11. Common Patterns**

**Status Indicators:**
```dart
// Energy status chip
Container(
  padding: EdgeInsets.symmetric(
    horizontal: SolarSpacing.sm,
    vertical: SolarSpacing.xs,
  ),
  decoration: BoxDecoration(
    color: context.colorScheme.energyHigh,
    borderRadius: BorderRadius.circular(SolarBorderRadius.sm),
  ),
  child: Text(
    'Optimal',
    style: context.textTheme.statusBadge.copyWith(
      color: Colors.white,
    ),
  ),
)
```

**Metric Cards:**
```dart
Card(
  margin: EdgeInsets.all(SolarSpacing.md),
  child: Padding(
    padding: EdgeInsets.all(SolarSpacing.lg),
    child: Column(
      children: [
        Text(
          '2.4 kW',
          style: context.textTheme.metricValue.copyWith(
            color: context.colorScheme.solarBlue,
          ),
        ),
        SizedBox(height: SolarSpacing.xs),
        Text(
          'Current Output',
          style: context.textTheme.metricLabel,
        ),
      ],
    ),
  ),
)
```

This migration guide helps maintain consistency while transitioning to the new Solar theme system!

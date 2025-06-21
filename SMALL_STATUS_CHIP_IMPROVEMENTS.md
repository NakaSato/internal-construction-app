## Small Status Chip Improvements - Enhanced Visibility

I've optimized the `ProjectStatusChip` small size to be more visible and readable while maintaining its compact nature.

### 🎯 **Key Improvements for Small Size:**

#### 1. **Enhanced Dimensions**
- **Height**: Increased from 24px to 26px (+2px)
- **Icon Size**: Increased from 14px to 15px (+1px)
- **Horizontal Padding**: Increased from 8px to 10px (+2px)
- **Vertical Padding**: Increased from 3px to 4px (+1px)

#### 2. **Improved Visual Definition**
- **Background Opacity**: Increased from 0.1 to 0.12 (+20% visibility)
- **Border Color**: Strengthened from alpha 0.3 to 0.35
- **Border Width**: Increased to 1.2px for small size (from 1px)
- **Added Subtle Shadow**: 2px blur with 1px offset for depth

#### 3. **Enhanced Typography**
- **Font Size**: Increased from 11px to 12px (+1px)
- **Font Weight**: Upgraded to 700 (bold) for small size
- **Letter Spacing**: Added 0.2px for better readability
- **Border Radius**: Increased from 10px to 12px for better appearance

#### 4. **New Factory Constructors**

```dart
// Small but highly visible chip
ProjectStatusChip.smallVisible(
  status: 'In Progress',
  showIcon: true,
  showText: true,
)

// Small visible dot
ProjectStatusDot.smallVisible(
  status: 'Active',
)
```

### 📊 **Before vs After Comparison**

| Property | Before | After | Improvement |
|----------|--------|--------|-------------|
| Height | 24px | 26px | +8% larger |
| Font Size | 11px | 12px | +9% larger |
| Font Weight | 600 | 700 | Bolder |
| Border | 1px, α=0.3 | 1.2px, α=0.35 | Stronger definition |
| Background | α=0.1 | α=0.12 | +20% visibility |
| Shadow | None | 2px blur | Added depth |

### 🎨 **Visual Benefits**

1. **Better Readability**: Larger font with bolder weight
2. **Enhanced Contrast**: Stronger borders and background
3. **Improved Definition**: Subtle shadow adds depth
4. **Maintained Compactness**: Still small but much more visible
5. **Better Spacing**: Improved padding for cleaner appearance

### 💡 **Usage Examples**

```dart
// For lists and compact spaces
ProjectStatusChip.smallVisible(
  status: 'In Progress',
)

// For even more compact spaces
ProjectStatusDot.smallVisible(
  status: 'Active',
)

// Traditional small chip (still available)
ProjectStatusChip(
  status: 'Planning',
  size: ProjectStatusChipSize.small,
)
```

### 🎯 **Perfect For**

- **List Items**: More visible in dense layouts
- **Cards**: Better prominence without taking space
- **Compact Dashboards**: Clear status indication
- **Mobile Interfaces**: Touch-friendly and readable
- **Data Tables**: Status columns with good visibility

The small status chip now provides the perfect balance between compact size and excellent visibility, making it ideal for use cases where space is limited but clarity is essential!

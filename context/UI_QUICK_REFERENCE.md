# Quick Reference: New UI System

## 🎨 Theme Colors

```dart
// Primary colors
AppTheme.primaryGreen        // #2E7D32
AppTheme.primaryGreenLight   // #4CAF50
AppTheme.primaryGreenDark    // #1B5E20

// Status colors
AppTheme.successGreen        // Success states
AppTheme.warningOrange       // Warning states
AppTheme.errorRed            // Error states
AppTheme.infoBlue            // Info states

// Backgrounds
AppTheme.backgroundLight     // #F5F5F5
AppTheme.backgroundWhite     // #FFFFFF
AppTheme.cardBackground      // #FFFFFF
```

## 📐 Spacing Constants

```dart
AppTheme.spacing4    // 4.0
AppTheme.spacing8    // 8.0
AppTheme.spacing12   // 12.0
AppTheme.spacing16   // 16.0
AppTheme.spacing24   // 24.0
AppTheme.spacing32   // 32.0
AppTheme.spacing48   // 48.0
```

## 🔄 Responsive Checks

```dart
// Via context extension (recommended)
context.isMobile      // < 600px
context.isTablet      // 600-1024px
context.isDesktop     // > 1024px
context.screenWidth   // Get width
context.screenHeight  // Get height

// Via helper class
ResponsiveHelper.isMobile(context)
ResponsiveHelper.getGridColumns(context)  // 1, 2, 3, or 4
ResponsiveHelper.getSidebarWidth(context)
```

## 📱 Responsive Widgets

```dart
// Option 1: Responsive builder
ResponsiveHelper.responsive(
  context: context,
  mobile: Text('Mobile'),
  tablet: Text('Tablet'),
  desktop: Text('Desktop'),
)

// Option 2: Manual check
if (context.isMobile) {
  return MobileLayout();
} else {
  return DesktopLayout();
}

// Option 3: Responsive value
final columns = ResponsiveHelper.getResponsiveValue(
  context: context,
  mobile: 1,
  tablet: 2,
  desktop: 4,
);
```

## 🗂️ Dashboard Layout Template

```dart
import 'package:flutter/material.dart';
import '../widgets/dashboard_layout.dart';

class MyDashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Dashboard Title',
      currentRoute: '/my-route',
      breadcrumbs: const [
        BreadcrumbItem(label: 'Home'),
        BreadcrumbItem(label: 'Current Page'),
      ],
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {/* Action */},
        ),
      ],
      onNavigate: (route) {
        // Handle navigation
        Navigator.of(context).pushNamed(route);
      },
      child: Column(
        children: [
          // Your content here
        ],
      ),
    );
  }
}
```

## 🎴 Card Styling

```dart
Card(
  elevation: 2,  // Theme default
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
  ),
  child: Padding(
    padding: EdgeInsets.all(AppTheme.spacing16),
    child: YourContent(),
  ),
)

// Or use Container with custom styling
Container(
  decoration: BoxDecoration(
    color: AppTheme.cardBackground,
    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
    boxShadow: AppTheme.cardShadow,
  ),
  padding: EdgeInsets.all(AppTheme.spacing16),
  child: YourContent(),
)
```

## 🔘 Buttons

```dart
// Elevated button (primary action)
ElevatedButton(
  onPressed: () {},
  child: Text('Primary Action'),
)

// Text button (secondary action)
TextButton(
  onPressed: () {},
  child: Text('Secondary'),
)

// Outlined button
OutlinedButton(
  onPressed: () {},
  child: Text('Outlined'),
)
```

## 📊 Status Badges

```dart
// Get color based on status
final color = AppTheme.getStatusColor('SELESAI');  // Green
final color = AppTheme.getStatusColor('PENDING');  // Orange
final color = AppTheme.getStatusColor('ERROR');    // Red

// Use in widget
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppTheme.getStatusColor(status).withOpacity(0.2),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    status,
    style: TextStyle(
      color: AppTheme.getStatusColor(status),
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

## 📈 Performance Color

```dart
// Get color based on percentage
final color = AppTheme.getPerformanceColor(85);  // Green (>=80%)
final color = AppTheme.getPerformanceColor(65);  // Orange (>=50%)
final color = AppTheme.getPerformanceColor(30);  // Red (<50%)
```

## 🎭 Gradients

```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient,
    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
  ),
)

// Or secondary gradient
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.secondaryGradient,
  ),
)
```

## 📝 Typography Examples

```dart
// Heading
Text(
  'Heading',
  style: Theme.of(context).textTheme.headlineMedium,
)

// Title
Text(
  'Title',
  style: Theme.of(context).textTheme.titleLarge,
)

// Body
Text(
  'Body text',
  style: Theme.of(context).textTheme.bodyMedium,
)

// Caption
Text(
  'Small text',
  style: Theme.of(context).textTheme.bodySmall,
)
```

## 🎯 Common Patterns

### Responsive Padding
```dart
Padding(
  padding: context.responsivePadding,
  child: YourWidget(),
)

// Or dashboard specific
Padding(
  padding: context.dashboardPadding,
  child: YourWidget(),
)
```

### Responsive Grid
```dart
GridView.count(
  crossAxisCount: context.gridColumns,  // 1, 2, 3, or 4
  children: items.map((item) => ItemCard(item)).toList(),
)
```

### Loading State
```dart
if (isLoading) {
  return Center(
    child: CircularProgressIndicator(
      color: AppTheme.primaryGreen,
    ),
  );
}
```

### Error State
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppTheme.errorRed.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      Icon(Icons.error_outline, color: AppTheme.errorRed),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          errorMessage,
          style: TextStyle(color: AppTheme.errorRed),
        ),
      ),
    ],
  ),
)
```

---

## 🔍 Tips & Best Practices

1. **Always use theme colors** instead of hardcoded colors
2. **Use responsive helpers** for consistent behavior across devices
3. **Leverage context extensions** for cleaner code
4. **Wrap new dashboards** with DashboardLayout for consistency
5. **Use AppTheme spacing constants** instead of magic numbers
6. **Test on multiple screen sizes** (mobile, tablet, desktop)

---

## 📚 Import Statements

```dart
// Theme
import '../config/app_theme.dart';

// Responsive
import '../config/responsive_helper.dart';

// Layout
import '../widgets/dashboard_layout.dart';

// Sidebar (if needed standalone)
import '../widgets/sidebar_widget.dart';
```

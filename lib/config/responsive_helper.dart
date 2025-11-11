import 'package:flutter/material.dart';

/// Responsive Helper
/// Mengelola breakpoints dan responsive behavior untuk berbagai ukuran layar
/// 
/// Breakpoints (sama seperti octax-app/flutter-dashboard):
/// - Mobile: < 600px
/// - Tablet: 600px - 1024px
/// - Desktop: > 1024px

class ResponsiveHelper {
  // ==================== BREAKPOINTS ====================
  
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  // ==================== DEVICE TYPE CHECKS ====================
  
  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  /// Check if device is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  /// Check if device is mobile or tablet (not desktop)
  static bool isMobileOrTablet(BuildContext context) {
    return !isDesktop(context);
  }
  
  // ==================== RESPONSIVE BUILDER ====================
  
  /// Build widget based on device type
  static Widget responsive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    required Widget desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? desktop;
    } else {
      return desktop;
    }
  }
  
  /// Build widget with custom breakpoints
  static Widget responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
    required Widget Function(T value) builder,
  }) {
    T value;
    if (isMobile(context)) {
      value = mobile;
    } else if (isTablet(context)) {
      value = tablet ?? desktop;
    } else {
      value = desktop;
    }
    return builder(value);
  }
  
  // ==================== VALUE HELPERS ====================
  
  /// Get responsive value based on device type
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet ?? desktop;
    } else {
      return desktop;
    }
  }
  
  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  // ==================== LAYOUT HELPERS ====================
  
  /// Get number of columns for grid based on screen size
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else if (isLargeDesktop(context)) {
      return 4;
    } else {
      return 3;
    }
  }
  
  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }
  
  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    required double mobile,
    double? tablet,
    required double desktop,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  /// Get sidebar width based on screen size
  static double getSidebarWidth(BuildContext context) {
    if (isMobile(context)) {
      return 280; // Full drawer
    } else if (isTablet(context)) {
      return 240; // Narrow sidebar
    } else {
      return 260; // Standard sidebar
    }
  }
  
  /// Check if sidebar should be drawer (mobile) or permanent (desktop)
  static bool shouldUseSidebarDrawer(BuildContext context) {
    return isMobile(context);
  }
  
  /// Check if sidebar should be collapsed by default
  static bool shouldCollapseSidebarByDefault(BuildContext context) {
    return isTablet(context);
  }
  
  // ==================== CONTENT WIDTH ====================
  
  /// Get max content width for centered layouts
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 900;
    } else if (isLargeDesktop(context)) {
      return 1400;
    } else {
      return 1200;
    }
  }
  
  /// Get dashboard content padding
  static EdgeInsets getDashboardContentPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(24);
    }
  }
  
  // ==================== ORIENTATION ====================
  
  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  // ==================== ASPECT RATIO ====================
  
  /// Get card aspect ratio based on screen size
  static double getCardAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 1.5; // Wider cards on mobile
    } else {
      return 1.3; // Squarer cards on desktop
    }
  }
  
  // ==================== SPACING ====================
  
  /// Get responsive spacing between widgets
  static double getSpacing(BuildContext context, {
    double mobile = 12,
    double? tablet,
    double desktop = 24,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Extension for BuildContext to access responsive helpers easily
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isMobileOrTablet => ResponsiveHelper.isMobileOrTablet(this);
  
  double get screenWidth => ResponsiveHelper.screenWidth(this);
  double get screenHeight => ResponsiveHelper.screenHeight(this);
  
  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  EdgeInsets get dashboardPadding => ResponsiveHelper.getDashboardContentPadding(this);
  
  int get gridColumns => ResponsiveHelper.getGridColumns(this);
  double get sidebarWidth => ResponsiveHelper.getSidebarWidth(this);
}

import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Toast & Snackbar Helper
/// Utility untuk menampilkan notifications dengan styling konsisten
/// 
/// Usage:
/// ```dart
/// ToastHelper.showSuccess(context, 'Data berhasil disimpan!');
/// ToastHelper.showError(context, 'Gagal memuat data');
/// ToastHelper.showWarning(context, 'Perhatian: Data tidak lengkap');
/// ToastHelper.showInfo(context, 'Proses sedang berjalan...');
/// ```

class ToastHelper {
  // Duration constants
  static const Duration _mediumDuration = Duration(seconds: 3);
  static const Duration _longDuration = Duration(seconds: 5);
  
  /// Show success toast
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppTheme.successGreen,
      icon: Icons.check_circle,
      duration: duration ?? _mediumDuration,
      action: action,
    );
  }
  
  /// Show error toast
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppTheme.errorRed,
      icon: Icons.error,
      duration: duration ?? _longDuration,
      action: action,
    );
  }
  
  /// Show warning toast
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppTheme.warningOrange,
      icon: Icons.warning_amber,
      duration: duration ?? _mediumDuration,
      action: action,
    );
  }
  
  /// Show info toast
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppTheme.infoBlue,
      icon: Icons.info,
      duration: duration ?? _mediumDuration,
      action: action,
    );
  }
  
  /// Show loading toast
  static void showLoading(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppTheme.textSecondary,
      icon: null,
      duration: duration ?? _longDuration,
      showLoading: true,
    );
  }
  
  /// Show custom toast
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    IconData? icon,
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: backgroundColor ?? AppTheme.textPrimary,
      icon: icon,
      duration: duration ?? _mediumDuration,
      action: action,
    );
  }
  
  /// Internal method to show snackbar
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration? duration,
    SnackBarAction? action,
    bool showLoading = false,
  }) {
    // Clear existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();
    
    // Show new snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Icon or loading indicator
            if (showLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else if (icon != null)
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            
            if (icon != null || showLoading)
              const SizedBox(width: 12),
            
            // Message
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration ?? _mediumDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: action,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  /// Hide current snackbar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
  
  /// Clear all snackbars
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

/// Toast with action button
class ToastAction {
  /// Show success toast with action
  static void showSuccessWithAction(
    BuildContext context,
    String message, {
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    ToastHelper.showSuccess(
      context,
      message,
      action: SnackBarAction(
        label: actionLabel,
        textColor: Colors.white,
        onPressed: onAction,
      ),
    );
  }
  
  /// Show error toast with retry action
  static void showErrorWithRetry(
    BuildContext context,
    String message, {
    required VoidCallback onRetry,
  }) {
    ToastHelper.showError(
      context,
      message,
      action: SnackBarAction(
        label: 'Coba Lagi',
        textColor: Colors.white,
        onPressed: onRetry,
      ),
    );
  }
  
  /// Show undo action toast
  static void showUndo(
    BuildContext context,
    String message, {
    required VoidCallback onUndo,
  }) {
    ToastHelper.show(
      context,
      message,
      backgroundColor: AppTheme.textPrimary,
      icon: Icons.delete,
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppTheme.warningOrange,
        onPressed: onUndo,
      ),
    );
  }
}

/// Overlay toast (non-blocking)
/// Shows toast that doesn't block user interaction
class OverlayToast {
  static OverlayEntry? _currentOverlay;
  
  /// Show overlay toast
  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? backgroundColor,
    Duration? duration,
    ToastPosition position = ToastPosition.bottom,
  }) {
    // Remove existing overlay
    _currentOverlay?.remove();
    
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position == ToastPosition.top ? 80 : null,
        bottom: position == ToastPosition.bottom ? 80 : null,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor ?? AppTheme.textPrimary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);
    
    // Auto remove after duration
    Future.delayed(duration ?? const Duration(seconds: 2), () {
      overlayEntry.remove();
      _currentOverlay = null;
    });
  }
  
  /// Hide current overlay
  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

/// Toast position enum
enum ToastPosition {
  top,
  bottom,
}

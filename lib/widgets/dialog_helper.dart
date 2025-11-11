import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Custom Dialog Components
/// Reusable dialog components dengan consistent styling
/// 
/// Includes:
/// - Confirmation dialog
/// - Form dialog
/// - Info dialog
/// - Custom bottom sheet
/// - Alert dialogs

class DialogHelper {
  /// Show confirmation dialog
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isDangerous ? Icons.warning_amber : Icons.help_outline,
              color: isDangerous ? AppTheme.warningOrange : AppTheme.infoBlue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous
                ? ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  /// Show delete confirmation
  static Future<bool> showDeleteConfirmation(
    BuildContext context, {
    required String itemName,
  }) async {
    return showConfirmation(
      context,
      title: 'Delete $itemName?',
      message: 'This action cannot be undone. Are you sure you want to delete this $itemName?',
      confirmText: 'Delete',
      isDangerous: true,
    );
  }
  
  /// Show info dialog
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              icon ?? Icons.info_outline,
              color: iconColor ?? AppTheme.infoBlue,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Show success dialog
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showInfo(
      context,
      title: title,
      message: message,
      icon: Icons.check_circle,
      iconColor: AppTheme.successGreen,
    );
  }
  
  /// Show error dialog
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.errorRed,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  /// Show loading dialog
  static void showLoading(
    BuildContext context, {
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Expanded(
                child: Text(message ?? 'Loading...'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  /// Show input dialog
  static Future<String?> showInput(
    BuildContext context, {
    required String title,
    String? hint,
    String? initialValue,
    String? label,
    int? maxLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              labelText: label,
            ),
            maxLines: maxLines ?? 1,
            keyboardType: keyboardType,
            validator: validator,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(controller.text);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    
    controller.dispose();
    return result;
  }
  
  /// Show custom dialog
  static Future<T?> showCustom<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }
}

/// Custom Bottom Sheet Helper
class BottomSheetHelper {
  /// Show modal bottom sheet
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusLarge),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }
  
  /// Show options bottom sheet
  static Future<T?> showOptions<T>(
    BuildContext context, {
    required String title,
    required List<BottomSheetOption<T>> options,
  }) async {
    return show<T>(
      context,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(height: 1),
            
            // Options
            ...options.map((option) {
              return ListTile(
                leading: option.icon != null
                    ? Icon(option.icon, color: option.color)
                    : null,
                title: Text(
                  option.label,
                  style: TextStyle(color: option.color),
                ),
                onTap: () => Navigator.of(context).pop(option.value),
              );
            }),
            
            // Cancel button
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet option
class BottomSheetOption<T> {
  final String label;
  final T value;
  final IconData? icon;
  final Color? color;
  
  const BottomSheetOption({
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });
}

/// Custom alert dialog widget
class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;
  
  const CustomAlertDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.actions,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? AppTheme.primaryGreen),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(title),
          ),
        ],
      ),
      content: content ?? (message != null ? Text(message!) : null),
      actions: actions,
    );
  }
}

/// Form dialog widget
class FormDialog extends StatefulWidget {
  final String title;
  final List<FormField> fields;
  final Future<bool> Function(Map<String, dynamic> data)? onSubmit;
  
  const FormDialog({
    super.key,
    required this.title,
    required this.fields,
    this.onSubmit,
  });

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: field.label,
                    hintText: field.hint,
                  ),
                  initialValue: field.initialValue,
                  keyboardType: field.keyboardType,
                  maxLines: field.maxLines,
                  validator: field.validator,
                  onSaved: (value) {
                    _formData[field.key] = value;
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
  
  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      
      setState(() => _isSubmitting = true);
      
      try {
        final success = await widget.onSubmit?.call(_formData) ?? true;
        if (mounted) {
          setState(() => _isSubmitting = false);
          if (success) {
            Navigator.of(context).pop(_formData);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }
}

/// Form field definition
class FormField {
  final String key;
  final String label;
  final String? hint;
  final String? initialValue;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;
  
  const FormField({
    required this.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.keyboardType,
    this.maxLines,
    this.validator,
  });
}

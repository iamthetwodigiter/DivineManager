import 'package:divine_manager/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class UtilService {
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  static String formatExpiryDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Expired';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return '$difference days';
    }
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!_isValidContext(context)) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      
      try {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.cardColor),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      } catch (e) {
        debugPrint('Success: $message');
      }
    });
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    if (!_isValidContext(context)) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      
      try {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      } catch (e) {
        debugPrint('Error: $message');
      }
    });
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    if (!_isValidContext(context)) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      
      try {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.primaryOrange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      } catch (e) {
        debugPrint('Warning: $message');
      }
    });
  }
  
  static bool _isValidContext(BuildContext context) {
    try {
      return context.mounted && context.findAncestorWidgetOfExactType<Scaffold>() != null;
    } catch (e) {
      return false;
    }
  }

  static Color getRankColor(int index) {
    switch (index) {
      case 0:
        return AppTheme.primaryOrange;
      case 1:
        return AppTheme.primaryGrey;
      case 2:
        return AppTheme.primaryBrown;
      default:
        return AppTheme.primaryColor;
    }
  }
}

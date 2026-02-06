import 'package:flutter/material.dart';

class SnackbarUtils {
  /// Shows a success snackbar with improved UI
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Shows an error snackbar with improved UI
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Shows a warning snackbar with improved UI
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF59E0B),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Shows an info snackbar with improved UI
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Shows a loading snackbar with improved UI
  static void showLoading(BuildContext context, {required String message}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6B7C32),
        duration: const Duration(days: 1), // Long duration for loading
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Hides any currently displayed snackbar
  static void hide(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

/// Extension to extract clean error messages from exceptions
extension ExceptionExtension on Exception {
  String get cleanMessage {
    final message = toString();

    // Remove "Exception: " prefix
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    // Handle JSON error responses - extract message or error field
    if (message.contains('{') && message.contains('}')) {
      try {
        final jsonStart = message.indexOf('{');
        final jsonEnd = message.lastIndexOf('}') + 1;
        if (jsonStart != -1 && jsonEnd > jsonStart) {
          final jsonStr = message.substring(jsonStart, jsonEnd);
          // Try to parse JSON and extract meaningful error message
          if (jsonStr.contains('"error"') || jsonStr.contains('"message"')) {
            // Extract error message from JSON-like string
            final errorMatch = RegExp(
              r'"error"\s*:\s*"([^"]+)"',
            ).firstMatch(jsonStr);
            if (errorMatch != null) {
              return errorMatch.group(1) ?? 'An error occurred';
            }
            final messageMatch = RegExp(
              r'"message"\s*:\s*"([^"]+)"',
            ).firstMatch(jsonStr);
            if (messageMatch != null) {
              return messageMatch.group(1) ?? 'An error occurred';
            }
          }
        }
      } catch (e) {
        // If JSON parsing fails, continue with other methods
      }
    }

    // Handle common API error patterns
    if (message.contains('Failed to')) {
      final parts = message.split(':');
      if (parts.length >= 2) {
        // Extract the main error message, skip status codes and technical details
        final mainMessage = parts[0].trim();
        final details = parts.sublist(1).join(':').trim();

        // If details contain status codes or technical info, just return main message
        if (details.contains(RegExp(r'\d{3}')) ||
            details.contains('Response:') ||
            details.contains('{')) {
          return mainMessage;
        }

        // Otherwise return the clean part
        return details;
      }
    }

    // Handle network errors
    if (message.contains('SocketException') ||
        message.contains('TimeoutException')) {
      return 'Network connection error. Please check your internet connection.';
    }

    // Handle format errors
    if (message.contains('FormatException')) {
      return 'Invalid response format. Please try again.';
    }

    // Handle authentication errors
    if (message.contains('Invalid credentials') ||
        message.contains('Unauthorized') ||
        message.contains('401')) {
      return 'Invalid credentials. Please check your login details.';
    }

    // Handle server errors
    if (message.contains('500') || message.contains('Internal Server Error')) {
      return 'Server error. Please try again later.';
    }

    // Default: return the message as is
    return message;
  }
}

/// Extension for dynamic error handling
extension DynamicErrorExtension on dynamic {
  String get cleanMessage {
    if (this is Exception) {
      return (this as Exception).cleanMessage;
    }

    final message = toString();

    // Remove "Exception: " prefix
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    // Handle JSON error responses - extract message or error field
    if (message.contains('{') && message.contains('}')) {
      try {
        final jsonStart = message.indexOf('{');
        final jsonEnd = message.lastIndexOf('}') + 1;
        if (jsonStart != -1 && jsonEnd > jsonStart) {
          final jsonStr = message.substring(jsonStart, jsonEnd);
          // Try to parse JSON and extract meaningful error message
          if (jsonStr.contains('"error"') || jsonStr.contains('"message"')) {
            // Extract error message from JSON-like string
            final errorMatch = RegExp(
              r'"error"\s*:\s*"([^"]+)"',
            ).firstMatch(jsonStr);
            if (errorMatch != null) {
              return errorMatch.group(1) ?? 'An error occurred';
            }
            final messageMatch = RegExp(
              r'"message"\s*:\s*"([^"]+)"',
            ).firstMatch(jsonStr);
            if (messageMatch != null) {
              return messageMatch.group(1) ?? 'An error occurred';
            }
          }
        }
      } catch (e) {
        // If JSON parsing fails, continue with other methods
      }
    }

    // Handle common patterns
    if (message.contains('Failed to')) {
      final parts = message.split(':');
      if (parts.length >= 2) {
        final mainMessage = parts[0].trim();
        final details = parts.sublist(1).join(':').trim();

        if (details.contains(RegExp(r'\d{3}')) ||
            details.contains('Response:') ||
            details.contains('{')) {
          return mainMessage;
        }

        return details;
      }
    }

    // Handle authentication errors
    if (message.contains('Invalid credentials') ||
        message.contains('Unauthorized') ||
        message.contains('401')) {
      return 'Invalid credentials. Please check your login details.';
    }

    // Handle server errors
    if (message.contains('500') || message.contains('Internal Server Error')) {
      return 'Server error. Please try again later.';
    }

    return message;
  }
}

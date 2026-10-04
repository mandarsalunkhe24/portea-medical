import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme.dart';

class AppUtils {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Formats date: "15 Oct 2026"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Formats time: "10:00 AM"
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  /// Formats full date and time: "15 Oct 2026, 10:00 AM"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  /// Formats month & year: "October 2026"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Safely make phone calls with fallback snackbar
  static Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          showToast(
            context,
            'Unable to launch dialer on this device. Call: $cleanPhone',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showToast(
          context,
          'Calling simulated for: $cleanPhone',
          isError: false,
        );
      }
    }
  }

  /// Safely open URLs with fallback
  static Future<void> openUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          showToast(context, 'Could not open URL: $urlString', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context, 'Unable to open link', isError: true);
      }
    }
  }

  /// Pick image safely with fallback for Web and desktop
  static Future<XFile?> pickImageSafely(
    BuildContext context, {
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        showToast(
          context,
          'Image picker simulated or permission denied: $e',
          isError: false,
        );
      }
      return null;
    }
  }

  /// Modern snackbar toast
  static void showToast(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color bgColor = const Color(0xFF1E293B);
    IconData icon = Icons.info_outline;

    if (isError) {
      bgColor = AppTheme.emergencyRed;
      icon = Icons.error_outline;
    } else if (isSuccess) {
      bgColor = AppTheme.successGreen;
      icon = Icons.check_circle_outline;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
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
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: duration,
      ),
    );
  }

  /// Responsive layout helper
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  static double contentMaxWidth(BuildContext context) {
    return 1000.0;
  }
}

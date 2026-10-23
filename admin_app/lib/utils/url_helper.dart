import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper utility for safely launching telephone, email, and web links
/// across administrative desktop and mobile environments.
class UrlHelper {
  /// Launches telephone dialer with sanitized digits
  static Future<void> launchPhone(BuildContext context, String rawPhone) async {
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) return;

    final hasPlus = trimmed.startsWith('+');
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    final dialNumber = hasPlus ? '+$digitsOnly' : digitsOnly;

    final Uri phoneUri = Uri(scheme: 'tel', path: dialNumber);

    try {
      final launched = await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showCopyFallback(context, label: 'Phone Number', value: trimmed);
      }
    } catch (_) {
      if (context.mounted) {
        _showCopyFallback(context, label: 'Phone Number', value: trimmed);
      }
    }
  }

  /// Launches default email client with optional subject and body
  static Future<void> launchEmail(
    BuildContext context,
    String email, {
    String? subject,
    String? body,
  }) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;

    final queryParameters = <String, String>{};
    if (subject != null && subject.isNotEmpty) {
      queryParameters['subject'] = subject;
    }
    if (body != null && body.isNotEmpty) {
      queryParameters['body'] = body;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: trimmed,
      query: queryParameters.isNotEmpty
          ? queryParameters.entries
              .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
              .join('&')
          : null,
    );

    try {
      final launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showCopyFallback(context, label: 'Email Address', value: trimmed);
      }
    } catch (_) {
      if (context.mounted) {
        _showCopyFallback(context, label: 'Email Address', value: trimmed);
      }
    }
  }

  static void _showCopyFallback(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label ($value) copied to clipboard.'),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: const Color(0xFF38BDF8),
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}

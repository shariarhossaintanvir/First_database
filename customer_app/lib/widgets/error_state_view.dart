import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable error and offline state view with friendly messaging and retry action
class ErrorStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const ErrorStateView({
    super.key,
    this.icon = Icons.error_outline_rounded,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
  });

  /// Factory constructor specifically for network / offline situations
  factory ErrorStateView.offline({VoidCallback? onRetry}) {
    return ErrorStateView(
      icon: Icons.wifi_off_rounded,
      title: 'Connection Lost',
      message: 'Please check your internet connection and try reloading.',
      onRetry: onRetry,
      retryLabel: 'Reconnect',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space32,
          vertical: AppTheme.space40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error icon badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.statusError.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.statusError.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppTheme.statusError,
              ),
            ),
            const SizedBox(height: AppTheme.space20),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.headline.copyWith(
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: AppTheme.space8),

            // Message
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.body.copyWith(
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
            ),

            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.space24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

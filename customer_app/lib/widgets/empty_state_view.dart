import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable empty state view with structured hierarchy and optional action
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget? customAction;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
    this.customAction,
  });

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
            // Icon container with subtle dark-layer border
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderSubtle, width: 1.5),
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: AppTheme.space24),

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

            // Description
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: AppTheme.body.copyWith(
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
            ),

            // Action button
            if (customAction != null) ...[
              const SizedBox(height: AppTheme.space24),
              customAction!,
            ] else if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: AppTheme.space24),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

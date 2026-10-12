import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Clean SaaS empty state view for admin tables, filtered queries, and queues
class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget? customAction;

  const AdminEmptyState({
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
          horizontal: AdminTheme.space32,
          vertical: AdminTheme.space40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AdminTheme.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AdminTheme.borderSubtle, width: 1.5),
              ),
              child: Icon(
                icon,
                size: 28,
                color: AdminTheme.textMuted,
              ),
            ),
            const SizedBox(height: AdminTheme.space16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AdminTheme.headline.copyWith(
                fontSize: 16,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: AdminTheme.space6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: AdminTheme.body.copyWith(
                  color: AdminTheme.textMuted,
                  height: 1.45,
                ),
              ),
            ),
            if (customAction != null) ...[
              const SizedBox(height: AdminTheme.space20),
              customAction!,
            ] else if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: AdminTheme.space20),
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

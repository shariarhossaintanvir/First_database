import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

enum AdminStatusBadgeVariant {
  success,
  warning,
  error,
  info,
  accent,
  neutral,
}

/// Reusable SaaS status indicator badge for admin tables and detail views
class AdminStatusBadge extends StatelessWidget {
  final String label;
  final AdminStatusBadgeVariant variant;
  final IconData? icon;
  final bool showDot;
  final bool isSmall;

  const AdminStatusBadge({
    super.key,
    required this.label,
    this.variant = AdminStatusBadgeVariant.neutral,
    this.icon,
    this.showDot = true,
    this.isSmall = false,
  });

  /// Factory constructor for order fulfillment statuses in admin
  factory AdminStatusBadge.fromOrderStatus(String status, {bool isSmall = false}) {
    final s = status.toLowerCase().trim();
    switch (s) {
      case 'delivered':
      case 'completed':
        return AdminStatusBadge(
          label: status.toUpperCase(),
          variant: AdminStatusBadgeVariant.success,
          showDot: true,
          isSmall: isSmall,
        );
      case 'shipped':
      case 'processing':
        return AdminStatusBadge(
          label: status.toUpperCase(),
          variant: AdminStatusBadgeVariant.info,
          showDot: true,
          isSmall: isSmall,
        );
      case 'confirmed':
        return AdminStatusBadge(
          label: status.toUpperCase(),
          variant: AdminStatusBadgeVariant.accent,
          showDot: true,
          isSmall: isSmall,
        );
      case 'cancelled':
      case 'failed':
        return AdminStatusBadge(
          label: status.toUpperCase(),
          variant: AdminStatusBadgeVariant.error,
          showDot: true,
          isSmall: isSmall,
        );
      case 'pending':
      default:
        return AdminStatusBadge(
          label: status.toUpperCase(),
          variant: AdminStatusBadgeVariant.warning,
          showDot: true,
          isSmall: isSmall,
        );
    }
  }

  /// Factory constructor for stock / inventory status in admin
  factory AdminStatusBadge.fromStock(int stock, {bool isAvailable = true, bool isSmall = true}) {
    if (!isAvailable) {
      return AdminStatusBadge(
        label: 'INACTIVE',
        variant: AdminStatusBadgeVariant.neutral,
        showDot: true,
        isSmall: isSmall,
      );
    }
    if (stock <= 0) {
      return AdminStatusBadge(
        label: 'OUT OF STOCK',
        variant: AdminStatusBadgeVariant.error,
        showDot: true,
        isSmall: isSmall,
      );
    }
    if (stock <= 5) {
      return AdminStatusBadge(
        label: 'LOW STOCK ($stock)',
        variant: AdminStatusBadgeVariant.warning,
        showDot: true,
        isSmall: isSmall,
      );
    }
    return AdminStatusBadge(
      label: 'IN STOCK ($stock)',
      variant: AdminStatusBadgeVariant.success,
      showDot: true,
      isSmall: isSmall,
    );
  }

  Color _getColor() {
    switch (variant) {
      case AdminStatusBadgeVariant.success:
        return AdminTheme.statusSuccess;
      case AdminStatusBadgeVariant.warning:
        return AdminTheme.statusWarning;
      case AdminStatusBadgeVariant.error:
        return AdminTheme.statusError;
      case AdminStatusBadgeVariant.info:
        return AdminTheme.statusInfo;
      case AdminStatusBadgeVariant.accent:
        return AdminTheme.accent;
      case AdminStatusBadgeVariant.neutral:
        return AdminTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final horizontalPadding = isSmall ? AdminTheme.space8 : AdminTheme.space10;
    final verticalPadding = isSmall ? AdminTheme.space2 : AdminTheme.space4;
    final fontSize = isSmall ? 10.0 : 11.0;
    final dotSize = isSmall ? 5.0 : 6.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: isSmall ? AdminTheme.roundedXs : AdminTheme.roundedSm,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: isSmall ? AdminTheme.space4 : AdminTheme.space6),
          ] else if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: color),
            SizedBox(width: isSmall ? AdminTheme.space4 : AdminTheme.space6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

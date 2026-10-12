import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatusBadgeVariant {
  success,
  warning,
  error,
  info,
  accent,
  neutral,
}

/// Reusable status badge / pill component with accessible contrast
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeVariant variant;
  final IconData? icon;
  final bool showDot;
  final bool isSmall;
  final Color? customColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
    this.icon,
    this.showDot = false,
    this.isSmall = false,
    this.customColor,
  });

  /// Factory constructor for order fulfillment statuses
  factory StatusBadge.fromOrderStatus(String status, {bool isSmall = false}) {
    final s = status.toLowerCase().trim();
    switch (s) {
      case 'delivered':
      case 'completed':
        return StatusBadge(
          label: status.toUpperCase(),
          variant: StatusBadgeVariant.success,
          showDot: true,
          isSmall: isSmall,
        );
      case 'shipped':
      case 'processing':
        return StatusBadge(
          label: status.toUpperCase(),
          variant: StatusBadgeVariant.info,
          showDot: true,
          isSmall: isSmall,
        );
      case 'confirmed':
        return StatusBadge(
          label: status.toUpperCase(),
          variant: StatusBadgeVariant.accent,
          showDot: true,
          isSmall: isSmall,
        );
      case 'cancelled':
      case 'failed':
        return StatusBadge(
          label: status.toUpperCase(),
          variant: StatusBadgeVariant.error,
          showDot: true,
          isSmall: isSmall,
        );
      case 'pending':
      default:
        return StatusBadge(
          label: status.toUpperCase(),
          variant: StatusBadgeVariant.warning,
          showDot: true,
          isSmall: isSmall,
        );
    }
  }

  /// Factory constructor for stock / inventory availability
  factory StatusBadge.fromStock(int stock, {bool isAvailable = true, bool isSmall = true}) {
    if (!isAvailable || stock <= 0) {
      return StatusBadge(
        label: stock <= 0 ? 'OUT OF STOCK' : 'UNAVAILABLE',
        variant: StatusBadgeVariant.error,
        showDot: true,
        isSmall: isSmall,
      );
    } else if (stock <= 5) {
      return StatusBadge(
        label: 'ONLY $stock LEFT',
        variant: StatusBadgeVariant.warning,
        showDot: true,
        isSmall: isSmall,
      );
    }
    return StatusBadge(
      label: 'IN STOCK',
      variant: StatusBadgeVariant.success,
      showDot: true,
      isSmall: isSmall,
    );
  }

  Color _getColor() {
    if (customColor != null) return customColor!;
    switch (variant) {
      case StatusBadgeVariant.success:
        return AppTheme.statusSuccess;
      case StatusBadgeVariant.warning:
        return AppTheme.secondaryWarm;
      case StatusBadgeVariant.error:
        return AppTheme.statusError;
      case StatusBadgeVariant.info:
        return AppTheme.statusInfo;
      case StatusBadgeVariant.accent:
        return AppTheme.accent;
      case StatusBadgeVariant.neutral:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final horizontalPadding = isSmall ? AppTheme.space8 : AppTheme.space10;
    final verticalPadding = isSmall ? AppTheme.space2 : AppTheme.space4;
    final fontSize = isSmall ? 10.0 : 11.0;
    final dotSize = isSmall ? 5.0 : 6.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: isSmall ? AppTheme.roundedXs : AppTheme.roundedSm,
        border: Border.all(
          color: color.withValues(alpha: 0.35),
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
            SizedBox(width: isSmall ? AppTheme.space4 : AppTheme.space6),
          ] else if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: color),
            SizedBox(width: isSmall ? AppTheme.space4 : AppTheme.space6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

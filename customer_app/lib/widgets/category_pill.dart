import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable category and subcategory browsing pill (Daraz / Chaldal inspired)
class CategoryPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;
  final Color? activeColor;

  const CategoryPill({
    super.key,
    required this.label,
    this.icon,
    this.count,
    this.isSelected = false,
    required this.onTap,
    this.isCompact = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = activeColor ?? AppTheme.accent;
    final horizontalPadding = isCompact ? AppTheme.space12 : AppTheme.space16;
    final verticalPadding = isCompact ? AppTheme.space6 : AppTheme.space10;
    final fontSize = isCompact ? 12.0 : 13.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.roundedSm,
        child: AnimatedContainer(
          duration: AppTheme.durationFast,
          curve: AppTheme.curveDefault,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected ? effectiveAccent.withValues(alpha: 0.15) : AppTheme.surfaceCard,
            borderRadius: AppTheme.roundedSm,
            border: Border.all(
              color: isSelected ? effectiveAccent : AppTheme.borderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: fontSize + 3,
                  color: isSelected ? effectiveAccent : AppTheme.textMuted,
                ),
                SizedBox(width: isCompact ? AppTheme.space4 : AppTheme.space6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? effectiveAccent : AppTheme.textSecondary,
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: AppTheme.space6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? effectiveAccent.withValues(alpha: 0.2)
                        : AppTheme.surfaceElevated,
                    borderRadius: AppTheme.roundedXs,
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: isSelected ? effectiveAccent : AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Reusable SaaS KPI metric card for admin dashboard overviews
class AdminMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final String? trendLabel;
  final bool isTrendPositive;
  final Color? accentColor;

  const AdminMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.trendLabel,
    this.isTrendPositive = true,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeAccent = accentColor ?? AdminTheme.accent;

    return Container(
      padding: const EdgeInsets.all(AdminTheme.space20),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceCard,
        borderRadius: AdminTheme.roundedMd,
        border: Border.all(color: AdminTheme.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Title and Icon badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AdminTheme.label.copyWith(
                    color: AdminTheme.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: AdminTheme.space8),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: activeAccent.withValues(alpha: 0.12),
                  borderRadius: AdminTheme.roundedSm,
                  border: Border.all(
                    color: activeAccent.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: activeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminTheme.space12),

          // Metric Value
          Text(
            value,
            style: AdminTheme.metricLarge.copyWith(
              color: AdminTheme.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AdminTheme.space8),

          // Footer: Trend or Subtitle
          if (trendLabel != null)
            Row(
              children: [
                Icon(
                  isTrendPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 16,
                  color: isTrendPositive
                      ? AdminTheme.statusSuccess
                      : AdminTheme.statusError,
                ),
                const SizedBox(width: AdminTheme.space4),
                Text(
                  trendLabel!,
                  style: TextStyle(
                    color: isTrendPositive
                        ? AdminTheme.statusSuccess
                        : AdminTheme.statusError,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: AdminTheme.space6),
                  Text(
                    subtitle!,
                    style: AdminTheme.bodySmall.copyWith(
                      color: AdminTheme.textMuted,
                    ),
                  ),
                ],
              ],
            )
          else if (subtitle != null)
            Text(
              subtitle!,
              style: AdminTheme.bodySmall.copyWith(
                color: AdminTheme.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

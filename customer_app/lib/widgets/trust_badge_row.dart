import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Individual trust badge descriptor
class TrustBadgeData {
  final IconData icon;
  final String title;
  final String subtitle;

  const TrustBadgeData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

/// Trust and assurance badge row for product details and storefront footer (Daraz / Pickaboo / Rokomari inspired)
class TrustBadgeRow extends StatelessWidget {
  final List<TrustBadgeData>? items;

  const TrustBadgeRow({
    super.key,
    this.items,
  });

  static const List<TrustBadgeData> defaultBadges = [
    TrustBadgeData(
      icon: Icons.verified_user_outlined,
      title: '100% Authentic',
      subtitle: 'Original guaranteed',
    ),
    TrustBadgeData(
      icon: Icons.local_shipping_outlined,
      title: 'Fast Delivery',
      subtitle: 'Across Bangladesh',
    ),
    TrustBadgeData(
      icon: Icons.assignment_return_outlined,
      title: 'Easy Returns',
      subtitle: '7-day policy',
    ),
    TrustBadgeData(
      icon: Icons.security_outlined,
      title: 'Warranty Support',
      subtitle: 'Official warranty',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final badgeItems = items ?? defaultBadges;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: AppTheme.roundedMd,
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // If wide enough (e.g. desktop web or tablet), show in a single row
          final isWide = constraints.maxWidth >= 600;

          if (isWide) {
            return Row(
              children: [
                for (int i = 0; i < badgeItems.length; i++) ...[
                  if (i > 0)
                    Container(
                      height: 32,
                      width: 1,
                      color: AppTheme.borderSubtle,
                      margin: const EdgeInsets.symmetric(horizontal: AppTheme.space8),
                    ),
                  Expanded(
                    child: _buildBadgeItem(badgeItems[i]),
                  ),
                ],
              ],
            );
          }

          // Mobile 2x2 grid layout
          return Wrap(
            runSpacing: AppTheme.space16,
            spacing: AppTheme.space16,
            children: [
              for (final item in badgeItems)
                SizedBox(
                  width: (constraints.maxWidth - AppTheme.space16) / 2,
                  child: _buildBadgeItem(item),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadgeItem(TrustBadgeData item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.accentSubtle,
            borderRadius: AppTheme.roundedSm,
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
          ),
          child: Icon(
            item.icon,
            size: 18,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: AppTheme.space10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

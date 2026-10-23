import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/url_helper.dart';

/// Comprehensive responsive footer for the ShopEase storefront.
/// Provides legitimate navigation, verified contact channels (clickable tel and mailto),
/// policy information, and a dynamic copyright year.
class StorefrontFooter extends StatelessWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const StorefrontFooter({super.key, this.onNavigateTab});

  static const String supportEmail = 'support@shopease.com';
  static const String supportPhone = '+880 1700-000000';

  void _showPolicyDialog(BuildContext context, {required String title, required String content}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: const BorderSide(color: AppTheme.borderSubtle),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border(
          top: BorderSide(color: AppTheme.borderSubtle, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Columns
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 768;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Column 1: Brand & Bio
                        Expanded(
                          flex: 4,
                          child: _buildBrandColumn(context),
                        ),
                        const SizedBox(width: 32),

                        // Column 2: Quick Navigation
                        Expanded(
                          flex: 3,
                          child: _buildNavColumn(context),
                        ),
                        const SizedBox(width: 24),

                        // Column 3: Contact & Customer Care
                        Expanded(
                          flex: 4,
                          child: _buildContactColumn(context),
                        ),
                      ],
                    );
                  }

                  // Mobile Column layout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBrandColumn(context),
                      const SizedBox(height: 28),
                      const Divider(color: AppTheme.borderSubtle, height: 1),
                      const SizedBox(height: 24),
                      _buildNavColumn(context),
                      const SizedBox(height: 28),
                      const Divider(color: AppTheme.borderSubtle, height: 1),
                      const SizedBox(height: 24),
                      _buildContactColumn(context),
                    ],
                  );
                },
              ),

              const SizedBox(height: 36),
              const Divider(color: AppTheme.borderSubtle, height: 1),
              const SizedBox(height: 20),

              // Bottom Bar: Dynamic Copyright & Policy Badges
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  Text(
                    '© $currentYear ShopEase Bangladesh. All rights reserved.',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/terms-and-conditions'),
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      InkWell(
                        onTap: () => _showPolicyDialog(
                          context,
                          title: 'Cancellation & Return Policy',
                          content:
                              'ShopEase Bangladesh Customer Assurance:\n\n'
                              '• Order Cancellation: Customers may request cancellation of any order in "Pending" status directly through the My Orders screen.\n'
                              '• Damaged or Incorrect Goods: If an item received does not match the catalog specification, notify our customer care team at support@shopease.com within 24 hours of delivery.',
                        ),
                        child: const Text(
                          'Cancellation Policy',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.accentSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppTheme.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'ShopEase',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 19,
                letterSpacing: -0.4,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'ShopEase is Bangladesh’s premier multi-category e-commerce storefront delivering authentic products, direct catalog reliability, cash on delivery, and dedicated customer support.',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 14, color: AppTheme.statusSuccess),
              SizedBox(width: 6),
              Text(
                '100% Authentic Products Guaranteed',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXPLORE STORE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        _buildFooterLink('Home Storefront', () {
          onNavigateTab?.call(0);
        }),
        const SizedBox(height: 8),
        _buildFooterLink('Product Categories', () {
          onNavigateTab?.call(1);
        }),
        const SizedBox(height: 8),
        _buildFooterLink('Shopping Cart', () {
          onNavigateTab?.call(2);
        }),
        const SizedBox(height: 8),
        _buildFooterLink('Order History & Tracking', () {
          onNavigateTab?.call(3);
        }),
        const SizedBox(height: 8),
        _buildFooterLink('Customer Account Profile', () {
          onNavigateTab?.call(4);
        }),
      ],
    );
  }

  Widget _buildContactColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CUSTOMER CARE & CONTACT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        // Clickable Email link
        InkWell(
          onTap: () => UrlHelper.launchEmail(
            context,
            supportEmail,
            subject: 'ShopEase Customer Support Inquiry',
          ),
          borderRadius: BorderRadius.circular(4),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email_outlined, size: 16, color: AppTheme.accent),
                SizedBox(width: 8),
                Text(
                  supportEmail,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Clickable Phone link
        InkWell(
          onTap: () => UrlHelper.launchPhone(context, supportPhone),
          borderRadius: BorderRadius.circular(4),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_outlined, size: 16, color: AppTheme.accent),
                SizedBox(width: 8),
                Text(
                  supportPhone,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Delivery coverage location
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textMuted),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Headquarters: Dhaka, Bangladesh • Nationwide Delivery',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Cash on Delivery notice
        const Row(
          children: [
            Icon(Icons.payments_outlined, size: 16, color: AppTheme.textMuted),
            SizedBox(width: 8),
            Text(
              'Cash on Delivery • Safe & Secure Orders',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

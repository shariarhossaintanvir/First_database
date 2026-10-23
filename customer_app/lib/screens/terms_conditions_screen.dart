import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/url_helper.dart';

/// Dedicated, accessible Terms and Conditions page for ShopEase Storefront.
///
/// Covers acceptable use, account responsibilities, order processing,
/// Cash on Delivery terms, intellectual property, service limits,
/// and flags unresolved legal provisions for owner review.
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const String routeName = '/terms-and-conditions';

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Terms and Conditions | ShopEase',
      color: AppTheme.primary,
      child: Scaffold(
        backgroundColor: AppTheme.bgPrimary,
        appBar: AppBar(
          backgroundColor: AppTheme.bgPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            tooltip: 'Back',
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
          title: const Text(
            'Terms & Conditions',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24, vertical: AppTheme.space20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  const Text(
                    'Terms and Conditions of Use',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space8),
                  const Text(
                    'Effective Date: October 2026 | Last Updated: October 23, 2026',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space20),
                  const Divider(color: AppTheme.borderSubtle, height: 1),
                  const SizedBox(height: AppTheme.space24),

                  // Owner Review Notice
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: AppTheme.roundedMd,
                      border: Border.all(color: AppTheme.primaryMedium),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.gavel_outlined, color: AppTheme.primary, size: 22),
                        const SizedBox(width: AppTheme.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Legal Notice for Store Administration',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: AppTheme.space4),
                              Text(
                                'These Terms and Conditions set forth the operational rules governing the ShopEase e-commerce platform based on verified application capabilities (account registration, order placement, and Cash on Delivery fulfillment). Specific business terms, such as statutory dispute venue, return period, and merchant warranties, require formal owner approval and legal review.',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.space28),

                  _buildSection(
                    title: '1. Acceptance of Terms',
                    content: [
                      'By creating an account, browsing the catalog, or placing an order on ShopEase ("the Platform"), you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you must discontinue use of the platform.',
                    ],
                  ),

                  _buildSection(
                    title: '2. User Accounts & Security',
                    content: [
                      '• Account Registration: You must provide accurate, current contact and delivery information when registering an account.',
                      '• Password Confidentiality: You are responsible for safeguarding your login credentials. Notify us immediately at support@shopease.com if you suspect unauthorized access.',
                      '• Account Responsibility: You are responsible for all activities and orders placed under your authenticated account.',
                    ],
                  ),

                  _buildSection(
                    title: '3. Products, Pricing & Availability',
                    content: [
                      '• Catalog Display: All prices are listed in Bangladesh Taka (BDT / ৳) and include applicable taxes unless specified otherwise.',
                      '• Availability: Product availability is subject to live warehouse stock. While we strive to maintain accurate inventory counts, items may occasionally become unavailable before an order is processed.',
                      '• Order Confirmation: Order submission does not constitute a final binding contract of sale until verified and confirmed by our operations team.',
                    ],
                  ),

                  _buildSection(
                    title: '4. Payment by Cash on Delivery (COD)',
                    content: [
                      '• Payment Method: ShopEase operates primarily on a Cash on Delivery (COD) basis. Customers agree to remit the exact order total in cash directly to the delivery courier upon handover of the package.',
                      '• Refusal of Valid Orders: Repeated refusal to accept valid, undamaged packages ordered via Cash on Delivery may result in suspension of account ordering privileges.',
                    ],
                  ),

                  _buildSection(
                    title: '5. Acceptable Use',
                    content: [
                      'You agree not to engage in any of the following prohibited behaviors:',
                      '• Submitting fictitious orders, fake delivery addresses, or fraudulent contact information.',
                      '• Attempting to disrupt, decompile, compromise, or inject harmful code into the platform infrastructure.',
                      '• Harvesting or scraping product data or customer information without written permission.',
                    ],
                  ),

                  _buildSection(
                    title: '6. Intellectual Property',
                    content: [
                      'All brand assets, software code, UI designs, logos, and catalog content on ShopEase are the property of ShopEase or its content suppliers and are protected under applicable intellectual property laws.',
                    ],
                  ),

                  _buildSection(
                    title: '7. Service Limitations & Disclaimer',
                    content: [
                      'The platform is provided on an "as is" and "as available" basis. ShopEase makes no warranties that the service will be entirely uninterrupted or error-free during scheduled maintenance, network outages, or events beyond our reasonable control.',
                    ],
                  ),

                  _buildSection(
                    title: '8. Provisions Pending Owner & Legal Review',
                    content: [
                      'The following policies are pending formal ratification by the store owner:',
                      '• Formal Return Window: Standard 7-day inspection and return policy [Pending Formal Merchant Review].',
                      '• Governing Law & Jurisdiction: Courts of Dhaka, Bangladesh [Pending Owner Confirmation].',
                      '• Merchant Entity Details: [Pending Corporate Registration Confirmation].',
                    ],
                  ),

                  _buildSection(
                    title: '9. Contact Information',
                    content: [
                      'For questions regarding these Terms and Conditions, please contact:',
                    ],
                  ),

                  const SizedBox(height: AppTheme.space8),
                  InkWell(
                    onTap: () => UrlHelper.launchEmail(context, 'support@shopease.com', subject: 'Terms and Conditions Inquiry'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.email_outlined, size: 18, color: AppTheme.primary),
                          SizedBox(width: AppTheme.space8),
                          Text(
                            'support@shopease.com',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space6),
                  InkWell(
                    onTap: () => UrlHelper.launchPhone(context, '+880 1700-000000'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.phone_outlined, size: 18, color: AppTheme.primary),
                          SizedBox(width: AppTheme.space8),
                          Text(
                            '+880 1700-000000',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.space40),
                  const Divider(color: AppTheme.borderSubtle, height: 1),
                  const SizedBox(height: AppTheme.space20),

                  // Return action
                  Center(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.storefront_outlined, size: 18),
                      label: const Text('Return to ShopEase Storefront'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.borderStrong),
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space24, vertical: AppTheme.space12),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.roundedSm,
                        ),
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.space40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<String> content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space10),
          for (final paragraph in content)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.space6),
              child: Text(
                paragraph,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

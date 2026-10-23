import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/url_helper.dart';

/// Dedicated, accessible Privacy Policy page for ShopEase Storefront.
///
/// Accurately details data collection, Firebase authentication, Firestore storage,
/// local storage caching, and flags items requiring business owner confirmation.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String routeName = '/privacy-policy';

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Privacy Policy | ShopEase',
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
            'Privacy Policy',
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
                    'ShopEase Privacy Policy',
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
                        const Icon(Icons.info_outline, color: AppTheme.primary, size: 22),
                        const SizedBox(width: AppTheme.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Notice for Store Administration & Legal Counsel',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: AppTheme.space4),
                              Text(
                                'This Privacy Policy reflects the exact technical implementation of the ShopEase web and mobile applications (Firebase Authentication, Cloud Firestore, and client-side browser storage). Specific legal disclosures, including registered legal entity name, corporate registration number, and registered physical address, are marked for store owner confirmation prior to public marketing.',
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
                    title: '1. Information We Collect',
                    content: [
                      'We collect information necessary to provide e-commerce purchasing and order fulfillment services in Bangladesh. This includes:',
                      '• Account Credentials: Name, email address, and encrypted authentication tokens managed through Google Firebase Authentication.',
                      '• Delivery Details: Shipping address, city/region, and contact phone number supplied during profile creation or order checkout.',
                      '• Order History: Records of purchased products, quantities, purchase totals, order statuses, and selected payment methods (Cash on Delivery).',
                      '• Customer Support Communications: Inquiries and messages directed to our support team.',
                    ],
                  ),

                  _buildSection(
                    title: '2. Local Browser Storage & Cookies',
                    content: [
                      'ShopEase uses client-side web storage (browser localStorage via SharedPreferences) strictly to provide core shopping functionality:',
                      '• Active Cart Persistence: Items added to your cart are stored locally in your browser so your cart is preserved across page refreshes.',
                      '• Authentication Sessions: Firebase Authentication stores secure session tokens locally to maintain your sign-in state between visits.',
                      'We do not use intrusive third-party tracking cookies or sell your browsing history to advertising brokers.',
                    ],
                  ),

                  _buildSection(
                    title: '3. How We Use Your Information',
                    content: [
                      'Your data is processed exclusively for genuine service operations:',
                      '• Verifying and processing your customer account and orders.',
                      '• Coordinating physical package dispatch and Cash on Delivery courier collection.',
                      '• Sending essential transactional notifications (password resets, order confirmation, and delivery status updates).',
                      '• Addressing customer inquiries, cancellations, or product assistance requests.',
                    ],
                  ),

                  _buildSection(
                    title: '4. Third-Party Service Providers',
                    content: [
                      'We partner with reputable infrastructure providers to operate the store:',
                      '• Google Cloud / Firebase: Cloud hosting, user authentication, and encrypted database infrastructure (Cloud Firestore and Firebase Storage).',
                      '• Courier & Delivery Services: Third-party logistics personnel in Bangladesh receive your delivery name, address, and contact number solely to complete package delivery.',
                    ],
                  ),

                  _buildSection(
                    title: '5. Data Retention & Account Deletion',
                    content: [
                      'We retain customer profile and order data for as long as your account remains active. Customers may request review or deletion of their personal information by contacting support@shopease.com.',
                    ],
                  ),

                  _buildSection(
                    title: '6. Pending Business Confirmations',
                    content: [
                      'The following operational details require final store owner review and ratification:',
                      '• Formal Registered Corporate Entity Name: [Pending Owner Confirmation]',
                      '• Registered Office Address in Bangladesh: [Pending Owner Confirmation]',
                      '• Data Protection Officer Contact: support@shopease.com',
                    ],
                  ),

                  _buildSection(
                    title: '7. Contact Us',
                    content: [
                      'If you have questions regarding this Privacy Policy or your personal data, please contact our support team:',
                    ],
                  ),

                  const SizedBox(height: AppTheme.space8),
                  InkWell(
                    onTap: () => UrlHelper.launchEmail(context, 'support@shopease.com', subject: 'Privacy Policy Inquiry'),
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

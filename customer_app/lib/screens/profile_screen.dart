import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/url_helper.dart';
import 'orders_screen.dart';
import 'cart_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showAccountSecurityDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderSubtle),
        ),
        title: const Row(
          children: [
            Icon(Icons.security, color: AppTheme.accent),
            SizedBox(width: 8),
            Text('Account Security', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your account is secured with Firebase Authentication email and password credentials.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, size: 18, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      email,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Need to change your password? We will send a secure password reset link to your registered email address.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppTheme.bgPrimary,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthService>(context, listen: false);
              final err = await auth.sendPasswordResetEmail(email);
              if (context.mounted) {
                if (err == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset link sent to $email. Please check your inbox.'),
                      backgroundColor: AppTheme.surfaceElevated,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err), backgroundColor: AppTheme.statusError),
                  );
                }
              }
            },
            icon: const Icon(Icons.lock_reset, size: 16),
            label: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    String currentName,
    String currentPhone,
    String currentAddress,
  ) {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);
    final addressController = TextEditingController(text: currentAddress);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.borderSubtle),
          ),
          title: const Text(
            'Edit Profile Information',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Name cannot be empty';
                      }
                      if (v.trim().length > 100) {
                        return 'Name too long (max 100)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+880 1XXXXXXXXX',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) {
                      if (v != null && v.trim().isNotEmpty && v.trim().length > 30) {
                        return 'Phone too long (max 30)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: addressController,
                    maxLines: 2,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Default Delivery Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (v) {
                      if (v != null && v.trim().isNotEmpty && v.trim().length > 500) {
                        return 'Address too long (max 500)';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.bgPrimary,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final auth = Provider.of<AuthService>(context, listen: false);
                final err = await auth.updateProfile(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  if (err == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: AppTheme.surfaceElevated,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err), backgroundColor: AppTheme.statusError),
                    );
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Card
            StreamBuilder<DocumentSnapshot>(
              stream: auth.getUserProfileStream(),
              builder: (context, snapshot) {
                String displayName = user?.displayName ?? 'Valued Customer';
                String email = user?.email ?? 'No email';
                String phone = '';
                String address = 'Dhaka, Bangladesh';

                if (snapshot.hasData && snapshot.data?.exists == true) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data != null) {
                    if (data['name'] != null &&
                        (data['name'] as String).isNotEmpty) {
                      displayName = data['name'];
                    }
                    if (data['phone'] != null) {
                      phone = data['phone'] as String;
                    }
                    if (data['address'] != null &&
                        (data['address'] as String).isNotEmpty) {
                      address = data['address'] as String;
                    }
                  }
                }

                return Column(
                  children: [
                    Card(
                      color: AppTheme.surfaceCard,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: AppTheme.accentSubtle,
                                  child: Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      InkWell(
                                        onTap: () => UrlHelper.launchEmail(context, email, subject: 'ShopEase Customer Profile Inquiry'),
                                        borderRadius: BorderRadius.circular(4),
                                        child: Text(
                                          email,
                                          style: const TextStyle(
                                            color: AppTheme.accent,
                                            fontSize: 13,
                                            decoration: TextDecoration.underline,
                                            decorationColor: AppTheme.accent,
                                          ),
                                        ),
                                      ),
                                      if (phone.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        InkWell(
                                          onTap: () => UrlHelper.launchPhone(context, phone),
                                          borderRadius: BorderRadius.circular(4),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.phone_outlined, size: 12, color: AppTheme.accent),
                                              const SizedBox(width: 4),
                                              Text(
                                                phone,
                                                style: const TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontSize: 12,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: AppTheme.accent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentSubtle,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: AppTheme.accent.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: const Text(
                                          'ShopEase Member',
                                          style: TextStyle(
                                            color: AppTheme.accent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: AppTheme.borderSubtle),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showEditProfileDialog(
                                  context,
                                  displayName,
                                  phone,
                                  address,
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('Edit Profile Information'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.borderSubtle),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Profile Options Menu
                    Card(
                      color: AppTheme.surfaceCard,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentSubtle,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                color: AppTheme.accent,
                                size: 20,
                              ),
                            ),
                            title: const Text('My Orders', style: TextStyle(color: AppTheme.textPrimary)),
                            subtitle: const Text('Track and view order history', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OrdersScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: AppTheme.borderSubtle),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentSubtle,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                color: AppTheme.accent,
                                size: 20,
                              ),
                            ),
                            title: const Text('Shopping Cart', style: TextStyle(color: AppTheme.textPrimary)),
                            subtitle: const Text('Manage your saved items', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CartScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, color: AppTheme.borderSubtle),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentSubtle,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: AppTheme.accent,
                                size: 20,
                              ),
                            ),
                            title: const Text('Shipping Address', style: TextStyle(color: AppTheme.textPrimary)),
                            subtitle: Text(address, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: const Icon(Icons.edit_outlined, color: AppTheme.textMuted, size: 18),
                            onTap: () => _showEditProfileDialog(
                              context,
                              displayName,
                              phone,
                              address,
                            ),
                          ),
                          const Divider(height: 1, color: AppTheme.borderSubtle),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentSubtle,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.security_outlined,
                                color: AppTheme.accent,
                                size: 20,
                              ),
                            ),
                            title: const Text('Account Security', style: TextStyle(color: AppTheme.textPrimary)),
                            subtitle: const Text('Email & password authentication via Firebase', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                            onTap: () => _showAccountSecurityDialog(context, email),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.surfaceCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        'Are you sure you want to sign out?',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.statusError,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            auth.signOut();
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout, color: AppTheme.statusError, size: 18),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppTheme.statusError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.statusError.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

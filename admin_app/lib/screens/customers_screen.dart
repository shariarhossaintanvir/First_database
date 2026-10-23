import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer_model.dart';
import '../services/firestore_service.dart';
import '../theme/admin_theme.dart';
import '../utils/url_helper.dart';
import '../widgets/admin_layout.dart';
import '../widgets/admin_status_badge.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';

  void _showCustomerDetailDialog(CustomerModel customer) {
    final formattedDate = DateFormat(
      'MMMM dd, yyyy • hh:mm a',
    ).format(customer.createdAt);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AdminTheme.borderSubtle),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AdminTheme.accentSubtle,
              child: const Icon(Icons.person, color: AdminTheme.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AdminTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'UID: ${customer.uid.length > 12 ? "${customer.uid.substring(0, 12)}..." : customer.uid}',
                    style: const TextStyle(color: AdminTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: AdminTheme.borderSubtle),
              const SizedBox(height: 8),
              _buildModalRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: customer.email.isNotEmpty ? customer.email : 'No email provided',
                onTap: customer.email.isNotEmpty
                    ? () => UrlHelper.launchEmail(context, customer.email)
                    : null,
              ),
              const SizedBox(height: 10),
              _buildModalRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: customer.phone.isNotEmpty ? customer.phone : 'Not provided',
                onTap: customer.phone.isNotEmpty
                    ? () => UrlHelper.launchPhone(context, customer.phone)
                    : null,
              ),
              const SizedBox(height: 10),
              _buildModalRow(
                icon: Icons.location_on_outlined,
                label: 'Delivery Address',
                value: customer.address != null && customer.address!.isNotEmpty
                    ? customer.address!
                    : 'No saved address',
              ),
              const SizedBox(height: 10),
              _buildModalRow(
                icon: Icons.calendar_today_outlined,
                label: 'Registered On',
                value: formattedDate,
              ),
              const SizedBox(height: 10),
              _buildModalRow(
                icon: Icons.verified_user_outlined,
                label: 'Account Role',
                value: customer.role.toUpperCase(),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AdminTheme.bgWorkspace,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AdminTheme.borderSubtle),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: AdminTheme.accent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Read-only customer profile. Authentication credentials and password management are handled securely by Firebase Auth.',
                        style: TextStyle(
                          color: AdminTheme.textMuted,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AdminTheme.accent)),
          ),
        ],
      ),
    );
  }

  Widget _buildModalRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AdminTheme.textMuted),
        const SizedBox(width: 8),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: AdminTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: onTap != null
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onTap,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AdminTheme.accent,
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    color: AdminTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Customer Directory',
      currentRoute: '/customers',
      body: Column(
        children: [
          // Search & Filter Toolbar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AdminTheme.bgSidebar,
              border: Border(bottom: BorderSide(color: AdminTheme.borderSubtle, width: 1)),
            ),
            child: TextField(
              style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search customers by name, email, or phone number...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),

          // Customers Stream
          Expanded(
            child: StreamBuilder<List<CustomerModel>>(
              stream: _firestoreService.getCustomersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AdminTheme.accent),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AdminTheme.statusWarning,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to load customers',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AdminTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Verify Firestore security rules and network permissions: ${snapshot.error}',
                            style: const TextStyle(color: AdminTheme.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allCustomers = snapshot.data ?? [];

                final filtered = _searchQuery.isEmpty
                    ? allCustomers
                    : allCustomers.where((c) {
                        return c.name.toLowerCase().contains(_searchQuery) ||
                            c.email.toLowerCase().contains(_searchQuery) ||
                            c.phone.toLowerCase().contains(_searchQuery) ||
                            (c.address != null && c.address!.toLowerCase().contains(_searchQuery));
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AdminTheme.surfaceCard,
                            shape: BoxShape.circle,
                            border: Border.all(color: AdminTheme.borderSubtle),
                          ),
                          child: const Icon(
                            Icons.people_outline,
                            size: 48,
                            color: AdminTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No customers matching "$_searchQuery"'
                              : 'No registered customers found',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdminTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Customers will appear here when they register via the Storefront.',
                          style: TextStyle(color: AdminTheme.textMuted, fontSize: 13),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          OutlinedButton(
                            onPressed: () => setState(() => _searchQuery = ''),
                            child: const Text('Clear Search Filter'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 960;

                    if (isDesktop) {
                      // Desktop Data Table View
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Card(
                          color: AdminTheme.surfaceCard,
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Table Header Bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                color: AdminTheme.bgSidebar,
                                child: Row(
                                  children: [
                                    Text(
                                      'Showing ${filtered.length} Customer Account${filtered.length == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        color: AdminTheme.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: AdminTheme.borderSubtle),

                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filtered.length,
                                separatorBuilder: (ctx, idx) =>
                                    const Divider(height: 1, color: AdminTheme.borderSubtle),
                                itemBuilder: (context, index) {
                                  final customer = filtered[index];
                                  final formattedDate = DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(customer.createdAt);

                                  return ListTile(
                                    hoverColor: AdminTheme.surfaceHover,
                                    onTap: () => _showCustomerDetailDialog(customer),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AdminTheme.accentSubtle,
                                      child: Text(
                                        customer.name.isNotEmpty
                                            ? customer.name.substring(0, 1).toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: AdminTheme.accent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          customer.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AdminTheme.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const AdminStatusBadge(
                                          label: 'CUSTOMER',
                                          variant: AdminStatusBadgeVariant.info,
                                          isSmall: true,
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${customer.email.isNotEmpty ? customer.email : "No email"} • Phone: ${customer.phone.isNotEmpty ? customer.phone : "Not provided"} • Joined: $formattedDate',
                                        style: const TextStyle(
                                          color: AdminTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.visibility_outlined, size: 14),
                                          label: const Text('View Profile'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AdminTheme.accent,
                                            side: const BorderSide(color: AdminTheme.borderSubtle),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            textStyle: const TextStyle(fontSize: 12),
                                          ),
                                          onPressed: () => _showCustomerDetailDialog(customer),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.chevron_right,
                                          size: 18,
                                          color: AdminTheme.textMuted,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Mobile / Tablet Card View
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final customer = filtered[index];
                        final formattedDate = DateFormat(
                          'MMM dd, yyyy',
                        ).format(customer.createdAt);

                        return Card(
                          color: AdminTheme.surfaceCard,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AdminTheme.borderSubtle),
                          ),
                          child: InkWell(
                            onTap: () => _showCustomerDetailDialog(customer),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: AdminTheme.accentSubtle,
                                        child: Text(
                                          customer.name.isNotEmpty
                                              ? customer.name.substring(0, 1).toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            color: AdminTheme.accent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              customer.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AdminTheme.textPrimary,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              customer.email.isNotEmpty ? customer.email : 'No email',
                                              style: const TextStyle(
                                                color: AdminTheme.textMuted,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const AdminStatusBadge(
                                        label: 'CUSTOMER',
                                        variant: AdminStatusBadgeVariant.info,
                                        isSmall: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1, color: AdminTheme.borderSubtle),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Phone: ${customer.phone.isNotEmpty ? customer.phone : "Not provided"}',
                                        style: const TextStyle(
                                          color: AdminTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'Joined $formattedDate',
                                        style: const TextStyle(
                                          color: AdminTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

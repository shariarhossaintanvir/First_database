import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_layout.dart';
import '../widgets/admin_status_badge.dart';
import 'products_screen.dart';
import 'categories_screen.dart';
import 'orders_screen.dart';
import 'order_detail_screen.dart';
import 'add_edit_product_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _firestoreService.seedDefaultCategoriesIfEmpty();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AdminTheme.statusWarning;
      case 'Confirmed':
        return AdminTheme.accent;
      case 'Processing':
      case 'Shipped':
        return AdminTheme.statusInfo;
      case 'Delivered':
        return AdminTheme.statusSuccess;
      case 'Cancelled':
        return AdminTheme.statusError;
      default:
        return AdminTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Dashboard Overview',
      currentRoute: '/dashboard',
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
            );
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminTheme.accent,
            foregroundColor: AdminTheme.bgSidebar,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Analytics Cards Stream
            StreamBuilder<List<ProductModel>>(
              stream: _firestoreService.getProductsStream(),
              builder: (context, productSnap) {
                final products = productSnap.data ?? [];
                final productCount = products.length;
                final lowStockCount = products.where((p) => p.stock <= 5).length;

                return StreamBuilder<List<CategoryModel>>(
                  stream: _firestoreService.getCategoriesStream(),
                  builder: (context, catSnap) {
                    final catCount = catSnap.data?.length ?? 0;

                    return StreamBuilder<List<OrderModel>>(
                      stream: _firestoreService.getOrdersStream(),
                      builder: (context, orderSnap) {
                        final orders = orderSnap.data ?? [];
                        final orderCount = orders.length;
                        final totalRevenue = orders
                            .where((o) => o.status != 'Cancelled')
                            .fold<double>(0.0, (sum, o) => sum + o.totalAmount);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 4 Key SaaS Metric Cards
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 800;
                                return GridView.count(
                                  crossAxisCount: isWide ? 4 : 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: isWide ? 1.6 : 1.3,
                                  children: [
                                    _buildMetricCard(
                                      title: 'Gross Revenue',
                                      value: '৳ ${totalRevenue.toStringAsFixed(0)}',
                                      subtitle: 'Confirmed & pending orders',
                                      icon: Icons.payments_outlined,
                                      color: AdminTheme.statusSuccess,
                                    ),
                                    _buildMetricCard(
                                      title: 'Total Orders',
                                      value: orderCount.toString(),
                                      subtitle: '${orders.where((o) => o.status == 'Pending').length} pending fulfillment',
                                      icon: Icons.receipt_long_outlined,
                                      color: AdminTheme.accent,
                                    ),
                                    _buildMetricCard(
                                      title: 'Active Catalog',
                                      value: productCount.toString(),
                                      subtitle: '$lowStockCount low stock items',
                                      icon: Icons.inventory_2_outlined,
                                      color: const Color(0xFFA855F7),
                                    ),
                                    _buildMetricCard(
                                      title: 'Categories',
                                      value: catCount.toString(),
                                      subtitle: 'Department taxonomies',
                                      icon: Icons.category_outlined,
                                      color: AdminTheme.statusWarning,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // Low Stock Operational Alert (if any)
                            if (lowStockCount > 0)
                              Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AdminTheme.statusWarning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AdminTheme.statusWarning.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: AdminTheme.statusWarning,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Inventory Notice: $lowStockCount catalog products have 5 or fewer items remaining in stock.',
                                        style: const TextStyle(
                                          color: AdminTheme.textPrimary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const ProductsScreen(filterLowStock: true),
                                          ),
                                        );
                                      },
                                      child: const Text('Review Inventory'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),

            // Quick Navigation Hub
            const Text(
              'Operational Hub',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AdminTheme.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    title: 'Inventory',
                    subtitle: 'Manage catalog & stock',
                    icon: Icons.inventory_2_outlined,
                    color: AdminTheme.accent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    title: 'Categories',
                    subtitle: 'Taxonomies & departments',
                    icon: Icons.category_outlined,
                    color: AdminTheme.statusWarning,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    title: 'Orders',
                    subtitle: 'Fulfill & track shipments',
                    icon: Icons.local_shipping_outlined,
                    color: AdminTheme.statusSuccess,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Recent Orders Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Customer Orders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AdminTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                  child: const Text('View All Orders'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Recent Orders Stream Table / Cards
            StreamBuilder<List<OrderModel>>(
              stream: _firestoreService.getOrdersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: AdminTheme.accent),
                    ),
                  );
                }

                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return Card(
                    color: AdminTheme.surfaceCard,
                    child: const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No orders placed yet. Orders from the Customer App will appear here in real time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AdminTheme.textMuted),
                        ),
                      ),
                    ),
                  );
                }

                final recentOrders = orders.take(5).toList();

                return Card(
                  color: AdminTheme.surfaceCard,
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentOrders.length,
                    separatorBuilder: (ctx, idx) => const Divider(height: 1, color: AdminTheme.borderSubtle),
                    itemBuilder: (context, index) {
                      final o = recentOrders[index];
                      final dateStr = DateFormat(
                        'MMM dd, hh:mm a',
                      ).format(o.createdAt);
                      final color = _getStatusColor(o.status);

                      return ListTile(
                        hoverColor: AdminTheme.surfaceHover,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailScreen(order: o),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(Icons.receipt_outlined, color: color, size: 18),
                        ),
                        title: Text(
                          '#${o.id.length > 8 ? o.id.substring(0, 8) : o.id} • ${o.customerName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AdminTheme.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          '$dateStr • ${o.items.length} ${o.items.length == 1 ? 'item' : 'items'} • ${o.paymentMethod}',
                          style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AdminStatusBadge.fromOrderStatus(
                              o.status,
                              isSmall: true,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              '৳ ${o.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AdminTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right, size: 18, color: AdminTheme.textMuted),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AdminTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AdminTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AdminTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: AdminTheme.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AdminTheme.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AdminTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AdminTheme.textMuted, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

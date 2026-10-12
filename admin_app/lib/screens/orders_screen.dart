import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_layout.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;

  final List<String> _tabs = [
    'All',
    'Pending',
    'Confirmed',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AdminTheme.statusWarning;
      case 'Confirmed':
        return const Color(0xFF14B8A6);
      case 'Processing':
        return AdminTheme.statusInfo;
      case 'Shipped':
        return const Color(0xFFA855F7);
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
      title: 'Customer Orders',
      currentRoute: '/orders',
      body: Column(
        children: [
          // Filter Tabs Container
          Container(
            color: AdminTheme.bgSidebar,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AdminTheme.accent,
              indicatorWeight: 2,
              dividerColor: AdminTheme.borderSubtle,
              labelColor: AdminTheme.accent,
              unselectedLabelColor: AdminTheme.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),

          // Orders Stream
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _firestoreService.getOrdersStream(),
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
                            'Unable to load orders',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AdminTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Verify connection and permissions: ${snapshot.error}',
                            style: const TextStyle(color: AdminTheme.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allOrders = snapshot.data ?? [];

                return TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    final filteredOrders = tab == 'All'
                        ? allOrders
                        : allOrders
                            .where(
                              (o) => o.status.toLowerCase() == tab.toLowerCase(),
                            )
                            .toList();

                    if (filteredOrders.isEmpty) {
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
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: AdminTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No $tab orders found',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AdminTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Customer purchases with this status will appear here.',
                              style: TextStyle(color: AdminTheme.textMuted, fontSize: 13),
                            ),
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
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredOrders.length,
                                separatorBuilder: (ctx, idx) =>
                                    const Divider(height: 1, color: AdminTheme.borderSubtle),
                                itemBuilder: (context, index) {
                                  final order = filteredOrders[index];
                                  final formattedDate = DateFormat(
                                    'MMM dd, yyyy • hh:mm a',
                                  ).format(order.createdAt);
                                  final color = _getStatusColor(order.status);

                                  return ListTile(
                                    hoverColor: AdminTheme.surfaceHover,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OrderDetailScreen(order: order),
                                        ),
                                      );
                                    },
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: color.withValues(alpha: 0.12),
                                      child: Icon(Icons.receipt_outlined, color: color, size: 18),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AdminTheme.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: color.withValues(alpha: 0.3)),
                                          ),
                                          child: Text(
                                            order.status,
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Customer: ${order.customerName} • Placed: $formattedDate • Items: ${order.items.length}',
                                        style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12),
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '৳ ${order.totalAmount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AdminTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.chevron_right, size: 18, color: AdminTheme.textMuted),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }

                        // Mobile View
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            final formattedDate = DateFormat(
                              'MMM dd, yyyy - hh:mm a',
                            ).format(order.createdAt);
                            final color = _getStatusColor(order.status);

                            return Card(
                              color: AdminTheme.surfaceCard,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: AdminTheme.borderSubtle),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailScreen(order: order),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AdminTheme.textPrimary,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: color.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: color.withValues(alpha: 0.3)),
                                            ),
                                            child: Text(
                                              order.status,
                                              style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Customer: ${order.customerName}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AdminTheme.textPrimary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Date: $formattedDate',
                                        style: const TextStyle(
                                          color: AdminTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(height: 1, color: AdminTheme.borderSubtle),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'} • ${order.paymentMethod}',
                                            style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12),
                                          ),
                                          Text(
                                            '৳ ${order.totalAmount.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AdminTheme.textPrimary,
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
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

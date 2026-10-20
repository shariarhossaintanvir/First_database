import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import '../widgets/status_badge.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedStatus = 'All';

  final List<String> _filters = [
    'All',
    'Pending',
    'Confirmed',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppTheme.bgPrimary,
        body: EmptyStateView(
          icon: Icons.person_outline,
          title: 'Sign In Required',
          description: 'Please sign in to view your order history.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        title: const Text('My Orders'),
      ),
      body: Column(
        children: [
          // ── Status Filter Chips ──────────────────────────────────────
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space16, vertical: AppTheme.space10),
                child: Row(
                  children: _filters.map((f) {
                    final isSelected = _selectedStatus == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppTheme.space8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedStatus = f),
                        child: AnimatedContainer(
                          duration: AppTheme.durationFast,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.space12,
                              vertical: AppTheme.space6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accentSubtle
                                : AppTheme.bgSecondary,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.accent
                                  : AppTheme.borderSubtle,
                            ),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ── Orders List ───────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _firestoreService.getCustomerOrdersStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  );
                }

                if (snapshot.hasError) {
                  return const ErrorStateView(
                    icon: Icons.receipt_long_outlined,
                    title: 'Unable to Load Orders',
                    message:
                        'Please check your connection and try refreshing.',
                  );
                }

                var orders = snapshot.data ?? [];

                if (_selectedStatus != 'All') {
                  orders = orders
                      .where((o) =>
                          o.status.trim().toLowerCase() ==
                          _selectedStatus.trim().toLowerCase())
                      .toList();
                }

                if (orders.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: _selectedStatus == 'All'
                        ? "No Orders Yet"
                        : "No $_selectedStatus Orders",
                    description: _selectedStatus == 'All'
                        ? 'Your orders will appear here once you make a purchase.'
                        : 'No orders with "$_selectedStatus" status found.',
                    actionLabel:
                        _selectedStatus != 'All' ? 'Show All Orders' : null,
                    onActionPressed: _selectedStatus != 'All'
                        ? () => setState(() => _selectedStatus = 'All')
                        : null,
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.space16, AppTheme.space4,
                        AppTheme.space16, AppTheme.space40,
                      ),
                      itemCount: orders.length,
                      separatorBuilder: (ctx, idx) =>
                          const SizedBox(height: AppTheme.space10),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _OrderCard(
                          order: order,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(order: order),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('MMM dd, yyyy  •  h:mm a').format(order.createdAt);
    final shortId =
        order.id.length > 8 ? order.id.substring(0, 8) : order.id;

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Order #$shortId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                StatusBadge.fromOrderStatus(order.status),
              ],
            ),
            const SizedBox(height: AppTheme.space6),

            // Date
            Text(
              dateStr,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
            const SizedBox(height: AppTheme.space12),
            const Divider(height: 1, color: AppTheme.borderSubtle),
            const SizedBox(height: AppTheme.space12),

            // Item count + total + chevron
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '৳ ${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.accent,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: AppTheme.space8),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

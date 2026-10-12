import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppTheme.statusWarning;
      case 'Confirmed':
        return const Color(0xFF14B8A6); // Teal
      case 'Processing':
        return AppTheme.statusInfo;
      case 'Shipped':
        return const Color(0xFFA855F7); // Purple
      case 'Delivered':
        return AppTheme.statusSuccess;
      case 'Cancelled':
        return AppTheme.statusError;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppTheme.bgPrimary,
        body: Center(
          child: Text(
            'Please log in to view your orders',
            style: TextStyle(color: AppTheme.textMuted),
          ),
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
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _filters.map((f) {
                final isSelected = _selectedStatus == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    selectedColor: AppTheme.accentSubtle,
                    backgroundColor: AppTheme.bgSecondary,
                    side: BorderSide(
                      color: isSelected ? AppTheme.accent : AppTheme.borderSubtle,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedStatus = f);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Orders Stream
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppTheme.statusWarning,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Unable to load your orders',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Please check your connection and try refreshing.',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                var orders = snapshot.data ?? [];

                if (_selectedStatus != 'All') {
                  orders = orders
                      .where(
                        (o) =>
                            o.status.toLowerCase() ==
                            _selectedStatus.toLowerCase(),
                      )
                      .toList();
                }

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStatus == 'All'
                              ? "You haven't placed any orders yet"
                              : "No $_selectedStatus orders found",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Your completed orders will appear here.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final dateStr = DateFormat(
                      'MMM dd, yyyy - hh:mm a',
                    ).format(order.createdAt);
                    final color = _getStatusColor(order.status);

                    return Card(
                      color: AppTheme.surfaceCard,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
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
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: color.withValues(alpha: 0.4)),
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
                              const SizedBox(height: 6),
                              Text(
                                'Ordered on $dateStr',
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1, color: AppTheme.borderSubtle),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                  ),
                                  Text(
                                    '৳ ${order.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.accent,
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
            ),
          ),
        ],
      ),
    );
  }
}

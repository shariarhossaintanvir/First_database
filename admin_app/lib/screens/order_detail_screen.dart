import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../theme/admin_theme.dart';
import '../utils/url_helper.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late String _currentStatus;
  bool _isUpdating = false;

  final List<String> _statusOptions = [
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
    _currentStatus = widget.order.status;
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

  void _confirmStatusUpdate(String newStatus) {
    if (_isUpdating) return;
    final shortId = widget.order.id.length > 8 ? widget.order.id.substring(0, 8) : widget.order.id;
    final color = _getStatusColor(newStatus);

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
            Icon(Icons.swap_horiz, color: color, size: 22),
            const SizedBox(width: 10),
            const Text(
              'Update Order Status',
              style: TextStyle(
                color: AdminTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to transition Order #$shortId from "$_currentStatus" to "$newStatus"?',
              style: const TextStyle(color: AdminTheme.textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Customer will see "$newStatus" on their order tracking timeline.',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AdminTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(newStatus);
            },
            child: Text('Confirm ($newStatus)'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await _firestoreService.updateOrderStatus(widget.order.id, newStatus);
      setState(() {
        _currentStatus = newStatus;
        _isUpdating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: AdminTheme.surfaceElevated,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating status: $e'), backgroundColor: AdminTheme.statusError));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(widget.order.createdAt);
    final shortId = widget.order.id.length > 8 ? widget.order.id.substring(0, 8) : widget.order.id;

    return Title(
      title: 'Order #$shortId Details | ShopEase Admin',
      color: AdminTheme.accent,
      child: Scaffold(
        backgroundColor: AdminTheme.bgWorkspace,
        appBar: AppBar(
          backgroundColor: AdminTheme.bgSidebar,
          elevation: 0,
          title: Text('Order #$shortId Details'),
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status & Fulfillment Action Card
            Card(
              color: AdminTheme.surfaceCard,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AdminTheme.borderSubtle),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fulfillment Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AdminTheme.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_currentStatus).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getStatusColor(_currentStatus).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _currentStatus,
                            style: TextStyle(
                              color: _getStatusColor(_currentStatus),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Recorded: $formattedDate',
                      style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AdminTheme.borderSubtle),
                    const SizedBox(height: 14),
                    const Text(
                      'Transition Order Status:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _isUpdating
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(color: AdminTheme.accent),
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _statusOptions.map((status) {
                              final isSelected = status == _currentStatus;
                              final color = _getStatusColor(status);

                              return ChoiceChip(
                                label: Text(status),
                                selected: isSelected,
                                selectedColor: color.withValues(alpha: 0.15),
                                backgroundColor: AdminTheme.bgSidebar,
                                side: BorderSide(
                                  color: isSelected ? color : AdminTheme.borderSubtle,
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected ? color : AdminTheme.textSecondary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                onSelected: (selected) {
                                  if (selected && status != _currentStatus && !_isUpdating) {
                                    _confirmStatusUpdate(status);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Customer Details Card
            Card(
              color: AdminTheme.surfaceCard,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AdminTheme.borderSubtle),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer & Delivery Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AdminTheme.borderSubtle),
                    const SizedBox(height: 14),
                    _buildInfoRow(Icons.person_outline, 'Customer Name', widget.order.customerName),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.email_outlined,
                      'Email Address',
                      widget.order.customerEmail,
                      onTap: widget.order.customerEmail.isNotEmpty
                          ? () => UrlHelper.launchEmail(context, widget.order.customerEmail)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.phone_outlined,
                      'Contact Phone',
                      widget.order.customerPhone.isNotEmpty ? widget.order.customerPhone : 'Not provided',
                      onTap: widget.order.customerPhone.isNotEmpty
                          ? () => UrlHelper.launchPhone(context, widget.order.customerPhone)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.location_on_outlined, 'Delivery Address', widget.order.customerAddress),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.payment_outlined, 'Payment Method', widget.order.paymentMethod),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items Card
            Card(
              color: AdminTheme.surfaceCard,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AdminTheme.borderSubtle),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Line Items (${widget.order.items.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AdminTheme.borderSubtle),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.order.items.length,
                      separatorBuilder: (ctx, idx) => const Divider(height: 16, color: AdminTheme.borderSubtle),
                      itemBuilder: (context, index) {
                        final item = widget.order.items[index];
                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 52,
                                height: 52,
                                color: AdminTheme.bgSidebar,
                                padding: const EdgeInsets.all(4),
                                child: Image.network(
                                  item.imageUrl,
                                  cacheWidth: 104,
                                  cacheHeight: 104,
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AdminTheme.textMuted,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AdminTheme.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '৳ ${item.price.toStringAsFixed(0)} × ${item.quantity}',
                                    style: const TextStyle(
                                      color: AdminTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '৳ ${(item.price * item.quantity).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AdminTheme.textPrimary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AdminTheme.borderSubtle),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Order Value',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AdminTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '৳ ${widget.order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AdminTheme.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AdminTheme.accent),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: AdminTheme.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 12,
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
                        fontWeight: FontWeight.w500,
                        color: AdminTheme.accent,
                        decoration: TextDecoration.underline,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AdminTheme.textPrimary,
                    fontSize: 13,
                  ),
                ),
        ),
      ],
    );
  }
}

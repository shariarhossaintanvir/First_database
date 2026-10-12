import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppTheme.statusWarning;
      case 'Confirmed':
        return const Color(0xFF14B8A6);
      case 'Processing':
        return AppTheme.statusInfo;
      case 'Shipped':
        return const Color(0xFFA855F7);
      case 'Delivered':
        return AppTheme.statusSuccess;
      case 'Cancelled':
        return AppTheme.statusError;
      default:
        return AppTheme.textMuted;
    }
  }

  int _getStatusStep(String status) {
    switch (status) {
      case 'Pending':
        return 0;
      case 'Confirmed':
        return 1;
      case 'Processing':
        return 2;
      case 'Shipped':
        return 3;
      case 'Delivered':
        return 4;
      default:
        return -1;
    }
  }

  void _showCancellationPolicy(String orderId) {
    final shortId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppTheme.borderSubtle),
        ),
        title: const Text(
          'Order Cancellation Request',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'To ensure order security, orders are fulfilled and managed by administrators. '
          'To request a cancellation for Order #$shortId, '
          'please contact support at support@ecommerce.com or call our fulfillment team.',
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OrderModel?>(
      stream: _firestoreService.getOrderStream(widget.order.id),
      initialData: widget.order,
      builder: (context, snapshot) {
        final currentOrder = snapshot.data ?? widget.order;
        final currentStatus = currentOrder.status;
        final formattedDate = DateFormat(
          'MMM dd, yyyy - hh:mm a',
        ).format(currentOrder.createdAt);
        final activeStep = _getStatusStep(currentStatus);
        final shortId = currentOrder.id.length > 8
            ? currentOrder.id.substring(0, 8)
            : currentOrder.id;

        return Scaffold(
          backgroundColor: AppTheme.bgPrimary,
          appBar: AppBar(
            backgroundColor: AppTheme.bgPrimary,
            elevation: 0,
            title: Text('Order #$shortId'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Tracking Card
                Card(
                  color: AppTheme.surfaceCard,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tracking Status',
                              style: TextStyle(
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
                                color: _getStatusColor(currentStatus).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _getStatusColor(currentStatus).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                currentStatus,
                                style: TextStyle(
                                  color: _getStatusColor(currentStatus),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Placed on $formattedDate',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 18),

                        if (currentStatus == 'Cancelled')
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.statusError.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.statusError.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.cancel_outlined, color: AppTheme.statusError, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'This order was cancelled.',
                                  style: TextStyle(color: AppTheme.statusError, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          // 5 Progress Steps
                          Row(
                            children: [
                              _buildStepIndicator('Placed', 0, activeStep),
                              _buildStepLine(0 < activeStep),
                              _buildStepIndicator('Confirmed', 1, activeStep),
                              _buildStepLine(1 < activeStep),
                              _buildStepIndicator('Processing', 2, activeStep),
                              _buildStepLine(2 < activeStep),
                              _buildStepIndicator('Shipped', 3, activeStep),
                              _buildStepLine(3 < activeStep),
                              _buildStepIndicator('Delivered', 4, activeStep),
                            ],
                          ),
                        ],

                        if (currentStatus == 'Pending') ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: AppTheme.borderSubtle),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showCancellationPolicy(currentOrder.id),
                              icon: const Icon(Icons.help_outline, size: 16),
                              label: const Text('Request Order Cancellation'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textMuted,
                                side: const BorderSide(color: AppTheme.borderSubtle),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Delivery Details
                Card(
                  color: AppTheme.surfaceCard,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shipping Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppTheme.borderSubtle),
                        const SizedBox(height: 10),
                        Text(
                          'Recipient: ${currentOrder.customerName}',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phone: ${currentOrder.customerPhone}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Address: ${currentOrder.customerAddress}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Items List
                Card(
                  color: AppTheme.surfaceCard,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items (${currentOrder.items.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppTheme.borderSubtle),
                        const SizedBox(height: 10),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: currentOrder.items.length,
                          separatorBuilder: (ctx, idx) =>
                              const Divider(height: 16, color: AppTheme.borderSubtle),
                          itemBuilder: (context, index) {
                            final item = currentOrder.items[index];
                            return Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    color: AppTheme.bgSecondary,
                                    padding: const EdgeInsets.all(4),
                                    child: Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (ctx, err, stack) =>
                                          const Icon(
                                            Icons.image_not_supported_outlined,
                                            color: AppTheme.textMuted,
                                            size: 20,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '৳ ${item.price.toStringAsFixed(0)} x ${item.quantity}',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
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
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppTheme.borderSubtle),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount Paid',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '৳ ${currentOrder.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppTheme.accent,
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
        );
      },
    );
  }

  Widget _buildStepIndicator(String label, int stepIndex, int currentStep) {
    final isDone = stepIndex <= currentStep;
    final isCurrent = stepIndex == currentStep;

    return Column(
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: isDone ? AppTheme.accent : AppTheme.bgSecondary,
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            size: isDone ? 13 : 6,
            color: isDone ? AppTheme.bgPrimary : AppTheme.borderSubtle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isDone ? AppTheme.accent : AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? AppTheme.accent : AppTheme.borderSubtle,
        margin: const EdgeInsets.only(bottom: 14),
      ),
    );
  }
}

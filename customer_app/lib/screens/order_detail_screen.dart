import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

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
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int _getStatusStep(String status) {
    switch (status) {
      case 'Pending':
        return 0;
      case 'Processing':
        return 1;
      case 'Shipped':
        return 2;
      case 'Delivered':
        return 3;
      default:
        return -1;
    }
  }

  void _showCancellationPolicy(String orderId) {
    final shortId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Order Cancellation Request'),
        content: Text(
          'To ensure order security, orders are fulfilled and managed by administrators. '
          'To request a cancellation for Order #$shortId, '
          'please contact support at support@ecommerce.com or call our fulfillment team.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
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
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(title: Text('Order #$shortId')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Tracking Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  currentStatus,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(currentStatus),
                                ),
                              ),
                              child: Text(
                                currentStatus,
                                style: TextStyle(
                                  color: _getStatusColor(currentStatus),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Placed on $formattedDate',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (currentStatus == 'Cancelled')
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.red.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'This order was cancelled.',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          // 4 Progress Steps
                          Row(
                            children: [
                              _buildStepIndicator('Placed', 0, activeStep),
                              _buildStepLine(0 < activeStep),
                              _buildStepIndicator('Processing', 1, activeStep),
                              _buildStepLine(1 < activeStep),
                              _buildStepIndicator('Shipped', 2, activeStep),
                              _buildStepLine(2 < activeStep),
                              _buildStepIndicator('Delivered', 3, activeStep),
                            ],
                          ),
                        ],

                        if (currentStatus == 'Pending') ...[
                          const Divider(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showCancellationPolicy(currentOrder.id),
                              icon: const Icon(Icons.help_outline, size: 16),
                              label: const Text('Request Order Cancellation'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF475569),
                                side: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Delivery Details
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                            fontSize: 16,
                          ),
                        ),
                        const Divider(height: 20),
                        Text(
                          'Recipient: ${currentOrder.customerName}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Phone: ${currentOrder.customerPhone}',
                          style: const TextStyle(color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Address: ${currentOrder.customerAddress}',
                          style: const TextStyle(color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Items List
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                            fontSize: 16,
                          ),
                        ),
                        const Divider(height: 20),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: currentOrder.items.length,
                          separatorBuilder: (ctx, idx) =>
                              const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final item = currentOrder.items[index];
                            return Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade100,
                                    child: Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) =>
                                          const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
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
                                        ),
                                      ),
                                      Text(
                                        '\$${item.price.toStringAsFixed(2)} x ${item.quantity}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount Paid',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${currentOrder.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF0F172A),
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
          radius: 12,
          backgroundColor: isDone ? Colors.blue : Colors.grey.shade300,
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            size: isDone ? 14 : 8,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isDone ? Colors.blue.shade800 : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? Colors.blue : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 14),
      ),
    );
  }
}

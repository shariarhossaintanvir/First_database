import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

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
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: const BorderSide(color: AppTheme.borderSubtle),
        ),
        title: const Text(
          'Order Cancellation Request',
          style:
              TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'To ensure order security, orders are managed by administrators. '
          'To request a cancellation for Order #$shortId, '
          'please contact support at support@shopease.com or call our fulfillment team.',
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood',
                style: TextStyle(color: AppTheme.accent)),
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
        final formattedDate =
            DateFormat('MMM dd, yyyy  •  h:mm a').format(currentOrder.createdAt);
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
            padding: const EdgeInsets.all(AppTheme.space16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                // ── Status Tracking Card ─────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Order Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          StatusBadge.fromOrderStatus(currentStatus),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space6),
                      Text(
                        'Placed on $formattedDate',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11),
                      ),
                      const SizedBox(height: AppTheme.space20),

                      // Cancelled notice or step tracker
                      if (currentStatus == 'Cancelled')
                        Container(
                          padding: const EdgeInsets.all(AppTheme.space12),
                          decoration: BoxDecoration(
                            color: AppTheme.statusError.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(
                              color: AppTheme.statusError
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.cancel_outlined,
                                  color: AppTheme.statusError, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'This order has been cancelled.',
                                style: TextStyle(
                                  color: AppTheme.statusError,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        _OrderStepTracker(activeStep: activeStep),

                      // Cancel request (Pending orders only)
                      if (currentStatus == 'Pending') ...[
                        const SizedBox(height: AppTheme.space16),
                        const Divider(height: 1, color: AppTheme.borderSubtle),
                        const SizedBox(height: AppTheme.space12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showCancellationPolicy(currentOrder.id),
                            icon: const Icon(Icons.help_outline, size: 15),
                            label: const Text('Request Cancellation'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textMuted,
                              side:
                                  const BorderSide(color: AppTheme.borderSubtle),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space12),

                // ── Shipping Details ─────────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel(
                        icon: Icons.location_on_outlined,
                        label: 'Shipping Details',
                      ),
                      const SizedBox(height: AppTheme.space12),
                      const Divider(height: 1, color: AppTheme.borderSubtle),
                      const SizedBox(height: AppTheme.space12),
                      _DetailRow(
                          label: 'Recipient', value: currentOrder.customerName),
                      const SizedBox(height: AppTheme.space6),
                      _DetailRow(
                          label: 'Phone', value: currentOrder.customerPhone),
                      const SizedBox(height: AppTheme.space6),
                      _DetailRow(
                          label: 'Address',
                          value: currentOrder.customerAddress),
                      const SizedBox(height: AppTheme.space6),
                      _DetailRow(
                          label: 'Payment',
                          value: currentOrder.paymentMethod),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space12),

                // ── Items List ───────────────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(
                        icon: Icons.inventory_2_outlined,
                        label: 'Items (${currentOrder.items.length})',
                      ),
                      const SizedBox(height: AppTheme.space12),
                      const Divider(height: 1, color: AppTheme.borderSubtle),
                      const SizedBox(height: AppTheme.space12),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentOrder.items.length,
                        separatorBuilder: (ctx, idx) => const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: AppTheme.space8),
                          child: Divider(
                              height: 1, color: AppTheme.borderSubtle),
                        ),
                        itemBuilder: (context, index) {
                          final item = currentOrder.items[index];
                          return Row(
                            children: [
                              // Item thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusXs),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  color: AppTheme.bgSecondary,
                                  padding:
                                      const EdgeInsets.all(AppTheme.space4),
                                  child: Image.network(
                                    item.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (ctx, err, stack) =>
                                        const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: AppTheme.textMuted,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppTheme.space12),

                              // Title + unit price
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      '৳ ${item.price.toStringAsFixed(0)}  ×  ${item.quantity}',
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Line total
                              Text(
                                '৳ ${(item.price * item.quantity).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: AppTheme.space12),
                      const Divider(height: 1, color: AppTheme.borderSubtle),
                      const SizedBox(height: AppTheme.space12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Paid',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '৳ ${currentOrder.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: AppTheme.accent,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.space24),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}

// ─── Shared Helper Widgets ──────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.accent),
        const SizedBox(width: AppTheme.space8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            '$label:',
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Order Step Tracker ─────────────────────────────────────────────────────

class _OrderStepTracker extends StatelessWidget {
  final int activeStep;

  const _OrderStepTracker({required this.activeStep});

  static const _steps = ['Placed', 'Confirmed', 'Processing', 'Shipped', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _steps.length; i++) ...[
          _StepDot(
            label: _steps[i],
            stepIndex: i,
            activeStep: activeStep,
          ),
          if (i < _steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 14),
                color:
                    i < activeStep ? AppTheme.accent : AppTheme.borderSubtle,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final int stepIndex;
  final int activeStep;

  const _StepDot({
    required this.label,
    required this.stepIndex,
    required this.activeStep,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = stepIndex <= activeStep;
    final isCurrent = stepIndex == activeStep;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: isDone ? AppTheme.accent : AppTheme.bgSecondary,
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            size: isDone ? 13 : 5,
            color: isDone ? AppTheme.bgPrimary : AppTheme.borderStrong,
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
}

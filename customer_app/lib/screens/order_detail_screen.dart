import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';
import 'cart_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isReordering = false;

  Future<void> _handleBuyAgain(OrderModel currentOrder) async {
    if (_isReordering) return;
    setState(() => _isReordering = true);

    final cart = Provider.of<CartProvider>(context, listen: false);
    int addedCount = 0;
    int unavailableCount = 0;

    try {
      for (final item in currentOrder.items) {
        final product = await _firestoreService.getProductById(item.productId);
        if (product != null && product.isAvailable && product.stock > 0) {
          final inCart = cart.getProductQuantity(product.id);
          final availableToAdd = product.stock - inCart;
          if (availableToAdd > 0) {
            final qtyToAdd = item.quantity.clamp(1, availableToAdd);
            cart.addItem(product, quantity: qtyToAdd);
            addedCount++;
          } else {
            unavailableCount++;
          }
        } else {
          unavailableCount++;
        }
      }

      if (!mounted) return;
      setState(() => _isReordering = false);

      if (addedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              unavailableCount > 0
                  ? 'Added $addedCount items to cart ($unavailableCount unavailable or out of stock).'
                  : 'Added $addedCount items to your shopping cart!',
            ),
            backgroundColor: AppTheme.surfaceElevated,
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: AppTheme.accent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Items from this order are currently out of stock or unavailable.'),
            backgroundColor: AppTheme.statusError,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isReordering = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not reorder: $e'),
            backgroundColor: AppTheme.statusError,
          ),
        );
      }
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
            scrolledUnderElevation: 0,
            title: Text('Order #$shortId'),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceCard,
              border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isReordering ? null : () => _handleBuyAgain(currentOrder),
                      icon: _isReordering
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.bgPrimary),
                            )
                          : const Icon(Icons.replay_rounded, size: 18),
                      label: Text(_isReordering ? 'Checking Available Stock...' : 'Buy Again / Reorder Items'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.bgPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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

                      // Cancelled notice or progressive timeline
                      if (currentStatus == 'Cancelled')
                        _CancelledOrderNotice(order: currentOrder)
                      else if (activeStep == -1)
                        _UnknownStatusNotice(status: currentStatus)
                      else
                        _OrderTimeline(
                          order: currentOrder,
                          activeStep: activeStep,
                        ),

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

// ─── Order Timeline & Status Presentation ───────────────────────────────────

class _TimelineStage {
  final String status;
  final String title;
  final String description;
  final IconData icon;

  const _TimelineStage({
    required this.status,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _OrderTimeline extends StatelessWidget {
  final OrderModel order;
  final int activeStep;

  const _OrderTimeline({
    required this.order,
    required this.activeStep,
  });

  static const List<_TimelineStage> _stages = [
    _TimelineStage(
      status: 'Pending',
      title: 'Order Placed',
      description: 'Your order was received and is awaiting merchant confirmation.',
      icon: Icons.receipt_long_outlined,
    ),
    _TimelineStage(
      status: 'Confirmed',
      title: 'Order Confirmed',
      description: 'Order details and inventory verified by store administrator.',
      icon: Icons.check_circle_outline,
    ),
    _TimelineStage(
      status: 'Processing',
      title: 'Processing & Quality Check',
      description: 'Items are being packed and prepared for dispatch.',
      icon: Icons.inventory_2_outlined,
    ),
    _TimelineStage(
      status: 'Shipped',
      title: 'Dispatched for Delivery',
      description: 'Package has departed fulfillment center and is on route.',
      icon: Icons.local_shipping_outlined,
    ),
    _TimelineStage(
      status: 'Delivered',
      title: 'Delivered',
      description: 'Package successfully delivered to recipient.',
      icon: Icons.home_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_stages.length, (index) {
        final stage = _stages[index];
        final isCompleted = index < activeStep;
        final isCurrent = index == activeStep;
        final isPending = index > activeStep;
        final isLast = index == _stages.length - 1;

        // Display genuine timestamps only:
        // Index 0 (Order Placed) has createdAt.
        // If active step is > 0 and order.updatedAt != null, display genuine updatedAt on current stage.
        String? timestampStr;
        if (index == 0) {
          timestampStr = DateFormat('MMM dd, yyyy • h:mm a').format(order.createdAt);
        } else if (isCurrent && order.updatedAt != null) {
          timestampStr = 'Updated: ${DateFormat('MMM dd, yyyy • h:mm a').format(order.updatedAt!)}';
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Node & Connecting Line
              Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isCompleted || isCurrent
                        ? AppTheme.accent
                        : AppTheme.bgSecondary,
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : (isCurrent ? stage.icon : Icons.circle),
                      size: isCompleted ? 14 : (isCurrent ? 14 : 6),
                      color: isCompleted || isCurrent
                          ? AppTheme.bgPrimary
                          : AppTheme.borderStrong,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isCompleted ? AppTheme.accent : AppTheme.borderSubtle,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppTheme.space12),

              // Stage Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : AppTheme.space20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stage.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isCurrent ? FontWeight.bold : (isCompleted ? FontWeight.w600 : FontWeight.normal),
                              color: isCurrent
                                  ? AppTheme.accent
                                  : (isCompleted ? AppTheme.textPrimary : AppTheme.textMuted),
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentSubtle,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'CURRENT STAGE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stage.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: isPending ? AppTheme.textDisabled : AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (timestampStr != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          timestampStr,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CancelledOrderNotice extends StatelessWidget {
  final OrderModel order;

  const _CancelledOrderNotice({required this.order});

  @override
  Widget build(BuildContext context) {
    final cancelDate = order.updatedAt ?? order.createdAt;
    final formattedDate = DateFormat('MMM dd, yyyy • h:mm a').format(cancelDate);

    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.statusError.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.statusError.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.statusError.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: AppTheme.statusError,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Cancelled',
                      style: TextStyle(
                        color: AppTheme.statusError,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'This order has been cancelled and will not be delivered.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Recorded on $formattedDate',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnknownStatusNotice extends StatelessWidget {
  final String status;

  const _UnknownStatusNotice({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.textMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Current Order Status: $status',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

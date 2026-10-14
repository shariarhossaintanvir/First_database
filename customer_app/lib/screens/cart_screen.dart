import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_view.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        title: Text(
          cart.itemList.isEmpty
              ? 'Shopping Cart'
              : 'Cart (${cart.itemList.length} ${cart.itemList.length == 1 ? 'item' : 'items'})',
        ),
        actions: [
          if (cart.itemList.isNotEmpty)
            IconButton(
              tooltip: 'Clear Cart',
              icon: const Icon(Icons.delete_sweep_outlined,
                  color: AppTheme.textMuted),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.surfaceCard,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      side: const BorderSide(color: AppTheme.borderSubtle),
                    ),
                    title: const Text(
                      'Clear Cart',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                      'Remove all items from your shopping cart?',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel',
                            style: TextStyle(color: AppTheme.textMuted)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.statusError,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm)),
                        ),
                        onPressed: () {
                          cart.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),

      // ── Bottom Bar — Checkout ─────────────────────────────────────────
      bottomNavigationBar: cart.itemList.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.space20, AppTheme.space16,
                AppTheme.space20, AppTheme.space16,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceCard,
                border: Border(
                    top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
              ),
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Price breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'}',
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textMuted),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text(
                                  'Subtotal  ',
                                  style: TextStyle(
                                      fontSize: 13, color: AppTheme.textMuted),
                                ),
                                Text(
                                  '৳ ${cart.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.4,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.space12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CheckoutScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: AppTheme.bgPrimary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: AppTheme.space16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSm),
                              ),
                            ),
                            child: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

      // ── Body ──────────────────────────────────────────────────────────
      body: cart.itemList.isEmpty
          ? EmptyStateView(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              description:
                  'Browse our catalog and add items to your cart to get started.',
              customAction: ElevatedButton(
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                child: const Text('Browse Products'),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  itemCount: cart.itemList.length,
                  separatorBuilder: (ctx, idx) =>
                      const SizedBox(height: AppTheme.space10),
                  itemBuilder: (context, index) {
                    final item = cart.itemList[index];
                    final canIncrement = item.quantity < item.product.stock;
                    return _CartItemRow(
                      item: item,
                      canIncrement: canIncrement,
                      onIncrement: () {
                        if (!canIncrement) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Cannot add more: only ${item.product.stock} available in stock.'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppTheme.surfaceElevated,
                            ),
                          );
                          return;
                        }
                        cart.incrementQuantity(item.product.id);
                      },
                      onDecrement: () =>
                          cart.decrementQuantity(item.product.id),
                      onRemove: () => cart.removeItem(item.product.id),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

/// Individual cart item row widget
class _CartItemRow extends StatelessWidget {
  final dynamic item; // CartItemModel
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemRow({
    required this.item,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: Container(
                width: 76,
                height: 76,
                color: AppTheme.bgSecondary,
                padding: const EdgeInsets.all(AppTheme.space6),
                child: Image.network(
                  item.product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppTheme.textMuted,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.space12),

            // Title, price, stepper
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product title
                  Text(
                    item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space6),

                  // Unit price and stock limit indicator
                  Row(
                    children: [
                      Text(
                        '৳ ${item.product.price.toStringAsFixed(0)} / unit',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      if (!canIncrement) ...[
                        const SizedBox(width: AppTheme.space8),
                        const Text(
                          '• Max stock reached',
                          style: TextStyle(
                            color: AppTheme.secondaryWarm,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppTheme.space8),

                  // Stepper row + line total
                  Row(
                    children: [
                      // Compact quantity stepper
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.bgSecondary,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusXs),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MiniStepperButton(
                                icon: Icons.remove, onPressed: onDecrement),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.space10),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            _MiniStepperButton(
                              icon: Icons.add,
                              onPressed: onIncrement,
                              color: canIncrement ? AppTheme.accent : AppTheme.textDisabled,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Line total
                      Text(
                        '৳ ${item.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Remove button
            const SizedBox(width: AppTheme.space4),
            GestureDetector(
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: AppTheme.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  const _MiniStepperButton({
    required this.icon,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Icon(
          icon,
          size: 14,
          color: color ?? AppTheme.textSecondary,
        ),
      ),
    );
  }
}

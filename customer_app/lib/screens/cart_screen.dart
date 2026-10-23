import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'checkout_screen.dart';
import 'product_detail_screen.dart';
import 'main_navigation_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // ── Clear-cart confirmation ───────────────────────────────────────────────
  void _showClearCartDialog(BuildContext context, CartProvider cart) {
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
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Remove all items from your shopping cart?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusError,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
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
  }

  // ── Remove single item confirmation ──────────────────────────────────────
  void _showRemoveItemDialog(
      BuildContext context, CartProvider cart, CartItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: const BorderSide(color: AppTheme.borderSubtle),
        ),
        title: const Text(
          'Remove Item',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Remove "${item.product.title}" from your cart?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusError,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            ),
            onPressed: () {
              cart.removeItem(item.product.id);
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          cart.itemList.isEmpty
              ? 'Shopping Cart'
              : 'Cart (${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'})',
        ),
        actions: [
          if (cart.itemList.isNotEmpty)
            IconButton(
              tooltip: 'Clear Cart',
              icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.textMuted),
              onPressed: () => _showClearCartDialog(context, cart),
            ),
        ],
      ),

      // ── Bottom checkout bar ───────────────────────────────────────────────
      bottomNavigationBar: cart.itemList.isEmpty
          ? null
          : _CheckoutBar(cart: cart),

      // ── Body ─────────────────────────────────────────────────────────────
      body: cart.itemList.isEmpty
          ? _EmptyCartBody()
          : _CartBody(
              cart: cart,
              onRemoveItem: (item) => _showRemoveItemDialog(context, cart, item),
              onRemoveAtOne: (item) => _showRemoveItemDialog(context, cart, item),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state with catalog recommendations
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyCartBody extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  _EmptyCartBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: AppTheme.space24),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppTheme.accentSubtle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 40,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: AppTheme.space20),
              const Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppTheme.space8),
              const Text(
                'Browse our catalog and add items you love.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppTheme.space16),
              OutlinedButton.icon(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationScreen(),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.explore_outlined, size: 16),
                label: const Text('Explore Catalog'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space20,
                    vertical: AppTheme.space12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space28),

              // ── Catalog recommendations ────────────────────────────────
              StreamBuilder<List<ProductModel>>(
                stream: _firestoreService.getProductsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final products = snapshot.data!
                      .where((p) => p.isAvailable && p.stock > 0)
                      .take(6)
                      .toList();
                  if (products.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: AppTheme.borderSubtle),
                      const SizedBox(height: AppTheme.space16),
                      const Text(
                        'Popular Products',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: AppTheme.space12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: AppTheme.space12,
                          mainAxisSpacing: AppTheme.space12,
                        ),
                        itemCount: products.length,
                        itemBuilder: (ctx, idx) =>
                            ProductCard(product: products[idx]),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppTheme.space32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart item list with responsive 2-column desktop layout
// ─────────────────────────────────────────────────────────────────────────────
class _CartBody extends StatelessWidget {
  final CartProvider cart;
  final void Function(CartItemModel) onRemoveItem;
  final void Function(CartItemModel) onRemoveAtOne;

  const _CartBody({
    required this.cart,
    required this.onRemoveItem,
    required this.onRemoveAtOne,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          // ── Desktop: 65/35 split ─────────────────────────────────────────
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item list (65%)
                  Expanded(
                    flex: 65,
                    child: _ItemList(
                      cart: cart,
                      onRemoveItem: onRemoveItem,
                      onRemoveAtOne: onRemoveAtOne,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space16),
                  // Order summary card (35%)
                  SizedBox(
                    width: 340,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          0, AppTheme.space16, AppTheme.space16, AppTheme.space16),
                      child: _OrderSummaryCard(cart: cart),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ── Mobile / tablet: single column ──────────────────────────────────
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Column(
                children: [
                  _ItemList(
                    cart: cart,
                    onRemoveItem: onRemoveItem,
                    onRemoveAtOne: onRemoveAtOne,
                    isSingleColumn: true,
                  ),
                  const SizedBox(height: AppTheme.space16),
                  _OrderSummaryCard(cart: cart),
                  const SizedBox(height: AppTheme.space8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scrollable list of cart items
// ─────────────────────────────────────────────────────────────────────────────
class _ItemList extends StatelessWidget {
  final CartProvider cart;
  final void Function(CartItemModel) onRemoveItem;
  final void Function(CartItemModel) onRemoveAtOne;
  final bool isSingleColumn;

  const _ItemList({
    required this.cart,
    required this.onRemoveItem,
    required this.onRemoveAtOne,
    this.isSingleColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = cart.itemList;
    final listView = ListView.separated(
      shrinkWrap: isSingleColumn,
      physics: isSingleColumn
          ? const NeverScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(AppTheme.space16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppTheme.space10),
      itemBuilder: (context, index) {
        final item = items[index];
        final canIncrement = item.quantity < item.product.stock;
        return _CartItemCard(
          item: item,
          canIncrement: canIncrement,
          onIncrement: () {
            if (!canIncrement) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Maximum stock reached: only ${item.product.stock} available.'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppTheme.surfaceElevated,
                ),
              );
              return;
            }
            cart.incrementQuantity(item.product.id);
          },
          onDecrement: () {
            if (item.quantity <= 1) {
              onRemoveAtOne(item);
            } else {
              cart.decrementQuantity(item.product.id);
            }
          },
          onRemove: () => onRemoveItem(item),
          onTapTitle: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailScreen(product: item.product)),
            );
          },
        );
      },
    );

    if (isSingleColumn) return listView;

    return Expanded(child: listView);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual cart item card
// ─────────────────────────────────────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final VoidCallback onTapTitle;

  const _CartItemCard({
    required this.item,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onTapTitle,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final isLowStock = p.stock > 0 && p.stock <= 5;
    final isOutOfStock = p.stock <= 0;

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
            // ── Product image ─────────────────────────────────────────────
            GestureDetector(
              onTap: onTapTitle,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Container(
                  width: 92,
                  height: 92,
                  color: AppTheme.bgSecondary,
                  padding: const EdgeInsets.all(AppTheme.space8),
                  child: Image.network(
                    p.imageUrl,
                    cacheWidth: 184,
                    cacheHeight: 184,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, error, stackTrace) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppTheme.textMuted,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.space12),

            // ── Product info + controls ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clickable product name
                  GestureDetector(
                    onTap: onTapTitle,
                    child: Text(
                      p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.borderSubtle,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space4),

                  // Category chip
                  if (p.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentSubtle,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        p.category.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppTheme.space6),

                  // Unit price + stock status
                  Row(
                    children: [
                      Text(
                        '৳ ${p.price.toStringAsFixed(0)} / unit',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      if (isOutOfStock) ...[
                        const SizedBox(width: 6),
                        const Text(
                          '• Out of stock',
                          style: TextStyle(
                            color: AppTheme.statusError,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (isLowStock) ...[
                        const SizedBox(width: 6),
                        Text(
                          '• Only ${p.stock} left',
                          style: const TextStyle(
                            color: AppTheme.secondaryWarm,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (!canIncrement) ...[
                        const SizedBox(width: 6),
                        const Text(
                          '• Max stock in cart',
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

                  // Quantity stepper + line total
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.bgSecondary,
                          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _StepperBtn(icon: Icons.remove, onPressed: onDecrement),
                            SizedBox(
                              width: 34,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            _StepperBtn(
                              icon: Icons.add,
                              onPressed: onIncrement,
                              color: canIncrement
                                  ? AppTheme.accent
                                  : AppTheme.textDisabled,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '৳ ${item.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Remove button ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Order summary card
// ─────────────────────────────────────────────────────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  final CartProvider cart;

  const _OrderSummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    final itemCount = cart.itemCount;
    final subtotal = cart.totalAmount;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space16),
          _SummaryRow(
            label: '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            value: '৳ ${subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: AppTheme.space8),
          _SummaryRow(
            label: 'Delivery fee',
            value: 'Confirmed at checkout',
            valueStyle: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          const Divider(color: AppTheme.borderSubtle),
          const SizedBox(height: AppTheme.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '৳ ${subtotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space6),
          const Text(
            'Final total including delivery will be shown at checkout.',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
          ),
          const SizedBox(height: AppTheme.space16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.bgPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.space16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom checkout bar (mobile / tablet only)
// ─────────────────────────────────────────────────────────────────────────────
class _CheckoutBar extends StatelessWidget {
  final CartProvider cart;

  const _CheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hide bottom bar on desktop: summary card handles checkout CTA
        if (constraints.maxWidth >= 900) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.fromLTRB(
              AppTheme.space20, AppTheme.space16,
              AppTheme.space20, AppTheme.space16),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceCard,
            border:
                Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    const SizedBox(height: AppTheme.space10),
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
                          padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.space16),
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
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact stepper button
// ─────────────────────────────────────────────────────────────────────────────
class _StepperBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  const _StepperBtn({required this.icon, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, size: 14, color: color ?? AppTheme.textSecondary),
      ),
    );
  }
}

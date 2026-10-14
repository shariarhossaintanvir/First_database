import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/spec_attribute_row.dart';
import '../widgets/status_badge.dart';
import '../widgets/trust_badge_row.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final p = widget.product;
    final isOutOfStock = p.stock <= 0;
    final isUnavailable = !p.isAvailable || isOutOfStock;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        title: Text(
          p.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                    Icons.shopping_cart_outlined, color: AppTheme.textPrimary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cart.itemCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.bgPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ── Bottom Bar: Quantity Stepper + Add to Cart ────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space20, AppTheme.space16,
          AppTheme.space20, AppTheme.space16,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceCard,
          border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Row(
                children: [
                  // Quantity stepper
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgSecondary,
                      border: Border.all(color: AppTheme.borderSubtle),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StepperButton(
                          icon: Icons.remove,
                          enabled: _quantity > 1,
                          onPressed: () => setState(() => _quantity--),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$_quantity',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        _StepperButton(
                          icon: Icons.add,
                          enabled: !isOutOfStock && _quantity < p.stock,
                          onPressed: () => setState(() => _quantity++),
                          activeColor: AppTheme.accent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.space12),

                  // Add to Cart button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isUnavailable
                          ? null
                          : () {
                              final inCartQty = cart.getProductQuantity(p.id);
                              if (inCartQty + _quantity > p.stock) {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      inCartQty >= p.stock
                                          ? 'Cannot add more: maximum available stock reached ($inCartQty in cart).'
                                          : 'Cannot add $_quantity items: only ${p.stock - inCartQty} more available ($inCartQty in cart).',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: AppTheme.surfaceElevated,
                                  ),
                                );
                                return;
                              }
                              cart.addItem(p, quantity: _quantity);
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Added $_quantity × "${p.title}" to cart'),
                                  backgroundColor: AppTheme.surfaceElevated,
                                  action: SnackBarAction(
                                    label: 'VIEW CART',
                                    textColor: AppTheme.accent,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const CartScreen()),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                      icon: Icon(
                        isUnavailable
                            ? Icons.block_outlined
                            : Icons.shopping_bag_outlined,
                        size: 18,
                      ),
                      label: Text(
                        !p.isAvailable
                            ? 'Currently Unavailable'
                            : isOutOfStock
                                ? 'Out of Stock'
                                : 'Add to Cart',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isUnavailable ? AppTheme.surfaceElevated : AppTheme.accent,
                        foregroundColor:
                            isUnavailable ? AppTheme.textDisabled : AppTheme.bgPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          side: isUnavailable
                              ? const BorderSide(color: AppTheme.borderSubtle)
                              : BorderSide.none,
                        ),
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
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Product Image Hero
            Stack(
              children: [
                Container(
                  height: 320,
                  width: double.infinity,
                  color: AppTheme.bgSecondary,
                  padding: const EdgeInsets.all(AppTheme.space24),
                  child: Image.network(
                    p.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 64,
                            color: AppTheme.textMuted,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Image unavailable',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accent,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  ),
                ),

                // Stock badge overlay
                if (isUnavailable || p.stock <= 5)
                  Positioned(
                    top: AppTheme.space12,
                    left: AppTheme.space12,
                    child: StatusBadge.fromStock(
                      p.stock,
                      isAvailable: p.isAvailable,
                      isSmall: false,
                    ),
                  ),
              ],
            ),
            const Divider(height: 1, color: AppTheme.borderSubtle),

            // Product Info Block
            Padding(
              padding: const EdgeInsets.all(AppTheme.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category pill + availability
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.space10, vertical: AppTheme.space4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentSubtle,
                          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          border: Border.all(
                              color: AppTheme.accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          p.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const Spacer(),
                      StatusBadge.fromStock(
                        p.stock,
                        isAvailable: p.isAvailable,
                        isSmall: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space12),

                  // Product title
                  Text(
                    p.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space12),

                  // Price (BDT)
                  Text(
                    '৳ ${p.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppTheme.space20),
                  const Divider(color: AppTheme.borderSubtle),
                  const SizedBox(height: AppTheme.space16),

                  // Description
                  const Text(
                    'Product Overview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space10),
                  Text(
                    p.description.isNotEmpty
                        ? p.description
                        : 'No detailed description is available for this product.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: AppTheme.space24),

                  // Product Specifications Table
                  SpecAttributeTable(
                    title: 'Product Specifications',
                    specifications: {
                      'Category': p.category,
                      'Stock Availability': p.stock > 0
                          ? (p.stock <= 5
                              ? 'Low Stock (${p.stock} units left)'
                              : 'In Stock (${p.stock} units available)')
                          : 'Currently Out of Stock',
                      'Unit Price': '৳ ${p.price.toStringAsFixed(0)}',
                      'Payment Method': 'Cash on Delivery (COD)',
                    },
                  ),

                  const SizedBox(height: AppTheme.space24),

                  // Trust badge row (Phase 2 component)
                  const TrustBadgeRow(),

                  const SizedBox(height: AppTheme.space32),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}

/// Compact stepper icon button used in the quantity control
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;
  final Color? activeColor;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    this.onPressed,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? (activeColor ?? AppTheme.textSecondary)
        : AppTheme.textDisabled;
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}

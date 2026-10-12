import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.textPrimary),
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
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceCard,
          border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Stepper
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgSecondary,
                  border: Border.all(color: AppTheme.borderSubtle),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18, color: AppTheme.textSecondary),
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18, color: AppTheme.textSecondary),
                      onPressed: _quantity < p.stock ? () => setState(() => _quantity++) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Add to Cart Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUnavailable
                      ? null
                      : () {
                          cart.addItem(p, quantity: _quantity);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added $_quantity "${p.title}" to cart'),
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
                        },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: Text(
                    !p.isAvailable
                        ? 'Currently Unavailable'
                        : (isOutOfStock ? 'Out of Stock' : 'Add to Cart'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUnavailable ? AppTheme.surfaceElevated : AppTheme.accent,
                    foregroundColor: isUnavailable ? AppTheme.textDisabled : AppTheme.bgPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Hero Image Frame
            Container(
              height: 340,
              width: double.infinity,
              color: AppTheme.bgSecondary,
              padding: const EdgeInsets.all(24),
              child: Image.network(
                p.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: AppTheme.textMuted,
                  ),
                ),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderSubtle),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Stock Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentSubtle,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          p.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: !p.isAvailable
                              ? AppTheme.surfaceCard
                              : (isOutOfStock
                                  ? AppTheme.statusError.withValues(alpha: 0.15)
                                  : AppTheme.statusSuccess.withValues(alpha: 0.15)),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: !p.isAvailable
                                ? AppTheme.borderSubtle
                                : (isOutOfStock
                                    ? AppTheme.statusError.withValues(alpha: 0.4)
                                    : AppTheme.statusSuccess.withValues(alpha: 0.4)),
                          ),
                        ),
                        child: Text(
                          !p.isAvailable
                              ? 'Unavailable'
                              : (isOutOfStock
                                  ? 'Out of Stock'
                                  : 'In Stock (${p.stock} units)'),
                          style: TextStyle(
                            color: !p.isAvailable
                                ? AppTheme.textMuted
                                : (isOutOfStock ? AppTheme.statusError : AppTheme.statusSuccess),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Product Title
                  Text(
                    p.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price (BDT)
                  Text(
                    '৳ ${p.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.borderSubtle),
                  const SizedBox(height: 16),

                  // Product Description Header & Content
                  const Text(
                    'Product Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    p.description.isNotEmpty
                        ? p.description
                        : 'No detailed description provided for this catalog item.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Security & Guarantee Badges
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DetailBadge(
                          icon: Icons.verified_user_outlined,
                          title: '100% Genuine',
                          subtitle: 'Verified Product',
                        ),
                        _DetailBadge(
                          icon: Icons.local_shipping_outlined,
                          title: 'Fast Delivery',
                          subtitle: 'All Bangladesh',
                        ),
                        _DetailBadge(
                          icon: Icons.replay_outlined,
                          title: 'Easy Return',
                          subtitle: '7-Day Policy',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DetailBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.accent, size: 22),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

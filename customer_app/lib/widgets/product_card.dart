import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import 'status_badge.dart';

/// Clean Bangladeshi E-Commerce Product Card (0.72 Aspect Ratio)
class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final inCartQty = cart.getProductQuantity(product.id);
    final isOutOfStock = product.stock <= 0;
    final isUnavailable = !product.isAvailable || isOutOfStock;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: AppTheme.roundedMd,
        border: Border.all(color: AppTheme.borderSubtle, width: 1),
        boxShadow: AppTheme.shadowSubtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Frame with fixed proportion
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppTheme.bgSecondary,
                      padding: const EdgeInsets.all(AppTheme.space10),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 36,
                                color: AppTheme.textMuted.withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.category.isNotEmpty
                                    ? product.category
                                    : 'ShopEase',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Stock/Availability status badge
                    if (isUnavailable || product.stock <= 5)
                      Positioned(
                        top: AppTheme.space8,
                        left: AppTheme.space8,
                        child: StatusBadge.fromStock(
                          product.stock,
                          isAvailable: product.isAvailable,
                          isSmall: true,
                        ),
                      ),
                  ],
                ),
              ),

              // Product Details Block
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.space10,
                  AppTheme.space8,
                  AppTheme.space10,
                  AppTheme.space10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category Tag
                    Text(
                      product.category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space4),

                    // Product Title
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space8),

                    // Price & Quick Cart Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '৳ ${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: isUnavailable
                              ? null
                              : () {
                                  if (inCartQty >= product.stock) {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Cannot add more: maximum available stock reached.'),
                                        backgroundColor: Color(0xFF1F2937),
                                      ),
                                    );
                                    return;
                                  }
                                  cart.addItem(product);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Added "${product.title}" to cart'),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: const Color(0xFF1F2937),
                                      action: SnackBarAction(
                                        label: 'VIEW CART',
                                        textColor: AppTheme.primary,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const CartScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isUnavailable
                                  ? AppTheme.surfaceElevated
                                  : (inCartQty > 0
                                      ? AppTheme.primary
                                      : AppTheme.primaryLight),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(
                                color: isUnavailable
                                    ? AppTheme.borderSubtle
                                    : (inCartQty > 0
                                        ? AppTheme.primary
                                        : AppTheme.primaryMedium),
                              ),
                            ),
                            child: Icon(
                              inCartQty > 0 ? Icons.check : Icons.add_shopping_cart,
                              size: 16,
                              color: isUnavailable
                                  ? AppTheme.textDisabled
                                  : (inCartQty > 0 ? Colors.white : AppTheme.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

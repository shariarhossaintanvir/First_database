import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../screens/product_detail_screen.dart';

/// Premium Minimal Dark Product Card
class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final isOutOfStock = product.stock <= 0;
    final isUnavailable = !product.isAvailable || isOutOfStock;

    return Card(
      clipBehavior: Clip.antiAlias,
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
            // Product Image Frame
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppTheme.bgSecondary,
                    padding: const EdgeInsets.all(12),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppTheme.bgSecondary,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Stock/Availability pill
                  if (isUnavailable)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.statusError.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          isOutOfStock ? 'OUT OF STOCK' : 'UNAVAILABLE',
                          style: const TextStyle(
                            color: AppTheme.statusError,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    )
                  else if (product.stock <= 5)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.statusWarning.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'ONLY ${product.stock} LEFT',
                          style: const TextStyle(
                            color: AppTheme.statusWarning,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Details Block
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category pill
                  Text(
                    product.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Product Title
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price & Quick Cart Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '৳ ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: isUnavailable
                            ? null
                            : () {
                                cart.addItem(product);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added "${product.title}" to cart'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: AppTheme.surfaceElevated,
                                    action: SnackBarAction(
                                      label: 'VIEW CART',
                                      textColor: AppTheme.accent,
                                      onPressed: () {
                                        // Cart tab navigation is handled via cart screen push or navigation
                                      },
                                    ),
                                  ),
                                );
                              },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isUnavailable ? AppTheme.surfaceElevated : AppTheme.accentSubtle,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isUnavailable ? AppTheme.borderSubtle : AppTheme.accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart,
                            size: 16,
                            color: isUnavailable ? AppTheme.textDisabled : AppTheme.accent,
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
    );
  }
}

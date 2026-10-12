import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import 'cart_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        title: Text(category.name),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final int crossAxisCount = width > 1100 ? 4 : (width > 680 ? 3 : 2);

          return StreamBuilder<List<ProductModel>>(
            stream: firestoreService.getProductsByCategory(category.name),
            builder: (context, snapshot) {
              // Loading state — shimmer skeleton grid
              if (snapshot.connectionState == ConnectionState.waiting) {
                return GridView.builder(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: AppTheme.space12,
                    mainAxisSpacing: AppTheme.space12,
                  ),
                  itemCount: crossAxisCount * 2,
                  itemBuilder: (context, _) => const ProductCardSkeleton(),
                );
              }

              // Error state
              if (snapshot.hasError) {
                return const ErrorStateView(
                  icon: Icons.inventory_2_outlined,
                  title: 'Unable to Load Products',
                  message: 'Please check your connection and try again.',
                );
              }

              final products = snapshot.data ?? [];

              // Empty state
              if (products.isEmpty) {
                return EmptyStateView(
                  icon: Icons.inventory_2_outlined,
                  title: 'No Products Yet',
                  description:
                      'No items found in ${category.name}. '
                      'Products will appear as soon as they are added.',
                );
              }

              // Products header + grid
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.space16, AppTheme.space16,
                        AppTheme.space16, AppTheme.space12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            '${products.length} ${products.length == 1 ? 'product' : 'products'}',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.space16, 0,
                      AppTheme.space16, AppTheme.space40,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: AppTheme.space12,
                        mainAxisSpacing: AppTheme.space12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ProductCard(product: products[index]),
                        childCount: products.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

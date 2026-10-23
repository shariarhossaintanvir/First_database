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

class CategoryProductsScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _sortBy = 'newest';
  bool _inStockOnly = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(widget.category.name),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.textPrimary),
                tooltip: 'Shopping Cart',
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
          final int crossAxisCount = width > 1200
              ? 5
              : (width > 900 ? 4 : (width > 600 ? 3 : 2));

          return StreamBuilder<List<ProductModel>>(
            stream: _firestoreService.getProductsByCategory(widget.category.name),
            builder: (context, snapshot) {
              // Loading state: shimmer skeleton grid
              if (snapshot.connectionState == ConnectionState.waiting) {
                return GridView.builder(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: AppTheme.space12,
                    mainAxisSpacing: AppTheme.space12,
                  ),
                  itemCount: crossAxisCount * 2,
                  itemBuilder: (context, _) => const ProductCardSkeleton(),
                );
              }

              // Error state
              if (snapshot.hasError) {
                return ErrorStateView.offline(
                  onRetry: () => setState(() {}),
                );
              }

              var products = snapshot.data ?? [];

              // Filter by in-stock only
              if (_inStockOnly) {
                products = products.where((p) => p.isAvailable && p.stock > 0).toList();
              }

              // Sorting
              if (_sortBy == 'price_asc') {
                products.sort((a, b) => a.price.compareTo(b.price));
              } else if (_sortBy == 'price_desc') {
                products.sort((a, b) => b.price.compareTo(a.price));
              } else if (_sortBy == 'availability') {
                products.sort((a, b) {
                  final aInStock = (a.isAvailable && a.stock > 0) ? 1 : 0;
                  final bInStock = (b.isAvailable && b.stock > 0) ? 1 : 0;
                  if (aInStock != bInStock) {
                    return bInStock.compareTo(aInStock);
                  }
                  return b.stock.compareTo(a.stock);
                });
              } else {
                products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              }

              // Empty state
              if (products.isEmpty) {
                return EmptyStateView(
                  icon: Icons.inventory_2_outlined,
                  title: _inStockOnly
                      ? 'No In-Stock Items'
                      : 'No Products Found',
                  description: _inStockOnly
                      ? 'All products in ${widget.category.name} are currently out of stock.'
                      : 'No items found in ${widget.category.name}.',
                  actionLabel: _inStockOnly ? 'Show All Products' : null,
                  onActionPressed: _inStockOnly
                      ? () => setState(() => _inStockOnly = false)
                      : null,
                );
              }

              // Products header + grid
              return CustomScrollView(
                slivers: [
                  // Filter & Sort Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.space16, AppTheme.space12,
                        AppTheme.space16, AppTheme.space12,
                      ),
                      child: Row(
                        children: [
                          // In-Stock toggle chip
                          FilterChip(
                            label: const Text('In-Stock Only'),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: _inStockOnly ? FontWeight.w600 : FontWeight.normal,
                              color: _inStockOnly ? AppTheme.accent : AppTheme.textSecondary,
                            ),
                            selected: _inStockOnly,
                            onSelected: (val) => setState(() => _inStockOnly = val),
                            selectedColor: AppTheme.accentSubtle,
                            backgroundColor: AppTheme.bgSecondary,
                            side: BorderSide(
                              color: _inStockOnly ? AppTheme.accent : AppTheme.borderSubtle,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                          ),
                          const Spacer(),

                          // Count label
                          Text(
                            '${products.length} ${products.length == 1 ? 'item' : 'items'}',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: AppTheme.space10),

                          // Sort dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.space10,
                              vertical: AppTheme.space4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              border: Border.all(color: AppTheme.borderSubtle),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                isDense: true,
                                dropdownColor: AppTheme.surfaceElevated,
                                icon: const Icon(
                                  Icons.sort_rounded,
                                  size: 16,
                                  color: AppTheme.textMuted,
                                ),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'newest',
                                    child: Text('Newest'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'price_asc',
                                    child: Text('Price: Low to High'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'price_desc',
                                    child: Text('Price: High to Low'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'availability',
                                    child: Text('Availability'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _sortBy = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Product Grid
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.space16, 0,
                      AppTheme.space16, AppTheme.space40,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: AppTheme.space12,
                        mainAxisSpacing: AppTheme.space12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ProductCard(product: products[index]),
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

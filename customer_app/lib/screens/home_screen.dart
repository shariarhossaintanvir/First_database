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
import '../widgets/category_pill.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.accentSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppTheme.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'ShopEase',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.5,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
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
          final int crossAxisCount = width > 1100 ? 4 : (width > 680 ? 3 : 2);

          return CustomScrollView(
            slivers: [
              // ── Search Bar ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.space16, AppTheme.space12,
                    AppTheme.space16, AppTheme.space12,
                  ),
                  child: TextField(
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search products, brands, categories...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      prefixIcon: const Icon(
                        Icons.search, color: AppTheme.textMuted, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 18),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.bgSecondary,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
                      ),
                    ),
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim().toLowerCase()),
                  ),
                ),
              ),

              // ── Hero Banner (hidden while searching) ────────────────────
              if (_searchQuery.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.space16, 0, AppTheme.space16, AppTheme.space4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      padding: const EdgeInsets.all(AppTheme.space20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.space8,
                                    vertical: AppTheme.space4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentSubtle,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                                    border: Border.all(
                                      color: AppTheme.accent.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: const Text(
                                    'CURATED CATALOG',
                                    style: TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppTheme.space10),
                                const Text(
                                  'Genuine Products\nDelivered Nationwide',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    height: 1.25,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.space6),
                                const Text(
                                  'Verified authenticity with delivery across Bangladesh.',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppTheme.space12),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.space16),
                            decoration: BoxDecoration(
                              color: AppTheme.bgSecondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.borderSubtle),
                            ),
                            child: const Icon(
                              Icons.verified_outlined,
                              color: AppTheme.accent,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Category Section Header ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.space16, AppTheme.space16,
                    AppTheme.space16, AppTheme.space10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (_selectedCategory != 'All')
                        GestureDetector(
                          onTap: () => setState(() => _selectedCategory = 'All'),
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Category Pills (Phase 2 CategoryPill) ───────────────────
              SliverToBoxAdapter(
                child: StreamBuilder<List<CategoryModel>>(
                  stream: _firestoreService.getCategoriesStream(),
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    if (categories.isEmpty) return const SizedBox.shrink();

                    return SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.space16),
                        children: [
                          CategoryPill(
                            label: 'All',
                            isSelected: _selectedCategory == 'All',
                            onTap: () =>
                                setState(() => _selectedCategory = 'All'),
                          ),
                          ...categories.map((cat) {
                            final isSelected = _selectedCategory == cat.name;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: AppTheme.space8),
                              child: CategoryPill(
                                label: cat.name,
                                isSelected: isSelected,
                                onTap: () => setState(() {
                                  _selectedCategory =
                                      isSelected ? 'All' : cat.name;
                                }),
                              ),
                            );
                          }),
                          const SizedBox(width: AppTheme.space8),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Product Grid Stream ──────────────────────────────────────
              StreamBuilder<List<ProductModel>>(
                stream: _firestoreService.getProductsStream(),
                builder: (context, snapshot) {
                  // Loading — shimmer skeleton placeholders
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.space16, AppTheme.space20,
                        AppTheme.space16, 0,
                      ),
                      sliver: SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: AppTheme.space12,
                          mainAxisSpacing: AppTheme.space12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, _) => const ProductCardSkeleton(),
                          childCount: crossAxisCount * 2,
                        ),
                      ),
                    );
                  }

                  // Error state
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppTheme.space32),
                        child: ErrorStateView.offline(
                          onRetry: () => setState(() {}),
                        ),
                      ),
                    );
                  }

                  var products = snapshot.data ?? [];

                  // Apply category filter
                  if (_selectedCategory != 'All') {
                    products = products
                        .where((p) =>
                            p.category.toLowerCase() ==
                            _selectedCategory.toLowerCase())
                        .toList();
                  }

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    products = products.where((p) {
                      return p.title
                              .toLowerCase()
                              .contains(_searchQuery) ||
                          p.category
                              .toLowerCase()
                              .contains(_searchQuery) ||
                          p.description
                              .toLowerCase()
                              .contains(_searchQuery);
                    }).toList();
                  }

                  // Empty state
                  if (products.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateView(
                        icon: Icons.inventory_2_outlined,
                        title: _searchQuery.isNotEmpty
                            ? 'No results for "$_searchQuery"'
                            : _selectedCategory != 'All'
                                ? 'No products in $_selectedCategory'
                                : 'Catalog is empty',
                        description: _searchQuery.isNotEmpty
                            ? 'Try different keywords or browse by category.'
                            : 'Products will appear here once added.',
                        actionLabel:
                            (_searchQuery.isNotEmpty ||
                                    _selectedCategory != 'All')
                                ? 'Clear Filter'
                                : null,
                        onActionPressed: () => setState(() {
                          _searchQuery = '';
                          _selectedCategory = 'All';
                        }),
                      ),
                    );
                  }

                  // Populated — section header + grid
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.space16, AppTheme.space20,
                            AppTheme.space16, AppTheme.space12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Search Results'
                                    : _selectedCategory == 'All'
                                        ? 'All Products'
                                        : _selectedCategory,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Text(
                                '${products.length} ${products.length == 1 ? 'item' : 'items'}',
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.space16),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppTheme.space40)),
            ],
          );
        },
      ),
    );
  }
}

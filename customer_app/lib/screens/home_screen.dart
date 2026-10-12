import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
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
              child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.accent, size: 20),
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
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: TextField(
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search products, brands, models...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.bgSecondary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  ),
                ),
              ),

              // Promotional Hero Banner (only when not searching)
              if (_searchQuery.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1E24), Color(0xFF131317)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentSubtle,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                                  ),
                                  child: const Text(
                                    'CURATED COLLECTION',
                                    style: TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Genuine Tech &\nPremium Goods',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Verified authenticity with fast nationwide delivery in Bangladesh.',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.borderSubtle),
                            ),
                            child: const Icon(
                              Icons.verified_outlined,
                              color: AppTheme.accent,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Category Pills Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (_selectedCategory != 'All')
                        TextButton(
                          onPressed: () => setState(() => _selectedCategory = 'All'),
                          child: const Text('Reset Filter'),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: StreamBuilder<List<CategoryModel>>(
                  stream: _firestoreService.getCategoriesStream(),
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    if (categories.isEmpty) return const SizedBox.shrink();

                    return SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length + 1,
                        separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            final isSelected = _selectedCategory == 'All';
                            return ChoiceChip(
                              label: const Text('All'),
                              selected: isSelected,
                              selectedColor: AppTheme.accentSubtle,
                              backgroundColor: AppTheme.bgSecondary,
                              side: BorderSide(
                                color: isSelected ? AppTheme.accent : AppTheme.borderSubtle,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 13,
                              ),
                              onSelected: (_) => setState(() => _selectedCategory = 'All'),
                            );
                          }

                          final cat = categories[index - 1];
                          final isSelected = _selectedCategory == cat.name;

                          return ChoiceChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            selectedColor: AppTheme.accentSubtle,
                            backgroundColor: AppTheme.bgSecondary,
                            side: BorderSide(
                              color: isSelected ? AppTheme.accent : AppTheme.borderSubtle,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? cat.name : 'All';
                              });
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Products Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
                  child: Text(
                    _selectedCategory == 'All'
                        ? (_searchQuery.isEmpty ? 'Trending Catalog' : 'Search Results')
                        : '$_selectedCategory Collection',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              // Products Stream Grid
              StreamBuilder<List<ProductModel>>(
                stream: _firestoreService.getProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: AppTheme.accent),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_off_outlined,
                                size: 64,
                                color: AppTheme.textMuted,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Unable to load products',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Please check your connection and try again.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => setState(() {}),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  var products = snapshot.data ?? [];

                  // Filter by category
                  if (_selectedCategory != 'All') {
                    products = products
                        .where(
                          (p) =>
                              p.category.toLowerCase() == _selectedCategory.toLowerCase(),
                        )
                        .toList();
                  }

                  // Filter by search query
                  if (_searchQuery.isNotEmpty) {
                    products = products.where((p) {
                      return p.title.toLowerCase().contains(_searchQuery) ||
                          p.category.toLowerCase().contains(_searchQuery) ||
                          p.description.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  if (products.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: AppTheme.textMuted,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No products matching "$_searchQuery"'
                                    : 'No products in this category yet',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Try clearing your filter or searching for another term.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProductCard(product: products[index]);
                        },
                        childCount: products.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 36)),
            ],
          );
        },
      ),
    );
  }
}

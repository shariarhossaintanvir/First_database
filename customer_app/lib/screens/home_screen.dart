import 'dart:async';
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

  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'newest';

  // Price & stock filters
  double? _minPrice;
  double? _maxPrice;
  bool _inStockOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      }
    });
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _resetAllFilters() {
    setState(() {
      _selectedCategory = 'All';
      _minPrice = null;
      _maxPrice = null;
      _inStockOnly = false;
      _sortBy = 'newest';
      _clearSearch();
    });
  }

  bool get _hasActiveFilters =>
      _selectedCategory != 'All' ||
      _minPrice != null ||
      _maxPrice != null ||
      _inStockOnly;

  void _showFilterModal() {
    double? tempMin = _minPrice;
    double? tempMax = _maxPrice;
    bool tempInStock = _inStockOnly;

    final minController = TextEditingController(
      text: tempMin != null ? tempMin.toInt().toString() : '',
    );
    final maxController = TextEditingController(
      text: tempMax != null ? tempMax.toInt().toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppTheme.space20,
                right: AppTheme.space20,
                top: AppTheme.space20,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.space24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.borderSubtle),
                  const SizedBox(height: AppTheme.space12),

                  // In-Stock Only Switch
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: AppTheme.accent,
                    title: const Text(
                      'In-Stock Items Only',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Hide products currently unavailable or out of stock',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    value: tempInStock,
                    onChanged: (val) {
                      setModalState(() => tempInStock = val);
                    },
                  ),

                  const SizedBox(height: AppTheme.space16),

                  // Price Range Header
                  const Text(
                    'Price Range (৳ BDT)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space10),

                  // Min & Max Price Fields
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Min Price',
                            hintText: '0',
                            prefixText: '৳ ',
                            filled: true,
                            fillColor: AppTheme.bgSecondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              borderSide: const BorderSide(color: AppTheme.borderSubtle),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.space12),
                        child: Text('—', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: maxController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Max Price',
                            hintText: 'Any',
                            prefixText: '৳ ',
                            filled: true,
                            fillColor: AppTheme.bgSecondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              borderSide: const BorderSide(color: AppTheme.borderSubtle),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.space24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _inStockOnly = false;
                              _minPrice = null;
                              _maxPrice = null;
                            });
                            Navigator.pop(ctx);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppTheme.borderSubtle),
                            foregroundColor: AppTheme.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final minVal = double.tryParse(minController.text.trim());
                            final maxVal = double.tryParse(maxController.text.trim());
                            setState(() {
                              _inStockOnly = tempInStock;
                              _minPrice = minVal;
                              _maxPrice = maxVal;
                            });
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: AppTheme.bgPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                          ),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
          final int crossAxisCount = width > 1200
              ? 5
              : (width > 900 ? 4 : (width > 600 ? 3 : 2));

          return CustomScrollView(
            slivers: [
              // ── Search & Filter Row ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.space16, AppTheme.space12,
                    AppTheme.space16, AppTheme.space8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search products, brands, categories...',
                            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                            prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 18),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            filled: true,
                            fillColor: AppTheme.bgSecondary,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space8),
                      // Filter button with active indicator badge
                      InkWell(
                        onTap: _showFilterModal,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _hasActiveFilters ? AppTheme.accentSubtle : AppTheme.bgSecondary,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: _hasActiveFilters ? AppTheme.accent : AppTheme.borderSubtle,
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 22,
                            color: _hasActiveFilters ? AppTheme.accent : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Active Filter Chips Bar (if filters active) ─────────────────
              if (_hasActiveFilters)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.space16, 0, AppTheme.space16, AppTheme.space8,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedCategory != 'All')
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Chip(
                                label: Text('Category: $_selectedCategory'),
                                labelStyle: const TextStyle(fontSize: 12, color: AppTheme.accent),
                                backgroundColor: AppTheme.accentSubtle,
                                deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.accent),
                                onDeleted: () => setState(() => _selectedCategory = 'All'),
                                side: const BorderSide(color: AppTheme.accent, width: 0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          if (_inStockOnly)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Chip(
                                label: const Text('In-Stock Only'),
                                labelStyle: const TextStyle(fontSize: 12, color: AppTheme.accent),
                                backgroundColor: AppTheme.accentSubtle,
                                deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.accent),
                                onDeleted: () => setState(() => _inStockOnly = false),
                                side: const BorderSide(color: AppTheme.accent, width: 0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          if (_minPrice != null || _maxPrice != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Chip(
                                label: Text(
                                  'Price: ৳${_minPrice?.toInt() ?? 0} - ${_maxPrice != null ? '৳${_maxPrice!.toInt()}' : 'Any'}',
                                ),
                                labelStyle: const TextStyle(fontSize: 12, color: AppTheme.accent),
                                backgroundColor: AppTheme.accentSubtle,
                                deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.accent),
                                onDeleted: () => setState(() {
                                  _minPrice = null;
                                  _maxPrice = null;
                                }),
                                side: const BorderSide(color: AppTheme.accent, width: 0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          TextButton(
                            onPressed: _resetAllFilters,
                            child: const Text(
                              'Reset All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Trust Banner (hidden during search or filtered state) ──────
              if (_searchQuery.isEmpty && !_hasActiveFilters)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.space16, AppTheme.space4, AppTheme.space16, AppTheme.space8,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space16,
                        vertical: AppTheme.space12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.space10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentSubtle,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
                            ),
                            child: const Icon(
                              Icons.verified_outlined,
                              color: AppTheme.accent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppTheme.space12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ShopEase Bangladesh',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '100% Genuine Products • Cash on Delivery • Fast Doorstep Delivery',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Category Navigation Bar ─────────────────────────────────────
              SliverToBoxAdapter(
                child: StreamBuilder<List<CategoryModel>>(
                  stream: _firestoreService.getCategoriesStream(),
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    if (categories.isEmpty) return const SizedBox.shrink();

                    return SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
                        children: [
                          CategoryPill(
                            label: 'All',
                            isSelected: _selectedCategory == 'All',
                            onTap: () => setState(() => _selectedCategory = 'All'),
                          ),
                          ...categories.map((cat) {
                            final isSelected = _selectedCategory == cat.name;
                            return Padding(
                              padding: const EdgeInsets.only(left: AppTheme.space8),
                              child: CategoryPill(
                                label: cat.name,
                                isSelected: isSelected,
                                onTap: () => setState(() {
                                  _selectedCategory = isSelected ? 'All' : cat.name;
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

              // ── Product Grid Stream ─────────────────────────────────────────
              StreamBuilder<List<ProductModel>>(
                stream: _firestoreService.getProductsStream(),
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.space16, AppTheme.space16,
                        AppTheme.space16, 0,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.72,
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

                  // 1. Category filter
                  if (_selectedCategory != 'All') {
                    products = products
                        .where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase())
                        .toList();
                  }

                  // 2. Debounced search filter
                  if (_searchQuery.isNotEmpty) {
                    products = products.where((p) {
                      return p.title.toLowerCase().contains(_searchQuery) ||
                          p.category.toLowerCase().contains(_searchQuery) ||
                          p.description.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  // 3. In-Stock filter
                  if (_inStockOnly) {
                    products = products.where((p) => p.isAvailable && p.stock > 0).toList();
                  }

                  // 4. Min Price filter
                  if (_minPrice != null) {
                    products = products.where((p) => p.price >= _minPrice!).toList();
                  }

                  // 5. Max Price filter
                  if (_maxPrice != null) {
                    products = products.where((p) => p.price <= _maxPrice!).toList();
                  }

                  // 6. Sorting
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
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateView(
                        icon: Icons.inventory_2_outlined,
                        title: _searchQuery.isNotEmpty
                            ? 'No results for "$_searchQuery"'
                            : _selectedCategory != 'All'
                                ? 'No products in $_selectedCategory'
                                : 'No matching products',
                        description: _hasActiveFilters || _searchQuery.isNotEmpty
                            ? 'Try clearing active filters or adjusting your search keywords.'
                            : 'Products will appear here once added.',
                        actionLabel: (_searchQuery.isNotEmpty || _hasActiveFilters)
                            ? 'Reset All Filters'
                            : null,
                        onActionPressed: _resetAllFilters,
                      ),
                    );
                  }

                  // Populated header + product grid
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.space16, AppTheme.space16,
                            AppTheme.space16, AppTheme.space12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'Search Results'
                                          : _selectedCategory == 'All'
                                              ? 'All Products'
                                              : _selectedCategory,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${products.length} ${products.length == 1 ? 'item' : 'items'} found',
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppTheme.space12),
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
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
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
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppTheme.space40)),
            ],
          );
        },
      ),
    );
  }
}

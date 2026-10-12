import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_layout.dart';
import 'add_edit_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.surfaceCard,
        title: const Text('Delete Product', style: TextStyle(color: AdminTheme.textPrimary)),
        content: Text(
          'Are you sure you want to permanently remove "${product.title}" from the catalog?',
          style: const TextStyle(color: AdminTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AdminTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.statusError,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _firestoreService.deleteProduct(product.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showStockDialog(ProductModel product) {
    final stockController = TextEditingController(text: product.stock.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminTheme.surfaceCard,
        title: Text(
          'Update Stock: ${product.title}',
          style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 16),
        ),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: AdminTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'New Stock Units',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AdminTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(stockController.text.trim());
              if (newStock == null || newStock < 0 || newStock > 1000000) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid stock value (0 - 1,000,000 allowed)'),
                    backgroundColor: AdminTheme.statusError,
                  ),
                );
                return;
              }
              await _firestoreService.updateProductStock(product.id, newStock);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stock updated to $newStock for "${product.title}"'),
                    backgroundColor: AdminTheme.surfaceElevated,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Catalog & Inventory',
      currentRoute: '/products',
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
            );
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Product'),
        ),
      ],
      body: Column(
        children: [
          // Filter Toolbar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AdminTheme.bgSidebar,
              border: Border(bottom: BorderSide(color: AdminTheme.borderSubtle, width: 1)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                final searchWidget = TextField(
                  style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search products by title, category, or specifications...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: searchWidget),
                      const SizedBox(width: 16),
                      // Category Filter Pill Dropdown
                      StreamBuilder<List<String>>(
                        stream: _firestoreService.getCategoriesStream().map((cats) => ['All', ...cats.map((c) => c.name)]),
                        builder: (context, catSnap) {
                          final categories = catSnap.data ?? ['All'];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AdminTheme.bgWorkspace,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AdminTheme.borderSubtle),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: categories.contains(_selectedCategory) ? _selectedCategory : 'All',
                                dropdownColor: AdminTheme.surfaceCard,
                                style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13),
                                items: categories.map((cat) {
                                  return DropdownMenuItem(value: cat, child: Text(cat));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedCategory = val);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }

                return searchWidget;
              },
            ),
          ),

          // Product Inventory Stream
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _firestoreService.getProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AdminTheme.accent),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Unable to load products. Check network permissions.',
                        style: TextStyle(color: AdminTheme.statusError),
                      ),
                    ),
                  );
                }

                var products = snapshot.data ?? [];

                // Filter by category
                if (_selectedCategory != 'All') {
                  products = products.where((p) => p.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 56,
                          color: AdminTheme.textMuted,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No products matching "$_searchQuery"'
                              : 'No products in store yet',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdminTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddEditProductScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Catalog Product'),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktopTable = constraints.maxWidth >= 960;

                    if (isDesktopTable) {
                      // Desktop Enterprise SaaS Table
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Card(
                          color: AdminTheme.surfaceCard,
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Table Header Bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                color: AdminTheme.bgSidebar,
                                child: Row(
                                  children: [
                                    Text(
                                      'Showing ${products.length} Products',
                                      style: const TextStyle(
                                        color: AdminTheme.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: AdminTheme.borderSubtle),

                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: products.length,
                                separatorBuilder: (ctx, idx) => const Divider(height: 1, color: AdminTheme.borderSubtle),
                                itemBuilder: (context, index) {
                                  final p = products[index];
                                  final isOutOfStock = p.stock <= 0;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    color: index % 2 == 0 ? Colors.transparent : AdminTheme.surfaceHover.withValues(alpha: 0.2),
                                    child: Row(
                                      children: [
                                        // Image Thumbnail
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            width: 48,
                                            height: 48,
                                            color: AdminTheme.bgSidebar,
                                            padding: const EdgeInsets.all(4),
                                            child: Image.network(
                                              p.imageUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder: (ctx, err, stack) => const Icon(
                                                Icons.image_not_supported_outlined,
                                                color: AdminTheme.textMuted,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Title & Specs
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: AdminTheme.textPrimary,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'ID: ${p.id.length > 8 ? p.id.substring(0, 8) : p.id}',
                                                style: const TextStyle(
                                                  color: AdminTheme.textMuted,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Category Pill
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AdminTheme.bgSidebar,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: AdminTheme.borderSubtle),
                                              ),
                                              child: Text(
                                                p.category,
                                                style: const TextStyle(
                                                  color: AdminTheme.textSecondary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Stock with Quick Edit
                                        Expanded(
                                          flex: 2,
                                          child: InkWell(
                                            onTap: () => _showStockDialog(p),
                                            borderRadius: BorderRadius.circular(6),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: isOutOfStock
                                                        ? AdminTheme.statusError.withValues(alpha: 0.12)
                                                        : (p.stock <= 5
                                                            ? AdminTheme.statusWarning.withValues(alpha: 0.12)
                                                            : AdminTheme.statusSuccess.withValues(alpha: 0.12)),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: isOutOfStock
                                                          ? AdminTheme.statusError.withValues(alpha: 0.3)
                                                          : (p.stock <= 5
                                                              ? AdminTheme.statusWarning.withValues(alpha: 0.3)
                                                              : AdminTheme.statusSuccess.withValues(alpha: 0.3)),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '${p.stock} units',
                                                    style: TextStyle(
                                                      color: isOutOfStock
                                                          ? AdminTheme.statusError
                                                          : (p.stock <= 5
                                                              ? AdminTheme.statusWarning
                                                              : AdminTheme.statusSuccess),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(Icons.edit_outlined, size: 13, color: AdminTheme.textMuted),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Status Pill (Toggle Active/Inactive)
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () async {
                                              await _firestoreService.toggleProductAvailability(p.id, !p.isAvailable);
                                            },
                                            borderRadius: BorderRadius.circular(6),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: p.isAvailable
                                                    ? AdminTheme.accentSubtle
                                                    : AdminTheme.surfaceElevated,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: p.isAvailable ? AdminTheme.accent.withValues(alpha: 0.3) : AdminTheme.borderSubtle,
                                                ),
                                              ),
                                              child: Text(
                                                p.isAvailable ? 'Active' : 'Inactive',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: p.isAvailable ? AdminTheme.accent : AdminTheme.textDisabled,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Price (BDT)
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '৳ ${p.price.toStringAsFixed(0)}',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AdminTheme.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 24),

                                        // Actions
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: AdminTheme.accent),
                                              tooltip: 'Edit Product Details',
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => AddEditProductScreen(product: p),
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 18, color: AdminTheme.statusError),
                                              tooltip: 'Delete Product',
                                              onPressed: () => _confirmDelete(p),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Mobile / Tablet Responsive Cards
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final p = products[index];

                        return Card(
                          color: AdminTheme.surfaceCard,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AdminTheme.borderSubtle),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    color: AdminTheme.bgSidebar,
                                    padding: const EdgeInsets.all(4),
                                    child: Image.network(
                                      p.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (ctx, err, stack) => const Icon(
                                        Icons.image_not_supported_outlined,
                                        color: AdminTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AdminTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AdminTheme.bgSidebar,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: AdminTheme.borderSubtle),
                                            ),
                                            child: Text(
                                              p.category,
                                              style: const TextStyle(fontSize: 10, color: AdminTheme.textSecondary),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => _showStockDialog(p),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: p.stock > 0
                                                    ? AdminTheme.statusSuccess.withValues(alpha: 0.12)
                                                    : AdminTheme.statusError.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Stock: ${p.stock}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: p.stock > 0 ? AdminTheme.statusSuccess : AdminTheme.statusError,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '৳ ${p.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AdminTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AdminTheme.accent),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddEditProductScreen(product: p),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: AdminTheme.statusError),
                                      onPressed: () => _confirmDelete(p),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

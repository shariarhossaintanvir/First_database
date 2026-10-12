import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_layout.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;

  String? _selectedCategory;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  bool _isAvailable = true;
  List<CategoryModel> _categories = [];

  // Preset sample high quality images
  final List<Map<String, String>> _sampleImages = [
    {
      'name': 'Laptop',
      'url':
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600&q=80',
    },
    {
      'name': 'Headphones',
      'url':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
    },
    {
      'name': 'Smartwatch',
      'url':
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80',
    },
    {
      'name': 'Sneakers',
      'url':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80',
    },
    {
      'name': 'Camera',
      'url':
          'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600&q=80',
    },
    {
      'name': 'Backpack',
      'url':
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(0) : '',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '15',
    );
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _selectedCategory = p?.category;
    _isAvailable = p?.isAvailable ?? true;

    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    _firestoreService.getCategoriesStream().first.then((cats) {
      if (mounted) {
        setState(() {
          _categories = cats;
          if (_selectedCategory == null && cats.isNotEmpty) {
            _selectedCategory = cats.first.name;
          }
        });
      }
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? file = await _storageService.pickImage();
      if (file == null) return;

      setState(() => _isUploadingImage = true);

      final downloadUrl = await _storageService.uploadProductImage(
        file,
        productId: widget.product?.id,
      );

      setState(() {
        _imageUrlController.text = downloadUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded to Firebase Storage successfully!'),
            backgroundColor: AdminTheme.surfaceElevated,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Storage upload note: $e. You can also paste an image URL directly.',
            ),
            backgroundColor: AdminTheme.statusWarning,
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category'), backgroundColor: AdminTheme.statusError));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final stock = int.tryParse(_stockController.text.trim()) ?? 0;
      final imageUrl = _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80';

      if (widget.product == null) {
        // Add new product
        final newProduct = ProductModel(
          id: '',
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          price: price,
          imageUrl: imageUrl,
          category: _selectedCategory!,
          stock: stock,
          isAvailable: _isAvailable,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestoreService.addProduct(newProduct);
      } else {
        // Update existing product
        final updatedProduct = widget.product!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          price: price,
          imageUrl: imageUrl,
          category: _selectedCategory!,
          stock: stock,
          isAvailable: _isAvailable,
          updatedAt: DateTime.now(),
        );
        await _firestoreService.updateProduct(updatedProduct);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving product: $e'), backgroundColor: AdminTheme.statusError));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final titleText = isEditing ? 'Edit Catalog Product' : 'Add New Product';

    return AdminLayout(
      title: titleText,
      currentRoute: '/add-product',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AdminTheme.accent))
          : LayoutBuilder(
              builder: (context, constraints) {
                final isTwoColumn = constraints.maxWidth >= 960;

                final formContent = Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Product Title
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Product Title / Model Name *',
                          prefixIcon: Icon(Icons.shopping_bag_outlined),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter product title';
                          }
                          final trimmed = v.trim();
                          if (trimmed.length < 2) {
                            return 'Title must be at least 2 characters';
                          }
                          if (trimmed.length > 150) {
                            return 'Title cannot exceed 150 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        dropdownColor: AdminTheme.surfaceCard,
                        style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Store Category *',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _categories.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.name,
                            child: Text(c.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedCategory = val);
                        },
                        validator: (v) => v == null ? 'Select category' : null,
                      ),
                      const SizedBox(height: 16),

                      // Price & Stock Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: const TextStyle(color: AdminTheme.textPrimary),
                              decoration: const InputDecoration(
                                labelText: 'Price in BDT (৳) *',
                                prefixIcon: Icon(Icons.payments_outlined),
                              ),
                              onChanged: (_) => setState(() {}),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter price';
                                }
                                final p = double.tryParse(v.trim());
                                if (p == null) {
                                  return 'Invalid number';
                                }
                                if (p <= 0) {
                                  return 'Price must be greater than 0';
                                }
                                if (p > 10000000) {
                                  return 'Price cannot exceed 10,000,000';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AdminTheme.textPrimary),
                              decoration: const InputDecoration(
                                labelText: 'Inventory Stock Units *',
                                prefixIcon: Icon(Icons.inventory_2_outlined),
                              ),
                              onChanged: (_) => setState(() {}),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter stock';
                                }
                                final s = int.tryParse(v.trim());
                                if (s == null) {
                                  return 'Invalid integer';
                                }
                                if (s < 0) {
                                  return 'Stock cannot be negative';
                                }
                                if (s > 1000000) {
                                  return 'Stock cannot exceed 1,000,000';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descController,
                        maxLines: 4,
                        style: const TextStyle(color: AdminTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Product Description & Specifications',
                          alignLabelWithHint: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v != null && v.trim().length > 3000) {
                            return 'Description cannot exceed 3,000 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Availability Switch
                      Card(
                        color: AdminTheme.surfaceCard,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AdminTheme.borderSubtle),
                        ),
                        child: SwitchListTile(
                          title: const Text(
                            'Available for Customer Purchase',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.textPrimary, fontSize: 13),
                          ),
                          subtitle: Text(
                            _isAvailable
                                ? 'Active: displayed and purchasable in the storefront'
                                : 'Disabled: hidden from catalog search & checkout',
                            style: TextStyle(
                              fontSize: 11,
                              color: _isAvailable ? AdminTheme.statusSuccess : AdminTheme.statusError,
                            ),
                          ),
                          value: _isAvailable,
                          activeThumbColor: AdminTheme.accent,
                          onChanged: (val) => setState(() => _isAvailable = val),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Image Section Card
                      Card(
                        color: AdminTheme.surfaceCard,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AdminTheme.borderSubtle),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Product Image Asset',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AdminTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Upload Button
                              ElevatedButton.icon(
                                onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                                icon: _isUploadingImage
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AdminTheme.bgSidebar,
                                        ),
                                      )
                                    : const Icon(Icons.cloud_upload_outlined, size: 16),
                                label: Text(
                                  _isUploadingImage
                                      ? 'Uploading to Firebase Storage...'
                                      : 'Upload Image to Firebase Storage',
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Image URL input fallback
                              TextFormField(
                                controller: _imageUrlController,
                                style: const TextStyle(color: AdminTheme.textPrimary, fontSize: 13),
                                decoration: InputDecoration(
                                  labelText: 'Or Direct Image URL',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.check, size: 16),
                                    onPressed: () => setState(() {}),
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 10),

                              // Preset sample images chips
                              const Text(
                                'Quick Image Samples:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AdminTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: _sampleImages.map((s) {
                                  return ActionChip(
                                    label: Text(
                                      s['name']!,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _imageUrlController.text = s['url']!;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      ElevatedButton(
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.accent,
                          foregroundColor: AdminTheme.bgSidebar,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isEditing
                              ? 'Save Product Changes'
                              : 'Publish Product to Live Storefront',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (isTwoColumn) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Form
                        Expanded(
                          flex: 3,
                          child: Card(
                            color: AdminTheme.surfaceCard,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AdminTheme.borderSubtle),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: formContent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Right Column: Live Store Preview Card
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Live Storefront Preview',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AdminTheme.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              _buildLivePreviewCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      formContent,
                      const SizedBox(height: 24),
                      const Text(
                        'Live Storefront Preview',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AdminTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLivePreviewCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLivePreviewCard() {
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : 'Sample Product Model';
    final category = _selectedCategory ?? 'Category';
    final priceStr = _priceController.text.trim().isNotEmpty
        ? _priceController.text.trim()
        : '0';
    final imageUrl = _imageUrlController.text.trim().isNotEmpty
        ? _imageUrlController.text.trim()
        : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80';
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Container(
            height: 200,
            width: double.infinity,
            color: AdminTheme.bgSidebar,
            padding: const EdgeInsets.all(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, stack) => const Center(
                child: Icon(Icons.image_not_supported_outlined, size: 48, color: AdminTheme.textMuted),
              ),
            ),
          ),
          const Divider(height: 1, color: AdminTheme.borderSubtle),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AdminTheme.accentSubtle,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                          color: AdminTheme.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Text(
                      _isAvailable ? 'In Stock ($stock)' : 'Unavailable',
                      style: TextStyle(
                        color: _isAvailable ? AdminTheme.statusSuccess : AdminTheme.statusError,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AdminTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '৳ $priceStr',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AdminTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

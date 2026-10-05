import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

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

  // Preset sample images for quick testing
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
      text: p != null ? p.price.toStringAsFixed(2) : '',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '10',
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
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.orange,
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
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
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
        // Add new
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
        // Update existing
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
        ).showSnackBar(SnackBar(content: Text('Error saving product: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Product Title *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                      ),
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
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
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
                            decoration: const InputDecoration(
                              labelText: 'Price (\$) *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
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
                              if (p > 1000000) {
                                return 'Price cannot exceed \$1,000,000';
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
                            decoration: const InputDecoration(
                              labelText: 'Stock Units *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                            ),
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
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (v) {
                        if (v != null && v.trim().length > 3000) {
                          return 'Description cannot exceed 3,000 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Availability Toggle
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Available for Purchase',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _isAvailable
                              ? 'Customers can view and order this product'
                              : 'Hidden / Disabled for checkout in Customer App',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isAvailable ? Colors.green.shade700 : Colors.red,
                          ),
                        ),
                        value: _isAvailable,
                        onChanged: (val) => setState(() => _isAvailable = val),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Image Section
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.grey.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Product Image',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Image Preview
                            if (_imageUrlController.text.trim().isNotEmpty)
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  _imageUrlController.text.trim(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) =>
                                      const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                            if (_imageUrlController.text.trim().isNotEmpty)
                              const SizedBox(height: 12),

                            // Upload Button
                            ElevatedButton.icon(
                              onPressed: _isUploadingImage
                                  ? null
                                  : _pickAndUploadImage,
                              icon: _isUploadingImage
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.cloud_upload_outlined),
                              label: Text(
                                _isUploadingImage
                                    ? 'Uploading Image...'
                                    : 'Pick & Upload to Firebase Storage',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Image URL input fallback
                            TextFormField(
                              controller: _imageUrlController,
                              decoration: InputDecoration(
                                labelText: 'Or Enter Image URL',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () => setState(() {}),
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 10),

                            // Preset images chips
                            const Text(
                              'Quick Presets:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _sampleImages.map((s) {
                                return ActionChip(
                                  label: Text(
                                    s['name']!,
                                    style: const TextStyle(fontSize: 12),
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

                    // Save / Update Button
                    ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isEditing
                            ? 'Save Product Changes'
                            : 'Publish Product to Store',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

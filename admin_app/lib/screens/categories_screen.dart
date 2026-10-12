import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_layout.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _firestoreService.seedDefaultCategoriesIfEmpty();
  }

  void _showAddEditDialog([CategoryModel? category]) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(
      text: category?.description ?? '',
    );
    final idController = TextEditingController(text: category?.id ?? '');
    final isEditing = category != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AdminTheme.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AdminTheme.borderSubtle),
          ),
          title: Text(
            isEditing ? 'Edit Category' : 'Add New Category',
            style: const TextStyle(color: AdminTheme.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditing)
                  TextField(
                    controller: idController,
                    style: const TextStyle(color: AdminTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Category Slug / ID (e.g. electronics)',
                      hintText: 'lowercase_slug',
                    ),
                  ),
                if (!isEditing) const SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Category Display Name',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  style: const TextStyle(color: AdminTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Category Description',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AdminTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final desc = descController.text.trim();
                if (name.isEmpty) return;

                final id = isEditing
                    ? category.id
                    : (idController.text.trim().isNotEmpty
                          ? idController.text.trim().toLowerCase()
                          : name.toLowerCase().replaceAll(' ', '_'));

                final newCat = CategoryModel(
                  id: id,
                  name: name,
                  description: desc,
                  icon: category?.icon ?? 'category',
                );

                if (isEditing) {
                  await _firestoreService.updateCategory(newCat);
                } else {
                  await _firestoreService.addCategory(newCat);
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save Changes' : 'Add Category'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminTheme.surfaceCard,
        title: const Text('Delete Category', style: TextStyle(color: AdminTheme.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${category.name}"? Products assigned to this category will lose category filtering.',
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
              await _firestoreService.deleteCategory(category.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Taxonomies & Categories',
      currentRoute: '/categories',
      actions: [
        IconButton(
          tooltip: 'Re-seed Defaults',
          icon: const Icon(Icons.refresh, color: AdminTheme.textMuted),
          onPressed: () async {
            await _firestoreService.seedDefaultCategoriesIfEmpty();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Categories verified and refreshed'),
                  backgroundColor: AdminTheme.surfaceElevated,
                ),
              );
            }
          },
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _showAddEditDialog(),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('New Category'),
        ),
      ],
      body: StreamBuilder<List<CategoryModel>>(
        stream: _firestoreService.getCategoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AdminTheme.accent),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.category_outlined, size: 48, color: AdminTheme.statusWarning),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Check admin permissions or connectivity: ${snapshot.error}',
                      style: const TextStyle(color: AdminTheme.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AdminTheme.surfaceCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: AdminTheme.borderSubtle),
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      size: 48,
                      color: AdminTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No categories in store catalog',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => _firestoreService.seedDefaultCategoriesIfEmpty(),
                    child: const Text('Load Standard 5 Categories'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: AdminTheme.surfaceCard,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AdminTheme.borderSubtle),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (ctx, idx) => const Divider(height: 1, color: AdminTheme.borderSubtle),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ListTile(
                    hoverColor: AdminTheme.surfaceHover,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AdminTheme.accentSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.folder_outlined, color: AdminTheme.accent, size: 20),
                    ),
                    title: Text(
                      cat.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AdminTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        cat.description.isNotEmpty
                            ? '${cat.description} • (ID: ${cat.id})'
                            : 'Slug: ${cat.id}',
                        style: const TextStyle(color: AdminTheme.textMuted, fontSize: 12),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AdminTheme.accent),
                          tooltip: 'Edit Category',
                          onPressed: () => _showAddEditDialog(cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AdminTheme.statusError),
                          tooltip: 'Delete Category',
                          onPressed: () => _confirmDelete(cat),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

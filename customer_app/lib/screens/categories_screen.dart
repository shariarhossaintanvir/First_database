import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('electronic')) {
      return Icons.devices_outlined;
    } else if (lower.contains('fashion') || lower.contains('apparel') || lower.contains('cloth')) {
      return Icons.checkroom_outlined;
    } else if (lower.contains('home') || lower.contains('living')) {
      return Icons.chair_outlined;
    } else if (lower.contains('beauty') || lower.contains('health')) {
      return Icons.spa_outlined;
    } else if (lower.contains('sport') || lower.contains('outdoor')) {
      return Icons.fitness_center_outlined;
    }
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        title: const Text('Browse Categories'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final int crossAxisCount = width > 1100 ? 4 : (width > 680 ? 3 : 2);

          return StreamBuilder<List<CategoryModel>>(
            stream: firestoreService.getCategoriesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.accent),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.category_outlined, size: 48, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'Unable to load categories',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Please check your network connection.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final categories = snapshot.data ?? [];
              if (categories.isEmpty) {
                return const Center(
                  child: Text(
                    'No categories available yet.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.15,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final icon = _getCategoryIcon(cat.name);

                  return Card(
                    color: AppTheme.surfaceCard,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppTheme.borderSubtle),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryProductsScreen(category: cat),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.accentSubtle,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.accent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Icon(
                                icon,
                                size: 28,
                                color: AppTheme.accent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

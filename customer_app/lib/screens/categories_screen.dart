import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import '../widgets/loading_shimmer.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tech') || lower.contains('electronic') ||
        lower.contains('laptop') || lower.contains('phone') ||
        lower.contains('computer') || lower.contains('gadget')) {
      return Icons.devices_outlined;
    } else if (lower.contains('fashion') || lower.contains('apparel') ||
        lower.contains('cloth') || lower.contains('wear') ||
        lower.contains('shirt') || lower.contains('dress')) {
      return Icons.checkroom_outlined;
    } else if (lower.contains('home') || lower.contains('living') ||
        lower.contains('furniture') || lower.contains('decor')) {
      return Icons.chair_outlined;
    } else if (lower.contains('beauty') || lower.contains('health') ||
        lower.contains('skincare') || lower.contains('cosmetic')) {
      return Icons.spa_outlined;
    } else if (lower.contains('sport') || lower.contains('outdoor') ||
        lower.contains('fitness') || lower.contains('gym')) {
      return Icons.fitness_center_outlined;
    } else if (lower.contains('food') || lower.contains('grocery') ||
        lower.contains('kitchen')) {
      return Icons.restaurant_menu_outlined;
    } else if (lower.contains('book') || lower.contains('stationery')) {
      return Icons.menu_book_outlined;
    } else if (lower.contains('toy') || lower.contains('kids') ||
        lower.contains('children')) {
      return Icons.toys_outlined;
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
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return GridView.builder(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: AppTheme.space12,
                    mainAxisSpacing: AppTheme.space12,
                  ),
                  itemCount: crossAxisCount * 2,
                  itemBuilder: (context, _) => _CategoryCardSkeleton(),
                );
              }

              // Error state
              if (snapshot.hasError) {
                return ErrorStateView(
                  icon: Icons.category_outlined,
                  title: 'Unable to Load Categories',
                  message: 'Please check your network connection and try again.',
                  onRetry: null,
                );
              }

              final categories = snapshot.data ?? [];

              // Empty state
              if (categories.isEmpty) {
                return const EmptyStateView(
                  icon: Icons.category_outlined,
                  title: 'No Categories Yet',
                  description:
                      'Categories will appear here once they have been added.',
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(AppTheme.space16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: AppTheme.space12,
                  mainAxisSpacing: AppTheme.space12,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final icon = _getCategoryIcon(cat.name);
                  return _CategoryCard(
                    category: cat,
                    icon: icon,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CategoryProductsScreen(category: cat),
                        ),
                      );
                    },
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

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: const BorderSide(color: AppTheme.borderSubtle),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.accentSubtle,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: AppTheme.space12),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.1,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton placeholder while categories load
class _CategoryCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShimmerBox(
              width: 52,
              height: 52,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            const SizedBox(height: AppTheme.space12),
            const ShimmerBox(width: 72, height: 12),
            const SizedBox(height: 6),
            const ShimmerBox(width: 48, height: 10),
          ],
        ),
      ),
    );
  }
}

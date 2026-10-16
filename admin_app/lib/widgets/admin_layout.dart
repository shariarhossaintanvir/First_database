import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/admin_theme.dart';
import 'admin_status_badge.dart';

class AdminLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final String currentRoute;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AdminLayout({
    super.key,
    required this.body,
    required this.title,
    required this.currentRoute,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        if (isDesktop) {
          return Scaffold(
            backgroundColor: AdminTheme.bgWorkspace,
            floatingActionButton: floatingActionButton,
            body: Row(
              children: [
                // Persistent Desktop Sidebar
                SizedBox(
                  width: 250,
                  child: _AdminSidebar(currentRoute: currentRoute),
                ),
                const VerticalDivider(width: 1, color: AdminTheme.borderSubtle),

                // Main Workspace
                Expanded(
                  child: Column(
                    children: [
                      // SaaS Workspace Header
                      Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: const BoxDecoration(
                          color: AdminTheme.bgSidebar,
                          border: Border(
                            bottom: BorderSide(color: AdminTheme.borderSubtle, width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AdminTheme.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const AdminStatusBadge(
                                  label: 'LIVE CATALOG',
                                  variant: AdminStatusBadgeVariant.success,
                                  showDot: true,
                                  isSmall: true,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                ...?actions,
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Content Area
                      Expanded(
                        child: Container(
                          color: AdminTheme.bgWorkspace,
                          child: body,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile / Tablet View (< 1024px)
        return Scaffold(
          backgroundColor: AdminTheme.bgWorkspace,
          appBar: AppBar(
            backgroundColor: AdminTheme.bgSidebar,
            title: Text(title),
            actions: actions,
          ),
          drawer: Drawer(
            backgroundColor: AdminTheme.bgSidebar,
            child: _AdminSidebar(currentRoute: currentRoute, isDrawer: true),
          ),
          floatingActionButton: floatingActionButton,
          body: body,
        );
      },
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final String currentRoute;
  final bool isDrawer;

  const _AdminSidebar({
    required this.currentRoute,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Container(
      color: AdminTheme.bgSidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand Logo Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AdminTheme.borderSubtle, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminTheme.accentSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminTheme.accent.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.storefront_outlined, color: AdminTheme.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ShopEase',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdminTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Operations Console',
                          style: TextStyle(
                            fontSize: 11,
                            color: AdminTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'MANAGEMENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AdminTheme.textMuted,
                      ),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard Overview',
                    route: '/dashboard',
                    isSelected: currentRoute == '/dashboard' || currentRoute == '/',
                    onTap: () {
                      if (isDrawer) Navigator.pop(context);
                      if (currentRoute != '/dashboard' && currentRoute != '/') {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      }
                    },
                  ),
                  _NavItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Catalog & Inventory',
                    route: '/products',
                    isSelected: currentRoute == '/products',
                    onTap: () {
                      if (isDrawer) Navigator.pop(context);
                      if (currentRoute != '/products') {
                        Navigator.pushReplacementNamed(context, '/products');
                      }
                    },
                  ),
                  _NavItem(
                    icon: Icons.add_circle_outline,
                    label: 'Add New Product',
                    route: '/add-product',
                    isSelected: currentRoute == '/add-product',
                    onTap: () {
                      if (isDrawer) Navigator.pop(context);
                      if (currentRoute != '/add-product') {
                        Navigator.pushNamed(context, '/add-product');
                      }
                    },
                  ),
                  _NavItem(
                    icon: Icons.category_outlined,
                    label: 'Categories',
                    route: '/categories',
                    isSelected: currentRoute == '/categories',
                    onTap: () {
                      if (isDrawer) Navigator.pop(context);
                      if (currentRoute != '/categories') {
                        Navigator.pushReplacementNamed(context, '/categories');
                      }
                    },
                  ),
                  _NavItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Customer Orders',
                    route: '/orders',
                    isSelected: currentRoute == '/orders',
                    onTap: () {
                      if (isDrawer) Navigator.pop(context);
                      if (currentRoute != '/orders') {
                        Navigator.pushReplacementNamed(context, '/orders');
                      }
                    },
                  ),
                  _NavItem(
                    icon: Icons.people_outline,
                    label: 'Customers',
                    route: '/customers',
                    isSelected: currentRoute == '/customers',
                    onTap: () {
                      if (isDrawer) Navigator.pop(context);
                      if (currentRoute != '/customers') {
                        Navigator.pushReplacementNamed(context, '/customers');
                      }
                    },
                  ),
                ],
              ),
            ),

            // Admin Profile Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AdminTheme.borderSubtle, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AdminTheme.accentSubtle,
                        child: const Icon(Icons.admin_panel_settings, size: 18, color: AdminTheme.accent),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.email ?? 'admin@ecommerce.com',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AdminTheme.textPrimary,
                              ),
                            ),
                            const Text(
                              'Master Admin',
                              style: TextStyle(
                                fontSize: 10,
                                color: AdminTheme.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AdminTheme.surfaceCard,
                          title: const Text('Sign Out', style: TextStyle(color: AdminTheme.textPrimary)),
                          content: const Text(
                            'Are you sure you want to end your administrator session?',
                            style: TextStyle(color: AdminTheme.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel', style: TextStyle(color: AdminTheme.textMuted)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AdminTheme.statusError,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                authService.signOut();
                              },
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, size: 14, color: AdminTheme.textMuted),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 12, color: AdminTheme.textMuted),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: AdminTheme.borderSubtle),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AdminTheme.surfaceHover : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: AdminTheme.borderStrong, width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AdminTheme.accent : AdminTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AdminTheme.textPrimary : AdminTheme.textSecondary,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AdminTheme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

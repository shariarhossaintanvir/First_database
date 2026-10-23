import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _navigateToTab(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 1:
        return 'Browse Categories | ShopEase';
      case 2:
        return 'Shopping Cart | ShopEase';
      case 3:
        return 'My Orders | ShopEase';
      case 4:
        return 'My Profile | ShopEase';
      case 0:
      default:
        return 'ShopEase | Online Shopping in Bangladesh';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    final List<Widget> screens = [
      HomeScreen(onNavigateTab: _navigateToTab),
      const CategoriesScreen(),
      const CartScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];

    return Title(
      title: _getPageTitle(),
      color: AppTheme.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 840;

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppTheme.bgPrimary,
            // Accessible Mobile Drawer
            drawer: isDesktop
                ? null
                : _buildAccessibleDrawer(context, cart, user, auth),
            // Desktop Top Header Navigation Bar
            appBar: isDesktop
                ? _buildDesktopAppBar(context, cart, user, auth)
                : null,
            body: IndexedStack(index: _currentIndex, children: screens),
            // Mobile Bottom Navigation Bar (Hidden on Desktop)
            bottomNavigationBar: isDesktop
                ? null
                : Container(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
                    ),
                    child: NavigationBar(
                      selectedIndex: _currentIndex,
                      backgroundColor: AppTheme.bgSecondary,
                      onDestinationSelected: _navigateToTab,
                      destinations: [
                        const NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: 'Home',
                          tooltip: 'Storefront Homepage',
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.category_outlined),
                          selectedIcon: Icon(Icons.category),
                          label: 'Categories',
                          tooltip: 'Product Categories',
                        ),
                        NavigationDestination(
                          icon: Badge(
                            isLabelVisible: cart.itemCount > 0,
                            backgroundColor: AppTheme.accent,
                            textColor: AppTheme.bgPrimary,
                            label: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                            child: const Icon(Icons.shopping_cart_outlined),
                          ),
                          selectedIcon: Badge(
                            isLabelVisible: cart.itemCount > 0,
                            backgroundColor: AppTheme.accent,
                            textColor: AppTheme.bgPrimary,
                            label: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                            child: const Icon(Icons.shopping_cart),
                          ),
                          label: 'Cart',
                          tooltip: 'Shopping Cart',
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.receipt_long_outlined),
                          selectedIcon: Icon(Icons.receipt_long),
                          label: 'Orders',
                          tooltip: 'My Purchases & Tracking',
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person),
                          label: 'Profile',
                          tooltip: 'Customer Profile',
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildDesktopAppBar(
    BuildContext context,
    CartProvider cart,
    dynamic user,
    AuthService auth,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(68),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgPrimary,
          border: Border(bottom: BorderSide(color: AppTheme.borderSubtle, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: SafeArea(
          child: Row(
            children: [
              // Clickable Brand Logo linking to Home (Tab 0)
              Semantics(
                label: 'ShopEase Home Logo',
                button: true,
                child: InkWell(
                  onTap: () => _navigateToTab(0),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
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
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ShopEase',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                letterSpacing: -0.5,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'BANGLADESH',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AppTheme.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 32),

              // Desktop Navigation Items
              _DesktopNavItem(
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                isSelected: _currentIndex == 0,
                onTap: () => _navigateToTab(0),
              ),
              const SizedBox(width: 8),
              _DesktopNavItem(
                label: 'Categories',
                icon: Icons.category_outlined,
                activeIcon: Icons.category,
                isSelected: _currentIndex == 1,
                onTap: () => _navigateToTab(1),
              ),
              const SizedBox(width: 8),
              _DesktopNavItem(
                label: 'Orders',
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                isSelected: _currentIndex == 3,
                onTap: () => _navigateToTab(3),
              ),
              const SizedBox(width: 8),
              _DesktopNavItem(
                label: 'Profile',
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                isSelected: _currentIndex == 4,
                onTap: () => _navigateToTab(4),
              ),

              const Spacer(),

              // Desktop Cart Action
              Semantics(
                label: 'Shopping Cart, ${cart.itemCount} items',
                button: true,
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToTab(2),
                  icon: Badge(
                    isLabelVisible: cart.itemCount > 0,
                    backgroundColor: AppTheme.accent,
                    textColor: AppTheme.bgPrimary,
                    label: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                    child: Icon(
                      _currentIndex == 2 ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                      size: 20,
                      color: _currentIndex == 2 ? AppTheme.accent : AppTheme.textPrimary,
                    ),
                  ),
                  label: Text(
                    'Cart (${cart.itemCount})',
                    style: TextStyle(
                      color: _currentIndex == 2 ? AppTheme.accent : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _currentIndex == 2 ? AppTheme.accent : AppTheme.borderSubtle,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessibleDrawer(
    BuildContext context,
    CartProvider cart,
    dynamic user,
    AuthService auth,
  ) {
    return Drawer(
      backgroundColor: AppTheme.bgPrimary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header with Clickable Logo
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderSubtle, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToTab(0);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.4,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                    tooltip: 'Close Menu',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Navigation List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'NAVIGATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  _DrawerNavItem(
                    icon: Icons.home_outlined,
                    label: 'Home Storefront',
                    isSelected: _currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToTab(0);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.category_outlined,
                    label: 'Browse Categories',
                    isSelected: _currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToTab(1);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Shopping Cart',
                    badgeCount: cart.itemCount,
                    isSelected: _currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToTab(2);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'My Orders',
                    isSelected: _currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToTab(3);
                    },
                  ),
                  _DrawerNavItem(
                    icon: Icons.person_outline,
                    label: 'Customer Profile',
                    isSelected: _currentIndex == 4,
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToTab(4);
                    },
                  ),
                ],
              ),
            ),

            // Drawer Footer: User & Sign Out
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (user?.email != null) ...[
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Signed in customer',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      auth.signOut();
                    },
                    icon: const Icon(Icons.logout, size: 16, color: AppTheme.statusError),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 13, color: AppTheme.statusError, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.statusError.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

class _DesktopNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DesktopNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentSubtle : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 18,
                color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      label: label,
      button: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: isSelected ? AppTheme.accentSubtle : Colors.transparent,
          leading: Icon(
            icon,
            size: 20,
            color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
            ),
          ),
          trailing: badgeCount != null && badgeCount! > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: AppTheme.bgPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}

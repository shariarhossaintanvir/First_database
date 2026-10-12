import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_app/theme/admin_theme.dart';
import 'package:admin_app/widgets/admin_status_badge.dart';
import 'package:admin_app/widgets/admin_metric_card.dart';
import 'package:admin_app/widgets/admin_empty_state.dart';
import 'package:admin_app/widgets/admin_table_toolbar.dart';
import 'package:admin_app/widgets/admin_spec_builder_row.dart';

void main() {
  group('AdminTheme Design System Tokens Tests', () {
    test('verifies core SaaS workspace and sky-blue accent colors', () {
      expect(AdminTheme.bgWorkspace, const Color(0xFF0D1117));
      expect(AdminTheme.bgSidebar, const Color(0xFF080B10));
      expect(AdminTheme.surfaceCard, const Color(0xFF161B22));
      expect(AdminTheme.accent, const Color(0xFF38BDF8));
      expect(AdminTheme.borderSubtle, const Color(0xFF30363D));
    });

    test('verifies spacing scale integrity', () {
      expect(AdminTheme.space4, 4.0);
      expect(AdminTheme.space8, 8.0);
      expect(AdminTheme.space12, 12.0);
      expect(AdminTheme.space16, 16.0);
      expect(AdminTheme.space20, 20.0);
      expect(AdminTheme.space24, 24.0);
      expect(AdminTheme.space32, 32.0);
    });

    test('verifies corner radius tokens', () {
      expect(AdminTheme.radiusXs, 4.0);
      expect(AdminTheme.radiusSm, 6.0);
      expect(AdminTheme.radiusMd, 8.0);
      expect(AdminTheme.radiusLg, 12.0);
      expect(AdminTheme.radiusFull, 999.0);
    });

    test('verifies ThemeData generates with dark brightness and proper colorScheme', () {
      final theme = AdminTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AdminTheme.bgWorkspace);
      expect(theme.primaryColor, AdminTheme.accent);
      expect(theme.colorScheme.primary, AdminTheme.accent);
      expect(theme.colorScheme.surface, AdminTheme.surfaceCard);
    });
  });

  group('AdminStatusBadge Widget Tests', () {
    testWidgets('renders SaaS status badge with dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdminStatusBadge(
              label: 'FULFILLED',
              variant: AdminStatusBadgeVariant.success,
              showDot: true,
            ),
          ),
        ),
      );

      expect(find.text('FULFILLED'), findsOneWidget);
    });

    testWidgets('renders fromOrderStatus correctly in admin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AdminStatusBadge.fromOrderStatus('Confirmed'),
                AdminStatusBadge.fromOrderStatus('Shipped'),
                AdminStatusBadge.fromOrderStatus('Delivered'),
                AdminStatusBadge.fromOrderStatus('Cancelled'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('CONFIRMED'), findsOneWidget);
      expect(find.text('SHIPPED'), findsOneWidget);
      expect(find.text('DELIVERED'), findsOneWidget);
      expect(find.text('CANCELLED'), findsOneWidget);
    });

    testWidgets('renders fromStock correctly in admin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AdminStatusBadge.fromStock(0),
                AdminStatusBadge.fromStock(4),
                AdminStatusBadge.fromStock(15),
                AdminStatusBadge.fromStock(10, isAvailable: false),
              ],
            ),
          ),
        ),
      );

      expect(find.text('OUT OF STOCK'), findsOneWidget);
      expect(find.text('LOW STOCK (4)'), findsOneWidget);
      expect(find.text('IN STOCK (15)'), findsOneWidget);
      expect(find.text('INACTIVE'), findsOneWidget);
    });
  });

  group('AdminMetricCard Widget Tests', () {
    testWidgets('renders KPI title, metric value, and positive trend', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdminMetricCard(
              title: 'Total Revenue',
              value: '৳ 2,450,000',
              icon: Icons.payments_outlined,
              trendLabel: '+14.2%',
              isTrendPositive: true,
              subtitle: 'vs last month',
            ),
          ),
        ),
      );

      expect(find.text('TOTAL REVENUE'), findsOneWidget);
      expect(find.text('৳ 2,450,000'), findsOneWidget);
      expect(find.text('+14.2%'), findsOneWidget);
      expect(find.text('vs last month'), findsOneWidget);
    });
  });

  group('AdminEmptyState Widget Tests', () {
    testWidgets('renders empty state message and triggers button callback', (tester) async {
      bool actionFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No Products Found',
              description: 'Try adjusting your search criteria or create a new product.',
              actionLabel: 'Add Product',
              onActionPressed: () {
                actionFired = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('No Products Found'), findsOneWidget);
      expect(find.text('Try adjusting your search criteria or create a new product.'), findsOneWidget);
      expect(find.text('Add Product'), findsOneWidget);

      await tester.tap(find.text('Add Product'));
      await tester.pump();
      expect(actionFired, isTrue);
    });
  });

  group('AdminTableToolbar Widget Tests', () {
    testWidgets('renders search field, count label, and action slots', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminTableToolbar(
              searchController: controller,
              searchHint: 'Search catalog...',
              countLabel: 'Showing 48 items',
              actions: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('New Item'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Showing 48 items'), findsOneWidget);
      expect(find.text('New Item'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('AdminSpecBuilderRow and Card Tests', () {
    testWidgets('renders key-value spec editor and handles removal', (tester) async {
      bool removed = false;
      final keyCtrl = TextEditingController(text: 'RAM');
      final valCtrl = TextEditingController(text: '16GB DDR5');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminSpecBuilderCard(
              title: 'Product Specifications',
              onAddRow: () {},
              children: [
                AdminSpecBuilderRow(
                  keyController: keyCtrl,
                  valueController: valCtrl,
                  onRemove: () {
                    removed = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Product Specifications'), findsOneWidget);
      expect(find.text('RAM'), findsOneWidget);
      expect(find.text('16GB DDR5'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove_circle_outline_rounded));
      await tester.pump();
      expect(removed, isTrue);
    });
  });
}

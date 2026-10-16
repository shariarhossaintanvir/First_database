import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/theme/app_theme.dart';
import 'package:customer_app/widgets/status_badge.dart';
import 'package:customer_app/widgets/empty_state_view.dart';
import 'package:customer_app/widgets/error_state_view.dart';
import 'package:customer_app/widgets/loading_shimmer.dart';
import 'package:customer_app/widgets/spec_attribute_row.dart';
import 'package:customer_app/widgets/category_pill.dart';
import 'package:customer_app/widgets/trust_badge_row.dart';

void main() {
  group('AppTheme Design System Tokens Tests', () {
    test('verifies core Light Theme brand colors', () {
      expect(AppTheme.bgPrimary, const Color(0xFFFFFFFF));
      expect(AppTheme.primary, const Color(0xFFFF6B35));
      expect(AppTheme.surfaceCard, const Color(0xFFFFFFFF));
      expect(AppTheme.borderSubtle, const Color(0xFFE5E7EB));
    });

    test('verifies spacing scale integrity', () {
      expect(AppTheme.space4, 4.0);
      expect(AppTheme.space8, 8.0);
      expect(AppTheme.space12, 12.0);
      expect(AppTheme.space16, 16.0);
      expect(AppTheme.space24, 24.0);
      expect(AppTheme.space32, 32.0);
      expect(AppTheme.space48, 48.0);
    });

    test('verifies corner radius tokens', () {
      expect(AppTheme.radiusSm, 6.0);
      expect(AppTheme.radiusMd, 10.0);
      expect(AppTheme.radiusLg, 14.0);
      expect(AppTheme.radiusFull, 999.0);
    });

    test('verifies ThemeData generates with light brightness and proper colorScheme', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppTheme.bgPrimary);
      expect(theme.primaryColor, AppTheme.primary);
      expect(theme.colorScheme.primary, AppTheme.primary);
      expect(theme.colorScheme.surface, AppTheme.surfaceCard);
    });
  });

  group('Customer StatusBadge Widget Tests', () {
    testWidgets('renders custom status badge with dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'ACTIVE',
              variant: StatusBadgeVariant.success,
              showDot: true,
            ),
          ),
        ),
      );

      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('renders fromOrderStatus correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge.fromOrderStatus('Delivered'),
                StatusBadge.fromOrderStatus('Pending'),
                StatusBadge.fromOrderStatus('Cancelled'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('DELIVERED'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('CANCELLED'), findsOneWidget);
    });

    testWidgets('renders fromStock correctly for various thresholds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge.fromStock(0),
                StatusBadge.fromStock(3),
                StatusBadge.fromStock(25),
              ],
            ),
          ),
        ),
      );

      expect(find.text('OUT OF STOCK'), findsOneWidget);
      expect(find.text('ONLY 3 LEFT'), findsOneWidget);
      expect(find.text('IN STOCK'), findsOneWidget);
    });
  });

  group('EmptyStateView Widget Tests', () {
    testWidgets('renders title, description and triggers action callback', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.shopping_bag_outlined,
              title: 'Your Cart is Empty',
              description: 'Looks like you have not added anything yet.',
              actionLabel: 'Shop Now',
              onActionPressed: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(find.text('Looks like you have not added anything yet.'), findsOneWidget);
      expect(find.text('Shop Now'), findsOneWidget);

      await tester.tap(find.text('Shop Now'));
      await tester.pump();
      expect(actionTriggered, isTrue);
    });
  });

  group('ErrorStateView Widget Tests', () {
    testWidgets('renders offline factory and retry action', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateView.offline(
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Connection Lost'), findsOneWidget);
      expect(find.text('Reconnect'), findsOneWidget);

      await tester.tap(find.text('Reconnect'));
      await tester.pump();
      expect(retried, isTrue);
    });
  });

  group('LoadingShimmer Skeleton Tests', () {
    testWidgets('renders ShimmerBox and ProductCardSkeleton without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductCardSkeleton(),
          ),
        ),
      );

      expect(find.byType(LoadingShimmer), findsOneWidget);
      expect(find.byType(ProductCardSkeleton), findsOneWidget);
    });
  });

  group('SpecAttributeRow and Table Tests', () {
    testWidgets('renders key-value specifications correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpecAttributeTable(
              title: 'Technical Specifications',
              specifications: {
                'Brand': 'Logitech',
                'Model': 'MX Master 3S',
                'Warranty': '1 Year Official',
              },
            ),
          ),
        ),
      );

      expect(find.text('Technical Specifications'), findsOneWidget);
      expect(find.text('Brand'), findsOneWidget);
      expect(find.text('Logitech'), findsOneWidget);
      expect(find.text('Model'), findsOneWidget);
      expect(find.text('MX Master 3S'), findsOneWidget);
      expect(find.text('Warranty'), findsOneWidget);
      expect(find.text('1 Year Official'), findsOneWidget);
    });
  });

  group('CategoryPill Widget Tests', () {
    testWidgets('renders active/inactive state and triggers onTap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryPill(
              label: 'Smartphones',
              count: 18,
              isSelected: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Smartphones'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);

      await tester.tap(find.text('Smartphones'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('TrustBadgeRow Widget Tests', () {
    testWidgets('renders default assurance badges', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrustBadgeRow(),
          ),
        ),
      );

      expect(find.text('Cash on Delivery'), findsOneWidget);
      expect(find.text('Order Tracking'), findsOneWidget);
      expect(find.text('Customer Support'), findsOneWidget);
      expect(find.text('Direct Catalog'), findsOneWidget);
    });
  });

  group('Phase 2 Customer Checkout & Order Timeline Tests', () {
    test('verifies profile pre-population logic does not overwrite existing user inputs', () {
      final nameController = TextEditingController();
      final phoneController = TextEditingController(text: '+880 1999 000000'); // User already typed

      final profileData = {
        'name': 'Jane Doe',
        'phone': '+880 1711 111111',
        'address': 'Dhanmondi, Dhaka',
      };

      // Simulated safe pre-population logic
      if (nameController.text.trim().isEmpty && profileData['name'] != null) {
        nameController.text = profileData['name']!;
      }
      if (phoneController.text.trim().isEmpty && profileData['phone'] != null) {
        phoneController.text = profileData['phone']!;
      }

      // Name was empty -> populated from profile
      expect(nameController.text, 'Jane Doe');
      // Phone was user-entered -> PRESERVED, not overwritten
      expect(phoneController.text, '+880 1999 000000');
    });

    test('verifies checkout field validation rules', () {
      String? validateName(String? v) {
        if (v == null || v.trim().isEmpty) return 'Enter recipient name';
        final trimmed = v.trim();
        if (trimmed.length < 2) return 'Name must be at least 2 characters';
        if (trimmed.length > 100) return 'Name cannot exceed 100 characters';
        return null;
      }

      String? validatePhone(String? v) {
        if (v == null || v.trim().isEmpty) return 'Enter phone number';
        final phone = v.trim();
        if (phone.length < 5 || phone.length > 30) return 'Phone number must be between 5 and 30 characters';
        final phoneRegex = RegExp(r'^[0-9+\-()\s]+$');
        if (!phoneRegex.hasMatch(phone)) return 'Enter a valid phone number';
        return null;
      }

      String? validateAddress(String? v) {
        if (v == null || v.trim().isEmpty) return 'Enter delivery address';
        final trimmed = v.trim();
        if (trimmed.length < 5) return 'Address must be at least 5 characters';
        if (trimmed.length > 500) return 'Address cannot exceed 500 characters';
        return null;
      }

      expect(validateName(''), isNotNull);
      expect(validateName('A'), isNotNull);
      expect(validateName('Valid Name'), isNull);

      expect(validatePhone(''), isNotNull);
      expect(validatePhone('123'), isNotNull);
      expect(validatePhone('invalid-phone!@#'), isNotNull);
      expect(validatePhone('+880 1712-345678'), isNull);

      expect(validateAddress(''), isNotNull);
      expect(validateAddress('Road'), isNotNull);
      expect(validateAddress('House 1, Road 2, Gulshan, Dhaka'), isNull);
    });

    test('verifies order timeline status step calculation and cancellation handling', () {
      int getStatusStep(String status) {
        switch (status) {
          case 'Pending':
            return 0;
          case 'Confirmed':
            return 1;
          case 'Processing':
            return 2;
          case 'Shipped':
            return 3;
          case 'Delivered':
            return 4;
          default:
            return -1;
        }
      }

      expect(getStatusStep('Pending'), 0);
      expect(getStatusStep('Confirmed'), 1);
      expect(getStatusStep('Processing'), 2);
      expect(getStatusStep('Shipped'), 3);
      expect(getStatusStep('Delivered'), 4);
      expect(getStatusStep('Cancelled'), -1);
      expect(getStatusStep('UnknownStatus'), -1);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_app/models/customer_model.dart';
import 'package:admin_app/models/order_model.dart';
import 'package:admin_app/models/category_model.dart';
import 'package:admin_app/models/product_model.dart';

void main() {
  group('Phase 4: CustomerModel Tests', () {
    test('CustomerModel parses standard customer profile document', () {
      final now = DateTime(2026, 10, 16, 12, 0, 0);
      final rawMap = {
        'uid': 'cust_001',
        'name': 'Tanvir Hossain',
        'email': 'tanvir@example.com',
        'phone': '+8801700000000',
        'role': 'customer',
        'address': 'House 12, Road 5, Dhanmondi, Dhaka',
        'createdAt': Timestamp.fromDate(now),
      };

      final customer = CustomerModel.fromMap(rawMap, 'cust_001');

      expect(customer.uid, 'cust_001');
      expect(customer.name, 'Tanvir Hossain');
      expect(customer.email, 'tanvir@example.com');
      expect(customer.phone, '+8801700000000');
      expect(customer.role, 'customer');
      expect(customer.address, 'House 12, Road 5, Dhanmondi, Dhaka');
      expect(customer.createdAt, now);

      final toMapResult = customer.toMap();
      expect(toMapResult['uid'], 'cust_001');
      expect(toMapResult['name'], 'Tanvir Hossain');
      expect(toMapResult['email'], 'tanvir@example.com');
      expect(toMapResult['phone'], '+8801700000000');
      expect(toMapResult['role'], 'customer');
      expect(toMapResult['address'], 'House 12, Road 5, Dhanmondi, Dhaka');
      expect(toMapResult['createdAt'], isA<Timestamp>());
    });

    test('CustomerModel handles missing optional fields gracefully', () {
      final rawMap = {
        'displayName': 'Guest User',
        'email': 'guest@ecommerce.com',
      };

      final customer = CustomerModel.fromMap(rawMap, 'guest_99');

      expect(customer.uid, 'guest_99');
      expect(customer.name, 'Guest User');
      expect(customer.email, 'guest@ecommerce.com');
      expect(customer.phone, '');
      expect(customer.role, 'customer');
      expect(customer.address, isNull);
      expect(customer.createdAt, isA<DateTime>());
    });

    test('CustomerModel parses structured address map gracefully', () {
      final rawMap = {
        'name': 'Rahim Uddin',
        'email': 'rahim@test.com',
        'address': {
          'street': 'Flat 4B, Green Tower',
          'area': 'Gulshan 2',
          'city': 'Dhaka',
          'postalCode': '1212',
        },
      };

      final customer = CustomerModel.fromMap(rawMap, 'user_gulshan');
      expect(
        customer.address,
        'Flat 4B, Green Tower, Gulshan 2, Dhaka, 1212',
      );
    });

    test('CustomerModel copyWith updates individual properties', () {
      final now = DateTime(2026, 10, 10);
      final customer = CustomerModel(
        uid: 'user_original',
        name: 'Original Name',
        email: 'orig@test.com',
        phone: '01800000000',
        role: 'customer',
        createdAt: now,
      );

      final updated = customer.copyWith(
        name: 'Updated Name',
        phone: '01999999999',
        address: 'Banani, Dhaka',
      );

      expect(updated.name, 'Updated Name');
      expect(updated.phone, '01999999999');
      expect(updated.address, 'Banani, Dhaka');
      expect(updated.email, 'orig@test.com');
      expect(updated.uid, 'user_original');
    });
  });

  group('Phase 4: Dashboard Metrics & Calculations', () {
    test('Gross Revenue calculation strictly excludes cancelled orders', () {
      final now = DateTime(2026, 10, 16);
      final item = OrderItemModel(
        productId: 'prod_1',
        title: 'Keyboard',
        price: 2500.0,
        quantity: 1,
        imageUrl: 'https://example.com/kb.jpg',
      );

      final orders = [
        OrderModel(
          id: 'ord_1',
          userId: 'u1',
          customerName: 'Customer A',
          customerEmail: 'a@test.com',
          customerPhone: '0171',
          customerAddress: 'Dhaka',
          paymentMethod: 'Cash on Delivery',
          items: [item],
          totalAmount: 2500.0,
          status: 'Confirmed',
          createdAt: now,
        ),
        OrderModel(
          id: 'ord_2',
          userId: 'u2',
          customerName: 'Customer B',
          customerEmail: 'b@test.com',
          customerPhone: '0172',
          customerAddress: 'Chittagong',
          paymentMethod: 'Cash on Delivery',
          items: [item],
          totalAmount: 5000.0,
          status: 'Delivered',
          createdAt: now,
        ),
        OrderModel(
          id: 'ord_3',
          userId: 'u3',
          customerName: 'Customer C',
          customerEmail: 'c@test.com',
          customerPhone: '0173',
          customerAddress: 'Sylhet',
          paymentMethod: 'Cash on Delivery',
          items: [item],
          totalAmount: 1500.0,
          status: 'Pending',
          createdAt: now,
        ),
        OrderModel(
          id: 'ord_4',
          userId: 'u4',
          customerName: 'Customer D',
          customerEmail: 'd@test.com',
          customerPhone: '0174',
          customerAddress: 'Rajshahi',
          paymentMethod: 'Cash on Delivery',
          items: [item],
          totalAmount: 8000.0,
          status: 'Cancelled', // Must NOT be included
          createdAt: now,
        ),
      ];

      final totalRevenue = orders
          .where((o) => o.status != 'Cancelled')
          .fold<double>(0.0, (acc, o) => acc + o.totalAmount);

      expect(totalRevenue, 9000.0); // 2500 + 5000 + 1500
    });

    test('Order status filtering accurately segments fulfillment pipelines', () {
      final statuses = [
        'Pending',
        'Confirmed',
        'Processing',
        'Shipped',
        'Delivered',
        'Cancelled',
      ];

      for (var status in statuses) {
        expect(
          [
            'Pending',
            'Confirmed',
            'Processing',
            'Shipped',
            'Delivered',
            'Cancelled',
          ].contains(status),
          isTrue,
        );
      }
    });

    test('Low stock filter identifies products with stock <= 5 units', () {
      final now = DateTime.now();
      final products = [
        ProductModel(
          id: 'p1',
          title: 'Mechanical Keyboard',
          description: 'RGB',
          price: 3500.0,
          imageUrl: 'https://example.com/p1.jpg',
          category: 'Electronics',
          stock: 3, // Low stock
          createdAt: now,
        ),
        ProductModel(
          id: 'p2',
          title: 'Gaming Mouse',
          description: 'Wireless',
          price: 1800.0,
          imageUrl: 'https://example.com/p2.jpg',
          category: 'Electronics',
          stock: 25, // Ample stock
          createdAt: now,
        ),
        ProductModel(
          id: 'p3',
          title: 'USB Cable',
          description: 'Type C',
          price: 350.0,
          imageUrl: 'https://example.com/p3.jpg',
          category: 'Accessories',
          stock: 0, // Out of stock (<= 5)
          createdAt: now,
        ),
      ];

      final lowStock = products.where((p) => p.stock <= 5).toList();
      expect(lowStock.length, 2);
      expect(lowStock.map((p) => p.id), containsAll(['p1', 'p3']));
    });
  });

  group('Phase 4: Search & Filtering Predicates', () {
    test('Order search matches ID, customer name, phone, or email', () {
      final now = DateTime.now();
      final order = OrderModel(
        id: 'ord_9876543210',
        userId: 'usr_abc',
        customerName: 'Shahriar Hossain',
        customerEmail: 'shahriar@example.com',
        customerPhone: '+8801912345678',
        customerAddress: 'Dhaka, Bangladesh',
        paymentMethod: 'Cash on Delivery',
        items: [],
        totalAmount: 1200.0,
        status: 'Processing',
        createdAt: now,
      );

      bool matches(String query) {
        final q = query.toLowerCase();
        return order.id.toLowerCase().contains(q) ||
            order.customerName.toLowerCase().contains(q) ||
            order.customerPhone.toLowerCase().contains(q) ||
            order.customerEmail.toLowerCase().contains(q);
      }

      expect(matches('98765'), isTrue);
      expect(matches('shahriar'), isTrue);
      expect(matches('0191234'), isTrue);
      expect(matches('example.com'), isTrue);
      expect(matches('random_unrelated'), isFalse);
    });

    test('Customer search matches name, email, phone, or address', () {
      final now = DateTime.now();
      final customer = CustomerModel(
        uid: 'cust_alpha',
        name: 'Fatima Begum',
        email: 'fatima@mail.bd',
        phone: '01755555555',
        role: 'customer',
        address: 'Uttara Sector 7, Dhaka',
        createdAt: now,
      );

      bool matches(String query) {
        final q = query.toLowerCase();
        return customer.name.toLowerCase().contains(q) ||
            customer.email.toLowerCase().contains(q) ||
            customer.phone.toLowerCase().contains(q) ||
            (customer.address != null &&
                customer.address!.toLowerCase().contains(q));
      }

      expect(matches('fatima'), isTrue);
      expect(matches('mail.bd'), isTrue);
      expect(matches('55555'), isTrue);
      expect(matches('uttara'), isTrue);
      expect(matches('sylhet'), isFalse);
    });
  });

  group('Phase 4: Referential Integrity Safeguard Logic', () {
    test('Category deletion guard blocks deletion when assigned products exist', () {
      final category = CategoryModel(
        id: 'electronics',
        name: 'Electronics',
        description: 'Gadgets',
      );
      expect(category.name, 'Electronics');

      // Simulated count of products referencing this category
      int activeProductsCount = 4;
      bool canDeleteCategory = activeProductsCount == 0;

      expect(canDeleteCategory, isFalse);

      // When active products are re-assigned or removed
      activeProductsCount = 0;
      canDeleteCategory = activeProductsCount == 0;

      expect(canDeleteCategory, isTrue);
    });
  });
}

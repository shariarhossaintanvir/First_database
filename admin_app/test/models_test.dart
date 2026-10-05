import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_app/models/product_model.dart';
import 'package:admin_app/models/order_model.dart';
import 'package:admin_app/models/category_model.dart';

void main() {
  group('Admin ProductModel Tests', () {
    test('ProductModel parses and outputs availability and compatibility fields', () {
      final now = DateTime(2026, 10, 4, 10, 0, 0);
      final product = ProductModel(
        id: 'prod_admin_1',
        title: 'Smart Watch',
        description: 'Fitness tracker and smartwatch',
        price: 199.99,
        imageUrl: 'https://storage.googleapis.com/watch.jpg',
        category: 'Wearables',
        stock: 45,
        isAvailable: true,
        createdAt: now,
      );

      expect(product.id, 'prod_admin_1');
      expect(product.title, 'Smart Watch');
      expect(product.name, 'Smart Watch');
      expect(product.category, 'Wearables');
      expect(product.categoryId, 'Wearables');
      expect(product.price, 199.99);
      expect(product.stock, 45);
      expect(product.isAvailable, isTrue);

      final map = product.toMap();
      expect(map['title'], 'Smart Watch');
      expect(map['name'], 'Smart Watch');
      expect(map['category'], 'Wearables');
      expect(map['categoryId'], 'Wearables');
      expect(map['isAvailable'], isTrue);
      expect(map['stock'], 45);
    });

    test('ProductModel handles copyWith with isAvailable toggle', () {
      final now = DateTime.now();
      final p1 = ProductModel(
        id: 'p1',
        title: 'Laptop Stand',
        description: 'Aluminum stand',
        price: 29.99,
        imageUrl: 'https://example.com/stand.jpg',
        category: 'Accessories',
        stock: 10,
        isAvailable: true,
        createdAt: now,
      );

      final pDisabled = p1.copyWith(isAvailable: false);
      expect(pDisabled.isAvailable, isFalse);
      expect(pDisabled.stock, 10);
      expect(pDisabled.title, 'Laptop Stand');
    });
  });

  group('Admin OrderModel Tests', () {
    test('OrderModel parses Confirmed status and paymentMethod correctly', () {
      final now = DateTime(2026, 10, 4, 11, 0, 0);
      final item = OrderItemModel(
        productId: 'prod_admin_1',
        title: 'Smart Watch',
        price: 199.99,
        quantity: 1,
        imageUrl: 'https://storage.googleapis.com/watch.jpg',
      );

      final order = OrderModel(
        id: 'order_admin_55',
        userId: 'user_123',
        customerName: 'Carol Danvers',
        customerEmail: 'carol@marvel.com',
        customerPhone: '+1122334455',
        customerAddress: '500 Avengers Way',
        paymentMethod: 'Cash on Delivery',
        items: [item],
        totalAmount: 199.99,
        status: 'Confirmed',
        createdAt: now,
      );

      expect(order.id, 'order_admin_55');
      expect(order.status, 'Confirmed');
      expect(order.deliveryAddress, '500 Avengers Way');
      expect(order.paymentMethod, 'Cash on Delivery');

      final map = order.toMap();
      expect(map['status'], 'Confirmed');
      expect(map['deliveryAddress'], '500 Avengers Way');
      expect(map['customerAddress'], '500 Avengers Way');
      expect(map['paymentMethod'], 'Cash on Delivery');
    });

    test('OrderModel fromMap handles deliveryAddress fallback', () {
      final rawMap = {
        'userId': 'usr_9',
        'customerName': 'Diana Prince',
        'customerEmail': 'diana@example.com',
        'customerPhone': '+4455667788',
        'deliveryAddress': '10 Downing St, London',
        'items': [],
        'totalAmount': 0.0,
        'status': 'Processing',
        'createdAt': Timestamp.now(),
      };

      final order = OrderModel.fromMap(rawMap, 'ord_diana');
      expect(order.customerAddress, '10 Downing St, London');
      expect(order.deliveryAddress, '10 Downing St, London');
      expect(order.status, 'Processing');
    });
  });

  group('Admin CategoryModel Tests', () {
    test('CategoryModel handles serialization and deserialization', () {
      final category = CategoryModel(
        id: 'cat_appliances',
        name: 'Appliances',
        description: 'Home appliances',
        icon: 'kitchen',
      );

      final map = category.toMap();
      expect(map['name'], 'Appliances');

      final from = CategoryModel.fromMap(map, 'cat_appliances');
      expect(from.id, 'cat_appliances');
      expect(from.name, 'Appliances');
      expect(from.icon, 'kitchen');
    });
  });
}

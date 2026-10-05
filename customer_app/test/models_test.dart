import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/models/product_model.dart';
import 'package:customer_app/models/order_model.dart';
import 'package:customer_app/models/category_model.dart';

void main() {
  group('ProductModel Tests', () {
    test('ProductModel parses standard fields correctly', () {
      final now = DateTime(2026, 10, 4, 12, 0, 0);
      final product = ProductModel(
        id: 'prod_123',
        title: 'Wireless Headphones',
        description: 'Noise cancelling over-ear headphones',
        price: 99.99,
        imageUrl: 'https://storage.googleapis.com/test.jpg',
        category: 'Electronics',
        stock: 15,
        isAvailable: true,
        createdAt: now,
      );

      expect(product.id, 'prod_123');
      expect(product.title, 'Wireless Headphones');
      expect(product.name, 'Wireless Headphones');
      expect(product.category, 'Electronics');
      expect(product.categoryId, 'Electronics');
      expect(product.price, 99.99);
      expect(product.stock, 15);
      expect(product.isAvailable, isTrue);

      final map = product.toMap();
      expect(map['title'], 'Wireless Headphones');
      expect(map['name'], 'Wireless Headphones');
      expect(map['category'], 'Electronics');
      expect(map['categoryId'], 'Electronics');
      expect(map['price'], 99.99);
      expect(map['stock'], 15);
      expect(map['isAvailable'], isTrue);
    });

    test('ProductModel fromMap handles backwards compatibility (name / categoryId)', () {
      final rawMap = {
        'name': 'Ergonomic Chair',
        'description': 'Comfortable office chair',
        'price': 149,
        'imageUrl': 'https://example.com/chair.png',
        'categoryId': 'Furniture',
        'stock': 5,
        'isAvailable': false,
        'createdAt': Timestamp.fromDate(DateTime(2026, 10, 1)),
      };

      final product = ProductModel.fromMap(rawMap, 'prod_chair');
      expect(product.id, 'prod_chair');
      expect(product.title, 'Ergonomic Chair');
      expect(product.name, 'Ergonomic Chair');
      expect(product.category, 'Furniture');
      expect(product.categoryId, 'Furniture');
      expect(product.price, 149.0);
      expect(product.stock, 5);
      expect(product.isAvailable, isFalse);
    });

    test('ProductModel defaults isAvailable to true when missing', () {
      final rawMap = {
        'title': 'Keyboard',
        'description': 'Mechanical keyboard',
        'price': 49.50,
        'imageUrl': 'https://example.com/kb.png',
        'category': 'Electronics',
        'stock': 20,
      };

      final product = ProductModel.fromMap(rawMap, 'prod_kb');
      expect(product.isAvailable, isTrue);
    });
  });

  group('OrderModel Tests', () {
    test('OrderModel parses fields, confirmed status, and payment method correctly', () {
      final now = DateTime(2026, 10, 4, 14, 30);
      final item = OrderItemModel(
        productId: 'prod_123',
        title: 'Wireless Headphones',
        price: 99.99,
        quantity: 2,
        imageUrl: 'https://storage.googleapis.com/test.jpg',
      );

      final order = OrderModel(
        id: 'ord_999',
        userId: 'usr_abc',
        customerName: 'Alice Johnson',
        customerEmail: 'alice@example.com',
        customerPhone: '+1234567890',
        customerAddress: '123 Main St, Springfield',
        paymentMethod: 'Cash on Delivery',
        items: [item],
        totalAmount: 199.98,
        status: 'Confirmed',
        createdAt: now,
      );

      expect(order.id, 'ord_999');
      expect(order.status, 'Confirmed');
      expect(order.paymentMethod, 'Cash on Delivery');
      expect(order.deliveryAddress, '123 Main St, Springfield');
      expect(order.items.length, 1);
      expect(order.totalAmount, 199.98);

      final map = order.toMap();
      expect(map['status'], 'Confirmed');
      expect(map['paymentMethod'], 'Cash on Delivery');
      expect(map['deliveryAddress'], '123 Main St, Springfield');
      expect(map['items'], isA<List>());
    });

    test('OrderModel fromMap handles deliveryAddress and customerAddress alias', () {
      final rawMap = {
        'userId': 'usr_xyz',
        'customerName': 'Bob Smith',
        'customerEmail': 'bob@example.com',
        'customerPhone': '+9876543210',
        'deliveryAddress': '456 Oak Avenue, Metropolis',
        'paymentMethod': 'Credit Card',
        'items': [
          {
            'productId': 'p1',
            'title': 'Book',
            'price': 15.0,
            'quantity': 1,
            'imageUrl': 'https://example.com/b.jpg',
          }
        ],
        'totalAmount': 15.0,
        'status': 'Processing',
        'createdAt': Timestamp.fromDate(DateTime(2026, 10, 2)),
      };

      final order = OrderModel.fromMap(rawMap, 'ord_888');
      expect(order.customerAddress, '456 Oak Avenue, Metropolis');
      expect(order.deliveryAddress, '456 Oak Avenue, Metropolis');
      expect(order.paymentMethod, 'Credit Card');
      expect(order.status, 'Processing');
    });
  });

  group('CategoryModel Tests', () {
    test('CategoryModel serialization and deserialization', () {
      final cat = CategoryModel(
        id: 'cat_electronics',
        name: 'Electronics',
        description: 'Gadgets and tech',
        icon: 'phone_android',
      );

      expect(cat.id, 'cat_electronics');
      expect(cat.name, 'Electronics');

      final map = cat.toMap();
      expect(map['name'], 'Electronics');

      final deserialized = CategoryModel.fromMap(map, 'cat_electronics');
      expect(deserialized.name, 'Electronics');
    });
  });
}

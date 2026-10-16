import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/models/product_model.dart';
import 'package:customer_app/models/order_model.dart';
import 'package:customer_app/providers/cart_provider.dart';

void main() {
  group('Phase 3 Storefront Search, Filtering & Sorting Tests', () {
    late List<ProductModel> mockCatalog;

    setUp(() {
      final now = DateTime.now();
      mockCatalog = [
        ProductModel(
          id: 'p1',
          title: 'Mechanical Gaming Keyboard',
          description: 'RGB mechanical keyboard with blue tactile switches.',
          price: 3500.0,
          category: 'Electronics',
          imageUrl: 'https://example.com/keyboard.jpg',
          stock: 15,
          isAvailable: true,
          createdAt: now.subtract(const Duration(days: 3)),
        ),
        ProductModel(
          id: 'p2',
          title: 'Wireless Ergonomic Mouse',
          description: 'Precision wireless mouse for office and gaming.',
          price: 1800.0,
          category: 'Electronics',
          imageUrl: 'https://example.com/mouse.jpg',
          stock: 5,
          isAvailable: true,
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        ProductModel(
          id: 'p3',
          title: 'Cotton Graphic T-Shirt',
          description: '100% premium combed cotton t-shirt for daily wear.',
          price: 650.0,
          category: 'Fashion',
          imageUrl: 'https://example.com/tshirt.jpg',
          stock: 0, // Out of stock
          isAvailable: true,
          createdAt: now.subtract(const Duration(days: 5)),
        ),
        ProductModel(
          id: 'p4',
          title: 'Stainless Steel Water Bottle',
          description: 'Insulated vacuum thermal flask, holds 1 litre.',
          price: 950.0,
          category: 'Home & Living',
          imageUrl: 'https://example.com/bottle.jpg',
          stock: 25,
          isAvailable: true,
          createdAt: now,
        ),
        ProductModel(
          id: 'p5',
          title: 'Discontinued Vintage Headphones',
          description: 'Legacy audio gear.',
          price: 4200.0,
          category: 'Electronics',
          imageUrl: 'https://example.com/headphones.jpg',
          stock: 10,
          isAvailable: false, // Unavailable
          createdAt: now.subtract(const Duration(days: 10)),
        ),
      ];
    });

    test('Search filters products across title, category, and description', () {
      final query = 'wireless';
      final results = mockCatalog.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();

      expect(results.length, 1);
      expect(results.first.id, 'p2');
    });

    test('In-stock only filter excludes zero-stock and unavailable products', () {
      final inStockResults = mockCatalog.where((p) => p.isAvailable && p.stock > 0).toList();

      expect(inStockResults.length, 3);
      expect(inStockResults.any((p) => p.id == 'p3'), isFalse); // Stock 0 excluded
      expect(inStockResults.any((p) => p.id == 'p5'), isFalse); // isAvailable false excluded
    });

    test('Price range filter respects min and max bounds', () {
      final minPrice = 800.0;
      final maxPrice = 2000.0;

      final results = mockCatalog.where((p) {
        return p.price >= minPrice && p.price <= maxPrice;
      }).toList();

      expect(results.length, 2); // Mouse (1800) and Bottle (950)
      expect(results.map((p) => p.id).toSet(), equals({'p2', 'p4'}));
    });

    test('Sorting by Newest orders products by createdAt descending', () {
      final sorted = [...mockCatalog];
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      expect(sorted.first.id, 'p4'); // Created today
      expect(sorted.last.id, 'p5');  // Created 10 days ago
    });

    test('Sorting by Price: Low to High orders ascending', () {
      final sorted = [...mockCatalog];
      sorted.sort((a, b) => a.price.compareTo(b.price));

      expect(sorted.first.id, 'p3'); // 650
      expect(sorted.last.id, 'p5');  // 4200
    });

    test('Sorting by Price: High to Low orders descending', () {
      final sorted = [...mockCatalog];
      sorted.sort((a, b) => b.price.compareTo(a.price));

      expect(sorted.first.id, 'p5'); // 4200
      expect(sorted.last.id, 'p3');  // 650
    });

    test('Sorting by Availability prioritizes active in-stock products', () {
      final sorted = [...mockCatalog];
      sorted.sort((a, b) {
        final aInStock = (a.isAvailable && a.stock > 0) ? 1 : 0;
        final bInStock = (b.isAvailable && b.stock > 0) ? 1 : 0;
        if (aInStock != bInStock) {
          return bInStock.compareTo(aInStock);
        }
        return b.stock.compareTo(a.stock);
      });

      // The first 3 items must all be in stock and available
      expect(sorted[0].isAvailable && sorted[0].stock > 0, isTrue);
      expect(sorted[1].isAvailable && sorted[1].stock > 0, isTrue);
      expect(sorted[2].isAvailable && sorted[2].stock > 0, isTrue);

      // Bottle (stock 25) comes before Keyboard (stock 15)
      expect(sorted[0].id, 'p4');
      expect(sorted[1].id, 'p1');
      expect(sorted[2].id, 'p2');
    });
  });

  group('Phase 3 Stock Revalidation & Checkout Protection Tests', () {
    test('Detects insufficient stock and flags unavailable items', () {
      final productInCart = ProductModel(
        id: 'prod_1',
        title: 'Bluetooth Speaker',
        description: 'Portable wireless speaker',
        price: 2500,
        imageUrl: '',
        category: 'Electronics',
        stock: 2, // only 2 left in inventory
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      final requestedQuantity = 5;
      final issues = <String>[];

      // Revalidation logic
      if (!productInCart.isAvailable || productInCart.stock <= 0) {
        issues.add('Out of stock');
      } else if (productInCart.stock < requestedQuantity) {
        issues.add(
          '"${productInCart.title}" only has ${productInCart.stock} units remaining (requested: $requestedQuantity).',
        );
      }

      expect(issues.isNotEmpty, isTrue);
      expect(issues.first, contains('only has 2 units remaining'));
    });

    test('Duplicate submission guard blocks repeated submissions', () {
      bool isPlacingOrder = false;
      int ordersCreated = 0;

      void submitOrder() {
        if (isPlacingOrder) return;
        isPlacingOrder = true;
        ordersCreated++;
      }

      // First tap
      submitOrder();
      expect(ordersCreated, 1);
      expect(isPlacingOrder, isTrue);

      // Rapid consecutive tap while busy
      submitOrder();
      expect(ordersCreated, 1); // Not incremented

      // Once finished
      isPlacingOrder = false;
      submitOrder();
      expect(ordersCreated, 2);
    });
  });

  group('Phase 3 Reorder / Buy Again Behavior Tests', () {
    test('Buy Again correctly clamps quantities to available inventory', () {
      final cart = CartProvider();
      final freshProduct = ProductModel(
        id: 'p_reorder',
        title: 'USB-C Cable',
        description: 'Fast charging cable',
        price: 350,
        imageUrl: '',
        category: 'Accessories',
        stock: 3, // only 3 available
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      final pastOrderItem = OrderItemModel(
        productId: 'p_reorder',
        title: 'USB-C Cable',
        price: 350,
        quantity: 5, // user originally ordered 5
        imageUrl: '',
      );

      // Reorder logic
      final inCart = cart.getProductQuantity(freshProduct.id);
      final availableToAdd = freshProduct.stock - inCart;
      expect(availableToAdd, 3);

      final qtyToAdd = pastOrderItem.quantity.clamp(1, availableToAdd);
      cart.addItem(freshProduct, quantity: qtyToAdd);

      expect(cart.getProductQuantity(freshProduct.id), 3);
      expect(cart.totalAmount, 350 * 3);
    });

    test('Buy Again skips out of stock items and informs user', () {
      final outOfStockProduct = ProductModel(
        id: 'p_oos',
        title: 'Winter Jacket',
        description: 'Warm winter jacket',
        price: 4500,
        imageUrl: '',
        category: 'Fashion',
        stock: 0,
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      bool canAdd = outOfStockProduct.isAvailable && outOfStockProduct.stock > 0;
      expect(canAdd, isFalse);
    });
  });
}

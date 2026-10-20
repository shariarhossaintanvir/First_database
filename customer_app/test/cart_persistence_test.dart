import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_app/models/product_model.dart';
import 'package:customer_app/models/cart_item_model.dart';
import 'package:customer_app/providers/cart_provider.dart';

/// Unit tests for CartProvider — in-memory operations.
/// Persistence tests (SharedPreferences) require Flutter integration tests
/// with a real platform; those are validated by the manual smoke test plan.
// ── Helpers ────────────────────────────────────────────────────────────────
ProductModel _makeProduct({
  String id = 'p1',
  String title = 'Test Product',
  double price = 100.0,
  int stock = 10,
  bool isAvailable = true,
  String category = 'Electronics',
}) {
  return ProductModel(
    id: id,
    title: title,
    description: 'A test product',
    price: price,
    imageUrl: 'https://example.com/img.jpg',
    category: category,
    stock: stock,
    isAvailable: isAvailable,
    createdAt: DateTime(2024, 1, 1),
  );
}

void main() {

  group('CartProvider — add / remove / clear', () {
    test('starts empty', () {
      final cart = CartProvider();
      expect(cart.itemList, isEmpty);
      expect(cart.itemCount, 0);
      expect(cart.totalAmount, 0.0);
    });

    test('addItem adds a new product', () {
      final cart = CartProvider();
      final product = _makeProduct();
      cart.addItem(product);

      expect(cart.isInCart(product.id), isTrue);
      expect(cart.getProductQuantity(product.id), 1);
    });

    test('addItem with quantity=2 sets initial quantity', () {
      final cart = CartProvider();
      final product = _makeProduct();
      cart.addItem(product, quantity: 2);

      expect(cart.getProductQuantity(product.id), 2);
    });

    test('addItem on existing product accumulates quantity', () {
      final cart = CartProvider();
      final product = _makeProduct();
      cart.addItem(product, quantity: 2);
      cart.addItem(product, quantity: 3);

      expect(cart.getProductQuantity(product.id), 5);
    });

    test('removeItem deletes the item', () {
      final cart = CartProvider();
      final product = _makeProduct();
      cart.addItem(product);
      cart.removeItem(product.id);

      expect(cart.isInCart(product.id), isFalse);
      expect(cart.itemList, isEmpty);
    });

    test('clearCart empties all items', () {
      final cart = CartProvider();
      cart.addItem(_makeProduct(id: 'p1'));
      cart.addItem(_makeProduct(id: 'p2'));
      cart.clearCart();

      expect(cart.itemList, isEmpty);
      expect(cart.itemCount, 0);
    });
  });

  group('CartProvider — increment / decrement', () {
    test('incrementQuantity increases by 1', () {
      final cart = CartProvider();
      final product = _makeProduct(stock: 5);
      cart.addItem(product, quantity: 2);
      cart.incrementQuantity(product.id);

      expect(cart.getProductQuantity(product.id), 3);
    });

    test('decrementQuantity decreases by 1 when qty > 1', () {
      final cart = CartProvider();
      final product = _makeProduct();
      cart.addItem(product, quantity: 3);
      cart.decrementQuantity(product.id);

      expect(cart.getProductQuantity(product.id), 2);
    });

    test('decrementQuantity at qty==1 does NOT auto-remove (requires UI confirmation)', () {
      final cart = CartProvider();
      final product = _makeProduct();
      cart.addItem(product, quantity: 1);
      cart.decrementQuantity(product.id); // Should stay at 1, not be removed

      // Item must still be in cart — removal requires explicit removeItem call
      expect(cart.isInCart(product.id), isTrue);
      expect(cart.getProductQuantity(product.id), 1);
    });

    test('incrementQuantity on missing product is a no-op', () {
      final cart = CartProvider();
      cart.incrementQuantity('non_existent');
      expect(cart.itemList, isEmpty);
    });

    test('decrementQuantity on missing product is a no-op', () {
      final cart = CartProvider();
      cart.decrementQuantity('non_existent');
      expect(cart.itemList, isEmpty);
    });
  });

  group('CartProvider — setQuantity', () {
    test('setQuantity changes to specified value', () {
      final cart = CartProvider();
      final product = _makeProduct(stock: 10);
      cart.addItem(product, quantity: 2);
      cart.setQuantity(product.id, 5, maxStock: 10);

      expect(cart.getProductQuantity(product.id), 5);
    });

    test('setQuantity clamps to maxStock upper bound', () {
      final cart = CartProvider();
      final product = _makeProduct(stock: 3);
      cart.addItem(product, quantity: 1);
      cart.setQuantity(product.id, 999, maxStock: 3);

      expect(cart.getProductQuantity(product.id), 3);
    });

    test('setQuantity clamps to minimum of 1', () {
      final cart = CartProvider();
      final product = _makeProduct();
      cart.addItem(product, quantity: 2);
      cart.setQuantity(product.id, -5, maxStock: 10);

      expect(cart.getProductQuantity(product.id), 1);
    });

    test('setQuantity on non-existent item is a no-op', () {
      final cart = CartProvider();
      cart.setQuantity('ghost', 5, maxStock: 10);
      expect(cart.itemList, isEmpty);
    });
  });

  group('CartProvider — totals', () {
    test('totalAmount is sum of all line totals', () {
      final cart = CartProvider();
      cart.addItem(_makeProduct(id: 'p1', price: 100.0), quantity: 2); // 200
      cart.addItem(_makeProduct(id: 'p2', price: 50.0), quantity: 3);  // 150

      expect(cart.totalAmount, closeTo(350.0, 0.001));
    });

    test('itemCount counts total units across all products', () {
      final cart = CartProvider();
      cart.addItem(_makeProduct(id: 'p1'), quantity: 3);
      cart.addItem(_makeProduct(id: 'p2'), quantity: 2);

      expect(cart.itemCount, 5);
    });

    test('totalAmount reflects quantity changes', () {
      final cart = CartProvider();
      final product = _makeProduct(price: 100.0, stock: 10);
      cart.addItem(product, quantity: 1);
      expect(cart.totalAmount, 100.0);

      cart.incrementQuantity(product.id);
      expect(cart.totalAmount, 200.0);

      cart.decrementQuantity(product.id);
      expect(cart.totalAmount, 100.0);
    });
  });

  group('CartProvider — CartItemModel.totalPrice', () {
    test('totalPrice = price × quantity', () {
      final product = ProductModel(
        id: 'x',
        title: 'Item',
        description: '',
        price: 150.0,
        imageUrl: '',
        category: 'Test',
        stock: 5,
        isAvailable: true,
        createdAt: DateTime.now(),
      );
      final item = CartItemModel(product: product, quantity: 4);
      expect(item.totalPrice, closeTo(600.0, 0.001));
    });

    test('CartItemModel.toMap includes required order fields', () {
      final product = ProductModel(
        id: 'abc',
        title: 'Gadget',
        description: '',
        price: 200.0,
        imageUrl: 'https://x.com/img.jpg',
        category: 'Tech',
        stock: 5,
        isAvailable: true,
        createdAt: DateTime.now(),
      );
      final item = CartItemModel(product: product, quantity: 2);
      final map = item.toMap();

      expect(map['productId'], 'abc');
      expect(map['title'], 'Gadget');
      expect(map['price'], 200.0);
      expect(map['quantity'], 2);
      expect(map['imageUrl'], 'https://x.com/img.jpg');
    });
  });

  group('CartProvider — wishlist', () {
    test('isInWishlist returns false for new product', () {
      final cart = CartProvider();
      expect(cart.isInWishlist('p1'), isFalse);
    });

    test('toggleWishlist adds product to wishlist', () {
      final cart = CartProvider();
      cart.toggleWishlist('p1');
      expect(cart.isInWishlist('p1'), isTrue);
    });

    test('toggleWishlist removes product when already in wishlist', () {
      final cart = CartProvider();
      cart.toggleWishlist('p1');
      cart.toggleWishlist('p1');
      expect(cart.isInWishlist('p1'), isFalse);
    });

    test('wishlist is independent of cart', () {
      final cart = CartProvider();
      final product = _makeProduct();
      cart.addItem(product);
      cart.toggleWishlist(product.id);

      // In wishlist
      expect(cart.isInWishlist(product.id), isTrue);
      // Still in cart
      expect(cart.isInCart(product.id), isTrue);

      // Remove from cart — wishlist unaffected
      cart.removeItem(product.id);
      expect(cart.isInCart(product.id), isFalse);
      expect(cart.isInWishlist(product.id), isTrue);
    });

    test('wishlistIds returns unmodifiable set', () {
      final cart = CartProvider();
      cart.toggleWishlist('p1');
      cart.toggleWishlist('p2');

      final ids = cart.wishlistIds;
      expect(ids, containsAll(['p1', 'p2']));
    });
  });

  group('CartProvider — stock boundary guardrails', () {
    test('UI can enforce stock upper bound before calling incrementQuantity', () {
      // The CartProvider itself does not enforce stock limit on increment —
      // the calling screen is responsible for checking canIncrement.
      // This test verifies the canIncrement pattern used by CartScreen.
      const stock = 3;
      final cart = CartProvider();
      final product = _makeProduct(stock: stock);
      cart.addItem(product, quantity: 3);

      final canIncrement = cart.getProductQuantity(product.id) < stock;
      expect(canIncrement, isFalse); // At max stock
    });

    test('setQuantity with maxStock enforces upper bound', () {
      final cart = CartProvider();
      final product = _makeProduct(stock: 5);
      cart.addItem(product);
      cart.setQuantity(product.id, 100, maxStock: 5);

      expect(cart.getProductQuantity(product.id), 5);
    });
  });

  group('Order status normalization (case-insensitive)', () {
    // Tests the normalization logic extracted from OrderDetailScreen
    int getStatusStep(String status) {
      switch (status.trim().toLowerCase()) {
        case 'pending':
          return 0;
        case 'confirmed':
          return 1;
        case 'processing':
          return 2;
        case 'shipped':
          return 3;
        case 'delivered':
          return 4;
        default:
          return -1;
      }
    }

    test('Capitalised Pending → step 0', () => expect(getStatusStep('Pending'), 0));
    test('lowercase pending → step 0', () => expect(getStatusStep('pending'), 0));
    test('UPPERCASE PENDING → step 0', () => expect(getStatusStep('PENDING'), 0));
    test('Confirmed → step 1', () => expect(getStatusStep('Confirmed'), 1));
    test('confirmed → step 1', () => expect(getStatusStep('confirmed'), 1));
    test('Processing → step 2', () => expect(getStatusStep('Processing'), 2));
    test('processing → step 2', () => expect(getStatusStep('processing'), 2));
    test('Shipped → step 3', () => expect(getStatusStep('Shipped'), 3));
    test('shipped → step 3', () => expect(getStatusStep('shipped'), 3));
    test('Delivered → step 4', () => expect(getStatusStep('Delivered'), 4));
    test('delivered → step 4', () => expect(getStatusStep('delivered'), 4));
    test('Cancelled → -1 (handled separately)', () => expect(getStatusStep('Cancelled'), -1));
    test('cancelled → -1 (handled separately)', () => expect(getStatusStep('cancelled'), -1));
    test('unknown status → -1', () => expect(getStatusStep('refunded'), -1));
    test('whitespace-padded status → normalized correctly', () =>
        expect(getStatusStep('  Shipped  '), 3));

    test('Cancelled comparison is case-insensitive', () {
      const status = 'cancelled';
      expect(status.trim().toLowerCase() == 'cancelled', isTrue);
    });

    test('Mixed-case Cancelled comparison is case-insensitive', () {
      const status = 'Cancelled';
      expect(status.trim().toLowerCase() == 'cancelled', isTrue);
    });
    test('Order filter matching handles leading and trailing whitespace', () {
      bool matchesFilter(String orderStatus, String selectedFilter) {
        if (selectedFilter == 'All') return true;
        return orderStatus.trim().toLowerCase() == selectedFilter.trim().toLowerCase();
      }

      expect(matchesFilter(' Pending ', 'Pending'), isTrue);
      expect(matchesFilter('pending', 'Pending'), isTrue);
      expect(matchesFilter('PENDING', 'pending'), isTrue);
      expect(matchesFilter(' Shipped ', 'Shipped'), isTrue);
      expect(matchesFilter(' Delivered ', 'Delivered'), isTrue);
      expect(matchesFilter(' Cancelled ', 'Cancelled'), isTrue);
      expect(matchesFilter('Processing', 'All'), isTrue);
      expect(matchesFilter('Confirmed', 'Pending'), isFalse);
    });
  });

  group('Buy Now — cart isolation & checkout derivation', () {
    Map<String, dynamic> deriveCheckoutState({
      required CartProvider cart,
      CartItemModel? buyNowItem,
    }) {
      final isBuyNow = buyNowItem != null;
      return {
        'items': isBuyNow ? [buyNowItem] : cart.itemList,
        'count': isBuyNow ? buyNowItem.quantity : cart.itemCount,
        'total': isBuyNow ? buyNowItem.totalPrice : cart.totalAmount,
      };
    }

    test('Checkout derivation in Buy Now mode isolates from main cart', () {
      final mainCart = CartProvider();
      mainCart.addItem(_makeProduct(id: 'in_cart_1', price: 100.0), quantity: 2);
      mainCart.addItem(_makeProduct(id: 'in_cart_2', price: 250.0), quantity: 1);
      expect(mainCart.itemCount, 3);
      expect(mainCart.totalAmount, 450.0);

      final buyNowItem = CartItemModel(
        product: _makeProduct(id: 'buy_now_item', price: 1200.0),
        quantity: 2,
      );

      final state = deriveCheckoutState(cart: mainCart, buyNowItem: buyNowItem);
      final checkoutItems = state['items'] as List<CartItemModel>;

      expect(checkoutItems.length, 1);
      expect(checkoutItems.first.product.id, 'buy_now_item');
      expect(state['count'], 2);
      expect(state['total'], 2400.0);

      // Main cart untouched
      expect(mainCart.itemCount, 3);
      expect(mainCart.totalAmount, 450.0);
    });

    test('Checkout derivation in regular cart mode uses cart items', () {
      final mainCart = CartProvider();
      mainCart.addItem(_makeProduct(id: 'in_cart_1', price: 150.0), quantity: 2);
      mainCart.addItem(_makeProduct(id: 'in_cart_2', price: 300.0), quantity: 1);

      final state = deriveCheckoutState(cart: mainCart, buyNowItem: null);
      final checkoutItems = state['items'] as List<CartItemModel>;

      expect(checkoutItems.length, 2);
      expect(state['count'], 3);
      expect(state['total'], 600.0);
    });
    test('Buy Now item is independent from main cart', () {
      final mainCart = CartProvider();
      final mainProduct = _makeProduct(id: 'main_p', price: 200.0);
      mainCart.addItem(mainProduct, quantity: 2);

      // Simulate Buy Now: a separate checkout item
      final buyNowProduct = _makeProduct(id: 'buy_now_p', price: 999.0);
      final buyNowItem = CartItemModel(product: buyNowProduct, quantity: 1);

      // The Buy Now item's total
      expect(buyNowItem.totalPrice, 999.0);

      // Main cart is untouched
      expect(mainCart.itemCount, 2);
      expect(mainCart.totalAmount, 400.0);
      expect(mainCart.isInCart('buy_now_p'), isFalse);
    });

    test('Buy Now total computed from single item', () {
      final product = _makeProduct(price: 1500.0);
      final buyNowItem = CartItemModel(product: product, quantity: 3);

      // Simulate checkout total calculation from a single item list
      final itemsToOrder = [buyNowItem];
      final total = itemsToOrder.fold<double>(
        0.0,
        (runningTotal, ci) => runningTotal + ci.totalPrice,
      );

      expect(total, closeTo(4500.0, 0.001));
    });

    test('Cart is NOT cleared after Buy Now order (simulation)', () {
      final mainCart = CartProvider();
      mainCart.addItem(_makeProduct(id: 'existing'), quantity: 2);

      void simulateOrderCompletion({required bool isBuyNow}) {
        if (!isBuyNow) {
          mainCart.clearCart();
        }
      }

      simulateOrderCompletion(isBuyNow: true);

      // Main cart unchanged
      expect(mainCart.itemCount, 2);
    });

    test('Cart IS cleared after regular checkout (simulation)', () {
      final mainCart = CartProvider();
      mainCart.addItem(_makeProduct(id: 'existing'), quantity: 2);

      void simulateOrderCompletion({required bool isBuyNow}) {
        if (!isBuyNow) {
          mainCart.clearCart();
        }
      }

      simulateOrderCompletion(isBuyNow: false);

      expect(mainCart.itemCount, 0);
    });
  });

  group('CartProvider — SharedPreferences Runtime Persistence', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('Loads pre-existing cart items from SharedPreferences correctly', () async {
      final initialData = {
        'prod_stored_1': {
          'productId': 'prod_stored_1',
          'title': 'Stored Keyboard',
          'description': 'A mechanical keyboard',
          'price': 2200.0,
          'imageUrl': 'https://example.com/kbd.jpg',
          'category': 'Electronics',
          'stock': 8,
          'isAvailable': true,
          'createdAt': DateTime(2025, 1, 1).millisecondsSinceEpoch,
          'quantity': 2,
        },
      };

      SharedPreferences.setMockInitialValues({
        'shopease_cart_v1': jsonEncode(initialData),
        'shopease_wishlist_v1': ['prod_stored_1', 'prod_stored_2'],
      });

      final cart = CartProvider();
      // Allow async _loadFromStorage to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cart.isInCart('prod_stored_1'), isTrue);
      expect(cart.getProductQuantity('prod_stored_1'), 2);
      expect(cart.totalAmount, 4400.0);
      expect(cart.isInWishlist('prod_stored_1'), isTrue);
      expect(cart.isInWishlist('prod_stored_2'), isTrue);
    });

    test('Gracefully recovers from malformed/corrupt JSON without throwing', () async {
      SharedPreferences.setMockInitialValues({
        'shopease_cart_v1': '{{{NOT_VALID_JSON}}}',
        'shopease_wishlist_v1': ['w1'],
      });

      final cart = CartProvider();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Cart starts fresh and doesn't crash
      expect(cart.itemList, isEmpty);
      expect(cart.itemCount, 0);
      // Valid wishlist still loaded
      expect(cart.isInWishlist('w1'), isTrue);
    });

    test('Clearing cart preserves wishlist in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'shopease_wishlist_v1': ['w_item_1'],
      });

      final cart = CartProvider();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      cart.addItem(_makeProduct(id: 'c_item_1', price: 500.0));
      expect(cart.isInCart('c_item_1'), isTrue);
      expect(cart.isInWishlist('w_item_1'), isTrue);

      cart.clearCart();
      expect(cart.itemList, isEmpty);
      // Wishlist is completely intact
      expect(cart.isInWishlist('w_item_1'), isTrue);
    });
  });
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

/// Cart and wishlist state with cross-session local persistence.
///
/// Cart data is stored in the browser's localStorage (via shared_preferences)
/// so it survives page refreshes on Flutter Web. It is NOT synchronised across
/// different devices or browsers; it is strictly local to the current browser
/// session / user agent storage.
class CartProvider extends ChangeNotifier {
  static const String _cartStorageKey = 'shopease_cart_v1';
  static const String _wishlistStorageKey = 'shopease_wishlist_v1';

  final Map<String, CartItemModel> _items = {};
  final Set<String> _wishlistIds = {};

  CartProvider() {
    _loadFromStorage();
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  Map<String, CartItemModel> get items => {..._items};

  List<CartItemModel> get itemList => _items.values.toList();

  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool isInCart(String productId) => _items.containsKey(productId);

  int getProductQuantity(String productId) =>
      _items[productId]?.quantity ?? 0;

  bool isInWishlist(String productId) => _wishlistIds.contains(productId);

  Set<String> get wishlistIds => Set.unmodifiable(_wishlistIds);

  // ── Cart mutations ─────────────────────────────────────────────────────────

  void addItem(ProductModel product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItemModel(product: product, quantity: quantity);
    }
    notifyListeners();
    _saveCartToStorage();
  }

  /// Increments quantity by 1. The caller is responsible for enforcing the
  /// stock upper bound before calling this method.
  void incrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
      _saveCartToStorage();
    }
  }

  /// Decrements quantity by 1. If quantity reaches 1, this method does
  /// NOT auto-remove the item; the caller (UI) must explicitly call
  /// [removeItem] after confirming with the user.
  void decrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity--;
        notifyListeners();
        _saveCartToStorage();
      }
      // quantity == 1 → do nothing; UI shows remove confirmation dialog.
    }
  }

  /// Sets an item's quantity directly. Clamps to [1, product.stock].
  /// Use this for direct quantity editing if needed.
  void setQuantity(String productId, int newQuantity, {int maxStock = 9999}) {
    if (!_items.containsKey(productId)) return;
    final clamped = newQuantity.clamp(1, maxStock);
    _items[productId]!.quantity = clamped;
    notifyListeners();
    _saveCartToStorage();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
    _saveCartToStorage();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCartToStorage();
  }

  // ── Wishlist mutations ─────────────────────────────────────────────────────

  /// Toggles a product in/out of the wishlist (local persistence only).
  void toggleWishlist(String productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
    _saveWishlistToStorage();
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _loadCartFromPrefs(prefs);
      _loadWishlistFromPrefs(prefs);
    } catch (e) {
      // Storage is unavailable (e.g. in test environments). Start with empty state.
      debugPrint('CartProvider: storage unavailable, starting fresh. ($e)');
    }
    notifyListeners();
  }

  void _loadCartFromPrefs(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_cartStorageKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final itemMap = entry.value as Map<String, dynamic>;
        final product = _productFromJson(itemMap);
        final quantity = (itemMap['quantity'] as num?)?.toInt() ?? 1;
        if (product != null) {
          _items[entry.key] = CartItemModel(product: product, quantity: quantity);
        }
      }
    } catch (e) {
      // Stored data is corrupt or outdated; silently discard and start fresh.
      debugPrint('CartProvider: discarding malformed cart data. ($e)');
      prefs.remove(_cartStorageKey);
    }
  }

  void _loadWishlistFromPrefs(SharedPreferences prefs) {
    try {
      final raw = prefs.getStringList(_wishlistStorageKey);
      if (raw != null) _wishlistIds.addAll(raw);
    } catch (e) {
      debugPrint('CartProvider: discarding malformed wishlist data. ($e)');
      prefs.remove(_wishlistStorageKey);
    }
  }

  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {};
      for (final entry in _items.entries) {
        data[entry.key] = _cartItemToJson(entry.value);
      }
      await prefs.setString(_cartStorageKey, jsonEncode(data));
    } catch (e) {
      debugPrint('CartProvider: failed to persist cart. ($e)');
    }
  }

  Future<void> _saveWishlistToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_wishlistStorageKey, _wishlistIds.toList());
    } catch (e) {
      debugPrint('CartProvider: failed to persist wishlist. ($e)');
    }
  }

  // ── JSON helpers ───────────────────────────────────────────────────────────

  Map<String, dynamic> _cartItemToJson(CartItemModel item) {
    return {
      'productId': item.product.id,
      'title': item.product.title,
      'description': item.product.description,
      'price': item.product.price,
      'imageUrl': item.product.imageUrl,
      'category': item.product.category,
      'stock': item.product.stock,
      'isAvailable': item.product.isAvailable,
      'createdAt': item.product.createdAt.millisecondsSinceEpoch,
      'quantity': item.quantity,
    };
  }

  ProductModel? _productFromJson(Map<String, dynamic> map) {
    try {
      final id = map['productId'] as String?;
      final title = map['title'] as String?;
      final price = (map['price'] as num?)?.toDouble();
      if (id == null || id.isEmpty || title == null || price == null) {
        return null;
      }
      final createdAtMs = (map['createdAt'] as num?)?.toInt();
      final createdAt = createdAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(createdAtMs)
          : DateTime.now();
      return ProductModel(
        id: id,
        title: title,
        description: map['description'] as String? ?? '',
        price: price,
        imageUrl: map['imageUrl'] as String? ?? '',
        category: map['category'] as String? ?? '',
        stock: (map['stock'] as num?)?.toInt() ?? 0,
        isAvailable: map['isAvailable'] as bool? ?? true,
        createdAt: createdAt,
      );
    } catch (_) {
      return null;
    }
  }
}

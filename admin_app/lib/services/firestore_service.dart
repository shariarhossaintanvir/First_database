import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------- CATEGORIES ---------------- //

  CollectionReference get _categoriesCol => _firestore.collection('categories');

  /// Stream categories with query limit to prevent unconstrained reads
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _categoriesCol.limit(50).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoriesCol
        .doc(category.id.isEmpty ? null : category.id)
        .set(category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categoriesCol.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoriesCol.doc(categoryId).delete();
  }

  Future<void> seedDefaultCategoriesIfEmpty() async {
    final snapshot = await _categoriesCol.limit(1).get();
    if (snapshot.docs.isEmpty) {
      final defaultCategories = [
        CategoryModel(
          id: 'electronics',
          name: 'Electronics',
          description: 'Gadgets & devices',
          icon: 'devices',
        ),
        CategoryModel(
          id: 'fashion',
          name: 'Fashion & Apparel',
          description: 'Clothing & style',
          icon: 'checkroom',
        ),
        CategoryModel(
          id: 'home',
          name: 'Home & Living',
          description: 'Furniture & home decor',
          icon: 'chair',
        ),
        CategoryModel(
          id: 'beauty',
          name: 'Beauty & Health',
          description: 'Skincare & wellness',
          icon: 'spa',
        ),
        CategoryModel(
          id: 'sports',
          name: 'Sports & Outdoors',
          description: 'Fitness gear & equipment',
          icon: 'sports_basketball',
        ),
      ];

      for (var cat in defaultCategories) {
        await _categoriesCol.doc(cat.id).set(cat.toMap());
      }
    }
  }

  // ---------------- PRODUCTS ---------------- //

  CollectionReference get _productsCol => _firestore.collection('products');

  /// Stream products with descending ordering and query limit
  Stream<List<ProductModel>> getProductsStream() {
    return _productsCol
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ProductModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  Future<void> addProduct(ProductModel product) async {
    await _productsCol.add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _productsCol.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _productsCol.doc(productId).delete();
  }

  // ---------------- ORDERS ---------------- //

  CollectionReference get _ordersCol => _firestore.collection('orders');

  /// Stream orders with descending ordering and query limit
  Stream<List<OrderModel>> getOrdersStream() {
    return _ordersCol
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  /// Update order status with validation against allowed state values
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    const allowedStatuses = [
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled',
    ];
    if (!allowedStatuses.contains(newStatus)) {
      throw ArgumentError('Invalid order status: $newStatus');
    }
    await _ordersCol.doc(orderId).update({'status': newStatus});
  }
}

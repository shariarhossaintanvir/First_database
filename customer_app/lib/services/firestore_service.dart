import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------- CATEGORIES ---------------- //

  CollectionReference get _categoriesCol => _firestore.collection('categories');

  /// Stream categories with query limit to prevent unconstrained data download
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _categoriesCol.limit(50).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ---------------- PRODUCTS ---------------- //

  CollectionReference get _productsCol => _firestore.collection('products');

  /// Stream products with descending ordering and query limit
  Stream<List<ProductModel>> getProductsStream() {
    return _productsCol
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Stream products by category with query limit
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _productsCol
        .where('category', isEqualTo: category)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ---------------- ORDERS ---------------- //

  CollectionReference get _ordersCol => _firestore.collection('orders');

  /// Places a customer order in Firestore with initial 'Pending' status.
  /// Note: Inventory management/deduction is strictly handled by trusted server-side
  /// Cloud Functions to enforce least-privilege (customers cannot write to products).
  Future<String> placeOrder(OrderModel order) async {
    DocumentReference docRef = await _ordersCol.add(order.toMap());
    return docRef.id;
  }

  /// Stream current customer orders scoped strictly to the authenticated user ID with query limit
  Stream<List<OrderModel>> getCustomerOrdersStream(String userId) {
    return _ordersCol
        .where('userId', isEqualTo: userId)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      var orders = snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }
}

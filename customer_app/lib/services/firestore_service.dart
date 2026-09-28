import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------- CATEGORIES ---------------- //

  CollectionReference get _categoriesCol => _firestore.collection('categories');

  Stream<List<CategoryModel>> getCategoriesStream() {
    return _categoriesCol.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ---------------- PRODUCTS ---------------- //

  CollectionReference get _productsCol => _firestore.collection('products');

  Stream<List<ProductModel>> getProductsStream() {
    return _productsCol.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _productsCol
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ---------------- ORDERS ---------------- //

  CollectionReference get _ordersCol => _firestore.collection('orders');

  /// Places a customer order in Firestore
  Future<String> placeOrder(OrderModel order) async {
    // Add order to orders collection
    DocumentReference docRef = await _ordersCol.add(order.toMap());

    // Deduct stock for each item safely
    for (var item in order.items) {
      try {
        DocumentReference productRef = _productsCol.doc(item.productId);
        await _firestore.runTransaction((transaction) async {
          DocumentSnapshot snap = await transaction.get(productRef);
          if (snap.exists) {
            final currentStock = (snap.get('stock') as num?)?.toInt() ?? 0;
            final newStock = (currentStock - item.quantity).clamp(0, 999999);
            transaction.update(productRef, {'stock': newStock});
          }
        });
      } catch (e) {
        // Continue if stock update fails
      }
    }

    return docRef.id;
  }

  /// Stream current customer orders
  Stream<List<OrderModel>> getCustomerOrdersStream(String userId) {
    return _ordersCol
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      var orders = snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    await _ordersCol.doc(orderId).update({
      'status': 'Cancelled',
    });
  }
}

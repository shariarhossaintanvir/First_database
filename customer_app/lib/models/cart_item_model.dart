import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'title': product.title,
      'price': product.price,
      'quantity': quantity,
      'imageUrl': product.imageUrl,
    };
  }
}

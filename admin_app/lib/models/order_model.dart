import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] ?? '',
      title: map['title'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final String paymentMethod;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status; // 'Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled'
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    this.paymentMethod = 'Cash on Delivery',
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Alias for deliveryAddress
  String get deliveryAddress => customerAddress;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'deliveryAddress': customerAddress,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : Timestamp.fromDate(createdAt),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    DateTime? parsedUpdateDate;
    if (map['updatedAt'] is Timestamp) {
      parsedUpdateDate = (map['updatedAt'] as Timestamp).toDate();
    }

    var itemsRaw = map['items'] as List<dynamic>? ?? [];
    List<OrderItemModel> parsedItems = itemsRaw
        .map((e) => OrderItemModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return OrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      customerName: map['customerName'] ?? 'Customer',
      customerEmail: map['customerEmail'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAddress:
          map['customerAddress'] ?? map['deliveryAddress'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Cash on Delivery',
      items: parsedItems,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Pending',
      createdAt: parsedDate,
      updatedAt: parsedUpdateDate,
    );
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    String? paymentMethod,
    List<OrderItemModel>? items,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

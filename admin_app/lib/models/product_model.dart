import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    this.isAvailable = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Alias for compatibility
  String get name => title;
  String get categoryId => category;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'name': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'categoryId': category,
      'stock': stock,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : Timestamp.fromDate(createdAt),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
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

    return ProductModel(
      id: docId,
      title: map['title'] ?? map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? map['categoryId'] ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      isAvailable: map['isAvailable'] as bool? ?? true,
      createdAt: parsedDate,
      updatedAt: parsedUpdateDate,
    );
  }

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    int? stock,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

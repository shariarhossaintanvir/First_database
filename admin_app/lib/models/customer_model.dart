import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? address;
  final DateTime createdAt;

  CustomerModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'customer',
    this.address,
    required this.createdAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedCreatedAt = DateTime.now();
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
      }
    }

    String? parsedAddress;
    if (map['address'] != null) {
      if (map['address'] is String) {
        parsedAddress = map['address'] as String;
      } else if (map['address'] is Map) {
        // If stored as address map (street, city, etc.)
        final addrMap = map['address'] as Map;
        parsedAddress = [
          addrMap['street'],
          addrMap['area'],
          addrMap['city'],
          addrMap['postalCode'],
        ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');
      }
    }

    return CustomerModel(
      uid: id.isNotEmpty ? id : (map['uid'] ?? ''),
      name: map['name'] ?? map['displayName'] ?? 'Valued Customer',
      email: map['email'] ?? '',
      phone: map['phone'] ?? map['phoneNumber'] ?? '',
      role: map['role'] ?? 'customer',
      address: parsedAddress,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CustomerModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? address,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

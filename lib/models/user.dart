import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { customer, seller, admin }

class AddressModel {
  final String id;
  final String addressType; // Matches Node.js backend
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String country; // Matches Node.js backend
  final String zipCode;

  AddressModel({
    required this.id,
    required this.addressType,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.country,
    required this.zipCode,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'addressType': addressType,
      'address1': addressLine1, // Backend uses address1
      'address2': addressLine2, // Backend uses address2
      'city': city,
      'country': country,
      'zipCode': zipCode,
    };
    if (id.isNotEmpty) {
      map['_id'] = id;
    }
    return map;
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['_id'] ?? map['id'] ?? '',
      addressType: map['addressType'] ?? 'Default',
      addressLine1: map['address1'] ?? map['addressLine1'] ?? '',
      addressLine2: map['address2'] ?? map['addressLine2'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? map['state'] ?? '',
      zipCode: map['zipCode']?.toString() ?? '',
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final UserRole role;
  final List<AddressModel> addresses;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    this.role = UserRole.customer,
    this.addresses = const [],
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'addresses': addresses.map((a) => a.toMap()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return UserModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      role: UserRole.values.firstWhere((r) => r.name == map['role'], orElse: () => UserRole.customer),
      addresses: map['addresses'] != null
          ? (map['addresses'] as List).map((a) => AddressModel.fromMap(Map<String, dynamic>.from(a))).toList()
          : [],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, doc.id);
  }
}

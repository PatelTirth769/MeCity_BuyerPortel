import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String id;
  final String name;
  final String email;
  final String logo;
  final String banner;
  final String address;
  final String phoneNumber;
  final String description;
  final String category;
  final String ownerName;
  final String gstin;
  final String payoutUpi;
  final String operatingHours;
  final double rating;
  final int reviewsCount;
  final int totalProducts;
  final bool isVerified;
  final bool isOnline;
  final double deliveryRadiusKm;
  final DateTime joinedDate;

  // Additional fields for About Shop
  final String zipCode;
  final String city;
  final String state;
  final String shopFrontPhoto;
  final String ownerAtCounterPhoto;
  final List<dynamic> shopRatings;

  ShopModel({
    required this.id,
    required this.name,
    required this.email,
    required this.logo,
    required this.banner,
    required this.address,
    required this.phoneNumber,
    required this.description,
    this.category = 'General Marketplace',
    this.ownerName = 'Mecity Merchant',
    this.gstin = '',
    this.payoutUpi = '',
    this.operatingHours = '09:00 AM - 09:00 PM',
    required this.rating,
    required this.reviewsCount,
    required this.totalProducts,
    this.isVerified = true,
    this.isOnline = true,
    this.deliveryRadiusKm = 10.0,
    required this.joinedDate,
    this.zipCode = '',
    this.city = '',
    this.state = '',
    this.shopFrontPhoto = '',
    this.ownerAtCounterPhoto = '',
    this.shopRatings = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'logo': logo,
      'banner': banner,
      'address': address,
      'phoneNumber': phoneNumber,
      'description': description,
      'category': category,
      'ownerName': ownerName,
      'gstin': gstin,
      'payoutUpi': payoutUpi,
      'operatingHours': operatingHours,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'totalProducts': totalProducts,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'deliveryRadiusKm': deliveryRadiusKm,
      'joinedDate': joinedDate.toIso8601String(),
      'zipCode': zipCode,
      'city': city,
      'state': state,
      'shopFrontPhoto': shopFrontPhoto,
      'ownerAtCounterPhoto': ownerAtCounterPhoto,
      'shopRatings': shopRatings,
    };
  }

  factory ShopModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ShopModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      logo: map['logo'] ?? '',
      banner: map['banner'] ?? '',
      address: map['address'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General Marketplace',
      ownerName: map['ownerName'] ?? 'Mecity Merchant',
      gstin: map['gstin'] ?? '',
      payoutUpi: map['payoutUpi'] ?? '',
      operatingHours: map['operatingHours'] ?? '09:00 AM - 09:00 PM',
      rating: (map['rating'] ?? 5.0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      totalProducts: map['totalProducts'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      isOnline: map['isOnline'] ?? true,
      deliveryRadiusKm: (map['deliveryRadiusKm'] ?? 10.0).toDouble(),
      joinedDate: map['joinedDate'] != null ? DateTime.parse(map['joinedDate']) : DateTime.now(),
      zipCode: map['zipCode'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      shopFrontPhoto: map['shopFrontPhoto'] ?? '',
      ownerAtCounterPhoto: map['ownerAtCounterPhoto'] ?? '',
      shopRatings: map['shopRatings'] ?? [],
    );
  }

  factory ShopModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ShopModel.fromMap(data, doc.id);
  }

  factory ShopModel.fromApiJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'] ?? '';
    
    // Construct logo URL
    String logoUrl = (json['avatar'] ?? json['logo'] ?? '').toString();
    if (logoUrl.isNotEmpty && !logoUrl.startsWith('http')) {
      logoUrl = 'https://marketplace.mecity.in/$logoUrl';
    }

    String bannerUrl = (json['banner'] ?? '').toString();
    if (bannerUrl.isNotEmpty && !bannerUrl.startsWith('http')) {
      bannerUrl = 'https://marketplace.mecity.in/$bannerUrl';
    }
    
    String shopFrontUrl = (json['shopFrontPhoto'] ?? '').toString();
    if (shopFrontUrl.isNotEmpty && !shopFrontUrl.startsWith('http')) {
      shopFrontUrl = 'https://marketplace.mecity.in/$shopFrontUrl';
    }
    
    String ownerPhotoUrl = (json['ownerAtCounterPhoto'] ?? '').toString();
    if (ownerPhotoUrl.isNotEmpty && !ownerPhotoUrl.startsWith('http')) {
      ownerPhotoUrl = 'https://marketplace.mecity.in/$ownerPhotoUrl';
    }

    double ratingVal = 5.0;
    if (json['ratings'] != null && json['ratings'] != 'null') {
      ratingVal = (json['ratings'] is num)
          ? (json['ratings'] as num).toDouble()
          : (double.tryParse(json['ratings'].toString()) ?? 5.0);
    } else if (json['rating'] != null && json['rating'] != 'null') {
      ratingVal = (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : (double.tryParse(json['rating'].toString()) ?? 5.0);
    }

    DateTime parsedCreated = DateTime.now();
    if (json['createdAt'] != null) {
      final dt = DateTime.tryParse(json['createdAt'].toString());
      if (dt != null) parsedCreated = dt;
    }

    // Default or map properties
    return ShopModel(
      id: rawId.toString(),
      name: json['name'] ?? json['shopName'] ?? 'Unknown Shop',
      email: json['email'] ?? '',
      logo: logoUrl,
      banner: bannerUrl,
      address: json['address'] ?? '',
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      description: json['description'] ?? '',
      category: json['category'] ?? 'General Marketplace',
      ownerName: json['shopOwnerName'] ?? 'Mecity Merchant',
      rating: ratingVal,
      reviewsCount: (json['shopRatings'] is List) ? (json['shopRatings'] as List).length : 0,
      totalProducts: json['totalProducts'] is int ? json['totalProducts'] : (int.tryParse(json['totalProducts']?.toString() ?? '0') ?? 0),
      isVerified: json['status'] == 'Verified',
      isOnline: json['isActive'] ?? true,
      joinedDate: parsedCreated,
      zipCode: (json['zipCode'] ?? '').toString(),
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      shopFrontPhoto: shopFrontUrl,
      ownerAtCounterPhoto: ownerPhotoUrl,
      shopRatings: json['shopRatings'] is List ? json['shopRatings'] : [],
    );

  }
}

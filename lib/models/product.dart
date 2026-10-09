import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  factory Review.fromApiJson(Map<String, dynamic> json) {
    String uName = 'Verified Customer';
    String uAvatar = '';
    if (json['user'] is Map) {
      final uMap = json['user'] as Map;
      uName = (uMap['name'] ?? 'Verified Customer').toString();
      uAvatar = (uMap['avatar'] ?? '').toString();
    } else if (json['userName'] != null) {
      uName = json['userName'].toString();
    }
    if (uAvatar.isEmpty && json['userAvatar'] != null) {
      uAvatar = json['userAvatar'].toString();
    }

    double rVal = 5.0;
    if (json['rating'] != null) {
      rVal = (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : (double.tryParse(json['rating'].toString()) ?? 5.0);
    }

    DateTime createdDate = DateTime.now();
    if (json['createdAt'] != null) {
      final parsed = DateTime.tryParse(json['createdAt'].toString());
      if (parsed != null) createdDate = parsed;
    }

    return Review(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'rev_${DateTime.now().millisecondsSinceEpoch}',
      userName: uName,
      userAvatar: uAvatar,
      rating: rVal,
      comment: (json['comment'] ?? '').toString(),
      createdAt: createdDate,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final String subcategory;
  final double originalPrice;
  final double discountPrice;
  final int stock;
  final List<String> images;
  final String shopId;
  final String shopName;
  final String shopLogo;
  final double rating;
  final int reviewsCount;
  final List<Review> reviews;
  final List<String> tags;
  final bool isFeatured;
  final bool isBestSeller;
  final bool isEventProduct;
  final List<String> colors;
  final List<String> sizes;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.originalPrice,
    required this.discountPrice,
    required this.stock,
    required this.images,
    required this.shopId,
    required this.shopName,
    required this.shopLogo,
    required this.rating,
    required this.reviewsCount,
    this.reviews = const [],
    this.tags = const [],
    this.isFeatured = false,
    this.isBestSeller = false,
    this.isEventProduct = false,
    this.colors = const ['Black', 'White', 'Default'],
    this.sizes = const ['Standard', 'Pro', 'Ultra'],
  });

  double get discountPercent {
    if (originalPrice <= 0 || discountPrice >= originalPrice) return 0;
    return (((originalPrice - discountPrice) / originalPrice) * 100);
  }

  double get savings {
    return (originalPrice - discountPrice);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'originalPrice': originalPrice,
      'discountPrice': discountPrice,
      'stock': stock,
      'images': images,
      'shopId': shopId,
      'shopName': shopName,
      'shopLogo': shopLogo,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'reviews': reviews.map((r) => r.toMap()).toList(),
      'tags': tags,
      'isFeatured': isFeatured,
      'isBestSeller': isBestSeller,
      'isEventProduct': isEventProduct,
      'colors': colors,
      'sizes': sizes,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Product(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      originalPrice: (map['originalPrice'] ?? 0.0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0.0).toDouble(),
      stock: map['stock'] ?? 0,
      images: List<String>.from(map['images'] ?? []),
      shopId: map['shopId'] ?? '',
      shopName: map['shopName'] ?? '',
      shopLogo: map['shopLogo'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      reviews: map['reviews'] != null
          ? (map['reviews'] as List).map((r) => Review.fromMap(Map<String, dynamic>.from(r))).toList()
          : [],
      tags: List<String>.from(map['tags'] ?? []),
      isFeatured: map['isFeatured'] ?? false,
      isBestSeller: map['isBestSeller'] ?? false,
      isEventProduct: map['isEventProduct'] ?? false,
      colors: List<String>.from(map['colors'] ?? ['Default']),
      sizes: List<String>.from(map['sizes'] ?? ['Standard']),
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product.fromMap(data, doc.id);
  }

  static String _resolveCategoryName(String raw) {
    final trimmed = raw.trim();
    switch (trimmed) {
      case '6a4b85bee9ca0f13dc8218ff':
        return 'Food & Beverage';
      case '6a4dfbd5e9ca0f13dc823b4b':
        return 'Personal Care & Grooming';
      case '6a4dfca2e9ca0f13dc823b5c':
        return 'Food & Dining';
      case '6a4e1e97e9ca0f13dc823fe9':
        return 'Automobility';
      case '6a2a76354c34915295c748fd':
        return 'Accounting, Audit & Taxation';
      case '6a2a77a24c34915295c749f6':
        return 'Agriculture & Farming';
      case '6a2a78b84c34915295c74a0b':
        return 'Architect, Interior & Structural Design';
      case '6a2a811d4c34915295c74ab5':
        return 'Beauty & Salon';
      case '6a2a81704c34915295c74abb':
        return 'Building & Construction Material';
      case '6a2a9efc4c34915295c74c97':
        return 'Chartered Accountant';
      case '6a2aa00c4c34915295c74c9b':
        return 'Chemicals';
      case '6a2aa0694c34915295c74caa':
        return 'Construction Equipment & Machinery';
      case '6a2aa1094c34915295c74cb9':
        return 'Electronics';
      default:
        var cleaned = trimmed;
        if (cleaned.contains('\n')) {
          cleaned = cleaned.split('\n').first.trim();
        }
        if (RegExp(r'^\d+\.\s*').hasMatch(cleaned)) {
          cleaned = cleaned.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
        }
        if (cleaned.toLowerCase() == 'automobility') {
          return 'Automobility';
        }
        return cleaned.isNotEmpty ? cleaned : 'General';
    }
  }

  factory Product.fromApiJson(Map<String, dynamic> json) {
    // Parse prices safely
    double origPrice = 0.0;
    if (json['originalPrice'] != null) {
      origPrice = (json['originalPrice'] is num)
          ? (json['originalPrice'] as num).toDouble()
          : (double.tryParse(json['originalPrice'].toString()) ?? 0.0);
    } else if (json['price'] != null) {
      origPrice = (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : (double.tryParse(json['price'].toString()) ?? 0.0);
    }

    double discPrice = origPrice;
    if (json['discountPrice'] != null) {
      discPrice = (json['discountPrice'] is num)
          ? (json['discountPrice'] as num).toDouble()
          : (double.tryParse(json['discountPrice'].toString()) ?? origPrice);
    } else if (json['price'] != null) {
      discPrice = (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : (double.tryParse(json['price'].toString()) ?? origPrice);
    }

    if (origPrice <= 0 && discPrice > 0) origPrice = discPrice;
    if (discPrice <= 0 && origPrice > 0) discPrice = origPrice;
    if (origPrice < discPrice && origPrice > 0) {
      final temp = origPrice;
      origPrice = discPrice;
      discPrice = temp;
    }

    // Parse category, subcategory & embedded tags
    final rawCat = (json['category'] ?? 'General').toString();
    String extractedCat = rawCat;
    String extractedSubCat = '';
    List<String> extractedTags = [];

    if (rawCat.contains('\n')) {
      final lines = rawCat.split('\n');
      if (lines.isNotEmpty) {
        extractedCat = lines.first.trim();
      }
      for (final line in lines.skip(1)) {
        final lower = line.trim().toLowerCase();
        if (lower.startsWith('subcategory:')) {
          extractedSubCat = line.trim().substring('subcategory:'.length).trim();
        } else if (lower.startsWith('tags:')) {
          final tStr = line.trim().substring('tags:'.length).trim();
          for (final t in tStr.split(',')) {
            final tr = t.trim();
            if (tr.isNotEmpty && tr != 'null' && !extractedTags.contains(tr)) {
              extractedTags.add(tr);
            }
          }
        }
      }
    }

    final cat = _resolveCategoryName(extractedCat);

    String subCat = (json['subCategory'] ?? json['subcategory'] ?? '').toString().trim();
    if (subCat == 'null' || subCat.isEmpty) {
      subCat = extractedSubCat.isNotEmpty ? extractedSubCat : 'General';
    }

    // Parse images
    List<String> imageList = [];
    if (json['images'] is List) {
      for (var e in (json['images'] as List)) {
        if (e is Map && e['url'] != null) {
          final u = e['url'].toString();
          if (u.isNotEmpty && u != 'null') imageList.add(u);
        } else if (e is String && e.isNotEmpty && e != 'null') {
          imageList.add(e);
        }
      }
    } else if (json['images'] is String && (json['images'] as String).isNotEmpty && json['images'] != 'null') {
      imageList.add(json['images'].toString());
    }

    if (imageList.isEmpty && json['image'] != null && json['image'] != 'null') {
      imageList.add(json['image'].toString());
    }

    // Parse shop details
    String sId = '';
    String sName = 'Verified Seller';
    String sLogo = '';
    if (json['shop'] is Map) {
      final sMap = json['shop'] as Map;
      sId = sMap['_id']?.toString() ?? sMap['id']?.toString() ?? '';
      sName = sMap['name']?.toString().trim() ?? 'Verified Seller';
      sLogo = sMap['avatar']?.toString() ?? sMap['shopFrontPhoto']?.toString() ?? sMap['logo']?.toString() ?? '';
    } else {
      if (json['shopId'] != null) {
        if (json['shopId'] is String) {
          sId = json['shopId'];
        } else if (json['shopId'] is Map) {
          sId = json['shopId']['_id']?.toString() ?? json['shopId']['id']?.toString() ?? '';
        }
      }
      if (json['shopName'] != null) {
        sName = json['shopName'].toString().trim();
      }
      if (json['shopLogo'] != null) {
        sLogo = json['shopLogo'].toString();
      }
    }
    if (sName.isEmpty) sName = 'Verified Seller';

    // Parse reviews
    List<Review> reviewList = [];
    if (json['reviews'] is List) {
      reviewList = (json['reviews'] as List)
          .whereType<Map>()
          .map((r) => Review.fromApiJson(Map<String, dynamic>.from(r)))
          .toList();
    }

    // Parse rating
    double ratingVal = 0.0;
    if (json['ratings'] != null && json['ratings'] != 'null') {
      ratingVal = (json['ratings'] is num)
          ? (json['ratings'] as num).toDouble()
          : (double.tryParse(json['ratings'].toString()) ?? 0.0);
    } else if (json['rating'] != null && json['rating'] != 'null') {
      ratingVal = (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : (double.tryParse(json['rating'].toString()) ?? 0.0);
    } else if (reviewList.isNotEmpty) {
      final total = reviewList.fold<double>(0.0, (acc, r) => acc + r.rating);
      ratingVal = double.parse((total / reviewList.length).toStringAsFixed(1));
    }

    int revCount = reviewList.length;
    if (json['numOfReviews'] != null && json['numOfReviews'] != 'null') {
      revCount = (json['numOfReviews'] is int)
          ? json['numOfReviews'] as int
          : (int.tryParse(json['numOfReviews'].toString()) ?? revCount);
    } else if (json['reviewsCount'] != null && json['reviewsCount'] != 'null') {
      revCount = (json['reviewsCount'] is int)
          ? json['reviewsCount'] as int
          : (int.tryParse(json['reviewsCount'].toString()) ?? revCount);
    }

    // Parse tags
    List<String> parsedTags = List<String>.from(extractedTags);
    if (json['tags'] is List) {
      for (var e in (json['tags'] as List)) {
        final t = e.toString().trim();
        if (t.isNotEmpty && t != 'null' && !parsedTags.contains(t)) {
          parsedTags.add(t);
        }
      }
    } else if (json['tags'] is String) {
      final rawTagStr = json['tags'].toString().trim();
      if (rawTagStr.isNotEmpty && rawTagStr != 'null') {
        for (var t in rawTagStr.split(',')) {
          final trimmed = t.trim();
          if (trimmed.isNotEmpty && trimmed != 'null' && !parsedTags.contains(trimmed)) {
            parsedTags.add(trimmed);
          }
        }
      }
    }
    if (parsedTags.isEmpty) {
      if (cat != 'General') parsedTags.add(cat);
      if (subCat != 'General') parsedTags.add(subCat);
    }

    final int soldOutCount = (json['sold_out'] is num)
        ? (json['sold_out'] as num).toInt()
        : (int.tryParse(json['sold_out']?.toString() ?? '0') ?? 0);

    final bool isBest = json['isBestSelling'] == true ||
        json['isBestSeller'] == true ||
        soldOutCount > 0;

    final bool isFeat = json['isFeatured'] == true ||
        isBest ||
        (ratingVal >= 4.0 && reviewList.isNotEmpty);

    final int stockVal = (json['stock'] is num)
        ? (json['stock'] as num).toInt()
        : (int.tryParse(json['stock']?.toString() ?? '0') ?? 0);

    final String nameVal = (json['name'] ?? json['title'] ?? 'Product Item').toString().trim();
    final String descVal = (json['description'] ?? 'Quality product from Mecity Marketplace').toString().trim();

    return Product(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: nameVal.isNotEmpty ? nameVal : 'Product Item',
      description: descVal.isNotEmpty ? descVal : 'Quality product from Mecity Marketplace',
      category: cat.isNotEmpty ? cat : 'General',
      subcategory: subCat,
      originalPrice: origPrice,
      discountPrice: discPrice,
      stock: stockVal,
      images: imageList,
      shopId: sId,
      shopName: sName,
      shopLogo: sLogo,
      rating: ratingVal,
      reviewsCount: revCount,
      reviews: reviewList,
      tags: parsedTags,
      isFeatured: isFeat,
      isBestSeller: isBest,
      isEventProduct: json['isEventProduct'] == true,
      colors: json['colors'] is List && (json['colors'] as List).isNotEmpty
          ? List<String>.from((json['colors'] as List).map((c) => c.toString()))
          : ['Default'],
      sizes: json['sizes'] is List && (json['sizes'] as List).isNotEmpty
          ? List<String>.from((json['sizes'] as List).map((s) => s.toString()))
          : ['Standard'],
    );

  }
}

class GetAllProductsResponse {
  bool? success;
  List<Products>? products;

  GetAllProductsResponse({this.success, this.products});

  GetAllProductsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(Map<String, dynamic>.from(v)));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_all_products = GetAllProductsResponse;

class Products {
  String? sId;
  String? name;
  String? description;
  String? category;
  String? subCategory;
  String? tags;
  num? originalPrice;
  num? discountPrice;
  int? stock;
  List<String>? images;
  dynamic productId;
  String? shopId;
  Shop? shop;
  int? soldOut;
  bool? isFeatured;
  bool? isBestSelling;
  num? ratings;
  int? numOfReviews;
  String? createdAt;
  List<dynamic>? reviews;
  int? iV;

  Products({
    this.sId,
    this.name,
    this.description,
    this.category,
    this.subCategory,
    this.tags,
    this.originalPrice,
    this.discountPrice,
    this.stock,
    this.images,
    this.productId,
    this.shopId,
    this.shop,
    this.soldOut,
    this.isFeatured,
    this.isBestSelling,
    this.ratings,
    this.numOfReviews,
    this.createdAt,
    this.reviews,
    this.iV,
  });

  Products.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] as String?;
    name = json['name'] as String?;
    description = json['description'] as String?;
    category = json['category'] as String?;
    subCategory = json['subCategory'] as String?;
    tags = json['tags'] as String?;
    originalPrice = json['originalPrice'] is num ? json['originalPrice'] as num : (json['originalPrice'] != null ? num.tryParse(json['originalPrice'].toString()) : null);
    discountPrice = json['discountPrice'] is num ? json['discountPrice'] as num : (json['discountPrice'] != null ? num.tryParse(json['discountPrice'].toString()) : null);
    stock = json['stock'] is int ? json['stock'] as int : (json['stock'] != null ? int.tryParse(json['stock'].toString()) : null);
    if (json['images'] != null && json['images'] is List) {
      images = List<String>.from(json['images'].map((x) => x.toString()));
    }
    productId = json['productId'];
    shopId = json['shopId'] as String?;
    shop = json['shop'] != null && json['shop'] is Map<String, dynamic>
        ? Shop.fromJson(Map<String, dynamic>.from(json['shop']))
        : null;
    soldOut = json['sold_out'] is int ? json['sold_out'] as int : null;
    isFeatured = json['isFeatured'] as bool?;
    isBestSelling = json['isBestSelling'] as bool?;
    ratings = json['ratings'] is num ? json['ratings'] as num : (json['ratings'] != null ? num.tryParse(json['ratings'].toString()) : null);
    numOfReviews = json['numOfReviews'] is int ? json['numOfReviews'] as int : (json['numOfReviews'] != null ? int.tryParse(json['numOfReviews'].toString()) : null);
    createdAt = json['createdAt'] as String?;
    if (json['reviews'] != null && json['reviews'] is List) {
      reviews = List<dynamic>.from(json['reviews']);
    }
    iV = json['__v'] is int ? json['__v'] as int : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['category'] = category;
    data['subCategory'] = subCategory;
    data['tags'] = tags;
    data['originalPrice'] = originalPrice;
    data['discountPrice'] = discountPrice;
    data['stock'] = stock;
    data['images'] = images;
    data['productId'] = productId;
    data['shopId'] = shopId;
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    data['sold_out'] = soldOut;
    data['isFeatured'] = isFeatured;
    data['isBestSelling'] = isBestSelling;
    data['ratings'] = ratings;
    data['numOfReviews'] = numOfReviews;
    data['createdAt'] = createdAt;
    if (reviews != null) {
      data['reviews'] = reviews;
    }
    data['__v'] = iV;
    return data;
  }
}

class Shop {
  Document1? document1;
  Document1? document2;
  ShopLocation? location;
  String? sId;
  String? name;
  String? email;
  String? keyPoints;
  String? address;
  dynamic phoneNumber;
  String? role;
  String? avatar;
  dynamic zipCode;
  String? shopOwnerName;
  String? city;
  String? state;
  String? shopFrontPhoto;
  String? ownerAtCounterPhoto;
  String? docVerificationStatus;
  num? availableBalance;
  String? createdAt;
  String? status;
  String? rejectReason;
  bool? subscriptionPaid;
  String? subscriptionTransactionId;
  String? subscriptionPaidAt;
  bool? isActive;
  num? ratings;
  String? bankAccountNumber;
  String? bankIfscCode;
  String? bankAccountName;
  String? bankName;
  String? bankBranchName;
  String? employeeCode;
  String? registeredBy;
  bool? discountCouponApplied;
  String? discountCouponCode;
  List<dynamic>? transections;
  List<ShopRatings>? shopRatings;
  int? iV;
  String? description;
  String? resetPasswordTime;
  String? resetPasswordToken;

  Shop({
    this.document1,
    this.document2,
    this.location,
    this.sId,
    this.name,
    this.email,
    this.keyPoints,
    this.address,
    this.phoneNumber,
    this.role,
    this.avatar,
    this.zipCode,
    this.shopOwnerName,
    this.city,
    this.state,
    this.shopFrontPhoto,
    this.ownerAtCounterPhoto,
    this.docVerificationStatus,
    this.availableBalance,
    this.createdAt,
    this.status,
    this.rejectReason,
    this.subscriptionPaid,
    this.subscriptionTransactionId,
    this.subscriptionPaidAt,
    this.isActive,
    this.ratings,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankAccountName,
    this.bankName,
    this.bankBranchName,
    this.employeeCode,
    this.registeredBy,
    this.discountCouponApplied,
    this.discountCouponCode,
    this.transections,
    this.shopRatings,
    this.iV,
    this.description,
    this.resetPasswordTime,
    this.resetPasswordToken,
  });

  Shop.fromJson(Map<String, dynamic> json) {
    document1 = json['document1'] != null && json['document1'] is Map<String, dynamic>
        ? Document1.fromJson(Map<String, dynamic>.from(json['document1']))
        : null;
    document2 = json['document2'] != null && json['document2'] is Map<String, dynamic>
        ? Document1.fromJson(Map<String, dynamic>.from(json['document2']))
        : null;
    location = json['location'] != null && json['location'] is Map<String, dynamic>
        ? ShopLocation.fromJson(Map<String, dynamic>.from(json['location']))
        : null;
    sId = json['_id'] as String?;
    name = json['name'] as String?;
    email = json['email'] as String?;
    keyPoints = json['keyPoints'] as String?;
    address = json['address'] as String?;
    phoneNumber = json['phoneNumber'];
    role = json['role'] as String?;
    avatar = json['avatar'] as String?;
    zipCode = json['zipCode'];
    shopOwnerName = json['shopOwnerName'] as String?;
    city = json['city'] as String?;
    state = json['state'] as String?;
    shopFrontPhoto = json['shopFrontPhoto'] as String?;
    ownerAtCounterPhoto = json['ownerAtCounterPhoto'] as String?;
    docVerificationStatus = json['docVerificationStatus'] as String?;
    availableBalance = json['availableBalance'] is num ? json['availableBalance'] as num : null;
    createdAt = json['createdAt'] as String?;
    status = json['status'] as String?;
    rejectReason = json['rejectReason'] as String?;
    subscriptionPaid = json['subscriptionPaid'] as bool?;
    subscriptionTransactionId = json['subscriptionTransactionId'] as String?;
    subscriptionPaidAt = json['subscriptionPaidAt'] as String?;
    isActive = json['isActive'] as bool?;
    ratings = json['ratings'] is num ? json['ratings'] as num : null;
    bankAccountNumber = json['bankAccountNumber'] as String?;
    bankIfscCode = json['bankIfscCode'] as String?;
    bankAccountName = json['bankAccountName'] as String?;
    bankName = json['bankName'] as String?;
    bankBranchName = json['bankBranchName'] as String?;
    employeeCode = json['employeeCode'] as String?;
    registeredBy = json['registeredBy'] as String?;
    discountCouponApplied = json['discountCouponApplied'] as bool?;
    discountCouponCode = json['discountCouponCode'] as String?;
    if (json['transections'] != null && json['transections'] is List) {
      transections = List<dynamic>.from(json['transections']);
    }
    if (json['shopRatings'] != null && json['shopRatings'] is List) {
      shopRatings = <ShopRatings>[];
      json['shopRatings'].forEach((v) {
        shopRatings!.add(ShopRatings.fromJson(Map<String, dynamic>.from(v)));
      });
    }
    iV = json['__v'] is int ? json['__v'] as int : null;
    description = json['description'] as String?;
    resetPasswordTime = json['resetPasswordTime'] as String?;
    resetPasswordToken = json['resetPasswordToken'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (document1 != null) {
      data['document1'] = document1!.toJson();
    }
    if (document2 != null) {
      data['document2'] = document2!.toJson();
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['keyPoints'] = keyPoints;
    data['address'] = address;
    data['phoneNumber'] = phoneNumber;
    data['role'] = role;
    data['avatar'] = avatar;
    data['zipCode'] = zipCode;
    data['shopOwnerName'] = shopOwnerName;
    data['city'] = city;
    data['state'] = state;
    data['shopFrontPhoto'] = shopFrontPhoto;
    data['ownerAtCounterPhoto'] = ownerAtCounterPhoto;
    data['docVerificationStatus'] = docVerificationStatus;
    data['availableBalance'] = availableBalance;
    data['createdAt'] = createdAt;
    data['status'] = status;
    data['rejectReason'] = rejectReason;
    data['subscriptionPaid'] = subscriptionPaid;
    data['subscriptionTransactionId'] = subscriptionTransactionId;
    data['subscriptionPaidAt'] = subscriptionPaidAt;
    data['isActive'] = isActive;
    data['ratings'] = ratings;
    data['bankAccountNumber'] = bankAccountNumber;
    data['bankIfscCode'] = bankIfscCode;
    data['bankAccountName'] = bankAccountName;
    data['bankName'] = bankName;
    data['bankBranchName'] = bankBranchName;
    data['employeeCode'] = employeeCode;
    data['registeredBy'] = registeredBy;
    data['discountCouponApplied'] = discountCouponApplied;
    data['discountCouponCode'] = discountCouponCode;
    if (transections != null) {
      data['transections'] = transections;
    }
    if (shopRatings != null) {
      data['shopRatings'] = shopRatings!.map((v) => v.toJson()).toList();
    }
    data['__v'] = iV;
    data['description'] = description;
    data['resetPasswordTime'] = resetPasswordTime;
    data['resetPasswordToken'] = resetPasswordToken;
    return data;
  }
}

class Document1 {
  String? type;
  String? number;
  String? photo;

  Document1({this.type, this.number, this.photo});

  Document1.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String?;
    number = json['number'] as String?;
    photo = json['photo'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['number'] = number;
    data['photo'] = photo;
    return data;
  }
}

class ShopLocation {
  String? type;
  List<num>? coordinates;

  ShopLocation({this.type, this.coordinates});

  ShopLocation.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String?;
    if (json['coordinates'] != null && json['coordinates'] is List) {
      coordinates = (json['coordinates'] as List)
          .map((e) => (e is num) ? e : 0)
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

// ignore: camel_case_types
typedef Location = ShopLocation;

class ShopRatings {
  ProductUser? user;
  num? rating;
  String? comment;
  String? createdAt;
  String? sId;

  ShopRatings({this.user, this.rating, this.comment, this.createdAt, this.sId});

  ShopRatings.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null && json['user'] is Map<String, dynamic>
        ? ProductUser.fromJson(Map<String, dynamic>.from(json['user']))
        : null;
    rating = json['rating'] is num ? json['rating'] as num : null;
    comment = json['comment'] as String?;
    createdAt = json['createdAt'] as String?;
    sId = json['_id'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['rating'] = rating;
    data['comment'] = comment;
    data['createdAt'] = createdAt;
    data['_id'] = sId;
    return data;
  }
}

class ProductUser {
  ShopLocation? location;
  String? sId;
  String? name;
  String? email;
  dynamic phoneNumber;
  String? role;
  String? avatar;
  String? createdAt;
  String? adminStatus;
  String? adminPermissions;
  bool? isActiveAdmin;
  List<Addresses>? addresses;
  int? iV;

  ProductUser({
    this.location,
    this.sId,
    this.name,
    this.email,
    this.phoneNumber,
    this.role,
    this.avatar,
    this.createdAt,
    this.adminStatus,
    this.adminPermissions,
    this.isActiveAdmin,
    this.addresses,
    this.iV,
  });

  ProductUser.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null && json['location'] is Map<String, dynamic>
        ? ShopLocation.fromJson(Map<String, dynamic>.from(json['location']))
        : null;
    sId = json['_id'] as String?;
    name = json['name'] as String?;
    email = json['email'] as String?;
    phoneNumber = json['phoneNumber'];
    role = json['role'] as String?;
    avatar = json['avatar'] as String?;
    createdAt = json['createdAt'] as String?;
    adminStatus = json['adminStatus'] as String?;
    adminPermissions = json['adminPermissions'] as String?;
    isActiveAdmin = json['isActiveAdmin'] as bool?;
    if (json['addresses'] != null && json['addresses'] is List) {
      addresses = <Addresses>[];
      json['addresses'].forEach((v) {
        addresses!.add(Addresses.fromJson(Map<String, dynamic>.from(v)));
      });
    }
    iV = json['__v'] is int ? json['__v'] as int : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    data['role'] = role;
    data['avatar'] = avatar;
    data['createdAt'] = createdAt;
    data['adminStatus'] = adminStatus;
    data['adminPermissions'] = adminPermissions;
    data['isActiveAdmin'] = isActiveAdmin;
    if (addresses != null) {
      data['addresses'] = addresses!.map((v) => v.toJson()).toList();
    }
    data['__v'] = iV;
    return data;
  }
}

// ignore: camel_case_types
typedef User = ProductUser;

class Addresses {
  String? country;
  String? city;
  String? address1;
  String? address2;
  dynamic zipCode;
  String? addressType;
  String? sId;

  Addresses({
    this.country,
    this.city,
    this.address1,
    this.address2,
    this.zipCode,
    this.addressType,
    this.sId,
  });

  Addresses.fromJson(Map<String, dynamic> json) {
    country = json['country'] as String?;
    city = json['city'] as String?;
    address1 = json['address1'] as String?;
    address2 = json['address2'] as String?;
    zipCode = json['zipCode'];
    addressType = json['addressType'] as String?;
    sId = json['_id'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country'] = country;
    data['city'] = city;
    data['address1'] = address1;
    data['address2'] = address2;
    data['zipCode'] = zipCode;
    data['addressType'] = addressType;
    data['_id'] = sId;
    return data;
  }
}

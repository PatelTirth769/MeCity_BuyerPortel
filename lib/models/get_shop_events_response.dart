import 'package:mecity_marketplace/models/get_all_products_response.dart';

class GetShopEventsResponse {
  bool? success;
  List<Events>? events;

  GetShopEventsResponse({this.success, this.events});

  GetShopEventsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    if (json['events'] != null) {
      events = <Events>[];
      json['events'].forEach((v) {
        if (v != null) {
          events!.add(Events.fromJson(Map<String, dynamic>.from(v)));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (events != null) {
      data['events'] = events!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_shop_events = GetShopEventsResponse;

class Events {
  String? sId;
  String? name;
  String? description;
  String? category;
  String? startDate;
  String? finishDate;
  String? status;
  String? tags;
  num? originalPrice;
  num? discountPrice;
  int? stock;
  List<String>? images;
  String? shopId;
  Shop? shop;
  int? soldOut;
  String? createdAt;
  List<dynamic>? reviews;
  int? iV;

  Events({
    this.sId,
    this.name,
    this.description,
    this.category,
    this.startDate,
    this.finishDate,
    this.status,
    this.tags,
    this.originalPrice,
    this.discountPrice,
    this.stock,
    this.images,
    this.shopId,
    this.shop,
    this.soldOut,
    this.createdAt,
    this.reviews,
    this.iV,
  });

  Events.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] as String?;
    name = json['name'] as String?;
    description = json['description'] as String?;
    category = json['category'] as String?;
    startDate = (json['start_Date'] ?? json['startDate']) as String?;
    finishDate = (json['Finish_Date'] ?? json['finishDate']) as String?;
    status = json['status'] as String?;
    tags = json['tags'] as String?;
    originalPrice = json['originalPrice'] is num ? json['originalPrice'] as num : (json['originalPrice'] != null ? num.tryParse(json['originalPrice'].toString()) : null);
    discountPrice = json['discountPrice'] is num ? json['discountPrice'] as num : (json['discountPrice'] != null ? num.tryParse(json['discountPrice'].toString()) : null);
    stock = json['stock'] is int ? json['stock'] as int : (json['stock'] != null ? int.tryParse(json['stock'].toString()) : null);
    if (json['images'] != null && json['images'] is List) {
      images = List<String>.from(json['images'].map((x) => x.toString()));
    }
    shopId = json['shopId'] as String?;
    shop = json['shop'] != null && json['shop'] is Map<String, dynamic>
        ? Shop.fromJson(Map<String, dynamic>.from(json['shop']))
        : null;
    soldOut = json['sold_out'] is int ? json['sold_out'] as int : null;
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
    data['start_Date'] = startDate;
    data['Finish_Date'] = finishDate;
    data['status'] = status;
    data['tags'] = tags;
    data['originalPrice'] = originalPrice;
    data['discountPrice'] = discountPrice;
    data['stock'] = stock;
    data['images'] = images;
    data['shopId'] = shopId;
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    data['sold_out'] = soldOut;
    data['createdAt'] = createdAt;
    if (reviews != null) {
      data['reviews'] = reviews;
    }
    data['__v'] = iV;
    return data;
  }
}

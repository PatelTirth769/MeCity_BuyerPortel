import 'package:mecity_marketplace/models/get_all_products_response.dart';

class GetShopInfoResponse {
  bool? success;
  Shop? shop;
  String? message;

  GetShopInfoResponse({this.success, this.shop, this.message});

  GetShopInfoResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    message = json['message'] as String?;
    if (json['shop'] != null && json['shop'] is Map<String, dynamic>) {
      shop = Shop.fromJson(Map<String, dynamic>.from(json['shop']));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (shop != null) {
      data['shop'] = shop!.toJson();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_shop_info = GetShopInfoResponse;

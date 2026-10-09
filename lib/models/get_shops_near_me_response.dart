import 'package:mecity_marketplace/models/get_all_products_response.dart';

class GetShopsNearMeResponse {
  bool? success;
  List<Shop>? shops;
  String? message;

  GetShopsNearMeResponse({this.success, this.shops, this.message});

  GetShopsNearMeResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    message = json['message'] as String?;
    if (json['shops'] != null) {
      shops = <Shop>[];
      json['shops'].forEach((v) {
        if (v != null) {
          shops!.add(Shop.fromJson(Map<String, dynamic>.from(v)));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (shops != null) {
      data['shops'] = shops!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_shops_near_me = GetShopsNearMeResponse;

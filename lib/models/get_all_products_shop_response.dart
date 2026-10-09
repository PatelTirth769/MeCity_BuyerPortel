import 'package:mecity_marketplace/models/get_all_products_response.dart';

class GetAllProductsShopResponse {
  bool? success;
  List<Products>? products;

  GetAllProductsShopResponse({this.success, this.products});

  GetAllProductsShopResponse.fromJson(Map<String, dynamic> json) {
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
typedef get_all_products_shop = GetAllProductsShopResponse;

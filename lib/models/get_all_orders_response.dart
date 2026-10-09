import 'package:mecity_marketplace/models/create_order_response.dart';

class GetAllOrdersResponse {
  bool? success;
  List<Orders>? orders;

  GetAllOrdersResponse({this.success, this.orders});

  GetAllOrdersResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        if (v != null) {
          orders!.add(Orders.fromJson(Map<String, dynamic>.from(v)));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_all_orders = GetAllOrdersResponse;

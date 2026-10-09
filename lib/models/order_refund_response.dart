import 'package:mecity_marketplace/models/create_order_response.dart';

class OrderRefundResponse {
  bool? success;
  Orders? order;
  String? message;

  OrderRefundResponse({this.success, this.order, this.message});

  OrderRefundResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    order = json['order'] != null && json['order'] is Map<String, dynamic>
        ? Orders.fromJson(Map<String, dynamic>.from(json['order']))
        : null;
    message = json['message'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (order != null) {
      data['order'] = order!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef order_refund = OrderRefundResponse;

// ignore: camel_case_types
typedef Order = Orders;

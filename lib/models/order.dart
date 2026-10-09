import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mecity_marketplace/models/cart.dart';
import 'package:mecity_marketplace/models/user.dart';

enum OrderStatus {
  processing,
  transferredToDeliveryPartner,
  shipping,
  received,
  onTheWay,
  delivered,
  cancelled,
  processingRefund,
  refundSuccess
}

extension OrderStatusExtension on OrderStatus {
  String get apiString {
    switch (this) {
      case OrderStatus.processing: return "Processing";
      case OrderStatus.transferredToDeliveryPartner: return "Transferred to delivery partner";
      case OrderStatus.shipping: return "Shipping";
      case OrderStatus.received: return "Received";
      case OrderStatus.onTheWay: return "On the way";
      case OrderStatus.delivered: return "Delivered";
      case OrderStatus.cancelled: return "Canceled";
      case OrderStatus.processingRefund: return "Processing refund";
      case OrderStatus.refundSuccess: return "Refund Success";
    }
  }

  static OrderStatus fromApiString(String status) {
    switch (status) {
      case "Processing": return OrderStatus.processing;
      case "Transferred to delivery partner": return OrderStatus.transferredToDeliveryPartner;
      case "Shipping": return OrderStatus.shipping;
      case "Received": return OrderStatus.received;
      case "On the way": return OrderStatus.onTheWay;
      case "Delivered": return OrderStatus.delivered;
      case "Canceled": 
      case "Cancelled": return OrderStatus.cancelled;
      case "Processing refund": return OrderStatus.processingRefund;
      case "Refund Success": return OrderStatus.refundSuccess;
      default: return OrderStatus.processing; // Fallback
    }
  }
}

class TrackingStep {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  TrackingStep({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory TrackingStep.fromMap(Map<String, dynamic> map) {
    return TrackingStep(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double totalAmount;
  final OrderStatus status;
  final AddressModel shippingAddress;
  final String paymentMethod;
  final String trackingNumber;
  final List<TrackingStep> trackingSteps;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.trackingNumber,
    required this.trackingSteps,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'status': status.apiString,
      'shippingAddress': shippingAddress.toMap(),
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
      'trackingSteps': trackingSteps.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    // Some API responses use '_id', some use 'id'
    final orderId = docId ?? map['_id'] ?? map['id'] ?? '';
    
    return OrderModel(
      id: orderId,
      items: map['cart'] != null
          ? (map['cart'] as List).map((i) => CartItem.fromMap(Map<String, dynamic>.from(i))).toList()
          : (map['items'] != null ? (map['items'] as List).map((i) => CartItem.fromMap(Map<String, dynamic>.from(i))).toList() : []),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      shippingFee: (map['shippingFee'] ?? 0.0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0.0).toDouble(),
      totalAmount: (map['totalPrice'] ?? map['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatusExtension.fromApiString(map['status'] ?? ''),
      shippingAddress: AddressModel.fromMap(Map<String, dynamic>.from(map['shippingAddress'] ?? {})),
      paymentMethod: map['paymentInfo'] != null ? map['paymentInfo']['type'] ?? '' : (map['paymentMethod'] ?? ''),
      trackingNumber: map['trackingNumber'] ?? orderId, // use orderId if no tracking number
      trackingSteps: map['trackingSteps'] != null
          ? (map['trackingSteps'] as List).map((s) => TrackingStep.fromMap(Map<String, dynamic>.from(s))).toList()
          : [],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) ?? DateTime.now() : DateTime.now(),
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel.fromMap(data, doc.id);
  }
}

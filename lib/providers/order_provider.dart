import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mecity_marketplace/models/order.dart';
import 'package:mecity_marketplace/models/cart.dart';
import 'package:mecity_marketplace/models/user.dart';
import 'package:mecity_marketplace/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  final OrderService _orderService = OrderService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OrderModel> get orders => _orders;

  Future<void> fetchOrdersFromApi(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedOrders = await _orderService.getUserOrders(userId);
      _orders = fetchedOrders;
    } on OrderServiceException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<OrderModel> getOrdersByStatus(OrderStatus? status) {
    if (status == null) return _orders;
    return _orders.where((o) => o.status == status).toList();
  }

  Future<OrderModel?> placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double shippingFee,
    required double discountAmount,
    required double totalAmount,
    required AddressModel shippingAddress,
    required String paymentMethod,
    required UserModel user,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orderData = {
        'cart': items.map((i) => {
          'shopId': i.product.shopId,
          'productId': i.product.id,
          'quantity': i.quantity,
          'price': i.product.discountPrice,
        }).toList(),
        'shippingAddress': {
          'address': shippingAddress.addressLine1,
          'city': shippingAddress.city,
          'zipCode': shippingAddress.zipCode,
          'country': 'India',
        },
        'user': {
          '_id': user.id,
          'name': user.name,
          'email': user.email,
        },
        'totalPrice': totalAmount,
        'paymentInfo': {
          'id': 'pay_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'succeeded',
          'type': paymentMethod,
        }
      };

      final newOrder = await _orderService.createOrder(orderData);
      _orders.insert(0, newOrder);
      _isLoading = false;
      notifyListeners();
      return newOrder;
    } on OrderServiceException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> requestRefund(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _orderService.refundOrder(orderId, 'Processing refund');
      if (success) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          final oldOrder = _orders[index];
          // Update status locally for immediate feedback
          _orders[index] = OrderModel(
            id: oldOrder.id,
            items: oldOrder.items,
            subtotal: oldOrder.subtotal,
            shippingFee: oldOrder.shippingFee,
            discountAmount: oldOrder.discountAmount,
            totalAmount: oldOrder.totalAmount,
            status: OrderStatus.processingRefund,
            shippingAddress: oldOrder.shippingAddress,
            paymentMethod: oldOrder.paymentMethod,
            trackingNumber: oldOrder.trackingNumber,
            trackingSteps: oldOrder.trackingSteps,
            createdAt: oldOrder.createdAt,
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } on OrderServiceException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

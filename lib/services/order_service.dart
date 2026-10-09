import 'package:flutter/foundation.dart';
import 'package:mecity_marketplace/models/order.dart';
import 'package:mecity_marketplace/models/create_order_response.dart';
import 'package:mecity_marketplace/models/get_all_orders_response.dart';
import 'package:mecity_marketplace/models/order_refund_response.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';
import 'package:mecity_marketplace/core/network/api_exceptions.dart';

class OrderServiceException implements Exception {
  final String message;
  final int? statusCode;

  OrderServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class OrderService {
  final ApiClient _apiClient;

  OrderService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<GetAllOrdersResponse> getAllOrdersApi(String userId) async {
    try {
      final responseJson = await _apiClient.get('${ApiEndpoints.getAllOrders}/$userId');
      return GetAllOrdersResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw OrderServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw OrderServiceException('An unexpected error occurred: $e');
    }
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final responseJson = await _apiClient.get('${ApiEndpoints.getAllOrders}/$userId');
      
      List<dynamic> rawList = [];
      if (responseJson is Map<String, dynamic>) {
        if (responseJson.containsKey('orders')) {
          rawList = responseJson['orders'] as List;
        } else if (responseJson.containsKey('data')) {
          rawList = responseJson['data'] as List;
        }
      } else if (responseJson is List) {
        rawList = responseJson;
      }

      return rawList.map((item) => OrderModel.fromMap(item as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      debugPrint('⚠️ Orders API Note: ${e.message}');
      throw OrderServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      debugPrint('⚠️ Orders API error: $e');
      throw OrderServiceException('An unexpected error occurred: $e');
    }
  }

  Future<CreateOrderResponse> createOrderApi(Map<String, dynamic> orderData) async {
    try {
      final responseJson = await _apiClient.post(ApiEndpoints.createOrder, body: orderData);
      return CreateOrderResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw OrderServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw OrderServiceException('An unexpected error occurred: $e');
    }
  }

  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      final responseJson = await _apiClient.post(ApiEndpoints.createOrder, body: orderData);
      
      // API might return an array of orders or a single order object.
      Map<String, dynamic> dataToParse = {};
      if (responseJson is List && responseJson.isNotEmpty) {
        dataToParse = responseJson[0];
      } else if (responseJson is Map<String, dynamic>) {
        if (responseJson.containsKey('orders') && (responseJson['orders'] as List).isNotEmpty) {
          dataToParse = responseJson['orders'][0];
        } else if (responseJson.containsKey('order')) {
          dataToParse = responseJson['order'];
        } else {
          dataToParse = responseJson;
        }
      }
      return OrderModel.fromMap(dataToParse);
    } on ApiException catch (e) {
      throw OrderServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw OrderServiceException('An unexpected error occurred: $e');
    }
  }

  Future<OrderRefundResponse> requestOrderRefundApi({
    required String orderId,
    required String status,
  }) async {
    try {
      final responseJson = await _apiClient.put(
        '${ApiEndpoints.orderRefund}/$orderId',
        body: {'status': status},
      );
      return OrderRefundResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw OrderServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw OrderServiceException('An unexpected error occurred: $e');
    }
  }

  Future<bool> refundOrder(String orderId, String status) async {
    try {
      final responseJson = await _apiClient.put(
        '${ApiEndpoints.orderRefund}/$orderId', 
        body: {'status': status}
      );
      return responseJson['success'] == true;
    } on ApiException catch (e) {
      throw OrderServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw OrderServiceException('An unexpected error occurred: $e');
    }
  }
}

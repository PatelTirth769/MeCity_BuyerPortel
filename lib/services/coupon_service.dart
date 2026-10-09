import 'package:mecity_marketplace/models/get_coupon_value_response.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';
import 'package:mecity_marketplace/core/network/api_exceptions.dart';

class CouponServiceException implements Exception {
  final String message;
  final int? statusCode;

  CouponServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class CouponService {
  final ApiClient _apiClient;

  CouponService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<GetCouponValueResponse> getCouponValue(String couponName) async {
    try {
      final responseJson = await _apiClient.get('${ApiEndpoints.getCouponValue}/$couponName');
      return GetCouponValueResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw CouponServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw CouponServiceException('An unexpected error occurred: $e');
    }
  }
}

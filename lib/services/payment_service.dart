import 'package:mecity_marketplace/models/stripe_api_key_response.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';
import 'package:mecity_marketplace/core/network/api_exceptions.dart';

class PaymentServiceException implements Exception {
  final String message;
  final int? statusCode;

  PaymentServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class PaymentService {
  final ApiClient _apiClient;

  PaymentService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<StripeApiKeyResponse> getStripeApiKey() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getStripeApiKey);
      return StripeApiKeyResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw PaymentServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw PaymentServiceException('An unexpected error occurred: $e');
    }
  }
}

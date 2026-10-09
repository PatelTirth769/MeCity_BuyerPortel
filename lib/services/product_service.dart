import 'package:mecity_marketplace/models/product.dart';
import 'package:mecity_marketplace/models/get_all_products_response.dart';
import 'package:mecity_marketplace/models/get_all_products_shop_response.dart';
import 'package:mecity_marketplace/models/create_review_response.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';
import 'package:mecity_marketplace/core/network/api_exceptions.dart';

class ProductServiceException implements Exception {
  final String message;
  final int? statusCode;

  ProductServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<GetAllProductsResponse> getAllProductsApi() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getAllProducts);
      return GetAllProductsResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw ProductServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw ProductServiceException('An unexpected error occurred: $e');
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getAllProducts);

      List<dynamic>? rawList;
      if (responseJson['products'] is List) {
        rawList = responseJson['products'] as List;
      } else if (responseJson['data'] is List) {
        rawList = responseJson['data'] as List;
      } else if (responseJson['items'] is List) {
        rawList = responseJson['items'] as List;
      }

      if (rawList != null) {
        final products = rawList
            .whereType<Map>()
            .map((item) => Product.fromApiJson(Map<String, dynamic>.from(item)))
            .toList();

        return products;
      } else {
        return [];
      }
    } on ApiException catch (e) {
      throw ProductServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw ProductServiceException('An unexpected error occurred: $e');
    }
  }

  Future<GetAllProductsShopResponse> getProductsByShopId(String shopId) async {
    try {
      final responseJson = await _apiClient.get('${ApiEndpoints.getAllProductsShop}/$shopId');
      return GetAllProductsShopResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw ProductServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw ProductServiceException('An unexpected error occurred: $e');
    }
  }

  Future<CreateReviewResponse> createProductReview({
    required Map<String, dynamic> user,
    required num rating,
    required String comment,
    required String productId,
    required String orderId,
  }) async {
    try {
      final responseJson = await _apiClient.put(
        ApiEndpoints.createNewReview,
        body: {
          'user': user,
          'rating': rating,
          'comment': comment,
          'productId': productId,
          'orderId': orderId,
        },
      );
      return CreateReviewResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw ProductServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw ProductServiceException('An unexpected error occurred: $e');
    }
  }
}

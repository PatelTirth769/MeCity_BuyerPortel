import 'package:mecity_marketplace/models/get_all_blogs_response.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';
import 'package:mecity_marketplace/core/network/api_exceptions.dart';

class BlogServiceException implements Exception {
  final String message;
  final int? statusCode;

  BlogServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class BlogService {
  final ApiClient _apiClient;

  BlogService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<GetAllBlogsResponse> getAllBlogs() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getAllBlogs);
      return GetAllBlogsResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw BlogServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw BlogServiceException('An unexpected error occurred: $e');
    }
  }
}

import 'package:mecity_marketplace/models/get_user_terms_response.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';
import 'package:mecity_marketplace/core/network/api_exceptions.dart';

class TermsServiceException implements Exception {
  final String message;
  final int? statusCode;

  TermsServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class TermsService {
  final ApiClient _apiClient;

  TermsService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<GetUserTermsResponse> getUserTerms() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getUserTerms);
      return GetUserTermsResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw TermsServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw TermsServiceException('An unexpected error occurred: $e');
    }
  }
}

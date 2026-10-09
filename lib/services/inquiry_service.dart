import 'package:mecity_marketplace/models/create_inquiry_response.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';
import 'package:mecity_marketplace/core/network/api_exceptions.dart';

class InquiryService {
  final ApiClient _apiClient;

  InquiryService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<CreateInquiryResponse> submitInquiry({
    required String name,
    required String email,
    required String mobile,
    required String message,
  }) async {
    try {
      final responseJson = await _apiClient.post(
        ApiEndpoints.createInquiry,
        body: {
          'name': name.trim(),
          'email': email.trim(),
          'mobile': mobile.trim(),
          'message': message.trim(),
        },
      );
      return CreateInquiryResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      return CreateInquiryResponse(
        success: false,
        message: e.message,
      );
    } catch (e) {
      return CreateInquiryResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }
}

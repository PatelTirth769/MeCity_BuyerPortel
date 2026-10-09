import 'package:mecity_marketplace/models/get_shop_events_response.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';
import 'package:mecity_marketplace/core/network/api_exceptions.dart';

class EventServiceException implements Exception {
  final String message;
  final int? statusCode;

  EventServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class EventService {
  final ApiClient _apiClient;

  EventService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<GetShopEventsResponse> getAllEvents() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getAllEvents);
      return GetShopEventsResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw EventServiceException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw EventServiceException('An unexpected error occurred: $e');
    }
  }
}

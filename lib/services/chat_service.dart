import 'package:mecity_marketplace/models/create_conversation_response.dart';
import 'package:mecity_marketplace/models/create_message_response.dart';
import 'package:mecity_marketplace/models/get_all_conversation_user_response.dart';
import 'package:mecity_marketplace/models/get_all_messages_response.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<CreateConversationResponse> createConversation({
    required String groupTitle,
    required String userId,
    required String sellerId,
  }) async {
    try {
      final responseJson = await _apiClient.post(
        ApiEndpoints.createConversation,
        body: {
          'groupTitle': groupTitle,
          'userId': userId,
          'sellerId': sellerId,
        },
      );
      return CreateConversationResponse.fromJson(responseJson);
    } catch (e) {
      return CreateConversationResponse(success: false);
    }
  }

  Future<GetAllConversationUserResponse> getUserConversationsApi(String userId) async {
    try {
      final responseJson = await _apiClient.get('${ApiEndpoints.getAllConversations}/$userId');
      return GetAllConversationUserResponse.fromJson(responseJson);
    } catch (e) {
      return GetAllConversationUserResponse(success: false);
    }
  }

  Future<List<dynamic>> getUserConversations(String userId) async {
    try {
      final responseJson = await _apiClient.get('${ApiEndpoints.getAllConversations}/$userId');
      if (responseJson['success'] == true) {
        return responseJson['conversations'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<GetAllMessagesResponse> getMessagesApi(String conversationId) async {
    try {
      final responseJson = await _apiClient.get('${ApiEndpoints.getAllMessages}/$conversationId');
      return GetAllMessagesResponse.fromJson(responseJson);
    } catch (e) {
      return GetAllMessagesResponse(success: false);
    }
  }

  Future<List<dynamic>> getMessages(String conversationId) async {
    try {
      final responseJson = await _apiClient.get('${ApiEndpoints.getAllMessages}/$conversationId');
      if (responseJson['success'] == true) {
        return responseJson['messages'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<CreateMessageResponse> sendMessageApi({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    try {
      final responseJson = await _apiClient.post(
        ApiEndpoints.createMessage,
        body: {
          'conversationId': conversationId,
          'sender': senderId,
          'text': text,
        },
      );
      return CreateMessageResponse.fromJson(responseJson);
    } catch (e) {
      return CreateMessageResponse(success: false);
    }
  }

  Future<Map<String, dynamic>?> createMessage(Map<String, dynamic> data) async {
    try {
      final responseJson = await _apiClient.post(ApiEndpoints.createMessage, body: data);
      if (responseJson['success'] == true) {
        return responseJson['message'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

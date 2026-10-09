import 'package:mecity_marketplace/models/create_conversation_response.dart';

class GetAllConversationUserResponse {
  bool? success;
  List<Conversation>? conversations;

  GetAllConversationUserResponse({this.success, this.conversations});

  GetAllConversationUserResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    if (json['conversations'] != null) {
      conversations = <Conversation>[];
      json['conversations'].forEach((v) {
        if (v != null) {
          conversations!.add(Conversation.fromJson(Map<String, dynamic>.from(v)));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (conversations != null) {
      data['conversations'] = conversations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_all_conversation_user = GetAllConversationUserResponse;

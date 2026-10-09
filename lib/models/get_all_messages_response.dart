import 'package:mecity_marketplace/models/create_message_response.dart';

class GetAllMessagesResponse {
  bool? success;
  List<Message>? messages;

  GetAllMessagesResponse({this.success, this.messages});

  GetAllMessagesResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    if (json['messages'] != null) {
      messages = <Message>[];
      json['messages'].forEach((v) {
        if (v != null) {
          messages!.add(Message.fromJson(Map<String, dynamic>.from(v)));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_all_messages = GetAllMessagesResponse;

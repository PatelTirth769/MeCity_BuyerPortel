class CreateMessageResponse {
  bool? success;
  Message? message;

  CreateMessageResponse({this.success, this.message});

  CreateMessageResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    if (json['message'] != null && json['message'] is Map<String, dynamic>) {
      message = Message.fromJson(Map<String, dynamic>.from(json['message']));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (message != null) {
      data['message'] = message!.toJson();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef create_new_message = CreateMessageResponse;

class Message {
  String? sId;
  String? conversationId;
  String? sender;
  String? text;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Message({
    this.sId,
    this.conversationId,
    this.sender,
    this.text,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Message.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] as String?;
    conversationId = json['conversationId'] as String?;
    sender = json['sender'] as String?;
    text = json['text'] as String?;
    createdAt = json['createdAt'] as String?;
    updatedAt = json['updatedAt'] as String?;
    iV = json['__v'] is int ? json['__v'] as int : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['conversationId'] = conversationId;
    data['sender'] = sender;
    data['text'] = text;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

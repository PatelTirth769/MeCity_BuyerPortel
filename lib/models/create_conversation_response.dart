class CreateConversationResponse {
  bool? success;
  Conversation? conversation;

  CreateConversationResponse({this.success, this.conversation});

  CreateConversationResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    conversation = json['conversation'] != null
        ? Conversation.fromJson(Map<String, dynamic>.from(json['conversation']))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (conversation != null) {
      data['conversation'] = conversation!.toJson();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef create_new_conversation = CreateConversationResponse;

class Conversation {
  String? groupTitle;
  List<String>? members;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Conversation({
    this.groupTitle,
    this.members,
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Conversation.fromJson(Map<String, dynamic> json) {
    groupTitle = json['groupTitle'] as String?;
    if (json['members'] != null) {
      members = List<String>.from(json['members'].map((x) => x.toString()));
    }
    sId = json['_id'] as String?;
    createdAt = json['createdAt'] as String?;
    updatedAt = json['updatedAt'] as String?;
    iV = json['__v'] is int ? json['__v'] as int : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupTitle'] = groupTitle;
    data['members'] = members;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

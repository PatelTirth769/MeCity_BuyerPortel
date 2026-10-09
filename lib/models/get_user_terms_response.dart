class GetUserTermsResponse {
  bool? success;
  Terms? terms;

  GetUserTermsResponse({this.success, this.terms});

  GetUserTermsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    terms = json['terms'] != null && json['terms'] is Map<String, dynamic>
        ? Terms.fromJson(Map<String, dynamic>.from(json['terms']))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (terms != null) {
      data['terms'] = terms!.toJson();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_user_terms = GetUserTermsResponse;

class Terms {
  String? sId;
  String? type;
  List<TermsContent>? content;
  String? updatedAt;
  int? iV;

  Terms({this.sId, this.type, this.content, this.updatedAt, this.iV});

  Terms.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] as String?;
    type = json['type'] as String?;
    if (json['content'] != null && json['content'] is List) {
      content = <TermsContent>[];
      json['content'].forEach((v) {
        if (v != null) {
          content!.add(TermsContent.fromJson(Map<String, dynamic>.from(v)));
        }
      });
    }
    updatedAt = json['updatedAt'] as String?;
    iV = json['__v'] is int ? json['__v'] as int : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['type'] = type;
    if (content != null) {
      data['content'] = content!.map((v) => v.toJson()).toList();
    }
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class TermsContent {
  String? title;
  String? description;
  String? sId;

  TermsContent({this.title, this.description, this.sId});

  TermsContent.fromJson(Map<String, dynamic> json) {
    title = json['title'] as String?;
    description = json['description'] as String?;
    sId = json['_id'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['_id'] = sId;
    return data;
  }
}

// ignore: camel_case_types
typedef Content = TermsContent;

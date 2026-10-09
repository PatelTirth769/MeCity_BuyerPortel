class CreateInquiryResponse {
  bool? success;
  Inquiry? inquiry;
  String? message;

  CreateInquiryResponse({this.success, this.inquiry, this.message});

  CreateInquiryResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    inquiry = json['inquiry'] != null && json['inquiry'] is Map<String, dynamic>
        ? Inquiry.fromJson(Map<String, dynamic>.from(json['inquiry']))
        : null;
    message = json['message'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (inquiry != null) {
      data['inquiry'] = inquiry!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef create_inquiry = CreateInquiryResponse;

class Inquiry {
  String? name;
  String? email;
  String? mobile;
  String? message;
  String? createdAt;
  String? sId;
  int? iV;

  Inquiry({
    this.name,
    this.email,
    this.mobile,
    this.message,
    this.createdAt,
    this.sId,
    this.iV,
  });

  Inquiry.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    email = json['email'] as String?;
    mobile = json['mobile']?.toString();
    message = json['message'] as String?;
    createdAt = json['createdAt'] as String?;
    sId = json['_id'] as String?;
    iV = json['__v'] is int ? json['__v'] as int : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['mobile'] = mobile;
    data['message'] = message;
    data['createdAt'] = createdAt;
    data['_id'] = sId;
    data['__v'] = iV;
    return data;
  }
}

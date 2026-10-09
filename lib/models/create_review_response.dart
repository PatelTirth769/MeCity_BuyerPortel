class CreateReviewResponse {
  bool? success;
  String? message;

  CreateReviewResponse({this.success, this.message});

  CreateReviewResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    message = json['message'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef create_new_review = CreateReviewResponse;

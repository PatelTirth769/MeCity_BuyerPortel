class ForgotPasswordResponse {
  bool? success;
  String? message;

  ForgotPasswordResponse({this.success, this.message});

  ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
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

// ignore: camel_case_types
typedef forgate_password = ForgotPasswordResponse;
// ignore: camel_case_types
typedef forgot_password = ForgotPasswordResponse;

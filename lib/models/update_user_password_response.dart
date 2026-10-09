class UpdateUserPasswordResponse {
  bool? success;
  String? message;

  UpdateUserPasswordResponse({this.success, this.message});

  UpdateUserPasswordResponse.fromJson(Map<String, dynamic> json) {
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
typedef update_user_password = UpdateUserPasswordResponse;

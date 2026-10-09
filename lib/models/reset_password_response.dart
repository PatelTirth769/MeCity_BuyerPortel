import 'package:mecity_marketplace/models/update_user_addresses_response.dart';

class ResetPasswordResponse {
  bool? success;
  User? user;
  String? token;
  String? message;

  ResetPasswordResponse({this.success, this.user, this.token, this.message});

  ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    user = json['user'] != null && json['user'] is Map<String, dynamic>
        ? User.fromJson(Map<String, dynamic>.from(json['user']))
        : null;
    token = json['token'] as String?;
    message = json['message'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['token'] = token;
    data['message'] = message;
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef reset_password = ResetPasswordResponse;

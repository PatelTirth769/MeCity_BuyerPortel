import 'package:mecity_marketplace/models/update_user_addresses_response.dart';

class DeleteUserAddressResponse {
  bool? success;
  User? user;

  DeleteUserAddressResponse({this.success, this.user});

  DeleteUserAddressResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    user = json['user'] != null && json['user'] is Map<String, dynamic>
        ? User.fromJson(Map<String, dynamic>.from(json['user']))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef delete_user_address = DeleteUserAddressResponse;

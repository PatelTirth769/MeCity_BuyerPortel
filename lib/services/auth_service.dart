import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mecity_marketplace/models/login_response.dart';
import 'package:mecity_marketplace/models/create_user_request.dart';
import 'package:mecity_marketplace/models/create_user_response.dart';
import 'package:mecity_marketplace/models/forgot_password_response.dart';
import 'package:mecity_marketplace/models/get_user_response.dart';
import 'package:mecity_marketplace/models/logout_response.dart';
import 'package:mecity_marketplace/models/update_user_info_response.dart';
import 'package:mecity_marketplace/models/update_avatar_response.dart';
import 'package:mecity_marketplace/models/update_user_password_response.dart';
import 'package:mecity_marketplace/models/update_user_addresses_response.dart';
import 'package:mecity_marketplace/models/reset_password_response.dart';
import 'package:mecity_marketplace/models/delete_user_address_response.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';
import 'package:mecity_marketplace/core/network/api_exceptions.dart';

// Keeping AuthException for backward compatibility with providers, 
// but mapping from our new ApiExceptions.
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final responseJson = await _apiClient.post(
        ApiEndpoints.login,
        body: {
          'email': email.trim(),
          'password': password,
          'role': 'user',
        },
      );

      final loginResponse = LoginResponse.fromJson(responseJson);

      if (loginResponse.success == true) {
        return loginResponse;
      } else {
        throw AuthException('Login failed. Please check your credentials.');
      }
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<CreateUserResponse> createUser(
    CreateUserRequest request, {
    List<int>? avatarBytes,
    String? avatarFilename,
  }) async {
    final url = ApiEndpoints.register;
    final fields = request.toFields();

    // Default 1x1 avatar PNG if none provided (backend multer single('file') requires req.file)
    final bytesToUpload = avatarBytes ??
        base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
    final filename = avatarFilename ?? 'avatar.png';

    if (kDebugMode) {
      debugPrint('================ CREATE USER ================');
      debugPrint('URL: $url');
      debugPrint('METHOD: POST');
      debugPrint('BODY: ${jsonEncode(request.toJson(maskPassword: true))}');
      debugPrint('=============================================');
    }

    try {
      final responseJson = await _apiClient.multipartPost(
        url,
        fields: fields,
        fileBytes: bytesToUpload,
        fileName: filename,
      );

      final createResp = CreateUserResponse.fromJson(responseJson);

      debugPrint('STEP 3: STATUS = 201');
      debugPrint('STEP 4: RESPONSE = ${jsonEncode(createResp.toJson())}');
      debugPrint('STEP 5: Account created successfully');

      if (createResp.success == true) {
        return createResp;
      } else {
        throw AuthException(createResp.message ?? 'User registration failed.');
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        debugPrint('================ CREATE USER ERROR ================');
        debugPrint('STATUS: ${e.statusCode}');
        debugPrint('RESPONSE: ${e.message}');
        debugPrint('===================================================');
      }

      String msg = e.message;
      if (msg.contains('User already exits') || msg.contains('User already exists') || msg.contains('duplicate key')) {
        msg = 'An account with this email is already registered.';
      } else if (msg.contains('Cast to Number failed') || msg.contains('phoneNumber')) {
        msg = 'Please enter a valid numeric phone number.';
      }
      throw AuthException(msg, statusCode: e.statusCode);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('================ CREATE USER UNEXPECTED ERROR ================');
        debugPrint('ERROR: $e');
        debugPrint('=============================================================');
      }
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<ForgotPasswordResponse> forgotPassword({
    required String email,
    String role = 'user',
  }) async {
    try {
      final responseJson = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        body: {
          'email': email.trim(),
          'role': role,
        },
      );

      final forgotResp = ForgotPasswordResponse.fromJson(responseJson);

      if (forgotResp.success == true) {
        return forgotResp;
      } else {
        throw AuthException(forgotResp.message ?? 'Failed to send password reset email.');
      }
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<ResetPasswordResponse> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final responseJson = await _apiClient.put(
        '${ApiEndpoints.resetPassword}/$token',
        body: {
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      return ResetPasswordResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<GetUserResponse> getLoggedInUser() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getUserProfile);
      return GetUserResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getUserProfile);
      return responseJson;
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<LogoutResponse> logoutUser() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.logout);
      return LogoutResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<UpdateUserInfoResponse> updateUserInfoApi(Map<String, dynamic> data) async {
    try {
      final responseJson = await _apiClient.put(ApiEndpoints.updateUserProfile, body: data);
      return UpdateUserInfoResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<UpdateAvatarResponse> updateAvatarApi({
    required List<int> imageBytes,
    required String fileName,
  }) async {
    try {
      final responseJson = await _apiClient.multipartPut(
        ApiEndpoints.updateUserAvatar,
        fileBytes: imageBytes,
        fileName: fileName,
        fileField: 'image',
      );
      return UpdateAvatarResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> updateUserInfo(Map<String, dynamic> data) async {
    try {
      final responseJson = await _apiClient.put(ApiEndpoints.updateUserProfile, body: data);
      return responseJson;
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<UpdateUserPasswordResponse> updatePasswordApi({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final responseJson = await _apiClient.put(ApiEndpoints.updatePassword, body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });
      return UpdateUserPasswordResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> updatePassword(String oldPassword, String newPassword, String confirmPassword) async {
    try {
      final responseJson = await _apiClient.put(ApiEndpoints.updatePassword, body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });
      return responseJson;
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<UpdateUserAddressesResponse> addUserAddressApi(Map<String, dynamic> data) async {
    try {
      final responseJson = await _apiClient.put(ApiEndpoints.updateUserAddresses, body: data);
      return UpdateUserAddressesResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> addUserAddress(Map<String, dynamic> data) async {
    try {
      final responseJson = await _apiClient.put(ApiEndpoints.updateUserAddresses, body: data);
      return responseJson;
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<DeleteUserAddressResponse> deleteUserAddressApi(String id) async {
    try {
      final responseJson = await _apiClient.delete('${ApiEndpoints.deleteUserAddress}/$id');
      return DeleteUserAddressResponse.fromJson(responseJson);
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> deleteUserAddress(String id) async {
    try {
      final responseJson = await _apiClient.delete('${ApiEndpoints.deleteUserAddress}/$id');
      return responseJson;
    } on ApiException catch (e) {
      throw AuthException(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }
}

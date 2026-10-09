class CreateUserResponse {
  final bool? success;
  final String? message;

  CreateUserResponse({
    this.success,
    this.message,
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

// ignore: camel_case_types
typedef create_user = CreateUserResponse;

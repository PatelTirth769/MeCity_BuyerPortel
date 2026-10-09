class CreateUserRequest {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String? city;
  final String? role;

  CreateUserRequest({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.city,
    this.role = 'user',
  });

  Map<String, String> toFields() {
    final fields = <String, String>{
      'name': name.trim(),
      'email': email.trim(),
      'phoneNumber': phoneNumber.trim(),
      'password': password,
    };
    if (city != null && city!.trim().isNotEmpty) {
      fields['city'] = city!.trim();
    }
    if (role != null) {
      fields['role'] = role!;
    }
    return fields;
  }

  Map<String, dynamic> toJson({bool maskPassword = false}) {
    return {
      'name': name.trim(),
      'email': email.trim(),
      'phoneNumber': phoneNumber.trim(),
      'password': maskPassword ? '******' : password,
      if (city != null && city!.trim().isNotEmpty) 'city': city!.trim(),
      if (role != null) 'role': role!,
    };
  }
}

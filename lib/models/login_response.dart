class LoginResponse {
  bool? success;
  ApiUser? user;
  String? token;

  LoginResponse({this.success, this.user, this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool?,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? ApiUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['token'] = token;
    return data;
  }
}

// ignore: camel_case_types
typedef login = LoginResponse;

class ApiUser {
  Location? location;
  String? sId;
  String? name;
  String? email;
  String? password;
  dynamic phoneNumber;
  String? role;
  String? avatar;
  String? createdAt;
  String? adminStatus;
  String? adminPermissions;
  bool? isActiveAdmin;
  List<dynamic>? addresses;
  int? iV;

  ApiUser({
    this.location,
    this.sId,
    this.name,
    this.email,
    this.password,
    this.phoneNumber,
    this.role,
    this.avatar,
    this.createdAt,
    this.adminStatus,
    this.adminPermissions,
    this.isActiveAdmin,
    this.addresses,
    this.iV,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    List<dynamic>? addressList;
    if (json['addresses'] != null && json['addresses'] is List) {
      addressList = List<dynamic>.from(json['addresses']);
    }

    return ApiUser(
      location: json['location'] != null && json['location'] is Map<String, dynamic>
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      sId: json['_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      phoneNumber: json['phoneNumber'],
      role: json['role'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] as String?,
      adminStatus: json['adminStatus'] as String?,
      adminPermissions: json['adminPermissions'] as String?,
      isActiveAdmin: json['isActiveAdmin'] as bool?,
      addresses: addressList,
      iV: json['__v'] is int ? json['__v'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['phoneNumber'] = phoneNumber;
    data['role'] = role;
    data['avatar'] = avatar;
    data['createdAt'] = createdAt;
    data['adminStatus'] = adminStatus;
    data['adminPermissions'] = adminPermissions;
    data['isActiveAdmin'] = isActiveAdmin;
    if (addresses != null) {
      data['addresses'] = addresses;
    }
    data['__v'] = iV;
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    List<double>? coords;
    if (json['coordinates'] != null && json['coordinates'] is List) {
      coords = (json['coordinates'] as List)
          .map((e) => (e is num) ? e.toDouble() : 0.0)
          .toList();
    }
    return Location(
      type: json['type'] as String?,
      coordinates: coords,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

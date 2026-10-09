class GetUserResponse {
  bool? success;
  User? user;

  GetUserResponse({this.success, this.user});

  GetUserResponse.fromJson(Map<String, dynamic> json) {
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
typedef getuser = GetUserResponse;

class User {
  Location? location;
  String? sId;
  String? name;
  String? email;
  dynamic phoneNumber;
  String? role;
  String? avatar;
  String? createdAt;
  String? adminStatus;
  String? adminPermissions;
  bool? isActiveAdmin;
  List<dynamic>? addresses;
  int? iV;
  String? resetPasswordTime;
  String? resetPasswordToken;

  User({
    this.location,
    this.sId,
    this.name,
    this.email,
    this.phoneNumber,
    this.role,
    this.avatar,
    this.createdAt,
    this.adminStatus,
    this.adminPermissions,
    this.isActiveAdmin,
    this.addresses,
    this.iV,
    this.resetPasswordTime,
    this.resetPasswordToken,
  });

  User.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null && json['location'] is Map<String, dynamic>
        ? Location.fromJson(Map<String, dynamic>.from(json['location']))
        : null;
    sId = json['_id'] as String?;
    name = json['name'] as String?;
    email = json['email'] as String?;
    phoneNumber = json['phoneNumber'];
    role = json['role'] as String?;
    avatar = json['avatar'] as String?;
    createdAt = json['createdAt'] as String?;
    adminStatus = json['adminStatus'] as String?;
    adminPermissions = json['adminPermissions'] as String?;
    isActiveAdmin = json['isActiveAdmin'] as bool?;
    if (json['addresses'] != null && json['addresses'] is List) {
      addresses = List<dynamic>.from(json['addresses']);
    }
    iV = json['__v'] is int ? json['__v'] as int : null;
    resetPasswordTime = json['resetPasswordTime'] as String?;
    resetPasswordToken = json['resetPasswordToken'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
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
    data['resetPasswordTime'] = resetPasswordTime;
    data['resetPasswordToken'] = resetPasswordToken;
    return data;
  }
}

class Location {
  String? type;
  List<num>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String?;
    if (json['coordinates'] != null && json['coordinates'] is List) {
      coordinates = (json['coordinates'] as List)
          .map((e) => (e is num) ? e : 0)
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

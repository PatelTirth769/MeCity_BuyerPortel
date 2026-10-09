class UpdateUserAddressesResponse {
  bool? success;
  User? user;

  UpdateUserAddressesResponse({this.success, this.user});

  UpdateUserAddressesResponse.fromJson(Map<String, dynamic> json) {
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
typedef update_user_addresses = UpdateUserAddressesResponse;

class User {
  Location? location;
  String? sId;
  String? name;
  String? email;
  String? role;
  String? avatar;
  String? createdAt;
  String? adminStatus;
  String? adminPermissions;
  bool? isActiveAdmin;
  List<Addresses>? addresses;
  int? iV;
  dynamic phoneNumber;

  User({
    this.location,
    this.sId,
    this.name,
    this.email,
    this.role,
    this.avatar,
    this.createdAt,
    this.adminStatus,
    this.adminPermissions,
    this.isActiveAdmin,
    this.addresses,
    this.iV,
    this.phoneNumber,
  });

  User.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null && json['location'] is Map<String, dynamic>
        ? Location.fromJson(Map<String, dynamic>.from(json['location']))
        : null;
    sId = json['_id'] as String?;
    name = json['name'] as String?;
    email = json['email'] as String?;
    role = json['role'] as String?;
    avatar = json['avatar'] as String?;
    createdAt = json['createdAt'] as String?;
    adminStatus = json['adminStatus'] as String?;
    adminPermissions = json['adminPermissions'] as String?;
    isActiveAdmin = json['isActiveAdmin'] as bool?;
    if (json['addresses'] != null && json['addresses'] is List) {
      addresses = <Addresses>[];
      json['addresses'].forEach((v) {
        if (v != null) {
          addresses!.add(Addresses.fromJson(Map<String, dynamic>.from(v)));
        }
      });
    }
    iV = json['__v'] is int ? json['__v'] as int : null;
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['role'] = role;
    data['avatar'] = avatar;
    data['createdAt'] = createdAt;
    data['adminStatus'] = adminStatus;
    data['adminPermissions'] = adminPermissions;
    data['isActiveAdmin'] = isActiveAdmin;
    if (addresses != null) {
      data['addresses'] = addresses!.map((v) => v.toJson()).toList();
    }
    data['__v'] = iV;
    data['phoneNumber'] = phoneNumber;
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String?;
    if (json['coordinates'] != null && json['coordinates'] is List) {
      coordinates = (json['coordinates'] as List)
          .map((e) => (e is num) ? e.toDouble() : 0.0)
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

class Addresses {
  String? country;
  String? city;
  String? address1;
  String? address2;
  dynamic zipCode;
  String? addressType;
  String? sId;

  Addresses({
    this.country,
    this.city,
    this.address1,
    this.address2,
    this.zipCode,
    this.addressType,
    this.sId,
  });

  Addresses.fromJson(Map<String, dynamic> json) {
    country = json['country'] as String?;
    city = json['city'] as String?;
    address1 = json['address1'] as String?;
    address2 = json['address2'] as String?;
    zipCode = json['zipCode'];
    addressType = json['addressType'] as String?;
    sId = json['_id'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country'] = country;
    data['city'] = city;
    data['address1'] = address1;
    data['address2'] = address2;
    data['zipCode'] = zipCode;
    data['addressType'] = addressType;
    data['_id'] = sId;
    return data;
  }
}

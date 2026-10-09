class CreateOrderResponse {
  bool? success;
  List<Orders>? orders;

  CreateOrderResponse({this.success, this.orders});

  CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(Map<String, dynamic>.from(v)));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef create_order = CreateOrderResponse;

class Orders {
  List<CartItemOrder>? cart;
  ShippingAddress? shippingAddress;
  OrderUser? user;
  num? totalPrice;
  String? status;
  PaymentInfo? paymentInfo;
  String? paidAt;
  String? createdAt;
  String? sId;
  int? iV;

  Orders({
    this.cart,
    this.shippingAddress,
    this.user,
    this.totalPrice,
    this.status,
    this.paymentInfo,
    this.paidAt,
    this.createdAt,
    this.sId,
    this.iV,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    if (json['cart'] != null) {
      cart = <CartItemOrder>[];
      json['cart'].forEach((v) {
        cart!.add(CartItemOrder.fromJson(Map<String, dynamic>.from(v)));
      });
    }
    shippingAddress = json['shippingAddress'] != null
        ? ShippingAddress.fromJson(Map<String, dynamic>.from(json['shippingAddress']))
        : null;
    user = json['user'] != null ? OrderUser.fromJson(Map<String, dynamic>.from(json['user'])) : null;
    totalPrice = json['totalPrice'];
    status = json['status'];
    paymentInfo = json['paymentInfo'] != null
        ? PaymentInfo.fromJson(Map<String, dynamic>.from(json['paymentInfo']))
        : null;
    paidAt = json['paidAt'];
    createdAt = json['createdAt'];
    sId = json['_id'];
    iV = json['__v'] is int ? json['__v'] : (json['__v'] != null ? int.tryParse(json['__v'].toString()) : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cart != null) {
      data['cart'] = cart!.map((v) => v.toJson()).toList();
    }
    if (shippingAddress != null) {
      data['shippingAddress'] = shippingAddress!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['totalPrice'] = totalPrice;
    data['status'] = status;
    if (paymentInfo != null) {
      data['paymentInfo'] = paymentInfo!.toJson();
    }
    data['paidAt'] = paidAt;
    data['createdAt'] = createdAt;
    data['_id'] = sId;
    data['__v'] = iV;
    return data;
  }
}

class CartItemOrder {
  String? sId;
  String? name;
  int? qty;
  num? discountPrice;
  String? shopId;
  List<String>? images;

  CartItemOrder({
    this.sId,
    this.name,
    this.qty,
    this.discountPrice,
    this.shopId,
    this.images,
  });

  CartItemOrder.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    qty = json['qty'] is int ? json['qty'] : (json['qty'] != null ? int.tryParse(json['qty'].toString()) : null);
    discountPrice = json['discountPrice'];
    shopId = json['shopId'];
    if (json['images'] != null) {
      images = List<String>.from(json['images'].map((x) => x.toString()));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['qty'] = qty;
    data['discountPrice'] = discountPrice;
    data['shopId'] = shopId;
    data['images'] = images;
    return data;
  }
}

// Typedef for Cart in Orders
// ignore: camel_case_types
typedef Cart = CartItemOrder;

class ShippingAddress {
  String? address1;
  String? city;
  dynamic zipCode;
  String? country;

  ShippingAddress({this.address1, this.city, this.zipCode, this.country});

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    address1 = json['address1'];
    city = json['city'];
    zipCode = json['zipCode'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address1'] = address1;
    data['city'] = city;
    data['zipCode'] = zipCode;
    data['country'] = country;
    return data;
  }
}

class OrderUser {
  String? sId;
  String? name;
  String? email;
  dynamic phoneNumber;

  OrderUser({this.sId, this.name, this.email, this.phoneNumber});

  OrderUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    return data;
  }
}

// Typedef for User in Orders
// ignore: camel_case_types
typedef User = OrderUser;

class PaymentInfo {
  String? id;
  String? status;
  String? type;

  PaymentInfo({this.id, this.status, this.type});

  PaymentInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['type'] = type;
    return data;
  }
}

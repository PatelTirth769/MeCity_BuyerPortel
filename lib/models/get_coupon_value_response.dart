class GetCouponValueResponse {
  bool? success;
  CouponCode? couponCode;
  String? message;

  GetCouponValueResponse({this.success, this.couponCode, this.message});

  GetCouponValueResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    message = json['message'] as String?;
    if (json['couponCode'] != null && json['couponCode'] is Map<String, dynamic>) {
      couponCode = CouponCode.fromJson(Map<String, dynamic>.from(json['couponCode']));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (couponCode != null) {
      data['couponCode'] = couponCode!.toJson();
    }
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef get_coupon_value = GetCouponValueResponse;

class CouponCode {
  String? sId;
  String? name;
  num? value;
  num? minAmount;
  num? maxAmount;
  String? shopId;
  String? selectedProduct;
  String? createdAt;
  int? iV;

  CouponCode({
    this.sId,
    this.name,
    this.value,
    this.minAmount,
    this.maxAmount,
    this.shopId,
    this.selectedProduct,
    this.createdAt,
    this.iV,
  });

  CouponCode.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] as String?;
    name = json['name'] as String?;
    value = json['value'] is num ? json['value'] as num : (json['value'] != null ? num.tryParse(json['value'].toString()) : null);
    minAmount = json['minAmount'] is num ? json['minAmount'] as num : (json['minAmount'] != null ? num.tryParse(json['minAmount'].toString()) : null);
    maxAmount = json['maxAmount'] is num ? json['maxAmount'] as num : (json['maxAmount'] != null ? num.tryParse(json['maxAmount'].toString()) : null);
    shopId = json['shopId'] as String?;
    selectedProduct = json['selectedProduct'] as String?;
    createdAt = json['createdAt'] as String?;
    iV = json['__v'] is int ? json['__v'] as int : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['value'] = value;
    data['minAmount'] = minAmount;
    data['maxAmount'] = maxAmount;
    data['shopId'] = shopId;
    data['selectedProduct'] = selectedProduct;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}

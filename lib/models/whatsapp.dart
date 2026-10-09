// ignore_for_file: camel_case_types

class whatsapp {
  bool? success;
  String? message;
  String? whatsappUrl;
  String? whatsappAppUrl;
  InquiryData? inquiryData;

  whatsapp({
    this.success,
    this.message,
    this.whatsappUrl,
    this.whatsappAppUrl,
    this.inquiryData,
  });

  whatsapp.fromJson(Map<String, dynamic> json) {
    success = json['success'] is bool ? json['success'] as bool : (json['success']?.toString() == 'true');
    message = json['message']?.toString();
    whatsappUrl = json['whatsappUrl']?.toString();
    whatsappAppUrl = json['whatsappAppUrl']?.toString();
    inquiryData = json['inquiryData'] != null && json['inquiryData'] is Map
        ? InquiryData.fromJson(Map<String, dynamic>.from(json['inquiryData']))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['whatsappUrl'] = whatsappUrl;
    data['whatsappAppUrl'] = whatsappAppUrl;
    if (inquiryData != null) {
      data['inquiryData'] = inquiryData!.toJson();
    }
    return data;
  }
}

typedef WhatsAppResponse = whatsapp;
typedef WhatsAppProductInquiryResponse = whatsapp;

class InquiryData {
  String? sellerPhoneNumber;
  String? buyerPhoneNumber;
  String? buyerName;
  String? productId;
  String? productName;
  int? productPrice;
  int? originalPrice;
  String? productUrl;
  String? shopId;
  String? shopName;
  String? messageText;

  InquiryData({
    this.sellerPhoneNumber,
    this.buyerPhoneNumber,
    this.buyerName,
    this.productId,
    this.productName,
    this.productPrice,
    this.originalPrice,
    this.productUrl,
    this.shopId,
    this.shopName,
    this.messageText,
  });

  InquiryData.fromJson(Map<String, dynamic> json) {
    sellerPhoneNumber = json['sellerPhoneNumber']?.toString();
    buyerPhoneNumber = json['buyerPhoneNumber']?.toString();
    buyerName = json['buyerName']?.toString();
    productId = json['productId']?.toString();
    productName = json['productName']?.toString();
    if (json['productPrice'] != null) {
      if (json['productPrice'] is num) {
        productPrice = (json['productPrice'] as num).toInt();
      } else {
        productPrice = int.tryParse(json['productPrice'].toString());
      }
    }
    if (json['originalPrice'] != null) {
      if (json['originalPrice'] is num) {
        originalPrice = (json['originalPrice'] as num).toInt();
      } else {
        originalPrice = int.tryParse(json['originalPrice'].toString());
      }
    }
    productUrl = json['productUrl']?.toString();
    shopId = json['shopId']?.toString();
    shopName = json['shopName']?.toString();
    messageText = json['messageText']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sellerPhoneNumber'] = sellerPhoneNumber;
    data['buyerPhoneNumber'] = buyerPhoneNumber;
    data['buyerName'] = buyerName;
    data['productId'] = productId;
    data['productName'] = productName;
    data['productPrice'] = productPrice;
    data['originalPrice'] = originalPrice;
    data['productUrl'] = productUrl;
    data['shopId'] = shopId;
    data['shopName'] = shopName;
    data['messageText'] = messageText;
    return data;
  }
}

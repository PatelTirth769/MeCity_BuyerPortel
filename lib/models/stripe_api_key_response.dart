class StripeApiKeyResponse {
  String? stripeApikey;

  StripeApiKeyResponse({this.stripeApikey});

  StripeApiKeyResponse.fromJson(Map<String, dynamic> json) {
    stripeApikey = json['stripeApikey'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stripeApikey'] = stripeApikey;
    return data;
  }
}

// Typedef matching user naming
// ignore: camel_case_types
typedef stripeapikey = StripeApiKeyResponse;

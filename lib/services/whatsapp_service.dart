import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mecity_marketplace/models/whatsapp.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';
import 'package:mecity_marketplace/core/network/api_exceptions.dart';

class WhatsAppService {
  final ApiClient _apiClient;

  WhatsAppService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Call WhatsApp Product Inquiry API to get the WhatsApp direct chat link
  Future<whatsapp> createProductInquiry({
    required dynamic sellerPhoneNumber,
    dynamic buyerPhoneNumber,
    dynamic buyerName,
    dynamic productId,
    dynamic productName,
    dynamic productPrice,
    dynamic originalPrice,
    dynamic productUrl,
    dynamic shopId,
    dynamic shopName,
    dynamic message,
  }) async {
    try {
      final sPhone = sellerPhoneNumber?.toString().trim() ?? '';
      final bPhone = buyerPhoneNumber?.toString().trim();
      final bName = buyerName?.toString().trim();
      final pId = productId?.toString().trim();
      final pName = productName?.toString().trim();
      final pUrl = productUrl?.toString().trim();
      final sId = shopId?.toString().trim();
      final sName = shopName?.toString().trim();
      final msg = message?.toString().trim();

      int? pPrice;
      if (productPrice != null) {
        if (productPrice is num) {
          pPrice = productPrice.toInt();
        } else {
          pPrice = int.tryParse(productPrice.toString());
        }
      }

      int? origPrice;
      if (originalPrice != null) {
        if (originalPrice is num) {
          origPrice = originalPrice.toInt();
        } else {
          origPrice = int.tryParse(originalPrice.toString());
        }
      }

      final Map<String, dynamic> body = {
        'sellerPhoneNumber': sPhone,
      };
      if (bPhone != null && bPhone.isNotEmpty) {
        body['buyerPhoneNumber'] = bPhone;
      }
      if (bName != null && bName.isNotEmpty) {
        body['buyerName'] = bName;
      }
      if (pId != null && pId.isNotEmpty) {
        body['productId'] = pId;
      }
      if (pName != null && pName.isNotEmpty) {
        body['productName'] = pName;
      }
      if (pPrice != null) {
        body['productPrice'] = pPrice;
      }
      if (origPrice != null) {
        body['originalPrice'] = origPrice;
      }
      if (pUrl != null && pUrl.isNotEmpty) {
        body['productUrl'] = pUrl;
      }
      if (sId != null && sId.isNotEmpty) {
        body['shopId'] = sId;
      }
      if (sName != null && sName.isNotEmpty) {
        body['shopName'] = sName;
      }
      if (msg != null && msg.isNotEmpty) {
        body['message'] = msg;
      }

      final responseJson = await _apiClient.post(
        ApiEndpoints.whatsappProductInquiry,
        body: body,
      );

      if (responseJson is Map<String, dynamic>) {
        return whatsapp.fromJson(responseJson);
      } else {
        return whatsapp(
          success: false,
          message: 'Invalid response received from WhatsApp API',
        );
      }
    } on ApiException catch (e) {
      return whatsapp(
        success: false,
        message: e.message,
      );
    } catch (e) {
      return whatsapp(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Launch the generated WhatsApp URL in the browser or native WhatsApp App
  Future<bool> launchWhatsAppUrl(String urlString, {String? appUrlString}) async {
    try {
      // 1. On mobile devices, try native WhatsApp scheme first if provided
      if (appUrlString != null && appUrlString.isNotEmpty) {
        final Uri appUri = Uri.parse(appUrlString);
        try {
          final launched = await launchUrl(appUri, mode: LaunchMode.externalNonBrowserApplication);
          if (launched) return true;
        } catch (_) {}
      }

      // 2. Try launching https://wa.me/... in external application
      final Uri uri = Uri.parse(urlString);
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return true;
      } catch (_) {}

      // 3. Fallback to platform default browser
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Error launching WhatsApp URL: $e');
      try {
        final Uri uri = Uri.parse(urlString);
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (err) {
        debugPrint('Fallback launch error: $err');
        return false;
      }
    }
  }

  /// Helper method: Clean phone number with 91 country code prefix if needed
  String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 10) {
      cleaned = '91$cleaned';
    }
    return cleaned;
  }

  /// High level helper: Inquire about a product and immediately open WhatsApp
  Future<whatsapp> inquireAndOpenWhatsApp({
    required dynamic sellerPhoneNumber,
    dynamic buyerPhoneNumber,
    dynamic buyerName,
    dynamic productId,
    dynamic productName,
    dynamic productPrice,
    dynamic originalPrice,
    dynamic productUrl,
    dynamic shopId,
    dynamic shopName,
    dynamic customMessage,
  }) async {
    final sPhone = sellerPhoneNumber?.toString().trim() ?? '';
    final bPhone = buyerPhoneNumber?.toString().trim();
    final bName = buyerName?.toString().trim();
    final pId = productId?.toString().trim();
    final pName = productName?.toString().trim();
    final pUrl = productUrl?.toString().trim();
    final sId = shopId?.toString().trim();
    final sName = shopName?.toString().trim();
    final cMsg = customMessage?.toString().trim();

    // 1. Build standard WhatsApp direct links with full prefilled product information
    final formattedPhone = formatPhoneNumber(sPhone.isNotEmpty ? sPhone : '9876543210');
    final defaultText = (cMsg != null && cMsg.isNotEmpty)
        ? cMsg
        : 'Hello ${sName ?? "Seller"}, I am interested in your product "${pName ?? "Product"}" (Price: ₹${productPrice ?? ""}) on Mecity.\nProduct Link: ${pUrl ?? "https://marketplace.mecity.in/product/$pId"}\n\nIs this product currently available?';
    final encoded = Uri.encodeComponent(defaultText);
    final fallbackUrl = 'https://wa.me/$formattedPhone?text=$encoded';
    final fallbackAppUrl = 'whatsapp://send?phone=$formattedPhone&text=$encoded';

    String targetUrl = fallbackUrl;
    String targetAppUrl = fallbackAppUrl;

    // 2. Try calling backend API if available to generate customized server-side tracking link
    try {
      final apiResponse = await createProductInquiry(
        sellerPhoneNumber: sPhone,
        buyerPhoneNumber: bPhone,
        buyerName: bName,
        productId: pId,
        productName: pName,
        productPrice: productPrice,
        originalPrice: originalPrice,
        productUrl: pUrl,
        shopId: sId,
        shopName: sName,
        message: cMsg,
      );

      if (apiResponse.success == true && apiResponse.whatsappUrl != null && apiResponse.whatsappUrl!.isNotEmpty) {
        targetUrl = apiResponse.whatsappUrl!;
        if (apiResponse.whatsappAppUrl != null && apiResponse.whatsappAppUrl!.isNotEmpty) {
          targetAppUrl = apiResponse.whatsappAppUrl!;
        }
      }
    } catch (e) {
      debugPrint('WhatsApp API Note (using direct link): $e');
    }

    // 3. Launch WhatsApp directly
    final launched = await launchWhatsAppUrl(targetUrl, appUrlString: targetAppUrl);

    if (launched) {
      return whatsapp(
        success: true,
        message: 'Opening WhatsApp chat...',
        whatsappUrl: targetUrl,
        whatsappAppUrl: targetAppUrl,
      );
    } else {
      return whatsapp(
        success: false,
        message: 'Could not open WhatsApp. Please ensure WhatsApp is installed.',
      );
    }
  }
}

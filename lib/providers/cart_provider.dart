import 'package:flutter/material.dart';
import 'package:mecity_marketplace/models/cart.dart';
import 'package:mecity_marketplace/models/product.dart';
import 'package:mecity_marketplace/services/coupon_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  String? _appliedCoupon;
  double _couponDiscountPercent = 0.0;

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get shippingFee => subtotal > 2000 || _items.isEmpty ? 0.0 : 99.0;

  double get discountAmount => (subtotal * (_couponDiscountPercent / 100));

  double get totalAmount => (subtotal + shippingFee - discountAmount);

  String? get appliedCoupon => _appliedCoupon;

  void addToCart(Product product, {int quantity = 1, String color = 'Default', String size = 'Standard'}) {
    final existingIndex = _items.indexWhere((item) =>
        item.product.id == product.id &&
        item.selectedColor == color &&
        item.selectedSize == size);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        selectedColor: color,
        selectedSize: size,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      _items.remove(item);
    } else {
      item.quantity = quantity;
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  Future<bool> applyCouponApi(String code) async {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) return false;

    try {
      final response = await CouponService().getCouponValue(cleanCode);
      if (response.success == true && response.couponCode != null) {
        final coupon = response.couponCode!;
        final val = (coupon.value ?? 0).toDouble();
        _appliedCoupon = '${coupon.name ?? cleanCode} (${val.toStringAsFixed(0)}% OFF)';
        _couponDiscountPercent = val;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    // Fallback to local codes
    final upper = cleanCode.toUpperCase();
    if (upper == 'MECITY10') {
      _appliedCoupon = 'MECITY10 (10% OFF)';
      _couponDiscountPercent = 10.0;
      notifyListeners();
      return true;
    } else if (upper == 'FLASH20') {
      _appliedCoupon = 'FLASH20 (20% OFF)';
      _couponDiscountPercent = 20.0;
      notifyListeners();
      return true;
    }

    return false;
  }

  bool applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'MECITY10') {
      _appliedCoupon = 'MECITY10 (10% OFF)';
      _couponDiscountPercent = 10.0;
      notifyListeners();
      return true;
    } else if (cleanCode == 'FLASH20') {
      _appliedCoupon = 'FLASH20 (20% OFF)';
      _couponDiscountPercent = 20.0;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _couponDiscountPercent = 0.0;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCoupon = null;
    _couponDiscountPercent = 0.0;
    notifyListeners();
  }
}

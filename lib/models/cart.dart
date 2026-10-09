import 'package:mecity_marketplace/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  String selectedColor;
  String selectedSize;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedColor = 'Default',
    this.selectedSize = 'Standard',
  });

  double get totalPrice => product.discountPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(Map<String, dynamic>.from(map['product'])),
      quantity: map['quantity'] ?? 1,
      selectedColor: map['selectedColor'] ?? 'Default',
      selectedSize: map['selectedSize'] ?? 'Standard',
    );
  }
}

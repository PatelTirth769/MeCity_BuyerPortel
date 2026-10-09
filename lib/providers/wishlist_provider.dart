import 'package:flutter/material.dart';
import 'package:mecity_marketplace/models/product.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Product> _wishlist = [];

  List<Product> get wishlist => _wishlist;

  int get count => _wishlist.length;

  bool isFavorite(String productId) {
    return _wishlist.any((p) => p.id == productId);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product.id)) {
      _wishlist.removeWhere((p) => p.id == product.id);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  void clearWishlist() {
    _wishlist.clear();
    notifyListeners();
  }
}

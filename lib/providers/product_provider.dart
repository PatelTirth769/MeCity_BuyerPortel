import 'package:flutter/material.dart';
import 'package:mecity_marketplace/models/product.dart';
import 'package:mecity_marketplace/data/mock_data.dart';
import 'package:mecity_marketplace/services/product_service.dart';
import 'package:mecity_marketplace/services/firebase_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = List<Product>.from(MockData.products);
  final ProductService _productService = ProductService();

  bool _isLoadingApi = false;
  String? _apiError;

  String _selectedCategory = 'All';
  String? _selectedSubCategory;
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 200000);
  double _minRating = 0.0;
  String _sortBy = 'Popularity';

  ProductProvider() {
    fetchProductsFromApi();
  }

  bool get isLoadingApi => _isLoadingApi;
  String? get apiError => _apiError;

  Future<void> fetchProductsFromApi() async {
    _isLoadingApi = true;
    _apiError = null;
    notifyListeners();

    try {
      final apiProducts = await _productService.getAllProducts();
      if (apiProducts.isNotEmpty) {
        _products = apiProducts;

        // ===== Console Log: Print Fetched Products Summary =====
        debugPrint('═══════════════════════════════════════════');
        debugPrint('📦 ALL PRODUCTS FETCHED FROM API SUCCESSFULLY');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('Total Products Fetched: ${_products.length}');
        for (int i = 0; i < _products.length; i++) {
          final p = _products[i];
          debugPrint('[${i + 1}] ${p.name} | Category: ${p.category} | SubCategory: ${p.subcategory} | Price: ₹${p.discountPrice} | Stock: ${p.stock} | ID: ${p.id}');
        }
        debugPrint('═══════════════════════════════════════════');
      }
    } on ProductServiceException catch (e) {
      _apiError = e.message;
      debugPrint('⚠️ Product API Note: ${e.message}');
    } catch (e) {
      _apiError = e.toString();
      debugPrint('⚠️ Product API Note: ${e.toString()}');
    } finally {
      _isLoadingApi = false;
      notifyListeners();
    }
  }

  List<Product> get products => _products;
  String get selectedCategory => _selectedCategory;
  String? get selectedSubCategory => _selectedSubCategory;
  String get searchQuery => _searchQuery;
  RangeValues get priceRange => _priceRange;
  double get minRating => _minRating;
  String get sortBy => _sortBy;

  static String _normalize(String s) {
    return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  List<Product> get filteredProducts {
    final normCategory = _normalize(_selectedCategory);
    final normSubCategory = _selectedSubCategory != null ? _normalize(_selectedSubCategory!) : '';
    final normSearch = _searchQuery.trim().toLowerCase();

    return _products.where((product) {
      final productCatNorm = _normalize(product.category);
      final matchesCategory = normSearch.isNotEmpty ||
          _selectedCategory == 'All' ||
          normCategory.isEmpty ||
          productCatNorm == normCategory ||
          productCatNorm.contains(normCategory) ||
          normCategory.contains(productCatNorm) ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();

      final productSubNorm = _normalize(product.subcategory);
      final matchesSubCategory = normSearch.isNotEmpty ||
          _selectedSubCategory == null ||
          _selectedSubCategory == 'All' ||
          normSubCategory.isEmpty ||
          productSubNorm == normSubCategory ||
          productSubNorm.contains(normSubCategory) ||
          normSubCategory.contains(productSubNorm) ||
          product.subcategory.toLowerCase() == _selectedSubCategory!.toLowerCase();

      final matchesSearch = normSearch.isEmpty ||
          product.name.toLowerCase().contains(normSearch) ||
          product.description.toLowerCase().contains(normSearch) ||
          product.category.toLowerCase().contains(normSearch) ||
          product.subcategory.toLowerCase().contains(normSearch) ||
          product.tags.any((t) => t.toLowerCase().contains(normSearch)) ||
          product.shopName.toLowerCase().contains(normSearch);

      final matchesPrice = product.discountPrice >= _priceRange.start && product.discountPrice <= _priceRange.end;
      final matchesRating = _minRating == 0.0 || product.rating >= _minRating;

      return matchesCategory && matchesSubCategory && matchesSearch && matchesPrice && matchesRating;
    }).toList()..sort((a, b) {
      if (_sortBy == 'Price: Low to High') return a.discountPrice.compareTo(b.discountPrice);
      if (_sortBy == 'Price: High to Low') return b.discountPrice.compareTo(a.discountPrice);
      if (_sortBy == 'Top Rated') return b.rating.compareTo(a.rating);
      return b.reviewsCount.compareTo(a.reviewsCount);
    });
  }

  List<Product> get bestDeals {
    final deals = _products.where((p) => p.isBestSeller || p.discountPercent > 0).toList();
    if (deals.isNotEmpty) return deals;
    return _products.take(6).toList();
  }

  List<Product> get featuredProducts {
    final featured = _products.where((p) => p.isFeatured).toList();
    if (featured.isNotEmpty) return featured;
    return _products.take(10).toList();
  }


  void selectCategory(String category) {
    _selectedCategory = category;
    _selectedSubCategory = null; // Reset subcategory when category changes
    notifyListeners();
  }

  void selectSubCategory(String? subCategory) {
    _selectedSubCategory = subCategory;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void setMinRating(double rating) {
    _minRating = rating;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _selectedSubCategory = null;
    _searchQuery = '';
    _priceRange = const RangeValues(0, 200000);
    _minRating = 0.0;
    _sortBy = 'Popularity';
    notifyListeners();
  }

  Future<void> addReview(String productId, Review review) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final p = _products[index];
      final updatedReviews = List<Review>.from(p.reviews)..insert(0, review);
      final newRating = ((p.rating * p.reviewsCount) + review.rating) / (p.reviewsCount + 1);
      _products[index] = Product(
        id: p.id,
        name: p.name,
        description: p.description,
        category: p.category,
        subcategory: p.subcategory,
        originalPrice: p.originalPrice,
        discountPrice: p.discountPrice,
        stock: p.stock,
        images: p.images,
        shopId: p.shopId,
        shopName: p.shopName,
        shopLogo: p.shopLogo,
        rating: double.parse(newRating.toStringAsFixed(1)),
        reviewsCount: p.reviewsCount + 1,
        reviews: updatedReviews,
        tags: p.tags,
        isFeatured: p.isFeatured,
        isBestSeller: p.isBestSeller,
        isEventProduct: p.isEventProduct,
        colors: p.colors,
        sizes: p.sizes,
      );
      notifyListeners();
    }

    try {
      await FirebaseService.addReview(productId, review);
    } catch (e) {
      // Offline fallback
    }
  }

  Future<void> addProduct(Product product) async {
    _products.insert(0, product);
    notifyListeners();

    try {
      await FirebaseService.addProduct(product);
    } catch (e) {
      // Offline fallback
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
}

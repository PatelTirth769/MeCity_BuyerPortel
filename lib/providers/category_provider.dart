import 'package:flutter/foundation.dart';
import 'package:mecity_marketplace/data/mock_data.dart';
import 'package:mecity_marketplace/models/category.dart';
import 'package:mecity_marketplace/models/sub_category.dart';
import 'package:mecity_marketplace/services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];
  bool _isLoading = false;
  bool _hasFetched = false;

  List<CategoryModel> get categories => _categories;
  List<SubCategoryModel> get subCategories => _subCategories;
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;

  CategoryProvider() {
    fetchCategoriesFromApi();
  }

  /// Get subcategories for a specific category ID
  List<SubCategoryModel> getSubCategoriesByCategoryId(String categoryId) {
    return _subCategories.where((sub) => sub.categoryId == categoryId).toList();
  }

  /// Fetch all categories and subcategories from the Mecity API.
  /// Falls back to [MockData.categories] if the API returns nothing or fails.
  Future<void> fetchCategoriesFromApi() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _categoryService.getAllCategories(),
        _categoryService.getAllSubCategories(),
      ]);

      final List<CategoryModel> apiCategories = results[0] as List<CategoryModel>;
      final List<SubCategoryModel> apiSubCategories = results[1] as List<SubCategoryModel>;

      if (apiCategories.isNotEmpty) {
        _categories = apiCategories;
        _subCategories = apiSubCategories;

        // ===== Console Log: Print all fetched category details =====
        debugPrint('');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('🗂️  ALL CATEGORIES FETCHED FROM API SUCCESSFULLY');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('   Total Categories    : ${_categories.length}');
        debugPrint('   Total SubCategories : ${_subCategories.length}');
        debugPrint('');
      } else {
        // API returned empty — use mock data as fallback
        _categories = MockData.categories;
        _subCategories = [];
        debugPrint('');
        debugPrint('⚠️  Categories API returned empty. Using mock categories as fallback.');
      }
    } catch (e) {
      _categories = MockData.categories;
      _subCategories = [];
      debugPrint('');
      debugPrint('❌  Category fetch error: $e');
      debugPrint('   Falling back to ${_categories.length} mock categories.');
    }

    _isLoading = false;
    _hasFetched = true;
    notifyListeners();
  }
}

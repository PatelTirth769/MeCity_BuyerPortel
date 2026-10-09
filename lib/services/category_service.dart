import 'package:flutter/foundation.dart';
import 'package:mecity_marketplace/models/category.dart';
import 'package:mecity_marketplace/models/sub_category.dart';
import 'package:mecity_marketplace/models/get_all_categories_response.dart';
import 'package:mecity_marketplace/models/get_all_subcategories_response.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<GetAllCategoriesResponse> getAllCategoriesApi() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getAllCategories);
      return GetAllCategoriesResponse.fromJson(responseJson);
    } catch (e) {
      return GetAllCategoriesResponse(success: false);
    }
  }

  Future<GetAllSubCategoriesResponse> getAllSubCategoriesApi() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getAllSubCategories);
      return GetAllSubCategoriesResponse.fromJson(responseJson);
    } catch (e) {
      return GetAllSubCategoriesResponse(success: false);
    }
  }

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getAllCategories);

      List<dynamic> rawList = [];
      if (responseJson is Map<String, dynamic>) {
        if (responseJson.containsKey('categories')) {
          rawList = responseJson['categories'] as List<dynamic>;
        } else if (responseJson.containsKey('data')) {
          rawList = responseJson['data'] as List<dynamic>;
        }
      } else if (responseJson is List) {
        rawList = responseJson;
      }

      final List<CategoryModel> categories = rawList
          .map((item) =>
              CategoryModel.fromApiJson(item as Map<String, dynamic>))
          .toList();

      return categories;
    } catch (e) {
      debugPrint('❌ Categories API error: $e. Using mock data as fallback.');
      return [];
    }
  }

  Future<List<SubCategoryModel>> getAllSubCategories() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getAllSubCategories);

      List<dynamic> rawList = [];
      if (responseJson is Map<String, dynamic>) {
        if (responseJson.containsKey('subCategories')) {
          rawList = responseJson['subCategories'] as List<dynamic>;
        } else if (responseJson.containsKey('data')) {
          rawList = responseJson['data'] as List<dynamic>;
        }
      } else if (responseJson is List) {
        rawList = responseJson;
      }

      final List<SubCategoryModel> subCategories = rawList
          .map((item) =>
              SubCategoryModel.fromApiJson(item as Map<String, dynamic>))
          .toList();

      return subCategories;
    } catch (e) {
      debugPrint('❌ SubCategories API error: $e.');
      return [];
    }
  }
}

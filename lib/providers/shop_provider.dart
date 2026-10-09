import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mecity_marketplace/models/shop.dart';
import 'package:mecity_marketplace/models/get_shops_near_me_response.dart';
import 'package:mecity_marketplace/models/get_shop_info_response.dart';
import 'package:mecity_marketplace/data/mock_data.dart';
import 'package:mecity_marketplace/services/firebase_service.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';
import 'package:mecity_marketplace/core/constants/api_endpoints.dart';

class ShopProvider extends ChangeNotifier {
  List<ShopModel> _shops = List.from(MockData.shops);
  String _searchQuery = '';
  ShopModel? _activeSellerShop;
  StreamSubscription<List<ShopModel>>? _shopsSubscription;
  
  bool _isLoading = false;
  final ApiClient _apiClient = ApiClient();

  bool get isLoading => _isLoading;

  ShopProvider() {
    fetchShopsFromApi();
    _initFirestoreStream();
  }

  Future<void> fetchShopsFromApi() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getAllShops);
      
      List<dynamic> rawList = [];
      if (responseJson is Map<String, dynamic>) {
        if (responseJson.containsKey('shops')) {
          rawList = responseJson['shops'] as List<dynamic>;
        } else if (responseJson.containsKey('data')) {
          rawList = responseJson['data'] as List<dynamic>;
        }
      } else if (responseJson is List) {
        rawList = responseJson;
      }

      if (rawList.isNotEmpty) {
        _shops = rawList.map((item) => ShopModel.fromApiJson(item as Map<String, dynamic>)).toList();
        
        if (_activeSellerShop == null && _shops.isNotEmpty) {
          _activeSellerShop = _shops.first;
        }

        debugPrint('✅ Fetched ${_shops.length} shops from API successfully.');
      } else {
        debugPrint('⚠️ Shops API returned empty. Using mock data as fallback.');
        _shops = MockData.shops;
      }
    } catch (e) {
      debugPrint('❌ Error fetching shops from API: $e. Using mock data as fallback.');
      _shops = MockData.shops;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<GetShopsNearMeResponse> getShopsNearMeApi() async {
    try {
      final responseJson = await _apiClient.get(ApiEndpoints.getShopsNearMe);
      return GetShopsNearMeResponse.fromJson(responseJson);
    } catch (e) {
      return GetShopsNearMeResponse(success: false, message: e.toString());
    }
  }

  Future<GetShopInfoResponse> getShopInfoApi(String shopId) async {
    try {
      final responseJson = await _apiClient.get('${ApiEndpoints.getShopInfo}/$shopId');
      return GetShopInfoResponse.fromJson(responseJson);
    } catch (e) {
      return GetShopInfoResponse(success: false, message: e.toString());
    }
  }

  void _initFirestoreStream() {
    try {
      _shopsSubscription = FirebaseService.getShopsStream().listen((firestoreShops) {
        if (firestoreShops.isNotEmpty && _shops.isEmpty) {
          _shops = firestoreShops;
          if (_activeSellerShop == null) {
            _activeSellerShop = _shops.first;
          } else {
            // Update active reference if present in stream
            final idx = _shops.indexWhere((s) => s.id == _activeSellerShop!.id);
            if (idx != -1) _activeSellerShop = _shops[idx];
          }
          notifyListeners();
        }
      }, onError: (e) {
        // Offline fallback
      });
    } catch (e) {
      // Offline fallback
    }
  }

  @override
  void dispose() {
    _shopsSubscription?.cancel();
    super.dispose();
  }

  List<ShopModel> get shops => _shops;
  String get searchQuery => _searchQuery;
  ShopModel? get activeSellerShop => _activeSellerShop ?? (_shops.isNotEmpty ? _shops.first : null);

  List<ShopModel> get filteredShops {
    if (_searchQuery.isEmpty) return _shops;
    return _shops.where((s) =>
        s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.address.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveSellerShop(ShopModel shop) {
    _activeSellerShop = shop;
    notifyListeners();
  }

  ShopModel? getShopById(String shopId) {
    return _shops.firstWhere(
      (s) => s.id == shopId,
      orElse: () => _shops[0],
    );
  }

  Future<void> createShop(ShopModel newShop) async {
    _shops.insert(0, newShop);
    _activeSellerShop = newShop;
    notifyListeners();

    try {
      await FirebaseService.createShop(newShop);
    } catch (e) {
      // Offline fallback
    }
  }

  Future<void> updateShop(ShopModel updatedShop) async {
    final idx = _shops.indexWhere((s) => s.id == updatedShop.id);
    if (idx != -1) {
      _shops[idx] = updatedShop;
      if (_activeSellerShop?.id == updatedShop.id) {
        _activeSellerShop = updatedShop;
      }
      notifyListeners();
    }

    try {
      await FirebaseService.updateShop(updatedShop);
    } catch (e) {
      // Offline fallback
    }
  }

  Future<void> toggleShopOnlineStatus(String shopId) async {
    final idx = _shops.indexWhere((s) => s.id == shopId);
    if (idx != -1) {
      final s = _shops[idx];
      final updated = ShopModel(
        id: s.id,
        name: s.name,
        email: s.email,
        logo: s.logo,
        banner: s.banner,
        address: s.address,
        phoneNumber: s.phoneNumber,
        description: s.description,
        category: s.category,
        ownerName: s.ownerName,
        gstin: s.gstin,
        payoutUpi: s.payoutUpi,
        operatingHours: s.operatingHours,
        rating: s.rating,
        reviewsCount: s.reviewsCount,
        totalProducts: s.totalProducts,
        isVerified: s.isVerified,
        isOnline: !s.isOnline,
        deliveryRadiusKm: s.deliveryRadiusKm,
        joinedDate: s.joinedDate,
      );
      _shops[idx] = updated;
      if (_activeSellerShop?.id == shopId) {
        _activeSellerShop = updated;
      }
      notifyListeners();

      try {
        await FirebaseService.updateShop(updated);
      } catch (e) {
        // Offline fallback
      }
    }
  }

  Future<void> verifyShop(String shopId) async {
    final index = _shops.indexWhere((s) => s.id == shopId);
    if (index != -1) {
      final s = _shops[index];
      final updated = ShopModel(
        id: s.id,
        name: s.name,
        email: s.email,
        logo: s.logo,
        banner: s.banner,
        address: s.address,
        phoneNumber: s.phoneNumber,
        description: s.description,
        category: s.category,
        ownerName: s.ownerName,
        gstin: s.gstin,
        payoutUpi: s.payoutUpi,
        operatingHours: s.operatingHours,
        rating: s.rating,
        reviewsCount: s.reviewsCount,
        totalProducts: s.totalProducts,
        isVerified: true,
        isOnline: s.isOnline,
        deliveryRadiusKm: s.deliveryRadiusKm,
        joinedDate: s.joinedDate,
      );
      _shops[index] = updated;
      if (_activeSellerShop?.id == shopId) {
        _activeSellerShop = updated;
      }
      notifyListeners();
    }

    try {
      await FirebaseService.verifyShop(shopId);
    } catch (e) {
      // Offline fallback
    }
  }

  void addShop(ShopModel shop) {
    createShop(shop);
  }
}

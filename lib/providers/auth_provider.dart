import 'package:flutter/material.dart';
import 'package:mecity_marketplace/models/user.dart';
import 'package:mecity_marketplace/models/login_response.dart';
import 'package:mecity_marketplace/models/create_user_request.dart';
import 'package:mecity_marketplace/data/mock_data.dart';

import 'package:mecity_marketplace/services/firebase_service.dart';
import 'package:mecity_marketplace/services/auth_service.dart';
import 'package:mecity_marketplace/services/storage_service.dart';
import 'package:mecity_marketplace/services/location_service.dart';
import 'package:mecity_marketplace/core/network/api_client.dart';

class AuthProvider extends ChangeNotifier {
  UserModel _user = MockData.currentUser;
  ApiUser? _apiUser;
  String? _token;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  AddressModel? _currentAddress;
  bool _isFetchingLocation = false;

  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  UserModel get user => _user;
  ApiUser? get apiUser => _apiUser;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserRole get currentRole => _user.role;
  bool get isFetchingLocation => _isFetchingLocation;

  AddressModel get currentAddress {
    if (_currentAddress != null) return _currentAddress!;
    if (_user.addresses.isNotEmpty) {
      return _user.addresses.firstWhere(
        (a) => a.addressType == 'Default' || a.addressType == 'Live GPS',
        orElse: () => _user.addresses.first,
      );
    }
    return AddressModel(
      id: 'gps_live',
      addressType: 'Live GPS',
      addressLine1: 'Detecting live address...',
      city: 'Gujarat',
      country: 'India',
      zipCode: '',
    );
  }

  AuthProvider() {
    initSession();
  }

  Future<void> initSession() async {
    try {
      final savedToken = await _storageService.getToken();
      final savedUser = await _storageService.getUser();

      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        ApiClient().setToken(savedToken);
        _apiUser = savedUser;
        _isLoggedIn = true;

        if (savedUser != null) {
          _mapApiUserToUserModel(savedUser);
        }
        
        // Fetch fresh profile from API in background
        fetchUserProfile();
        notifyListeners();
      }

      // Automatically acquire live GPS location in background
      fetchAndSetLiveGpsLocation();
    } catch (_) {
      // Failed to restore session silently
    }
  }

  void setCurrentAddress(AddressModel address) {
    _currentAddress = address;
    notifyListeners();
  }

  Future<bool> fetchAndSetLiveGpsLocation() async {
    _isFetchingLocation = true;
    notifyListeners();

    try {
      final locResult = await LocationService.getCurrentLiveLocation();
      if (locResult != null) {
        _currentAddress = locResult.address;

        // Update user coordinates
        _user = UserModel(
          id: _user.id,
          name: _user.name,
          email: _user.email,
          phoneNumber: _user.phoneNumber,
          avatarUrl: _user.avatarUrl,
          role: _user.role,
          addresses: [
            locResult.address,
            ..._user.addresses.where((a) => a.addressType != 'Live GPS'),
          ],
          latitude: locResult.latitude,
          longitude: locResult.longitude,
          createdAt: _user.createdAt,
        );

        debugPrint('📍 Live GPS Location Set: ${_currentAddress?.addressLine1}, ${_currentAddress?.city} (${locResult.latitude}, ${locResult.longitude})');
        _isFetchingLocation = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ Error updating live GPS location in AuthProvider: $e');
    } finally {
      _isFetchingLocation = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> fetchUserProfile() async {
    if (_token == null) return;
    try {
      final profileData = await _authService.getUserProfile();
      if (profileData.containsKey('user')) {
        _apiUser = ApiUser.fromJson(profileData['user']);
      } else {
        _apiUser = ApiUser.fromJson(profileData);
      }
      
      if (_apiUser != null) {
        await _storageService.saveUser(_apiUser!);
        _mapApiUserToUserModel(_apiUser!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to fetch fresh user profile: $e');
    }
  }

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success == true && response.token != null) {
        _token = response.token;
        ApiClient().setToken(response.token!);
        _apiUser = response.user;
        _isLoggedIn = true;

        // ===== Console Log: Print logged-in user data =====
        debugPrint('═══════════════════════════════════════════');
        debugPrint('✅ LOGIN SUCCESSFUL');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('Token: ${response.token}');
        if (response.user != null) {
          debugPrint('User ID   : ${response.user!.sId}');
          debugPrint('Name      : ${response.user!.name}');
          debugPrint('Email     : ${response.user!.email}');
          debugPrint('Phone     : ${response.user!.phoneNumber}');
          debugPrint('Role      : ${response.user!.role}');
          debugPrint('Avatar    : ${response.user!.avatar}');
          debugPrint('Admin     : ${response.user!.isActiveAdmin}');
          debugPrint('Created   : ${response.user!.createdAt}');
          debugPrint('Full JSON : ${response.user!.toJson()}');
        }
        debugPrint('═══════════════════════════════════════════');

        await _storageService.saveToken(_token!);
        if (_apiUser != null) {
          await _storageService.saveUser(_apiUser!);
          _mapApiUserToUserModel(_apiUser!);
        }

        // Fetch fresh profile just in case login payload is missing fields
        fetchUserProfile();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Authentication failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String? city,
    List<int>? avatarBytes,
    String? avatarFilename,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = CreateUserRequest(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        city: city,
        role: 'user',
      );

      final response = await _authService.createUser(
        request,
        avatarBytes: avatarBytes,
        avatarFilename: avatarFilename,
      );

      if (response.success == true) {
        debugPrint('STEP 5: Registration success');
        // ===== Console Log: Print Created User Data =====
        debugPrint('═══════════════════════════════════════════');
        debugPrint('🎉 CREATE ACCOUNT / REGISTRATION SUCCESSFUL');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('Name        : $name');
        debugPrint('Email       : $email');
        debugPrint('Phone       : $phoneNumber');
        debugPrint('City        : ${city ?? "Chhapalsari"}');
        debugPrint('Server Msg  : ${response.message ?? "User created successfully."}');
        debugPrint('═══════════════════════════════════════════');

        debugPrint('STEP 6 - Starting automatic login');
        try {
          final loggedIn = await loginUser(
            email: email,
            password: password,
          );

          if (loggedIn) {
            debugPrint('STEP 7 - Login successful');
            return true;
          }
        } catch (e, stackTrace) {
          debugPrint('AUTO LOGIN ERROR: $e');
          debugPrint('$stackTrace');
        }

        // Fallback: establish local session if login endpoint has any delay
        _user = UserModel(
          id: 'u_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          avatarUrl: '',
          role: UserRole.customer,
          createdAt: DateTime.now(),
        );
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();

        debugPrint('STEP 7 - Fallback session established');
        return true;
      } else {
        _errorMessage = response.message ?? 'Registration failed.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword({required String email, String role = 'user'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(email: email, role: role);
      _isLoading = false;
      notifyListeners();
      return response.success == true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _authService.logoutUser();
    } catch (_) {
      // Clear session locally even if network is offline
    }
    _isLoggedIn = false;
    _token = null;
    ApiClient().clearToken();
    _apiUser = null;
    await _storageService.clearAll();
    notifyListeners();
  }

  void _mapApiUserToUserModel(ApiUser apiUser) {
    UserRole role = UserRole.customer;
    final rStr = (apiUser.role ?? '').toLowerCase();
    if (rStr.contains('admin')) {
      role = UserRole.admin;
    } else if (rStr.contains('seller')) {
      role = UserRole.seller;
    }

    List<AddressModel> mappedAddresses = _user.addresses;
    if (apiUser.addresses != null) {
      mappedAddresses = apiUser.addresses!
          .map((a) => AddressModel.fromMap(Map<String, dynamic>.from(a as Map)))
          .toList();
    }

    double? lat;
    double? lng;
    if (apiUser.location?.coordinates != null && apiUser.location!.coordinates!.length >= 2) {
      lng = apiUser.location!.coordinates![0];
      lat = apiUser.location!.coordinates![1];
    }

    _user = UserModel(
      id: apiUser.sId ?? _user.id,
      name: apiUser.name ?? _user.name,
      email: apiUser.email ?? _user.email,
      phoneNumber: apiUser.phoneNumber?.toString() ?? _user.phoneNumber,
      avatarUrl: apiUser.avatar ?? _user.avatarUrl,
      role: role,
      addresses: mappedAddresses,
      latitude: lat,
      longitude: lng,
      createdAt: apiUser.createdAt != null
          ? (DateTime.tryParse(apiUser.createdAt!) ?? DateTime.now())
          : DateTime.now(),
    );
    _syncUserToFirebase();
  }

  Future<void> _syncUserToFirebase() async {
    try {
      await FirebaseService.saveUser(_user);
    } catch (e) {
      // Offline fallback
    }
  }

  void switchRole(UserRole role) {
    _user = UserModel(
      id: _user.id,
      name: _user.name,
      email: _user.email,
      phoneNumber: _user.phoneNumber,
      avatarUrl: _user.avatarUrl,
      role: role,
      addresses: _user.addresses,
      createdAt: _user.createdAt,
    );
    notifyListeners();
    _syncUserToFirebase();
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.updatePassword(oldPassword, newPassword, confirmPassword);
      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = response['message'] ?? 'Failed to update password.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(
        token: token,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (response.success == true) {
        if (response.token != null) {
          _token = response.token;
          ApiClient().setToken(response.token!);
          await _storageService.saveToken(response.token!);
        }
        if (response.user != null) {
          _apiUser = ApiUser.fromJson(response.user!.toJson());
          await _storageService.saveUser(_apiUser!);
          _mapApiUserToUserModel(_apiUser!);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = response.message ?? 'Password reset failed.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addAddress(AddressModel address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.addUserAddress(address.toMap());
      if (response['success'] == true) {
        if (response['user'] != null) {
          _apiUser = ApiUser.fromJson(response['user']);
          _mapApiUserToUserModel(_apiUser!);
        } else {
          // Fallback fetch
          fetchUserProfile();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = response['message'] ?? 'Failed to add address.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserInfo({
    required String name,
    required String email,
    required String phoneNumber,
    required double? latitude,
    required double? longitude,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
      };
      
      if (latitude != null && longitude != null) {
        data['location'] = {
          'type': 'Point',
          'coordinates': [longitude, latitude]
        };
      }
      
      final response = await _authService.updateUserInfo(data);
      if (response['success'] == true) {
        if (response['user'] != null) {
          _apiUser = ApiUser.fromJson(response['user']);
          _mapApiUserToUserModel(_apiUser!);
        } else {
          fetchUserProfile();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = response['message'] ?? 'Failed to update profile.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.deleteUserAddress(id);
      if (response['success'] == true) {
        if (response['user'] != null) {
          _apiUser = ApiUser.fromJson(response['user']);
          _mapApiUserToUserModel(_apiUser!);
        } else {
          fetchUserProfile();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = response['message'] ?? 'Failed to delete address.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

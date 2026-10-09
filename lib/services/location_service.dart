import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mecity_marketplace/models/user.dart';

class LocationResult {
  final AddressModel address;
  final double latitude;
  final double longitude;
  final String formattedAddress;

  LocationResult({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });
}

class LocationService {
  static final Geocoding _geocoding = Geocoding();

  /// Request GPS permission and fetch live current position and geocoded address
  static Future<LocationResult?> getCurrentLiveLocation() async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ Location services are disabled.');
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) return null;
      }

      // 2. Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('⚠️ Location permission denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ Location permissions are permanently denied.');
        return null;
      }

      // 3. Get current GPS position with high accuracy
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      debugPrint('📍 Live GPS Coordinates: Lat: ${position.latitude}, Lng: ${position.longitude}');

      // 4. Reverse geocode coordinates to human-readable address
      String street = 'Current Area';
      String city = 'Current City';
      String state = 'Gujarat';
      String country = 'India';
      String postalCode = '';

      try {
        final List<Placemark> placemarks = await _geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          debugPrint('📍 Placemark details: street=${p.street}, subLocality=${p.subLocality}, locality=${p.locality}, adminArea=${p.administrativeArea}, postalCode=${p.postalCode}');

          // Build clean street / area name
          final parts = <String>[];
          if (p.street != null && p.street!.isNotEmpty && !p.street!.contains('+')) {
            parts.add(p.street!);
          }
          if (p.subLocality != null && p.subLocality!.isNotEmpty && p.subLocality != p.street) {
            parts.add(p.subLocality!);
          }
          if (p.thoroughfare != null && p.thoroughfare!.isNotEmpty && !parts.contains(p.thoroughfare)) {
            parts.add(p.thoroughfare!);
          }

          if (parts.isNotEmpty) {
            street = parts.join(', ');
          } else if (p.name != null && p.name!.isNotEmpty) {
            street = p.name!;
          }

          if (p.locality != null && p.locality!.isNotEmpty) {
            city = p.locality!;
          } else if (p.subAdministrativeArea != null && p.subAdministrativeArea!.isNotEmpty) {
            city = p.subAdministrativeArea!;
          }

          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
            state = p.administrativeArea!;
          }

          if (p.country != null && p.country!.isNotEmpty) {
            country = p.country!;
          }

          if (p.postalCode != null && p.postalCode!.isNotEmpty) {
            postalCode = p.postalCode!;
          }
        }
      } catch (geocodeError) {
        debugPrint('⚠️ Geocoding reverse lookup error: $geocodeError');
        // Fallback to coordinates label
        street = 'GPS (${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)})';
      }

      final addressModel = AddressModel(
        id: 'gps_${DateTime.now().millisecondsSinceEpoch}',
        addressType: 'Live GPS',
        addressLine1: street,
        city: city,
        country: state.isNotEmpty ? state : country,
        zipCode: postalCode,
      );

      final formatted = postalCode.isNotEmpty
          ? '$street, $city - $postalCode'
          : '$street, $city';

      return LocationResult(
        address: addressModel,
        latitude: position.latitude,
        longitude: position.longitude,
        formattedAddress: formatted,
      );
    } catch (e) {
      debugPrint('⚠️ Error getting live GPS location: $e');
      return null;
    }
  }
}

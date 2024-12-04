import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

Future<Position> getLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled
    return Future.error(
      'Location services are disabled. Please enable location services in your device settings.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied. Please grant location permission to use this app.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied. Please enable location permissions in your device settings.');
  }

  // Get the current position with best accuracy
  try {
    // For web platform, directly get current position
    if (kIsWeb) {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    }
    
    // For mobile platforms, try to get last known position first
    try {
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        // If last known position is recent (within last minute), use it
        if (DateTime.now().difference(lastKnownPosition.timestamp) < const Duration(minutes: 1)) {
          return lastKnownPosition;
        }
      }
    } catch (e) {
      // Ignore errors from getLastKnownPosition
    }
    
    // Get fresh position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  } catch (e) {
    return Future.error(
      'Failed to get location. Please check your internet connection and try again.');
  }
}
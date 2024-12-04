import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:tapps/services/api_helper.dart';

final currentWeatherProvider = FutureProvider.autoDispose((ref) {
  return ApiHelper.getCurrentweather();
});

final weatherByCoordinatesProvider = FutureProvider.autoDispose.family<dynamic, Location>((ref, location) {
  return ApiHelper.getWeatherByCoordinates(location.latitude, location.longitude);
});

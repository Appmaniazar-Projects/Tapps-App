import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapps/models/weather.dart';
import 'package:logger/logger.dart';

final weatherServiceProvider = Provider((ref) => WeatherService());

final selectedLocationProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final currentWeatherProvider = FutureProvider.family<Weather, ({double lat, double lon})>(
  (ref, coords) async {
    final weatherService = ref.read(weatherServiceProvider);
    return await weatherService.getCurrentWeather(
      latitude: coords.lat,
      longitude: coords.lon,
    );
  },
);

final locationSearchProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, query) async {
    final weatherService = ref.read(weatherServiceProvider);
    return await weatherService.searchLocations(query);
  },
);

class WeatherService {
  final dio = Dio();
  final String apiKey = 'd12a09f4569b47071241f919e50ab404';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';
  final logger = Logger();

  Future<Weather> getCurrentWeather({required double latitude, required double longitude}) async {
    try {
      logger.d('Fetching weather for lat: $latitude, lon: $longitude');
      
      final response = await dio.get(
        '$baseUrl/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': apiKey,
          'units': 'metric',
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        ),
      );
      
      logger.d('Weather API response: ${response.data}');
      
      return Weather.fromJson(response.data);
    } catch (e, stackTrace) {
      logger.e('Error fetching weather', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    try {
      logger.d('Searching locations for query: $query');
      
      final response = await dio.get(
        'https://api.openweathermap.org/geo/1.0/direct',
        queryParameters: {
          'q': query,
          'limit': 5,
          'appid': apiKey,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        ),
      );
      
      logger.d('Location search response: ${response.data}');
      
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e, stackTrace) {
      logger.e('Error searching locations', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

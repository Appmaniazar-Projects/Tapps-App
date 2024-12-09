import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class WeatherService {
  static const String _apiKey = 'YOUR_OPENWEATHERMAP_API_KEY'; // Replace with actual API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String _forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';
  static const String _geocodingUrl = 'https://api.openweathermap.org/geo/1.0/direct';
  final Logger _logger = Logger();

  Future<List<dynamic>> searchLocations(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_geocodingUrl?q=$query&limit=5&appid=$_apiKey'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger.e('Failed to search locations: ${response.body}');
        throw Exception('Failed to search locations');
      }
    } catch (e) {
      _logger.e('Error searching locations: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger.e('Failed to load weather data: ${response.body}');
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      _logger.e('Error fetching current weather: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getWeatherForecast(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_forecastUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['list'].sublist(0, 5); // Get next 5 forecast periods
      } else {
        _logger.e('Failed to load weather forecast: ${response.body}');
        throw Exception('Failed to load weather forecast');
      }
    } catch (e) {
      _logger.e('Error fetching weather forecast: $e');
      rethrow;
    }
  }
}

// Riverpod Providers
final weatherServiceProvider = Provider((ref) => WeatherService());

final locationSearchProvider = FutureProvider.family<List<dynamic>, String>((ref, query) async {
  final weatherService = ref.read(weatherServiceProvider);
  return weatherService.searchLocations(query);
});

final currentWeatherProvider = FutureProvider.family<Map<String, dynamic>, ({required double lat, required double lon})>((ref, coords) async {
  final weatherService = ref.read(weatherServiceProvider);
  return weatherService.getCurrentWeather(coords.lat, coords.lon);
});

final weatherForecastProvider = FutureProvider.family<List<dynamic>, ({required double lat, required double lon})>((ref, coords) async {
  final weatherService = ref.read(weatherServiceProvider);
  return weatherService.getWeatherForecast(coords.lat, coords.lon);
});

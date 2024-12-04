import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:tapps/constants/constants.dart';
import 'package:tapps/models/hourly_weather.dart';
import 'package:tapps/models/weather.dart';
import 'package:tapps/models/weekly_weather.dart';
import 'package:tapps/services/geolocator.dart';
import 'package:tapps/utils/logging.dart';
import 'package:geolocator/geolocator.dart';

@immutable
class ApiHelper {
  static const baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const weeklyWeatherUrl =
      'https://api.open-meteo.com/v1/forecast?current=&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto';
  static Position? _currentPosition;
  static bool _locationFetched = false;

  static final dio = Dio();
  static Weather? _cachedWeather;
  static DateTime? _lastWeatherFetch;
  static const _cacheValidityDuration = Duration(minutes: 5); // Reduced cache time

  static Future<void> fetchLocation() async {
    if (!_locationFetched || _currentPosition == null) {
      _currentPosition = await getLocation();
      _locationFetched = true;
    }
  }

  //Current Weather
  static Future<Weather> getCurrentweather() async {
    final now = DateTime.now();
    
    // Return cached weather if it's still valid
    if (_cachedWeather != null && 
        _lastWeatherFetch != null &&
        now.difference(_lastWeatherFetch!) < _cacheValidityDuration) {
      return _cachedWeather!;
    }

    await fetchLocation();
    final url = _construcWeatherUrl();
    final response = await _fetchData(url);
    _cachedWeather = Weather.fromJson(response);
    _lastWeatherFetch = now;
    return _cachedWeather!;
  }

  static Future<Weather> getWeatherByCoordinates(double lat, double lon) async {
    final url = '$baseUrl/weather?lat=$lat&lon=$lon&appid=${Constants.apiKey}&units=metric';
    final response = await _fetchData(url);
    return Weather.fromJson(response);
  }

  //Hourly Weather
  static Future<HourlyWeather> getHourlyForecast() async {
    await fetchLocation();
    final url = _construcForecastUrl();
    final response = await _fetchData(url);
    return HourlyWeather.fromJson(response);
  }

  //Weekly Forecast
  static Future<WeeklyWeather> getWeeklyForecast() async {
    await fetchLocation();
    final url = _construcWeeklyForecastUrl();
    final response = await _fetchData(url);
    return WeeklyWeather.fromJson(response);
  }

  //Weather by city
  static Future<Weather> getWeatherByCityName(String cityName) async {
    final url = _construcWeatherByCityUrl(cityName);
    final response = await _fetchData(url);
    return Weather.fromJson(response);
  }

  //Url Building
  static String _construcWeatherUrl() {
    if (_currentPosition == null) {
      throw Exception('Location not available');
    }
    return '$baseUrl/weather?lat=${_currentPosition!.latitude}&lon=${_currentPosition!.longitude}&appid=${Constants.apiKey}&units=metric';
  }

  static String _construcForecastUrl() {
    if (_currentPosition == null) {
      throw Exception('Location not available');
    }
    return '$baseUrl/forecast?lat=${_currentPosition!.latitude}&lon=${_currentPosition!.longitude}&appid=${Constants.apiKey}&units=metric';
  }

  static String _construcWeatherByCityUrl(String cityName) =>
      '$baseUrl/weather?q=$cityName&appid=${Constants.apiKey}&units=metric';

  static String _construcWeeklyForecastUrl() {
    if (_currentPosition == null) {
      throw Exception('Location not available');
    }
    return '$weeklyWeatherUrl&latitude=${_currentPosition!.latitude}&longitude=${_currentPosition!.longitude}';
  }

  static Future<Map<String, dynamic>> _fetchData(String url) async {
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        printWarning('Failed to load data: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      printWarning('Error fetching data from $url: $e');
      throw Exception('Error fetching data');
    }
  }
}

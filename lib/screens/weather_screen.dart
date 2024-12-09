import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';
import 'package:tapps/constants/text_styles.dart';
import 'package:tapps/extensions/datetime.dart';
import 'package:tapps/services/weather_service.dart';
import 'package:tapps/views/gradient_container.dart';
import 'package:tapps/views/hourly_forecast_view.dart';
import 'package:tapps/views/weather_info.dart';
import 'package:tapps/views/weather_skeleton.dart';

final selectedLocationProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<dynamic> _searchResults = [];

  void _searchLocations(String query) async {
    if (query.isEmpty) return;

    try {
      final results = await ref.read(locationSearchProvider(query).future);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      Logger().e('Search error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching locations: $e')),
      );
    }
  }

  void _selectLocation(Map<String, dynamic> location) {
    ref.read(selectedLocationProvider.notifier).state = location;
    _searchController.clear();
    _searchResults.clear();
    _searchFocusNode.unfocus();
  }

  String _getWeatherIcon(String code) {
    final baseCode = code.replaceAll('n', 'd');
    return 'assets/icons/$baseCode.png';
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocation = ref.watch(selectedLocationProvider);
    
    final weatherData = selectedLocation != null
        ? ref.watch(currentWeatherProvider(
            lat: selectedLocation['lat'], 
            lon: selectedLocation['lon']
          ))
        : null;

    final forecastData = selectedLocation != null
        ? ref.watch(weatherForecastProvider(
            lat: selectedLocation['lat'], 
            lon: selectedLocation['lon']
          ))
        : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: GradientContainer(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for a location',
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: _searchLocations,
                  ),
                  if (_searchResults.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final location = _searchResults[index];
                          return ListTile(
                            title: Text(
                              '${location['name']}, ${location['country']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () => _selectLocation(location),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // Current Weather Display
                  weatherData != null
                    ? weatherData.when(
                        loading: () => const WeatherSkeleton(),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error loading weather: $error',
                            style: TextStyles.subtitleText.copyWith(color: Colors.white),
                          ),
                        ),
                        data: (weather) => WeatherInfo(
                          cityName: weather['name'],
                          temperature: weather['main']['temp'].toStringAsFixed(1),
                          description: weather['weather'][0]['description'],
                          icon: _getWeatherIcon(weather['weather'][0]['icon']),
                        ),
                      )
                    : const WeatherSkeleton(),
                  
                  // Hourly Forecast
                  const SizedBox(height: 16),
                  forecastData != null
                    ? forecastData.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error loading forecast: $error',
                            style: TextStyles.subtitleText.copyWith(color: Colors.white),
                          ),
                        ),
                        data: (forecast) => HourlyForecastView(forecastData: forecast),
                      )
                    : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';
import 'package:tapps/constants/text_styles.dart';
import 'package:tapps/extensions/datetime.dart';
import 'package:tapps/providers/current_weather_provider.dart';
import 'package:tapps/services/places_service.dart';
import 'package:tapps/views/gradient_container.dart';
import 'package:tapps/views/hourly_forecast.dart';
import 'package:tapps/views/location_search.dart';
import 'package:tapps/views/weather_info.dart';
import 'package:tapps/views/weather_skeleton.dart';

final selectedLocationProvider = StateProvider<String?>((ref) => null);
final selectedCoordinatesProvider = StateProvider<Location?>((ref) => null);

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  String _getWeatherIcon(String code) {
    final baseCode = code.replaceAll('n', 'd');
    return 'assets/icons/$baseCode.png';
  }

  void _onLocationSelected(WidgetRef ref, String location) async {
    try {
      final placesService = ref.read(placesServiceProvider);
      final coordinates = await placesService.getLocationFromAddress(location);
      ref.read(selectedLocationProvider.notifier).state = location;
      ref.read(selectedCoordinatesProvider.notifier).state = coordinates;
    } catch (e) {
      Logger().e('Error getting location coordinates: $e');
      // Show error to user
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logger = Logger();
    final selectedLocation = ref.watch(selectedLocationProvider);
    final selectedCoordinates = ref.watch(selectedCoordinatesProvider);
    
    final weatherData = selectedCoordinates != null
        ? ref.watch(weatherByCoordinatesProvider(selectedCoordinates))
        : ref.watch(currentWeatherProvider);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: weatherData.when(
        data: (weather) {
          try {
            return GradientContainer(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      LocationSearch(
                        onLocationSelected: (location) =>
                            _onLocationSelected(ref, location),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: double.infinity),
                          Text(
                            selectedLocation ?? weather.name,
                            style: TextStyles.h1,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            DateTime.now().dateTime,
                            style: TextStyles.subtitleText,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: Image.asset(
                              _getWeatherIcon(weather.weather[0].icon),
                              width: 160,
                              height: 160,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.cloud,
                                size: 100,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            weather.weather[0].description,
                            style: TextStyles.h3,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      WeatherInfo(weather: weather),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Today', style: TextStyles.h2),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Next 7 Days >',
                                style: TextStyles.buttonText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const HourlyForecast(),
                    ],
                  ),
                ),
              ],
            );
          } catch (e) {
            logger.e('Error building weather UI: $e');
            return const WeatherSkeleton();
          }
        },
        loading: () => const WeatherSkeleton(),
        error: (error, stackTrace) {
          logger.e('Error loading weather data: $error');
          return const WeatherSkeleton();
        },
      ),
    );
  }
}

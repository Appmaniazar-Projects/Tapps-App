import 'package:flutter/material.dart';
import 'package:tapps/constants/text_styles.dart';
import 'package:tapps/models/weather.dart';

class WeatherInfo extends StatelessWidget {
  final String? cityName;
  final String? temperature;
  final String? description;
  final String? icon;
  final Weather? weather;

  const WeatherInfo({
    super.key, 
    this.cityName, 
    this.temperature, 
    this.description, 
    this.icon,
    this.weather
  });

  @override
  Widget build(BuildContext context) {
    // If weather model is provided, use it
    if (weather != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WeatherInfoTitle(title: 'Temp', value: '${weather!.main.temp}°C'),
            WeatherInfoTitle(title: 'Wind', value: '${weather!.wind.speed} km/h'),
            WeatherInfoTitle(title: 'Humidity', value: '${weather!.main.humidity}%'),
          ],
        ),
      );
    }

    // If individual parameters are provided
    return Column(
      children: [
        if (cityName != null)
          Text(
            cityName!,
            style: TextStyles.h1,
          ),
        if (icon != null)
          Image.asset(
            icon!,
            width: 100,
            height: 100,
          ),
        if (temperature != null)
          Text(
            '$temperature°C',
            style: TextStyles.h2,
          ),
        if (description != null)
          Text(
            description!,
            style: TextStyles.subtitleText,
          ),
      ],
    );
  }
}

class WeatherInfoTitle extends StatelessWidget {
  const WeatherInfoTitle({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TextStyles.subtitleText),
        const SizedBox(height: 10),
        Text(value, style: TextStyles.h3),
      ],
    );
  }
}

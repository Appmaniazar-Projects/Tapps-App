import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapps/models/weather.dart';
import 'package:tapps/services/api_helper.dart';


final weatherByCityNameProvider = FutureProvider.autoDispose.family<Weather, String>((ref, String cityName) {
  return ApiHelper.getWeatherByCityName(cityName);
});
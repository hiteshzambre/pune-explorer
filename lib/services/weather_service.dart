import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/weather_model.dart';

class WeatherService {
  final Map<String, WeatherData> _memoryCache = {};

  Future<WeatherData> fetchDestinationWeather(double lat, double lng) async {
    final cacheKey = '${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}';
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?'
        'latitude=$lat&longitude=$lng'
        '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,apparent_temperature'
        '&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weather_code'
        '&timezone=Asia/Kolkata&forecast_days=7',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final current = json['current'] as Map<String, dynamic>? ?? {};
        final daily = json['daily'] as Map<String, dynamic>? ?? {};

        final times = (daily['time'] as List<dynamic>?)?.cast<String>() ?? [];
        final maxTemps = (daily['temperature_2m_max'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
        final minTemps = (daily['temperature_2m_min'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
        final precips = (daily['precipitation_sum'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
        final codes = (daily['weather_code'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [];

        final List<DayForecast> dailyForecasts = [];
        for (int i = 0; i < times.length; i++) {
          dailyForecasts.add(
            DayForecast(
              date: times[i],
              maxTemp: i < maxTemps.length ? maxTemps[i] : 28.0,
              minTemp: i < minTemps.length ? minTemps[i] : 18.0,
              precipitation: i < precips.length ? precips[i] : 0.0,
              weatherCode: i < codes.length ? codes[i] : 0,
            ),
          );
        }

        final weather = WeatherData(
          temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 24.0,
          feelsLike: (current['apparent_temperature'] as num?)?.toDouble() ?? 24.0,
          humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 60,
          windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 10.0,
          weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
          dailyForecasts: dailyForecasts,
          isFallback: false,
        );

        _memoryCache[cacheKey] = weather;
        return weather;
      }
    } catch (_) {
      // Network failure, timeout, or DNS issue -> return Pune seasonal climate
    }

    final fallback = WeatherData.puneSeasonalDefault();
    _memoryCache[cacheKey] = fallback;
    return fallback;
  }
}

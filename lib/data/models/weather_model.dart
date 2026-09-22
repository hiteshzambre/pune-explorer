class DayForecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final double precipitation;
  final int weatherCode;

  const DayForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitation,
    required this.weatherCode,
  });

  String get conditionText {
    if (weatherCode >= 51 && weatherCode <= 67) return 'Monsoon Rain';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Rain Showers';
    if (weatherCode >= 1 && weatherCode <= 3) return 'Partly Cloudy';
    if (weatherCode == 0) return 'Clear Sky';
    return 'Pleasant';
  }

  String get weatherIcon {
    if (weatherCode >= 51 && weatherCode <= 67) return '🌧️';
    if (weatherCode >= 80 && weatherCode <= 82) return '🌦️';
    if (weatherCode >= 1 && weatherCode <= 3) return '⛅';
    if (weatherCode == 0) return '☀️';
    return '🌤️';
  }
}

class WeatherData {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final List<DayForecast> dailyForecasts;
  final bool isFallback;
  final String seasonName;
  final String trekAdvice;

  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.dailyForecasts,
    this.isFallback = false,
    this.seasonName = 'Winter (Pleasant)',
    this.trekAdvice = 'Clear skies and cool mornings ideal for Sahyadri fort treks.',
  });

  String get conditionText {
    if (weatherCode >= 51 && weatherCode <= 67) return 'Rain / Drizzle';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Rain Showers';
    if (weatherCode >= 1 && weatherCode <= 3) return 'Partly Cloudy';
    if (weatherCode == 0) return 'Clear & Sunny';
    return 'Mild Weather';
  }

  String get weatherIcon {
    if (weatherCode >= 51 && weatherCode <= 67) return '🌧️';
    if (weatherCode >= 80 && weatherCode <= 82) return '🌦️';
    if (weatherCode >= 1 && weatherCode <= 3) return '⛅';
    if (weatherCode == 0) return '☀️';
    return '🌤️';
  }

  /// Default Pune seasonal fallback when network/API is offline
  factory WeatherData.puneSeasonalDefault() {
    final now = DateTime.now();
    final month = now.month;

    if (month >= 6 && month <= 9) {
      // Monsoon
      return WeatherData(
        temperature: 24.5,
        feelsLike: 25.0,
        humidity: 88,
        windSpeed: 18.0,
        weatherCode: 63,
        isFallback: true,
        seasonName: 'Monsoon Season (July – Sept)',
        trekAdvice: 'Sahyadri ghats are covered in mist and waterfalls. Carry rain ponchos & sturdy grip shoes.',
        dailyForecasts: List.generate(7, (i) {
          final date = now.add(Duration(days: i));
          return DayForecast(
            date: '${date.day}/${date.month}',
            maxTemp: 26.0,
            minTemp: 22.0,
            precipitation: 15.0,
            weatherCode: 63,
          );
        }),
      );
    } else if (month >= 10 || month <= 2) {
      // Winter
      return WeatherData(
        temperature: 22.0,
        feelsLike: 21.0,
        humidity: 52,
        windSpeed: 10.5,
        weatherCode: 0,
        isFallback: true,
        seasonName: 'Winter Season (Oct – Feb)',
        trekAdvice: 'Peak fort trekking season. Crisp morning air with 360-degree panoramic valley visibility.',
        dailyForecasts: List.generate(7, (i) {
          final date = now.add(Duration(days: i));
          return DayForecast(
            date: '${date.day}/${date.month}',
            maxTemp: 28.0,
            minTemp: 15.0,
            precipitation: 0.0,
            weatherCode: 0,
          );
        }),
      );
    } else {
      // Summer
      return WeatherData(
        temperature: 32.0,
        feelsLike: 34.0,
        humidity: 40,
        windSpeed: 12.0,
        weatherCode: 0,
        isFallback: true,
        seasonName: 'Summer Season (March – June)',
        trekAdvice: 'Start climbs before 6:30 AM to beat the afternoon sun. Carry 2L hydration water.',
        dailyForecasts: List.generate(7, (i) {
          final date = now.add(Duration(days: i));
          return DayForecast(
            date: '${date.day}/${date.month}',
            maxTemp: 36.0,
            minTemp: 23.0,
            precipitation: 0.0,
            weatherCode: 0,
          );
        }),
      );
    }
  }
}

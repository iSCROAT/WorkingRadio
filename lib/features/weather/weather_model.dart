/// Modelos da previsão do tempo (wttr.in — dados reais, sem mock).
class WeatherReport {
  final String city;
  final String region;
  final String country;
  final int tempC;
  final int feelsLikeC;
  final String condition;
  final int conditionCode;
  final int humidity;
  final int windKmh;
  final String windDir;
  final int uvIndex;
  final List<HourForecast> hourly;
  final List<DayForecast> daily;

  const WeatherReport({
    required this.city,
    required this.region,
    required this.country,
    required this.tempC,
    required this.feelsLikeC,
    required this.condition,
    required this.conditionCode,
    required this.humidity,
    required this.windKmh,
    required this.windDir,
    required this.uvIndex,
    required this.hourly,
    required this.daily,
  });
}

class HourForecast {
  final String time;
  final int tempC;
  final String condition;
  final int chanceOfRain;

  const HourForecast({
    required this.time,
    required this.tempC,
    required this.condition,
    required this.chanceOfRain,
  });
}

class DayForecast {
  final String weekday;
  final int maxC;
  final int minC;
  final String condition;

  const DayForecast({
    required this.weekday,
    required this.maxC,
    required this.minC,
    required this.condition,
  });
}

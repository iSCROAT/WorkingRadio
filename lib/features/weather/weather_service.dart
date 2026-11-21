import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

/// Previsão do tempo via wttr.in (gratuito, sem chave).
/// Sem dados falsos: em caso de falha, expõe erro para a UI.
class WeatherService extends ChangeNotifier {
  WeatherReport? report;
  bool loading = false;
  String? error;

  String _lastCity = '';
  DateTime? _lastFetch;

  /// Recarrega apenas se os dados estiverem velhos (10 min) ou ausentes.
  Future<void> refreshIfStale() async {
    final stale = _lastFetch == null ||
        DateTime.now().difference(_lastFetch!) > const Duration(minutes: 10);
    if (stale && _lastCity.isNotEmpty) {
      await fetch(_lastCity);
    }
  }

  Future<void> fetch(String city) async {
    _lastCity = city;
    _lastFetch = DateTime.now();
    loading = true;
    error = null;
    notifyListeners();
    try {
      final uri = Uri.parse('https://wttr.in/$city?format=j1');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      report = _parse(jsonDecode(response.body));
    } catch (e) {
      error = 'Não foi possível carregar a previsão. Verifique sua conexão e tente novamente.';
    }
    loading = false;
    notifyListeners();
  }

  WeatherReport _parse(dynamic decoded) {
    final root = decoded as Map<String, dynamic>;
    final nearest = (root['nearest_area'] as List?)?.first as Map<String, dynamic>?;
    String area(String key) =>
        ((nearest?[key] as List?)?.first as Map<String, dynamic>?)?['value']?.toString() ?? '';

    final current = (root['current_condition'] as List?)?.first as Map<String, dynamic>?;
    int num(String key) => int.tryParse(current?[key]?.toString() ?? '') ?? 0;
    String desc(Map<String, dynamic>? obj) =>
        ((obj?['weatherDesc'] as List?)?.first as Map<String, dynamic>?)?['value']?.toString() ?? '';

    final hourly = <HourForecast>[];
    final daily = <DayForecast>[];
    final days = root['weather'] as List? ?? [];
    for (final dayEl in days) {
      final day = dayEl as Map<String, dynamic>;
      final hours = day['hourly'] as List? ?? [];
      if (hourly.length < 5) {
        for (final hEl in hours) {
          if (hourly.length >= 5) break;
          final h = hEl as Map<String, dynamic>;
          final raw = (h['time']?.toString() ?? '0').padLeft(4, '0');
          final hour = int.tryParse(raw.substring(0, 2)) ?? 0;
          hourly.add(HourForecast(
            time: hourly.isEmpty ? 'Agora' : '${hour}h',
            tempC: int.tryParse(h['tempC']?.toString() ?? '') ?? 0,
            condition: desc(h),
            chanceOfRain: int.tryParse(h['chanceofrain']?.toString() ?? '') ?? 0,
          ));
        }
      }
      final date = day['date']?.toString() ?? '';
      daily.add(DayForecast(
        weekday: _weekday(date),
        maxC: int.tryParse(day['maxtempC']?.toString() ?? '') ?? 0,
        minC: int.tryParse(day['mintempC']?.toString() ?? '') ?? 0,
        condition: hours.isNotEmpty ? desc(hours.first as Map<String, dynamic>) : '',
      ));
    }

    return WeatherReport(
      city: area('areaName').isEmpty ? 'Paraúna' : area('areaName'),
      region: area('region'),
      country: area('country'),
      tempC: num('temp_C'),
      feelsLikeC: num('FeelsLikeC'),
      condition: desc(current),
      conditionCode: num('weatherCode'),
      humidity: num('humidity'),
      windKmh: num('windspeedKmph'),
      windDir: current?['winddir16Point']?.toString() ?? '',
      uvIndex: num('uvIndex'),
      hourly: hourly,
      daily: daily,
    );
  }

  /// Dia da semana calculado a partir da data real da API (sem valores fixos).
  String _weekday(String date) {
    const names = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return names[parsed.weekday - 1];
  }
}

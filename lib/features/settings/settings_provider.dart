import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configurações persistidas — URL do stream, cidade e notificações.
/// Estrutura real: nada de dados falsos, tudo configurável pelo usuário.
class SettingsProvider extends ChangeNotifier {
  static const _kStreamUrl = 'stream_url';
  static const _kCity = 'weather_city';
  static const _kNotifications = 'notifications';

  /// Stream padrão público (SomaFM) — substitua pela URL oficial da rádio.
  static const defaultStreamUrl = 'https://ice1.somafm.com/groovesalad-128-mp3';

  String streamUrl = defaultStreamUrl;
  String city = 'Parauna';
  bool notifications = true;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    streamUrl = prefs.getString(_kStreamUrl) ?? defaultStreamUrl;
    city = prefs.getString(_kCity) ?? 'Parauna';
    notifications = prefs.getBool(_kNotifications) ?? true;
    notifyListeners();
  }

  Future<void> saveStreamUrl(String url) async {
    streamUrl = url.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStreamUrl, streamUrl);
    notifyListeners();
  }

  Future<void> saveCity(String value) async {
    city = value.trim().isEmpty ? 'Parauna' : value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCity, city);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    notifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, value);
    notifyListeners();
  }
}

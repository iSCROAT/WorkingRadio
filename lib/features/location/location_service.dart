import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Localização geográfica real do dispositivo (exige permissão do usuário).
///
/// Fluxo:
/// 1. Estrutura do modelo `LocationFix` (latitude, longitude, cidade, país).
/// 2. Permissões via `geolocator` (Android/iOS).
/// 3. Reverse geocoding via Nominatim/OpenStreetMap (gratuito, 1 req/s).
///
/// Sem fallback silencioso: se a permissão for negada, expõe o erro real
/// para a UI oferecer busca manual por país/estado.
class LocationService extends ChangeNotifier {
  Position? position;
  String city = '';
  String state = '';
  String country = '';
  String countryCode = '';
  bool loading = false;
  String? error;

  /// Coordenadas válidas para consultar estações próximas.
  bool get hasFix => position != null;

  Future<void> locate() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        error = 'Localização desativada no dispositivo. Ative o GPS e tente novamente.';
        loading = false;
        notifyListeners();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        error =
            'Permissão de localização negada. Use a busca por país ou região.';
        loading = false;
        notifyListeners();
        return;
      }

      final fix = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 20),
      ).timeout(const Duration(seconds: 25));
      position = fix;

      // Reverse geocoding (OpenStreetMap/Nominatim).
      try {
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?format=jsonv2&zoom=12&lat=${fix.latitude}&lon=${fix.longitude}',
        );
        final response = await http.get(
          uri,
          headers: const {'User-Agent': 'WorkingRadio/3.0.0'},
        ).timeout(const Duration(seconds: 12));
        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes))
              as Map<String, dynamic>;
          final address = data['address'] as Map<String, dynamic>? ?? {};
          city = (address['city'] ??
                  address['town'] ??
                  address['village'] ??
                  address['municipality'] ??
                  '')
              .toString();
          state = (address['state'] ?? '').toString();
          country = (address['country'] ?? '').toString();
          countryCode = (address['country_code'] ?? '').toString().toUpperCase();
        }
      } catch (_) {
        // Coordenadas já bastam para a busca geográfica; endereço é opcional.
      }
    } catch (e) {
      error = 'Não foi possível obter a localização. Tente novamente.';
    }

    loading = false;
    notifyListeners();
  }

  void clear() {
    position = null;
    city = '';
    state = '';
    country = '';
    countryCode = '';
    error = null;
    notifyListeners();
  }
}

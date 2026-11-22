import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'station_model.dart';

/// Cliente da API pública Radio Browser (sem chave, sem cadastro).
///
/// Espelhos oficiais: de1/de2, at1, nl1... — tentamos em sequência
/// porque a disponibilidade varia por região.
/// Documentação: https://docs.radio-browser.info/
class StationService extends ChangeNotifier {
  static const List<String> _mirrors = [
    'https://de1.api.radio-browser.info',
    'https://de2.api.radio-browser.info',
    'https://at1.api.radio-browser.info',
  ];

  /// Identifica o app (a API pede um User-Agent próprio).
  static const Map<String, String> _headers = {
    'User-Agent': 'WorkingRadio/3.0.0',
    'Accept': 'application/json',
  };

  List<RadioStation> results = [];
  List<RadioCountry> countries = [];
  bool loading = false;
  String? error;

  /// Filtros ativos (para exibir na UI e refazer a busca).
  String filterCountryCode = '';
  String filterState = '';
  String filterName = '';
  double? nearLat;
  double? nearLng;

  int _requestId = 0;

  Future<T?> _getJson<T>(
    String path, {
    Map<String, String>? query,
    required T Function(dynamic) parse,
  }) async {
    Object? lastError;
    for (final mirror in _mirrors) {
      try {
        final uri = Uri.parse('$mirror$path').replace(queryParameters: query);
        final response =
            await http.get(uri, headers: _headers).timeout(const Duration(seconds: 12));
        if (response.statusCode != 200) {
          lastError = Exception('HTTP ${response.statusCode}');
          continue;
        }
        return parse(jsonDecode(utf8.decode(response.bodyBytes)));
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('Falha ao consultar a base de estações ($lastError)');
  }

  /// Países disponíveis (com contagem de estações), ordenados por nome.
  Future<void> loadCountries() async {
    if (countries.isNotEmpty) return;
    try {
      final parsed = await _getJson<List<RadioCountry>>(
        '/json/countries',
        parse: (data) => (data as List)
            .map((e) => RadioCountry.fromJson(e as Map<String, dynamic>))
            .where((c) => c.code.length == 2 && c.stationCount > 0)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name)),
      );
      if (parsed != null) {
        countries = parsed;
        notifyListeners();
      }
    } catch (_) {
      // Silencioso: lista é opcional; a busca global ainda funciona.
    }
  }

  /// Busca estações por nome / país / estado.
  Future<void> search({
    String name = '',
    String countryCode = '',
    String state = '',
    int limit = 150,
  }) async {
    filterName = name;
    filterCountryCode = countryCode;
    filterState = state;
    nearLat = null;
    nearLng = null;

    final query = <String, String>{
      'hidebroken': 'true',
      'order': 'votes',
      'reverse': 'true',
      'limit': '$limit',
      if (name.isNotEmpty) 'name': name,
      if (countryCode.isNotEmpty) 'countrycode': countryCode,
      if (state.isNotEmpty) 'state': state,
    };
    await _runSearch('/json/stations/search', query);
  }

  /// Estações próximas por coordenadas (geolocalização do dispositivo).
  Future<void> searchNearby({
    required double lat,
    required double lng,
    double distanceKm = 100,
    int limit = 150,
  }) async {
    filterCountryCode = '';
    filterState = '';
    filterName = '';
    nearLat = lat;
    nearLng = lng;

    final query = <String, String>{
      'hidebroken': 'true',
      'has_geo_info': 'true',
      'geo_lat': '$lat',
      'geo_long': '$lng',
      'geo_distance': '${(distanceKm * 1000).round()}',
      'order': 'distance',
      'reverse': 'false',
      'limit': '$limit',
    };
    await _runSearch('/json/stations/search', query);
  }

  /// Catálogo ampliado do Brasil (entrada padrão brasileira).
  /// Usa o país BR com o máximo que a API entrega por página e inclui
  /// estações de todos os estados — o catálogo cresce com os filtros.
  Future<void> loadBrazil({int limit = 200}) async {
    await _runSearch('/json/stations/search', {
      'countrycode': 'BR',
      'hidebroken': 'true',
      'order': 'votes',
      'reverse': 'true',
      'limit': '$limit',
    });
    filterCountryCode = 'BR';
    filterState = '';
    filterName = '';
    nearLat = null;
    nearLng = null;
  }

  /// Top estações do mundo (entrada padrão, sem filtros).
  Future<void> loadTopWorld({int limit = 150}) async {
    filterCountryCode = '';
    filterState = '';
    filterName = '';
    nearLat = null;
    nearLng = null;
    await _runSearch('/json/stations/search', {
      'hidebroken': 'true',
      'order': 'clickcount',
      'reverse': 'true',
      'limit': '$limit',
    });
  }

  Future<void> _runSearch(String path, Map<String, String> query) async {
    final requestId = ++_requestId;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final parsed = await _getJson<List<RadioStation>>(
        path,
        query: query,
        parse: (data) => (data as List)
            .map((e) => RadioStation.fromJson(e as Map<String, dynamic>))
            .where((s) => s.url.isNotEmpty)
            .toList(),
      );
      if (requestId != _requestId) return; // resposta antiga: descarta
      results = parsed ?? [];
      if (results.isEmpty) {
        error = 'Nenhuma estação encontrada com esses filtros.';
      }
    } catch (e) {
      if (requestId != _requestId) return;
      results = [];
      error =
          'Não foi possível consultar a base de estações. Verifique a conexão.';
    }
    loading = false;
    notifyListeners();
  }
}

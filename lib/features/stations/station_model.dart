/// Modelo de estação de rádio vinda da API pública Radio Browser
/// (https://api.radio-browser.info) — 60 mil+ estações do mundo.
class RadioStation {
  final String id;
  final String name;
  final String url;
  final String? favicon;
  final String country;
  final String countryCode;
  final String state;
  final List<String> tags;
  final String codec;
  final int bitrate;
  final int votes;
  final bool isHttps;
  final double? geoLat;
  final double? geoLong;
  final int? distanceMeters;

  const RadioStation({
    required this.id,
    required this.name,
    required this.url,
    this.favicon,
    required this.country,
    required this.countryCode,
    required this.state,
    required this.tags,
    required this.codec,
    required this.bitrate,
    required this.votes,
    required this.isHttps,
    this.geoLat,
    this.geoLong,
    this.distanceMeters,
  });

  bool get hasGeo => geoLat != null && geoLong != null;

  String get subtitle {
    final parts = <String>[
      if (state.isNotEmpty) state,
      if (country.isNotEmpty) country,
    ];
    return parts.isEmpty ? 'Estação online' : parts.join(' · ');
  }

  String get quality {
    if (bitrate <= 0) return codec;
    return '$codec · $bitrate kbps';
  }

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      final parsed = double.tryParse(value.toString());
      if (parsed == null || parsed == 0) return null;
      return parsed;
    }

    return RadioStation(
      id: json['stationuuid']?.toString() ?? '',
      name: (json['name']?.toString() ?? '').trim().isEmpty
          ? 'Estação sem nome'
          : json['name'].toString().trim(),
      url: json['url_resolved']?.toString().isNotEmpty == true
          ? json['url_resolved'].toString()
          : (json['url']?.toString() ?? ''),
      favicon: (json['favicon']?.toString().isNotEmpty ?? false)
          ? json['favicon'].toString()
          : null,
      country: json['country']?.toString() ?? '',
      countryCode: json['countrycode']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      tags: (json['tags']?.toString() ?? '')
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      codec: json['codec']?.toString() ?? '',
      bitrate: int.tryParse(json['bitrate']?.toString() ?? '') ?? 0,
      votes: int.tryParse(json['votes']?.toString() ?? '') ?? 0,
      isHttps: json['url_resolved']?.toString().startsWith('https') == true,
      geoLat: parseDouble(json['geo_lat']),
      geoLong: parseDouble(json['geo_long']),
      distanceMeters: double.tryParse(json['distance']?.toString() ?? '')
          ?.round(),
    );
  }
}

/// País disponível na base do Radio Browser.
class RadioCountry {
  final String name;
  final String code;
  final int stationCount;

  const RadioCountry({
    required this.name,
    required this.code,
    required this.stationCount,
  });

  factory RadioCountry.fromJson(Map<String, dynamic> json) => RadioCountry(
        name: json['name']?.toString() ?? '',
        code: json['iso_3166_1']?.toString() ?? '',
        stationCount: int.tryParse(json['stationcount']?.toString() ?? '') ?? 0,
      );
}

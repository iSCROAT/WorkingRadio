import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../location/location_service.dart';
import '../weather/weather_service.dart';

/// Seletor de local da previsão do tempo.
///
/// Três caminhos reais (sem dados fixos):
/// 1. **Minha localização** (GPS + reverse geocoding) — usa coordenadas reais;
/// 2. **Cidade** digitada (ex.: Paraúna, Goiânia, Lisboa);
/// 3. **País** — busca a capital oficial do país e consulta o tempo lá.
///
/// O local escolhido fica persistido nas Configurações.
class WeatherLocationSheet extends StatefulWidget {
  const WeatherLocationSheet({super.key});

  @override
  State<WeatherLocationSheet> createState() => _WeatherLocationSheetState();
}

class _WeatherLocationSheetState extends State<WeatherLocationSheet> {
  late final TextEditingController _cityController;
  final _countryController = TextEditingController();
  int _mode = 0; // 0 = GPS, 1 = cidade, 2 = país

  /// Capitais reais (ISO 3166-1 alfa-2) usadas para consulta por país.
  static const Map<String, String> _capitals = {
    'BR': 'Brasilia', 'AR': 'Buenos Aires', 'CL': 'Santiago',
    'CO': 'Bogota', 'PE': 'Lima', 'VE': 'Caracas', 'EC': 'Quito',
    'BO': 'La Paz', 'PY': 'Asuncion', 'UY': 'Montevideo', 'MX': 'Mexico City',
    'US': 'Washington', 'CA': 'Ottawa', 'GB': 'London', 'IE': 'Dublin',
    'FR': 'Paris', 'DE': 'Berlin', 'ES': 'Madrid', 'IT': 'Rome',
    'PT': 'Lisbon', 'NL': 'Amsterdam', 'BE': 'Brussels', 'CH': 'Bern',
    'AT': 'Vienna', 'SE': 'Stockholm', 'NO': 'Oslo', 'DK': 'Copenhagen',
    'FI': 'Helsinki', 'PL': 'Warsaw', 'CZ': 'Prague', 'GR': 'Athens',
    'RU': 'Moscow', 'UA': 'Kyiv', 'TR': 'Ankara', 'IL': 'Jerusalem',
    'SA': 'Riyadh', 'AE': 'Abu Dhabi', 'EG': 'Cairo', 'ZA': 'Pretoria',
    'NG': 'Abuja', 'KE': 'Nairobi', 'MA': 'Rabat', 'CN': 'Beijing',
    'JP': 'Tokyo', 'KR': 'Seoul', 'IN': 'New Delhi', 'ID': 'Jakarta',
    'TH': 'Bangkok', 'VN': 'Hanoi', 'PH': 'Manila', 'MY': 'Kuala Lumpur',
    'SG': 'Singapore', 'AU': 'Canberra', 'NZ': 'Wellington',
    'AO': 'Luanda', 'MZ': 'Maputo', 'CV': 'Praia',
  };

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(
      text: context.read<WeatherService>().cityName,
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _applyCity(String city) async {
    final value = city.trim();
    if (value.isEmpty) return;
    await context.read<WeatherService>().fetch(value);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _applyCountry(String code) async {
    final capital = _capitals[code.toUpperCase()];
    if (capital == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('País sem capital cadastrada nesta lista.'),
            backgroundColor: Color(0xFFFF3B5C),
          ),
        );
      }
      return;
    }
    await _applyCity(capital);
  }

  Future<void> _applyGps() async {
    final location = context.read<LocationService>();
    await location.locate();
    if (!mounted) return;
    if (location.hasFix) {
      await context.read<WeatherService>().fetchByCoordinates(
            location.position!.latitude,
            location.position!.longitude,
            cityName: location.city.isEmpty ? 'Minha localização' : location.city,
          );
      if (mounted) Navigator.pop(context);
    } else if (location.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(location.error!),
          backgroundColor: const Color(0xFFFF3B5C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationService>();
    final height = MediaQuery.of(context).size.height;

    return NeumorphicSheetScaffold(
      height: height * 0.78,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Local da previsão',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF))),
          const SizedBox(height: 4),
          const Text('Escolha cidade, país ou use sua localização',
              style: TextStyle(fontSize: 12, color: Color(0xFF8A8D93))),
          const SizedBox(height: 18),
          _ModeChip(
            icon: Icons.my_location,
            label: 'Minha localização',
            selected: _mode == 0,
            onTap: () => setState(() => _mode = 0),
          ),
          const SizedBox(height: 10),
          _ModeChip(
            icon: Icons.location_city,
            label: 'Cidade',
            selected: _mode == 1,
            onTap: () => setState(() => _mode = 1),
          ),
          const SizedBox(height: 10),
          _ModeChip(
            icon: Icons.flag,
            label: 'País',
            selected: _mode == 2,
            onTap: () => setState(() => _mode = 2),
          ),
          const SizedBox(height: 18),
          if (_mode == 0) ...[
            Text(
              location.hasFix
                  ? 'GPS ativo — ${location.city.isEmpty ? 'posição atual' : location.city}'
                  : 'Toque para ativar o GPS e usar a posição atual',
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A8D93)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                icon: location.loading
                    ? Icons.gps_not_fixed
                    : Icons.my_location,
                label: location.loading ? 'Buscando...' : 'Usar minha localização',
                onTap: location.loading ? null : _applyGps,
              ),
            ),
          ],
          if (_mode == 1) ...[
            TextField(
              controller: _cityController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: _applyCity,
              style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Ex.: Paraúna, Goiânia, Lisboa',
                hintStyle: TextStyle(color: Color(0xFF5C5F66), fontSize: 13),
                prefixIcon:
                    Icon(Icons.search, color: Color(0xFFFF3B5C), size: 20),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                icon: Icons.check,
                label: 'Aplicar cidade',
                onTap: () => _applyCity(_cityController.text),
              ),
            ),
          ],
          if (_mode == 2) ...[
            TextField(
              controller: _countryController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: _applyCountry,
              style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Código do país (BR, US, PT, JP...)',
                hintStyle: TextStyle(color: Color(0xFF5C5F66), fontSize: 13),
                prefixIcon: Icon(Icons.flag, color: Color(0xFFFF3B5C), size: 20),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in _capitals.entries.take(12))
                  _CountryChip(
                    code: entry.key,
                    onTap: () => _applyCountry(entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                icon: Icons.check,
                label: 'Aplicar país',
                onTap: () => _applyCountry(_countryController.text),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Base neumórfica usada pelas folhas (bottom sheets) do app.
class NeumorphicSheetScaffold extends StatelessWidget {
  final Widget child;
  final double height;

  const NeumorphicSheetScaffold({
    super.key,
    required this.child,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
      decoration: const BoxDecoration(
        color: Color(0xFF14161A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(child: child),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF14161A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFFF3B5C) : const Color(0xFF23262C),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: selected ? const Color(0xFFFF3B5C) : const Color(0xFF8A8D93)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? const Color(0xFFFFFFFF) : const Color(0xFFC9CCD2),
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 18, color: Color(0xFFFF3B5C)),
          ],
        ),
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  final String code;
  final VoidCallback onTap;

  const _CountryChip({required this.code, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF14161A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF23262C)),
        ),
        child: Text(code,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFF3B5C))),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF14161A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF3B5C), width: 1.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFFFF3B5C)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF))),
          ],
        ),
      ),
    );
  }
}

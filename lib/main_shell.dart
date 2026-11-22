import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/neumorphic_theme.dart';
import 'core/widgets/nav_pill.dart';
import 'features/globe/globe_screen.dart';
import 'features/home/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/stations/stations_screen.dart';
import 'features/weather/weather_screen.dart';
import 'features/weather/weather_service.dart';

/// Navegação principal v4 — 5 abas com pílula neumórfica do protótipo:
/// Início (hexágono) · Explorar · Tempo · Globo · Ajustes.
/// As telas são abas persistentes: NÃO têm botão "voltar" próprio
/// (evita acesso duplicado e ícones soltos no topo).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int index) {
    setState(() => _index = index);
    if (index == 2) {
      context.read<WeatherService>().refreshIfStale();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuColors.background,
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onOpenWeather: () => _go(2),
            onOpenSettings: () => _go(4),
            onOpenStations: () => _go(1),
            onOpenGlobe: () => _go(3),
          ),
          const StationsScreen(),
          const WeatherScreen(),
          const GlobeScreen(),
          const SettingsScreen(
            onOpenWeather: () => _go(2),
            onOpenStations: () => _go(1),
            onOpenGlobe: () => _go(3),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 14),
        child: NeuNavPill(index: _index, onChanged: _go),
      ),
    );
  }
}

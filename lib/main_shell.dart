import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/neumorphic_theme.dart';
import 'core/widgets/nav_pill.dart';
import 'features/home/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/weather/weather_screen.dart';
import 'features/weather/weather_service.dart';

/// Navegação principal — pílula neumórfica inferior (recriada do protótipo).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int index) {
    setState(() => _index = index);
    if (index == 1) {
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
            onOpenWeather: () => _go(1),
            onOpenSettings: () => _go(2),
          ),
          WeatherScreen(onBack: () => _go(0)),
          SettingsScreen(
            onBack: () => _go(0),
            onOpenWeather: () => _go(1),
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

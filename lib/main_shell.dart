import 'package:flutter/material.dart';
import 'core/theme/neumorphic_theme.dart';
import 'core/widgets/neumorphic.dart';
import 'features/home/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/weather/weather_screen.dart';

/// Navegação principal — bottom bar neumórfica com 3 abas.
/// Transição suave entre telas (IndexedStack + fade).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: IndexedStack(
          key: ValueKey(_index),
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: NeumorphicContainer(
            borderRadius: 32,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavIcon(
                  icon: Icons.home,
                  label: 'Início',
                  selected: _index == 0,
                  onTap: () => _go(0),
                ),
                _NavIcon(
                  icon: Icons.water_drop,
                  label: 'Tempo',
                  selected: _index == 1,
                  onTap: () => _go(1),
                ),
                _NavIcon(
                  icon: Icons.settings,
                  label: 'Ajustes',
                  selected: _index == 2,
                  onTap: () => _go(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: selected ? NeuColors.accent : NeuColors.textMuted,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? NeuColors.accent : NeuColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

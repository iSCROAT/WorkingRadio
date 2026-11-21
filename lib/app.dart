import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/neumorphic_theme.dart';
import 'features/location/location_service.dart';
import 'features/radio/radio_service.dart';
import 'features/settings/settings_provider.dart';
import 'features/stations/station_service.dart';
import 'features/weather/weather_service.dart';
import 'main_shell.dart';

/// Working Radio v3 — Flutter + Neumorfismo.
/// Providers: rádio (just_audio), estações globais (Radio Browser),
/// localização (GPS), tempo (wttr.in) e configurações (prefs).
class WorkingRadioApp extends StatelessWidget {
  const WorkingRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RadioService()),
        ChangeNotifierProvider(create: (_) => WeatherService()),
        ChangeNotifierProvider(create: (_) => StationService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Working Radio',
        debugShowCheckedModeBanner: false,
        theme: buildNeuTheme(),
        home: const _Bootstrap(),
      ),
    );
  }
}

/// Carrega configurações persistidas e inicia os serviços reais.
class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = context.read<SettingsProvider>();
      final radio = context.read<RadioService>();
      final weather = context.read<WeatherService>();
      await settings.load();
      await radio.setStream(settings.streamUrl);
      if (!mounted) return;
      setState(() => _ready = true);
      await weather.fetch(settings.city);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: NeuColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: NeuColors.accent),
        ),
      );
    }
    return const MainShell();
  }
}

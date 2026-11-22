import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/neumorphic_theme.dart';
import '../../core/widgets/hexagon.dart';
import '../../core/widgets/nav_pill.dart';
import '../../core/widgets/neumorphic.dart';
import '../radio/radio_service.dart';
import '../weather/weather_service.dart';

/// TELA 1 — Radio Ao Vivo (neumorfismo).
/// Hexágono elevado + botão play convexo + gráfico REAL de temperatura
/// (dados da previsão do tempo — sem demonstrações falsas).
class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenWeather;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenStations;
  final VoidCallback onOpenGlobe;

  const HomeScreen({
    super.key,
    required this.onOpenWeather,
    required this.onOpenSettings,
    required this.onOpenStations,
    required this.onOpenGlobe,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _favorite = false;

  /// Rótulo real: host da URL do stream configurado.
  String _streamLabel(String url) {
    try {
      final host = Uri.parse(url).host;
      return host.isEmpty ? 'Stream configurado' : host;
    } catch (_) {
      return 'Stream configurado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final radio = context.watch<RadioService>();
    final weather = context.watch<WeatherService>();

    return Scaffold(
      backgroundColor: NeuColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Radio Ao Vivo',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              color: NeuColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('Stream configurável',
                          style: TextStyle(
                              fontSize: 12, color: NeuColors.textMuted)),
                    ],
                  ),
                  NeuGridButton(
                    size: 46,
                    onTap: widget.onOpenSettings,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Hexágono neumórfico com botão play central
              NeumorphicHexagon(
                size: 290,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NeumorphicButton(
                      icon: _favorite ? Icons.favorite : Icons.favorite_border,
                      size: 40,
                      active: _favorite,
                      onTap: () => setState(() => _favorite = !_favorite),
                    ),
                    const SizedBox(height: 10),
                    if (radio.isBuffering)
                      const SizedBox(
                        width: 34,
                        height: 34,
                        child: CircularProgressIndicator(
                            color: NeuColors.accent, strokeWidth: 2.5),
                      )
                    else
                      NeumorphicButton(
                        icon: radio.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 84,
                        active: radio.isPlaying,
                        iconColor: NeuColors.textPrimary,
                        onTap: radio.toggle,
                      ),
                    const SizedBox(height: 10),
                    // Identificação REAL do stream configurado (sem frequência falsa)
                    Text(
                      _streamLabel(radio.streamUrl),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: NeuColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text('AO VIVO',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: NeuColors.accent,
                            letterSpacing: 2)),
                  ],
                ),
              ),
              if (radio.error != null) ...[
                const SizedBox(height: 10),
                Text(radio.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, color: NeuColors.accent)),
              ],
              const SizedBox(height: 18),
              // Gráfico REAL: temperatura das próximas horas
              Row(
                children: [
                  const Icon(Icons.thermostat,
                      size: 16, color: NeuColors.textMuted),
                  const SizedBox(width: 6),
                  const Text('Temperatura hoje',
                      style: TextStyle(
                          fontSize: 13, color: NeuColors.textSecondary)),
                  const Spacer(),
                  Text(
                    weather.report != null
                        ? '${weather.report!.tempC}°C agora'
                        : 'dados reais (wttr.in)',
                    style: const TextStyle(
                        fontSize: 11, color: NeuColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _HourlyChart(weather: weather),
              const Spacer(),
              // Atalhos únicos (sem repetir ações já disponíveis)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeumorphicButton(
                    icon: Icons.public,
                    size: 56,
                    onTap: widget.onOpenStations,
                  ),
                  NeumorphicButton(
                    icon: Icons.water_drop,
                    size: 56,
                    onTap: widget.onOpenWeather,
                  ),
                  NeumorphicButton(
                    icon: Icons.language,
                    size: 56,
                    onTap: widget.onOpenGlobe,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gráfico de barras com dados REAIS da previsão (horas).
class _HourlyChart extends StatelessWidget {
  final WeatherService weather;

  const _HourlyChart({required this.weather});

  @override
  Widget build(BuildContext context) {
    if (weather.loading && weather.report == null) {
      return const SizedBox(
        height: 110,
        child: Center(
          child: CircularProgressIndicator(color: NeuColors.accent),
        ),
      );
    }
    final report = weather.report;
    if (report == null || report.hourly.isEmpty) {
      return SizedBox(
        height: 110,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off,
                  color: NeuColors.textMuted, size: 28),
              const SizedBox(height: 8),
              Text(
                weather.error ?? 'Sem dados — abra a Previsão do Tempo',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: NeuColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }
    final hours = report.hourly;
    final maxTemp = hours.map((h) => h.tempC).reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: hours.map((h) {
          final isNow = h.time == 'Agora';
          final barH = (h.tempC / (maxTemp == 0 ? 1 : maxTemp) * 64)
              .clamp(18.0, 64.0)
              .toDouble();
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${h.tempC}°',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isNow ? NeuColors.accent : NeuColors.textSecondary)),
              const SizedBox(height: 5),
              Container(
                width: 26,
                height: barH,
                decoration: BoxDecoration(
                  color: isNow ? NeuColors.accent : NeuColors.surface,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: neuShadows(convex: !isNow, depth: 4),
                ),
              ),
              const SizedBox(height: 5),
              Text(h.time,
                  style: const TextStyle(
                      fontSize: 10, color: NeuColors.textMuted)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

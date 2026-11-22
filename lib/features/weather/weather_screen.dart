import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/neumorphic_theme.dart';
import '../../core/widgets/neumorphic.dart';
import '../radio/radio_service.dart';
import '../location/location_service.dart';
import '../settings/settings_provider.dart';
import 'weather_location_sheet.dart';
import 'weather_service.dart';

/// TELA 2 — Previsão do Tempo (neumorfismo).
/// Card elevado com temperatura real, abas Hoje/Semana,
/// slider de volume e toggle de notificações — tudo tátil.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  int _tab = 0; // 0 = Hoje, 1 = Semana

  Future<void> _openLocationSheet() async {
    final weather = context.read<WeatherService>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WeatherLocationSheet(),
    );
    // Sincroniza o local escolhido com as Configurações (persistido).
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    final label = weather.displayLocation;
    if (label.isNotEmpty && label != settings.city) {
      await settings.saveCity(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherService>();
    final radio = context.watch<RadioService>();
    final report = weather.report;

    return Scaffold(
      backgroundColor: NeuColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Previsão do Tempo',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: NeuColors.textPrimary,
                                height: 1.2)),
                        SizedBox(height: 2),
                        Text('Dados reais via wttr.in',
                            style: TextStyle(
                                fontSize: 12, color: NeuColors.textMuted)),
                      ],
                    ),
                  ),
                  if (weather.loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 10, right: 10),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: NeuColors.accent, strokeWidth: 2),
                      ),
                    )
                  else
                    NeumorphicButton(
                      icon: Icons.refresh,
                      size: 44,
                      onTap: () => weather.refreshIfStaleForce(),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // LOCAL ESCOLHIDO — cidade, país ou GPS (um único acesso)
              _LocationBar(onTap: _openLocationSheet),
              const SizedBox(height: 16),
              if (weather.loading && report == null)
                const SizedBox(
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(color: NeuColors.accent),
                  ),
                )
              else if (report == null)
                NeumorphicCard(
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off,
                          size: 40, color: NeuColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        weather.error ?? 'Nenhum dado disponível.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, color: NeuColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      NeumorphicButton(
                        icon: Icons.refresh,
                        size: 52,
                        onTap: () => weather.refreshIfStaleForce(),
                      ),
                    ],
                  ),
                )
              else ...[
                NeumorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 18, color: NeuColors.accent),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${report.city}, ${report.region} — ${report.country}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: NeuColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${report.tempC}°',
                              style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w300,
                                  color: NeuColors.textPrimary)),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('°C',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: NeuColors.textSecondary)),
                                Text(report.condition,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: NeuColors.textSecondary)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(_iconFor(report.conditionCode),
                              size: 44, color: NeuColors.accent),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _Stat(Icons.water_drop, 'Umidade', '${report.humidity}%'),
                          ),
                          Expanded(
                            flex: 2,
                            child: _Stat(Icons.air, 'Vento', '${report.windKmh} km/h'),
                          ),
                          Expanded(
                            child: _Stat(Icons.wb_sunny, 'UV', '${report.uvIndex}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    _Tab('Hoje', _tab == 0, () => setState(() => _tab = 0)),
                    const SizedBox(width: 28),
                    _Tab('Semana', _tab == 1, () => setState(() => _tab = 1)),
                  ],
                ),
                const SizedBox(height: 14),
                if (_tab == 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: report.hourly.map((h) {
                      return Expanded(
                        child: Column(
                        children: [
                          Text(h.time,
                              style: const TextStyle(
                                  fontSize: 11, color: NeuColors.textMuted)),
                          const SizedBox(height: 6),
                          Icon(_iconForText(h.condition),
                              size: 22, color: NeuColors.textSecondary),
                          const SizedBox(height: 6),
                          Text('${h.tempC}°',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: NeuColors.textPrimary)),
                        ],
                        ),
                      );
                    }).toList(),
                  )
                else
                  Column(
                    children: report.daily.map((d) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: NeumorphicContainer(
                          borderRadius: 16,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 44,
                                child: Text(d.weekday,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: NeuColors.textPrimary)),
                              ),
                              Icon(_iconForText(d.condition),
                                  size: 20, color: NeuColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(d.condition,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: NeuColors.textSecondary)),
                              ),
                              Text('${d.minC}°  ${d.maxC}°',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: NeuColors.textPrimary)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
              const SizedBox(height: 24),
              const Text('Volume da rádio',
                  style: TextStyle(fontSize: 12, color: NeuColors.textMuted)),
              const SizedBox(height: 8),
              NeumorphicSlider(
                value: radio.volume,
                onChanged: radio.setVolume,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.notifications,
                      size: 20, color: NeuColors.textSecondary),
                  const SizedBox(width: 8),
                  const Text('Notificações',
                      style: TextStyle(
                          fontSize: 14, color: NeuColors.textPrimary)),
                  const Spacer(),
                  // Toggle real (estado persistido nas Configurações)
                  _NotificationsToggle(),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(int code) {
    if (code == 113) return Icons.wb_sunny;
    if (code == 116 || code == 119 || code == 122) return Icons.cloud;
    if ([143, 176, 179, 182, 185, 200, 386, 389].contains(code)) {
      return Icons.thunderstorm;
    }
    return Icons.cloud;
  }

  IconData _iconForText(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('sol') || c.contains('limpo') || c.contains('sunny') || c.contains('clear')) {
      return Icons.wb_sunny;
    }
    if (c.contains('chuva') || c.contains('tempestade') || c.contains('rain') || c.contains('thunder')) {
      return Icons.thunderstorm;
    }
    return Icons.cloud;
  }
}


/// Barra única de acesso ao seletor de local do tempo.
/// Concentra o acesso (antes havia texto solto + refresh sem local).
class _LocationBar extends StatelessWidget {
  final VoidCallback onTap;

  const _LocationBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherService>();
    final location = context.watch<LocationService>();
    final isGps = location.hasFix &&
        weather.report?.city ==
            (location.city.isEmpty ? 'Minha localização' : location.city);

    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(isGps ? Icons.my_location : Icons.place,
                size: 18, color: NeuColors.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.displayLocation.isEmpty
                        ? 'Escolher local'
                        : weather.displayLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NeuColors.textPrimary),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    isGps ? 'Sua localização (GPS)' : 'Cidade, país ou GPS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: NeuColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.expand_more, size: 20, color: NeuColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? NeuColors.textPrimary : NeuColors.textMuted)),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 34,
            color: selected ? NeuColors.accent : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Stat(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: NeuColors.accent),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 10, color: NeuColors.textMuted)),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: NeuColors.textPrimary)),
      ],
    );
  }
}

class _NotificationsToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Estado real persistido nas Configurações (SharedPreferences).
    final settings = context.watch<SettingsProvider>();
    return NeumorphicToggle(
      value: settings.notifications,
      onChanged: settings.setNotifications,
    );
  }
}

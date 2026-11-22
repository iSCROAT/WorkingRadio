import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/geo/globe_view.dart';
import '../../core/theme/neumorphic_theme.dart';
import '../../core/widgets/neumorphic.dart';
import '../location/location_service.dart';
import '../radio/radio_service.dart';
import '../stations/station_model.dart';
import '../stations/station_service.dart';

/// TELA — Globo de estações (engenharia reversa do protótipo).
///
/// - Gira por arrasto; zoom por pinça/roda;
/// - Cada ponto é uma estação REAL com coordenadas (Radio Browser);
/// - Tap no ponto abre o card com as informações da estação + local.
class GlobeScreen extends StatefulWidget {
  const GlobeScreen({super.key});

  @override
  State<GlobeScreen> createState() => _GlobeScreenState();
}

class _GlobeScreenState extends State<GlobeScreen> {
  RadioStation? _selected;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_loaded) return;
      _loaded = true;
      final stations = context.read<StationService>();
      if (stations.results.isEmpty) {
        await stations.loadTopWorld(limit: 120);
      }
      // Se houver GPS, carrega estações próximas para o globo pessoal
      final location = context.read<LocationService>();
      if (!location.hasFix && stations.nearLat == null) {
        // Sem GPS: mantém o globo global carregado acima.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stations = context.watch<StationService>();
    final location = context.watch<LocationService>();
    final radio = context.watch<RadioService>();

    final geoStations = stations.results.where((s) => s.hasGeo).toList();

    return Scaffold(
      backgroundColor: NeuColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Globo de estações',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: NeuColors.textPrimary,
                                height: 1.2)),
                        SizedBox(height: 2),
                        Text('Arraste para girar · toque em um ponto',
                            style: TextStyle(
                                fontSize: 12, color: NeuColors.textMuted)),
                      ],
                    ),
                  ),
                  NeumorphicButton(
                    icon: Icons.my_location,
                    size: 44,
                    active: location.hasFix,
                    onTap: () async {
                      await location.locate();
                      if (location.hasFix) {
                        await stations.searchNearby(
                          lat: location.position!.latitude,
                          lng: location.position!.longitude,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // Globo
            Expanded(
              child: Center(
                child: GlobeView(
                  size: 380,
                  initialLat: location.hasFix ? location.position!.latitude : -8,
                  initialLon: location.hasFix ? location.position!.longitude : -45,
                  selectedId: _selected?.id,
                  stations: geoStations
                      .map((s) => GlobeStation(
                            id: s.id,
                            name: s.name,
                            lat: s.geoLat!,
                            lon: s.geoLong!,
                            data: s,
                          ))
                      .toList(),
                  onStationTap: (pin) {
                    setState(() {
                      _selected = pin.data as RadioStation?;
                    });
                  },
                ),
              ),
            ),

            if (stations.loading && geoStations.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: CircularProgressIndicator(color: NeuColors.accent),
              )
            else if (geoStations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  stations.error ??
                      'Nenhuma estação com coordenadas encontrada. '
                          'Use "perto de mim" ou filtre por país.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, color: NeuColors.textSecondary),
                ),
              ),

            const SizedBox(height: 10),

            // Card da estação — informações e local PRESERVADOS
            if (_selected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: NeumorphicCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Favicon(station: _selected!),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_selected!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: NeuColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(
                                  _selected!.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: NeuColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          NeumorphicButton(
                            icon: radio.streamUrl == _selected!.url &&
                                    radio.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 48,
                            active: radio.streamUrl == _selected!.url &&
                                radio.isPlaying,
                            onTap: () async {
                              if (radio.streamUrl == _selected!.url) {
                                await radio.toggle();
                              } else {
                                await radio.setStream(_selected!.url);
                                await radio.toggle();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFF23262C)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.place,
                            label: _selected!.geoLat!.toStringAsFixed(2) +
                                ', ' +
                                _selected!.geoLong!.toStringAsFixed(2),
                          ),
                          _InfoChip(
                            icon: Icons.flag,
                            label: _selected!.countryCode.isNotEmpty
                                ? _selected!.countryCode
                                : '—',
                          ),
                          _InfoChip(icon: Icons.tune, label: _selected!.quality),
                          if (_selected!.distanceMeters != null)
                            _InfoChip(
                              icon: Icons.near_me,
                              label:
                                  '${(_selected!.distanceMeters! / 1000).toStringAsFixed(1)} km',
                            ),
                        ],
                      ),
                      if (_selected!.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _selected!.tags.take(6).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, color: NeuColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: NeuColors.accent),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: NeuColors.textPrimary)),
      ],
    );
  }
}

class _Favicon extends StatelessWidget {
  final RadioStation station;

  const _Favicon({required this.station});

  @override
  Widget build(BuildContext context) {
    const size = 46.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: NeuColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: neuShadows(convex: true, depth: 4),
      ),
      child: station.favicon == null
          ? const Icon(Icons.radio, size: 22, color: NeuColors.accent)
          : ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                station.favicon!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.radio, size: 22, color: NeuColors.accent),
              ),
            ),
    );
  }
}

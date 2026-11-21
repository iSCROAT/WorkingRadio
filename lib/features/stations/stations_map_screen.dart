import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/theme/neumorphic_theme.dart';
import '../../core/widgets/neumorphic.dart';
import '../location/location_service.dart';
import '../radio/radio_service.dart';
import 'station_model.dart';
import 'station_service.dart';

/// TELA — Mapa global de estações ativas.
/// Cada ponto é uma estação real com coordenadas na base Radio Browser.
class StationsMapScreen extends StatefulWidget {
  final VoidCallback onBack;

  const StationsMapScreen({super.key, required this.onBack});

  @override
  State<StationsMapScreen> createState() => _StationsMapScreenState();
}

class _StationsMapScreenState extends State<StationsMapScreen> {
  final MapController _map = MapController();
  RadioStation? _selected;

  @override
  Widget build(BuildContext context) {
    final stations = context.watch<StationService>();
    final location = context.watch<LocationService>();
    final radio = context.watch<RadioService>();

    final geoStations = stations.results.where((s) => s.hasGeo).toList();
    final center = location.hasFix
        ? LatLng(location.position!.latitude, location.position!.longitude)
        : const LatLng(-16.95, -50.45); // Paraúna/GO como ponto inicial

    return Scaffold(
      backgroundColor: NeuColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // MAPA — tiles OpenStreetMap (sem chave), estilo escuro via colorBlend
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: center,
                initialZoom: location.hasFix ? 9 : 4,
                backgroundColor: NeuColors.background,
                onTap: (_, __) => setState(() => _selected = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.workingradio',
                  tileBuilder: (context, tileWidget, _) => ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.45, 0, 0, 0, 0,
                      0, 0.45, 0, 0, 0,
                      0, 0, 0.50, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: tileWidget,
                  ),
                ),
                // Estações ativas (pontos reais)
                MarkerLayer(
                  markers: [
                    for (final station in geoStations)
                      Marker(
                        point: LatLng(station.geoLat!, station.geoLong!),
                        width: 34,
                        height: 34,
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = station),
                          child: _StationDot(
                            active: _selected?.id == station.id,
                            playing: radio.streamUrl == station.url &&
                                radio.isPlaying,
                          ),
                        ),
                      ),
                  ],
                ),
                if (location.hasFix)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: NeuColors.textPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: NeuColors.background, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Barra superior neumórfica
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  NeumorphicButton(
                    icon: Icons.arrow_back,
                    size: 44,
                    onTap: widget.onBack,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeumorphicContainer(
                      borderRadius: 22,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      child: Row(
                        children: [
                          const Icon(Icons.public,
                              size: 18, color: NeuColors.accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              location.hasFix
                                  ? '${location.city.isEmpty ? 'Sua região' : location.city}'
                                      ' · ${geoStations.length} estações'
                                  : '${geoStations.length} estações no mapa',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: NeuColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  NeumorphicButton(
                    icon: location.loading
                        ? Icons.gps_not_fixed
                        : Icons.my_location,
                    size: 44,
                    active: location.hasFix,
                    onTap: () async {
                      await location.locate();
                      if (location.hasFix && mounted) {
                        _map.move(
                          LatLng(location.position!.latitude,
                              location.position!.longitude),
                          9,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // Card da estação selecionada
            if (_selected != null)
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: NeumorphicCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _StationAvatar(station: _selected!, size: 48),
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
                                  _selected!.distanceMeters != null
                                      ? '${(_selected!.distanceMeters! / 1000).toStringAsFixed(1)} km · ${_selected!.quality}'
                                      : '${_selected!.subtitle} · ${_selected!.quality}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: NeuColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Consumer<RadioService>(
                            builder: (context, radio, _) => NeumorphicButton(
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
                          ),
                        ],
                      ),
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

class _StationDot extends StatelessWidget {
  final bool active;
  final bool playing;

  const _StationDot({required this.active, required this.playing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: active || playing ? NeuColors.accent : NeuColors.textPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: NeuColors.background, width: 2),
        boxShadow: [
          BoxShadow(
            color: (active || playing ? NeuColors.accent : NeuColors.textPrimary)
                .withOpacity(0.45),
            blurRadius: active ? 14 : 6,
            spreadRadius: active ? 3 : 0,
          ),
        ],
      ),
      child: Icon(
        Icons.radio,
        size: 15,
        color: NeuColors.background,
      ),
    );
  }
}

class _StationAvatar extends StatelessWidget {
  final RadioStation station;
  final double size;

  const _StationAvatar({required this.station, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: NeuColors.surface,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: neuShadows(convex: true, depth: 4),
      ),
      child: station.favicon == null
          ? Icon(Icons.radio, size: size * 0.5, color: NeuColors.accent)
          : ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.3),
              child: Image.network(
                station.favicon!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.radio,
                    size: size * 0.5, color: NeuColors.accent),
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/neumorphic_theme.dart';
import '../../core/widgets/neumorphic.dart';
import '../location/location_service.dart';
import '../radio/radio_service.dart';
import 'station_model.dart';
import 'station_service.dart';
import 'stations_map_screen.dart';

/// TELA — Explorar rádios do mundo (Radio Browser).
/// Busca por nome, país e estado; "perto de mim" usa GPS real.
class StationsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const StationsScreen({super.key, required this.onBack});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  late final TextEditingController _searchController;
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_initialLoaded) return;
      _initialLoaded = true;
      final stations = context.read<StationService>();
      await stations.loadCountries();
      if (stations.results.isEmpty) {
        await stations.loadTopWorld();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stations = context.watch<StationService>();
    final location = context.watch<LocationService>();

    return Scaffold(
      backgroundColor: NeuColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NeumorphicButton(
                        icon: Icons.arrow_back,
                        size: 44,
                        onTap: widget.onBack,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Explorar rádios',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: NeuColors.textPrimary)),
                      ),
                      NeumorphicButton(
                        icon: Icons.public,
                        size: 44,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                StationsMapScreen(onBack: () => Navigator.pop(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  NeumorphicTextField(
                    controller: _searchController,
                    hint: 'Buscar estação por nome...',
                    icon: Icons.search,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: NeumorphicButton(
                          icon: Icons.search,
                          size: 44,
                          onTap: () => stations.search(
                            name: _searchController.text.trim(),
                            countryCode: stations.filterCountryCode,
                            state: stations.filterState,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: NeumorphicButton(
                          icon: Icons.near_me,
                          size: 44,
                          active: stations.nearLat != null,
                          onTap: () async {
                            await location.locate();
                            if (location.hasFix) {
                              await stations.searchNearby(
                                lat: location.position!.latitude,
                                lng: location.position!.longitude,
                              );
                            } else if (mounted && location.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(location.error!),
                                  backgroundColor: NeuColors.accent,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: NeumorphicButton(
                          icon: Icons.filter_alt,
                          size: 44,
                          active: stations.filterCountryCode.isNotEmpty,
                          onTap: () => _openFilterSheet(context, stations),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: NeumorphicButton(
                          icon: Icons.public,
                          size: 44,
                          onTap: () => stations.loadTopWorld(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (stations.filterCountryCode.isNotEmpty ||
                      stations.filterState.isNotEmpty ||
                      stations.nearLat != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.tune,
                              size: 14, color: NeuColors.accent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              stations.nearLat != null
                                  ? 'Perto de você (${location.city.isEmpty ? 'GPS' : location.city}) · ${stations.results.length}'
                                  : '${stations.filterCountryCode}'
                                      '${stations.filterState.isNotEmpty ? ' / ${stations.filterState}' : ''}'
                                      ' · ${stations.results.length} estações',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, color: NeuColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildList(stations)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(StationService stations) {
    if (stations.loading) {
      return const Center(
        child: CircularProgressIndicator(color: NeuColors.accent),
      );
    }
    if (stations.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 40, color: NeuColors.textMuted),
              const SizedBox(height: 12),
              Text(stations.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: NeuColors.textSecondary)),
              const SizedBox(height: 18),
              NeumorphicButton(
                icon: Icons.refresh,
                size: 52,
                onTap: () => stations.loadTopWorld(),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: stations.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final station = stations.results[index];
        return _StationTile(station: station);
      },
    );
  }

  Future<void> _openFilterSheet(
      BuildContext context, StationService stations) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: NeuColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return _CountryFilterSheet(stations: stations);
      },
    );
  }
}

class _CountryFilterSheet extends StatefulWidget {
  final StationService stations;

  const _CountryFilterSheet({required this.stations});

  @override
  State<_CountryFilterSheet> createState() => _CountryFilterSheetState();
}

class _CountryFilterSheetState extends State<_CountryFilterSheet> {
  late final TextEditingController _countrySearch;

  @override
  void initState() {
    super.initState();
    _countrySearch = TextEditingController();
    widget.stations.loadCountries();
  }

  @override
  void dispose() {
    _countrySearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stations = widget.stations;
    final query = _countrySearch.text.toLowerCase();
    final filtered = query.isEmpty
        ? stations.countries
        : stations.countries
            .where((c) =>
                c.name.toLowerCase().contains(query) ||
                c.code.toLowerCase() == query)
            .toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: NeuColors.lightShadow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Escolher país',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: NeuColors.textPrimary)),
            const SizedBox(height: 12),
            NeumorphicTextField(
              controller: _countrySearch,
              hint: 'País ou código (BR, US...)',
              icon: Icons.flag,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: NeuColors.accent),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final country = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              await stations.search(
                                countryCode: country.code,
                                name: '',
                              );
                            },
                            child: NeumorphicContainer(
                              borderRadius: 16,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Text(country.code,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: NeuColors.accent)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(country.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: NeuColors.textPrimary)),
                                  ),
                                  Text('${country.stationCount}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: NeuColors.textMuted)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

}

class _StationTile extends StatelessWidget {
  final RadioStation station;

  const _StationTile({required this.station});

  @override
  Widget build(BuildContext context) {
    final radio = context.watch<RadioService>();
    final isCurrent = radio.streamUrl == station.url;
    final playing = isCurrent && radio.isPlaying;

    return GestureDetector(
      onTap: () async {
        if (isCurrent) {
          await radio.toggle();
        } else {
          await radio.setStream(station.url);
          await radio.toggle();
        }
      },
      child: NeumorphicContainer(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _Avatar(station: station),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: NeuColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    station.distanceMeters != null
                        ? '${(station.distanceMeters! / 1000).toStringAsFixed(1)} km · ${station.subtitle}'
                        : station.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: NeuColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (isCurrent)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.graphic_eq,
                              size: 12, color: NeuColors.accent),
                        ),
                      Text(station.quality,
                          style: const TextStyle(
                              fontSize: 10, color: NeuColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            NeumorphicButton(
              icon: playing ? Icons.pause : Icons.play_arrow,
              size: 44,
              active: playing,
              onTap: () async {
                if (isCurrent) {
                  await radio.toggle();
                } else {
                  await radio.setStream(station.url);
                  await radio.toggle();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final RadioStation station;

  const _Avatar({required this.station});

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

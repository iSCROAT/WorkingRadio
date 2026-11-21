import 'package:flutter/material.dart';

import '../theme/neumorphic_theme.dart';
import 'globe_painter.dart';

/// Ponto de estação exibido no globo.
class GlobeStation {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final Object? data; // payload livre (ex.: RadioStation)

  const GlobeStation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    this.data,
  });
}

/// Globo interativo:
/// - arrastar gira o globo (horizontal = longitude, vertical = latitude);
/// - tap em um marcador seleciona a estação;
/// - roda do mouse/pinça faz zoom do raio.
class GlobeView extends StatefulWidget {
  final List<GlobeStation> stations;
  final String? selectedId;
  final ValueChanged<GlobeStation> onStationTap;
  final double initialLat;
  final double initialLon;
  final double size;

  const GlobeView({
    super.key,
    required this.stations,
    required this.onStationTap,
    this.selectedId,
    this.initialLat = -8,
    this.initialLon = -45,
    this.size = 360,
  });

  @override
  State<GlobeView> createState() => _GlobeViewState();
}

class _GlobeViewState extends State<GlobeView> {
  late double _lat = widget.initialLat.clamp(-80.0, 80.0);
  late double _lon = widget.initialLon;
  double _radiusFactor = 1.0;

  Offset? _lastDrag;

  double get _radius {
    final side = widget.size;
    return side * 0.42 * _radiusFactor;
  }

  void _rotateBy(Offset delta) {
    final sensitivity = 180 / (_radius * 2.2);
    setState(() {
      _lon = (_lon - delta.dx * sensitivity) % 360;
      if (_lon > 180) _lon -= 360;
      if (_lon < -180) _lon += 360;
      _lat = (_lat + delta.dy * sensitivity).clamp(-80.0, 80.0);
    });
  }

  GlobeStation? _hitTest(Offset local) {
    final center = Offset(widget.size / 2, widget.size / 2);
    GlobeStation? best;
    double bestScore = double.infinity;
    for (final station in widget.stations) {
      final projected = GlobeMath.project(
        station.lat,
        station.lon,
        _lat,
        _lon,
        center,
        _radius,
      );
      if (!projected.visible) continue;
      final distance = (projected.position - local).distance;
      final hitRadius = 9 + 12 * projected.depth;
      if (distance <= hitRadius && projected.depth > bestScore) {
        bestScore = projected.depth;
        best = station;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final center = Offset(widget.size / 2, widget.size / 2);

    // Marcadores visíveis ordenados por profundidade (frente por último)
    final visible = <(GlobeStation, GlobeProjection)>[];
    for (final station in widget.stations) {
      final p = GlobeMath.project(
        station.lat,
        station.lon,
        _lat,
        _lon,
        center,
        _radius,
      );
      if (p.visible) visible.add((station, p));
    }
    visible.sort((a, b) => a.$2.depth.compareTo(b.$2.depth));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (details) {
        if (details.pointerCount == 1) {
          _lastDrag = details.localFocalPoint;
        }
      },
      onScaleUpdate: (details) {
        if (details.pointerCount >= 2) {
          setState(() {
            _radiusFactor = (_radiusFactor * details.scale).clamp(0.72, 1.18);
          });
          return;
        }
        final delta = details.localFocalPoint - (_lastDrag ?? Offset.zero);
        _lastDrag = details.localFocalPoint;
        if (delta.distanceSquared > 0) _rotateBy(delta);
      },
      onScaleEnd: (_) => _lastDrag = null,
      onTapUp: (details) {
        final hit = _hitTest(details.localPosition);
        if (hit != null) widget.onStationTap(hit);
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Esfera em meio-tom
            CustomPaint(
              size: Size.square(widget.size),
              painter: GlobeHaloPainter(
                radius: widget.size * 0.42 * _radiusFactor,
              ),
            ),
            CustomPaint(
              size: Size.square(widget.size),
              painter: GlobePainter(
                lat0: _lat,
                lon0: _lon,
                radius: _radius,
              ),
            ),
            // Pontos das estações
            for (final (station, projected) in visible)
              Positioned(
                left: projected.position.dx - 9,
                top: projected.position.dy - 9,
                child: _StationPin(
                  selected: station.id == widget.selectedId,
                  depth: projected.depth,
                  onTap: () => widget.onStationTap(station),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StationPin extends StatelessWidget {
  final bool selected;
  final double depth;
  final VoidCallback onTap;

  const _StationPin({
    required this.selected,
    required this.depth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = 9 + 8 * depth;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selected || depth > 0.85
              ? NeuColors.accent
              : NeuColors.textPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (selected || depth > 0.85
                      ? NeuColors.accent
                      : NeuColors.textPrimary)
                  .withOpacity(0.35 + 0.35 * depth),
              blurRadius: selected ? 14 : 6,
              spreadRadius: selected ? 3 : 1,
            ),
          ],
          border: Border.all(
            color: NeuColors.background.withOpacity(0.85),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

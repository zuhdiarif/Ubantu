import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ubantu/components/theme/app_colors.dart';

class UbantuCampusMap extends StatelessWidget {
  final LatLng? pickup;
  final LatLng? dropoff;
  final double? height;
  final bool interactive;
  final BorderRadius? borderRadius;
  final TileProvider? tileProvider;
  final String? urlTemplate;

  const UbantuCampusMap({
    super.key,
    this.pickup,
    this.dropoff,
    this.height = 200,
    this.interactive = true,
    this.borderRadius,
    this.tileProvider,
    this.urlTemplate,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);
    final hasBothPoints = pickup != null && dropoff != null && pickup != dropoff;
    final center = pickup ?? dropoff ?? const LatLng(-7.9526, 112.6145);

    final cameraFit = hasBothPoints
        ? CameraFit.bounds(
            bounds: LatLngBounds.fromPoints([pickup!, dropoff!]),
            padding: const EdgeInsets.all(32),
          )
        : null;

    final markers = <Marker>[
      if (pickup != null)
        Marker(
          point: pickup!,
          width: 36,
          height: 36,
          alignment: Alignment.topCenter,
          child: const Icon(
            Icons.location_on_rounded,
            color: AppColors.primaryGreen,
            size: 36,
          ),
        ),
      if (dropoff != null)
        Marker(
          point: dropoff!,
          width: 32,
          height: 32,
          alignment: Alignment.topCenter,
          child: const Icon(
            Icons.flag_rounded,
            color: AppColors.accentOrange,
            size: 32,
          ),
        ),
    ];

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        border: Border.all(
          color: const Color(0xFFE8EBE4),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15.0,
            initialCameraFit: cameraFit,
            interactionOptions: InteractionOptions(
              flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: urlTemplate ?? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'id.raion.ubantu',
              tileProvider: tileProvider,
            ),
            if (hasBothPoints)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [pickup!, dropoff!],
                    strokeWidth: 3.0,
                    color: AppColors.primaryDark,
                    pattern: StrokePattern.dashed(segments: const [8, 6]),
                  ),
                ],
              ),
            if (markers.isNotEmpty)
              MarkerLayer(
                markers: markers,
              ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

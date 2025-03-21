import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/views/map/controller.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class FocusPlace extends StatefulWidget {
  const FocusPlace({required this.controller, super.key});

  final NetworkMapController controller;

  Place get place => controller.focusedPlace!;
  LatLng? get pos => controller.posCoord;
  @override
  State<FocusPlace> createState() => _FocusPlaceState();
}

class _FocusPlaceState extends State<FocusPlace> {

  @override
  Widget build(BuildContext context) {
    if (widget.controller.focusedPlace == null) {
      return Container();
    }

    final pos = widget.place.position;
    String? distance = widget.pos != null
        ? "${(GpsDataProvider.calculateDistancePos(pos, widget.pos!) * 100).roundToDouble() / 100} km"
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20
      ),
      child: ClipRect(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.place.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10,),
            Row(
              children: distance != null
            ? [const Icon(Icons.directions_walk), Text(distance)]
                : []
            )
          ],
        ),
      ),
    );
  }
}

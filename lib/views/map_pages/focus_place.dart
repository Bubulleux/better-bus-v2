import 'package:better_bus_v2/data_provider/gps_data_provider.dart';
import 'package:better_bus_v2/model/clean/map_place.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class FocusPlace extends StatefulWidget {
  const FocusPlace(this.place, {this.pos, super.key});

  final MapPlace place;
  final LatLng? pos;

  @override
  State<FocusPlace> createState() => _FocusPlaceState();
}

class _FocusPlaceState extends State<FocusPlace> {
  @override
  Widget build(BuildContext context) {
    final pos = LatLng(widget.place.latitude, widget.place.longitude);
    String? distance = widget.pos != null
        ? "${(GpsDataProvider.calculateDistancePos(pos, widget.pos!) * 100).roundToDouble() / 100} km"
        : null;

    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20
      ),
      child: ClipRect(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.place.title,
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

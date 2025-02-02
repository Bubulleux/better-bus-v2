import 'package:better_bus_v2/model/clean/map_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PlaceLayer extends StatelessWidget {
  const PlaceLayer(this.place, {super.key});
  final MapPlace place;

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(place.latitude, place.longitude),
          child: Icon(Icons.place)
        )
      ],
    );
  }
}

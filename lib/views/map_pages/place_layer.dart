import 'package:better_bus_v2/core/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class PlaceLayer extends StatelessWidget {
  const PlaceLayer(this.place, {super.key});
  final Place place;

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          width: 50,
          height: 50,
          alignment: Alignment.topCenter,
          point: place.position,
          child: const Icon(
            Icons.place,
            size: 50,
            color: Colors.red,
          )
        )
      ],
    );
  }
}

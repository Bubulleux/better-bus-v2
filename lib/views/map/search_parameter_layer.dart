import 'package:better_bus_v2/views/route_page/route_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class RouteParameterLayer extends StatelessWidget {
  const RouteParameterLayer({required this.parameter, super.key});

  final RouteSearchParameter parameter;

  @override
  Widget build(BuildContext context) {
    if (!parameter.valid) {
      return Container();
    }

    return MarkerLayer(markers: [
      Marker(
        point: parameter.start!.position,
        alignment: Alignment.topCenter,
        child: const Icon(
          Icons.flag,
          color: Colors.green,
        ),
      ),
      Marker(
        point: parameter.stop!.position,
        alignment: Alignment.topCenter,
        child: const Icon(
          Icons.flag,
          color: Colors.red,
        ),
      ),
    ]);
  }
}

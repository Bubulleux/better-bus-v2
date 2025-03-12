import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/bus_line_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TripLayer extends StatefulWidget {
  const TripLayer({required this.stopTime, super.key});

  final StopTime stopTime;
  BusTrip get trip => stopTime.trip!;

  @override
  State<TripLayer> createState() => _TripLayerState();
}

class _TripLayerState extends State<TripLayer> {

  @override
  Widget build(BuildContext context) {

    Polyline<LatLng> polyline = Polyline(
        points: widget.trip.shape.wayPoints.map((e) => e.position).toList(),
        color: widget.trip.line.color,
        strokeWidth: 5,
        borderStrokeWidth: 3,
        borderColor: Colors.black38);

    return PolylineLayer(polylines: [polyline]);
  }
}

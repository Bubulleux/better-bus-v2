import 'package:better_bus_core/core.dart';
import 'package:better_bus_v2/model/bus_line_color.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class RouteLayer extends StatefulWidget {
  const RouteLayer({required this.route, super.key});

  final VitalisRoute route;

  @override
  State<RouteLayer> createState() => _RouteLayerState();
}

class _RouteLayerState extends State<RouteLayer> {
  @override
  Widget build(BuildContext context) {
    
    final lines = <Polyline>[];
    for (var i = 0; i < widget.route.itinerary.length; i += 1) {
      final passage = widget.route.itinerary[i];
      final line = widget.route.polyLines[i];
      lines.insert(
          passage.lines == null ? lines.length : 0,
          Polyline(
          points: line.wayPoints.map((e) => e.position).toList(),
          color: passage.lines?.color ?? Colors.grey,
          pattern: passage.lines == null
              ? const StrokePattern.dotted()
              : const StrokePattern.solid(),
          strokeWidth: 5,
          borderStrokeWidth: 2,
          borderColor: Colors.black38));
    }

    return PolylineLayer(polylines: lines);
  }
}

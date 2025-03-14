import 'package:better_bus_v2/views/map/controller.dart';
import 'package:flutter/material.dart';

class MapViewPort extends StatefulWidget {
  const MapViewPort({required this.controller, super.key});

  final NetworkMapController controller;

  @override
  State<MapViewPort> createState() => _MapViewPortState();
}

class _MapViewPortState extends State<MapViewPort> {
  @override
  Widget build(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      widget.controller.setRenderBox(box);
    }
    return Expanded(child: Container());
  }
}
